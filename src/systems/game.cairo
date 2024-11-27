////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

use starknet::ContractAddress;

#[starknet::interface]
trait IGameSystem<T> {
    fn start(ref self: T, table: ContractAddress) -> ();
    fn end_turn(ref self: T, table: ContractAddress) -> ();
    fn end(ref self: T, table: ContractAddress) -> ();
}

#[dojo::contract]
mod game_system {
    use zktt::models::components::{
        ComponentGame, ComponentCard, ComponentHand, ComponentDeck, ComponentDeposit,
        ComponentPlayer, ComponentDealer
    };
    use zktt::models::traits::{
        IEnumCard, IPlayer, ICard, IDeck, IDealer, IHand, IGasFee, IAssetGroup, IGame,
        IAsset, IBlockchain, IDeposit, IClaimYield, IFiftyOnePercentAttack, IChainReorg, IFrontRun,
        ISandwichAttack, IPriorityFee, IReplayAttack, IHardFork, ISoftFork, IMEVBoost
    };
    use zktt::models::enums::{
        EnumGasFeeType, EnumPlayerTarget, EnumGameState, EnumColor, EnumCard
    };
    use zktt::systems::player::player_system;
    use dojo::world::IWorldDispatcher;
    use core::poseidon::poseidon_hash_span;
    use starknet::{get_caller_address, get_block_timestamp, get_tx_info, ContractAddress};
    use dojo::model::ModelStorage;

    #[abi(embed_v0)]
    impl GameSystemImpl of super::IGameSystem<ContractState> {
        //////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////
        /////////////////////////////// EXTERNAL /////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////

        /// Starts the game and denies any new players from joining, as long as there are at
        /// least two players that have joined for up to a maximum of 5 players.
        ///
        /// Inputs:
        /// *world*: The mutable reference of the world to write components to.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn start(ref self: ContractState, table: ContractAddress) -> () {
            let mut world = InternalImpl::world_default(@self);
            let mut game: ComponentGame = world.read_model(table);
            assert!(game.m_state != EnumGameState::Started, "Game has already started or invalid game ID");
            assert!(game.m_players.len() >= 2, "Missing at least a player before starting");
            assert!(player_system::InternalImpl::_is_everyone_ready(@world, table), "Everyone needs to be ready");

            let cards_in_order = InternalImpl::_create_cards();
            let mut flattened_cards = InternalImpl::_flatten(ref world, cards_in_order);
            let mut dealer: ComponentDealer = IDealer::new(table, array![]);

            let mut index = 0;
            while let Option::Some(card) = flattened_cards.pop_front() {
                let new_card = ICard::new(index, card);
                world.write_model(@new_card);
                dealer.m_cards.append(index);
                index += 1;
            };

            world.write_model(@dealer);
            game.m_state = EnumGameState::Started;

            let seed: felt252 = InternalImpl::_generate_seed(@game.m_players);
            let mut dealer: ComponentDealer = world.read_model(table);
            dealer.shuffle(seed);

            let mut card_array: Array<EnumCard> = ArrayTrait::new();
            for card_index in dealer
                .m_cards
                .span() {
                    let card_component: ComponentCard = world.read_model(*card_index);
                    card_array.append(card_component.m_card_info);
                };

            InternalImpl::_distribute_cards(ref world, ref game.m_players, ref card_array);

            game.assign_next_turn(true);
            world.write_model(@dealer);
            world.write_model(@game);
        }

        /// Signal the end of a turn for the caller. This renders all other moves forbidden until
        /// next turn.
        ///
        /// Inputs:
        /// *self*: The mutable reference of the contract to write components to.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn end_turn(ref self: ContractState, table: ContractAddress) -> () {
            let mut world = InternalImpl::world_default(@self);
            let mut game: ComponentGame = world.read_model(table);
            assert!(game.m_state == EnumGameState::Started, "Game has not started yet");
            assert!(game.m_player_in_turn == get_caller_address(), "Not player's turn");

            game.assign_next_turn(false);
            world.write_model(@game);
        }

        /// Signal the end of the game. Return all assets and cards to the dealer. Once the game has
        /// ended. No one can re-join the table. Called from another contract within the world, not
        /// intended for external use.
        ///
        /// Inputs:
        /// *world*: The mutable reference of the world to write components to.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn end(ref self: ContractState, table: ContractAddress) -> () {
            // assert!(get_caller_address() == starknet::contract_address_const::<0x0>(), "Unauthorized");

            let mut world = InternalImpl::world_default(@self);
            let mut game: ComponentGame = world.read_model(table);
            assert!(game.m_state == EnumGameState::Started, "Game has not started yet");

            InternalImpl::_assign_winner(ref world);
            game.m_state = EnumGameState::Ended;

            // Double check that we have reaquired all assets from all players.
            for addr in game.m_players {
                player_system::InternalImpl::_relinquish_assets(addr, table, ref world);
            };
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        //////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////
        /////////////////////////////// INTERNAL /////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////

        /// Use the default namespace "zktt". This function is handy since the ByteArray
        /// can't be const.
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"zktt")
        }

        /// Create the seed to provide to the randomizer for shuffling cards in the deck at the
        /// beginning of the game. The seed is meant to be a deterministic ranzomized hash, in the
        /// event that the game needs to be inspected and verified for proof.
        ///
        /// Inputs:
        /// *world*: The mutable reference of the world to write components to.
        /// *players: The array of all the players that have joined in the world.
        ///
        /// Output:
        /// The resulting seed hash.
        /// Can Panic?: yes
        fn _generate_seed(players: @Array<ContractAddress>) -> felt252 {
            let mut array_of_felts: Array<felt252> = array![
                get_block_timestamp().into(), get_tx_info().nonce
            ];

            let mut index: usize = 0;
            while index < players.len() {
                array_of_felts.append(starknet::contract_address_to_felt252(*players.at(index)));
                index += 1;
            };

            let mut seed: felt252 = poseidon_hash_span(array_of_felts.span());
            return seed;
        }

        /// Take cards from the dealer's deck and distribute them across all players at the table.
        /// Five cards per player.
        ///
        /// Inputs:
        /// *world*: The mutable reference of the world to write components to.
        /// *players: The mutable reference of all the players that have joined in the world.
        /// *cards*: The dealer's cards to take cards from.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn _distribute_cards(
            ref world: dojo::world::WorldStorage, ref players: Array<ContractAddress>, ref cards: Array<EnumCard>
        ) -> () {
            if players.is_empty() {
                panic!("There are no players to distribute cards to!");
            }
            let mut index = 0;
            while let Option::Some(player) = players.get(index) {
                if cards.is_empty() {
                    break;
                }
                let mut player_hand: ComponentHand = world.read_model(player.unbox().clone());
                let mut inner_index: usize = 0;
                while inner_index < 5 {
                    if let Option::Some(card_given) = cards.pop_front() {
                        player_hand.add(card_given);
                    }
                    inner_index += 1;
                };
                index += 1;
                world.write_model(@player_hand);
            }
        }

        /// Create the initial deck of cards for the game in a deterministic manner to then shuffle.
        ///
        /// Inputs:
        /// None.
        ///
        /// Output:
        /// The deck with one copy of all the card types (unflatten) [59].
        /// Can Panic?: no
        fn _create_cards() -> Array<EnumCard> nopanic {
            // Step 1: Create cards and put them in a container in order.
            let cards_in_order: Array<EnumCard> =  // Eth.
            array![
                EnumCard::Asset(IAsset::new("ETH [1]", 1, 6)),
                EnumCard::Asset(IAsset::new("ETH [2]", 2, 5)),
                EnumCard::Asset(IAsset::new("ETH [3]", 3, 3)),
                EnumCard::Asset(IAsset::new("ETH [4]", 4, 3)),
                EnumCard::Asset(IAsset::new("ETH [5]", 5, 2)),
                EnumCard::Asset(IAsset::new("ETH [10]", 10, 1)),
                // Blockchains.
                EnumCard::Blockchain(IBlockchain::new("Aptos", EnumColor::Grey, 1, 2)),
                EnumCard::Blockchain(IBlockchain::new("Arbitrum", EnumColor::LightBlue, 1, 2)),
                EnumCard::Blockchain(IBlockchain::new("Avalanche", EnumColor::Red, 2, 4)),
                EnumCard::Blockchain(IBlockchain::new("Base", EnumColor::LightBlue, 1, 2)),
                EnumCard::Blockchain(IBlockchain::new("Bitcoin", EnumColor::Gold, 1, 2)),
                EnumCard::Blockchain(IBlockchain::new("Blast", EnumColor::Yellow, 2, 3)),
                EnumCard::Blockchain(IBlockchain::new("Canto", EnumColor::Green, 1, 1)),
                EnumCard::Blockchain(IBlockchain::new("Celestia", EnumColor::Purple, 2, 3)),
                EnumCard::Blockchain(IBlockchain::new("Celo", EnumColor::Yellow, 2, 3)),
                EnumCard::Blockchain(IBlockchain::new("Cosmos", EnumColor::Blue, 1, 1)),
                EnumCard::Blockchain(IBlockchain::new("Dogecoin", EnumColor::Gold, 1, 2)),
                EnumCard::Blockchain(IBlockchain::new("Ethereum", EnumColor::DarkBlue, 3, 4)),
                EnumCard::Blockchain(IBlockchain::new("Fantom", EnumColor::LightBlue, 1, 2)),
                EnumCard::Blockchain(IBlockchain::new("Gnosis Chain", EnumColor::Green, 1, 1)),
                EnumCard::Blockchain(IBlockchain::new("Kava", EnumColor::Red, 2, 4)),
                EnumCard::Blockchain(IBlockchain::new("Linea", EnumColor::Grey, 1, 2)),
                EnumCard::Blockchain(IBlockchain::new("Metis", EnumColor::LightBlue, 1, 2)),
                EnumCard::Blockchain(IBlockchain::new("Near", EnumColor::Green, 1, 1)),
                EnumCard::Blockchain(IBlockchain::new("Optimism", EnumColor::Red, 2, 4)),
                EnumCard::Blockchain(IBlockchain::new("Osmosis", EnumColor::Pink, 1, 1)),
                EnumCard::Blockchain(IBlockchain::new("Polkadot", EnumColor::Pink, 1, 1)),
                EnumCard::Blockchain(IBlockchain::new("Polygon", EnumColor::Purple, 2, 3)),
                EnumCard::Blockchain(IBlockchain::new("Scroll", EnumColor::Yellow, 2, 3)),
                EnumCard::Blockchain(IBlockchain::new("Solana", EnumColor::Purple, 2, 3)),
                EnumCard::Blockchain(IBlockchain::new("Starknet", EnumColor::DarkBlue, 3, 4)),
                EnumCard::Blockchain(IBlockchain::new("Taiko", EnumColor::Pink, 1, 1)),
                EnumCard::Blockchain(IBlockchain::new("Ton", EnumColor::Blue, 1, 1)),
                EnumCard::Blockchain(IBlockchain::new("ZKSync", EnumColor::Grey, 1, 2)),
                // Actions.
                EnumCard::ChainReorg(IChainReorg::default()),
                EnumCard::ClaimYield(IClaimYield::default()),
                EnumCard::FiftyOnePercentAttack(IFiftyOnePercentAttack::default()),
                EnumCard::FrontRun(IFrontRun::default()),
                EnumCard::GasFee(
                    IGasFee::new(
                        EnumPlayerTarget::All,
                        EnumGasFeeType::AgainstTwo((EnumColor::DarkBlue, EnumColor::Red)),
                        array![],
                        1,
                        2
                    )
                ),
                EnumCard::GasFee(
                    IGasFee::new(
                        EnumPlayerTarget::All,
                        EnumGasFeeType::AgainstTwo((EnumColor::Yellow, EnumColor::Purple)),
                        array![],
                        1,
                        2
                    )
                ),
                EnumCard::GasFee(
                    IGasFee::new(
                        EnumPlayerTarget::All,
                        EnumGasFeeType::AgainstTwo((EnumColor::Green, EnumColor::LightBlue)),
                        array![],
                        1,
                        2
                    )
                ),
                EnumCard::GasFee(
                    IGasFee::new(
                        EnumPlayerTarget::All,
                        EnumGasFeeType::AgainstTwo((EnumColor::Grey, EnumColor::Pink)),
                        array![],
                        1,
                        2
                    )
                ),
                EnumCard::GasFee(
                    IGasFee::new(
                        EnumPlayerTarget::All,
                        EnumGasFeeType::AgainstTwo((EnumColor::Blue, EnumColor::Gold)),
                        array![],
                        1,
                        2
                    )
                ),
                EnumCard::GasFee(
                    IGasFee::new(
                        EnumPlayerTarget::None,
                        EnumGasFeeType::Any(()),
                        array![], 3, 3)
                ),
                EnumCard::HardFork(IHardFork::default()),
                EnumCard::MEVBoost(IMEVBoost::default()),
                EnumCard::PriorityFee(IPriorityFee::default()),
                EnumCard::ReplayAttack(IReplayAttack::default()),
                EnumCard::SandwichAttack(ISandwichAttack::default()),
                EnumCard::SoftFork(ISoftFork::default()),
            ];

            return cards_in_order;
        }

        /// Flatten all copies of blockchains, Assets, and Action Cards in one big array for the
        /// dealer.
        ///
        /// Inputs:
        /// *world*: The mutable reference of the world to write components to.
        /// *container*: The deck with one copy of all the card types (unflatten) [59].
        ///
        /// Output:
        /// The deck with all copies of all the card types (flattened) [105].
        /// Can Panic?: yes
        fn _flatten(
            ref world: dojo::world::WorldStorage, mut container: Array<EnumCard>
        ) -> Array<EnumCard> {
            let mut flattened_array = ArrayTrait::new();

            while let Option::Some(mut card) = container.pop_front() {
                let mut index_left: u8 = card.get_index();
                while index_left > 0 {
                    flattened_array.append(card.remove_one_index());
                    index_left -= 1;
                };
            };
            return flattened_array;
        }

        /// Assign the winner when the game ends. Upon classic end, the winner is attributed to the
        /// one who gets [3] complete sets in their deck. There can only be one winner.
        ///
        /// Inputs:
        /// *world*: The mutable reference of the world to write components to.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn _assign_winner(ref world: dojo::world::WorldStorage) -> () {
            // TODO: Determine the winner upon interrupt and reward for the winner
        }
    }
}
