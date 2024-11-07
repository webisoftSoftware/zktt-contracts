////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

// TODO: Add comments to each component

#[starknet::interface]
trait IGameSystem<T> {
    fn start(ref self: T) -> ();
    fn end_turn(ref self: T) -> ();
}

#[dojo::contract]
mod game_system {
    use zktt::models::components::{
        ComponentGame, ComponentHand, ComponentDeck, ComponentDeposit, ComponentPlayer,
        ComponentDealer
    };
    use zktt::models::traits::{
        IEnumCard, IPlayer, IDeck, IDealer, IHand, IGasFee, IAssetGroup, IDraw, IGame, IAsset,
        IBlockchain, IDeposit
    };
    use zktt::models::enums::{
        EnumGasFeeType, EnumPlayerTarget, EnumGameState, EnumBlockchainType, EnumCard
    };
    use dojo::world::IWorldDispatcher;
    use core::poseidon::poseidon_hash_span;
    use starknet::{get_caller_address, get_block_timestamp, get_tx_info, ContractAddress};
    use dojo::model::ModelStorage;

    #[abi(embed_v0)]
    impl GameSystemImpl of super::IGameSystem<ContractState> {
        fn start(ref self: ContractState) -> () {
            let mut world = self.world_default();
            let seed = world.dispatcher.contract_address;
            let mut game: ComponentGame = world.read_model(seed);

            assert!(game.m_state != EnumGameState::Started, "Game has already started");
            assert!(game.m_players.len() >= 2, "Missing at least a player before starting");

            game.m_state = EnumGameState::Started;

            let seed: felt252 = InternalImpl::_generate_seed(
                @world.dispatcher.contract_address, @game.m_players
            );
            let mut dealer: ComponentDealer = world.read_model(world.dispatcher.contract_address);
            dealer.shuffle(seed);

            self._distribute_cards(ref game.m_players, ref dealer.m_cards);

            game.assign_next_turn(true);
            world.write_model(@dealer);
            world.write_model(@game);
        }

        fn end_turn(ref self: ContractState) -> () {
            let mut world = self.world_default();
            let mut game: ComponentGame = world.read_model(world.dispatcher.contract_address);
            assert!(game.m_state == EnumGameState::Started, "Game has not started yet");
            assert!(game.m_player_in_turn == get_caller_address(), "Not player's turn");

            game.assign_next_turn(false);
            world.write_model(@game);
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"zktt")
        }

        fn _generate_seed(
            world_address: @ContractAddress, players: @Array<ContractAddress>
        ) -> felt252 {
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

        fn _distribute_cards(
            ref self: ContractState, ref players: Array<ContractAddress>, ref cards: Array<EnumCard>
        ) -> () {
            if players.is_empty() {
                panic!("There are no players to distribute cards to!");
            }
            let mut world = self.world_default();
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

        fn _create_cards() -> Array<EnumCard> nopanic {
            // Step 1: Create cards and put them in a container in order.
            let cards_in_order: Array<EnumCard> = // Eth.
            array![
                EnumCard::Asset(IAsset::new("ETH [1]", 1, 6)),
                EnumCard::Asset(IAsset::new("ETH [2]", 2, 5)),
                EnumCard::Asset(IAsset::new("ETH [3]", 3, 3)),
                EnumCard::Asset(IAsset::new("ETH [4]", 4, 3)),
                EnumCard::Asset(IAsset::new("ETH [5]", 5, 2)),
                EnumCard::Asset(IAsset::new("ETH [10]", 10, 1)),
                // Blockchains.
                EnumCard::Blockchain(IBlockchain::new("Aptos", EnumBlockchainType::Grey, 1, 2)),
                EnumCard::Blockchain(
                    IBlockchain::new("Arbitrum", EnumBlockchainType::LightBlue, 1, 2)
                ),
                EnumCard::Blockchain(IBlockchain::new("Avalanche", EnumBlockchainType::Red, 2, 4)),
                EnumCard::Blockchain(IBlockchain::new("Base", EnumBlockchainType::LightBlue, 1, 2)),
                EnumCard::Blockchain(IBlockchain::new("Bitcoin", EnumBlockchainType::Gold, 1, 2)),
                EnumCard::Blockchain(IBlockchain::new("Blast", EnumBlockchainType::Yellow, 2, 3)),
                EnumCard::Blockchain(IBlockchain::new("Canto", EnumBlockchainType::Green, 1, 1)),
                EnumCard::Blockchain(
                    IBlockchain::new("Celestia", EnumBlockchainType::Purple, 2, 3)
                ),
                EnumCard::Blockchain(IBlockchain::new("Celo", EnumBlockchainType::Yellow, 2, 3)),
                EnumCard::Blockchain(IBlockchain::new("Cosmos", EnumBlockchainType::Blue, 1, 1)),
                EnumCard::Blockchain(IBlockchain::new("Dogecoin", EnumBlockchainType::Gold, 1, 2)),
                EnumCard::Blockchain(
                    IBlockchain::new("Ethereum", EnumBlockchainType::DarkBlue, 3, 4)
                ),
                EnumCard::Blockchain(
                    IBlockchain::new("Fantom", EnumBlockchainType::LightBlue, 1, 2)
                ),
                EnumCard::Blockchain(
                    IBlockchain::new("Gnosis Chain", EnumBlockchainType::Green, 1, 1)
                ),
                EnumCard::Blockchain(IBlockchain::new("Kava", EnumBlockchainType::Red, 2, 4)),
                EnumCard::Blockchain(IBlockchain::new("Linea", EnumBlockchainType::Grey, 1, 2)),
                EnumCard::Blockchain(
                    IBlockchain::new("Metis", EnumBlockchainType::LightBlue, 1, 2)
                ),
                EnumCard::Blockchain(IBlockchain::new("Near", EnumBlockchainType::Green, 1, 1)),
                EnumCard::Blockchain(IBlockchain::new("Optimism", EnumBlockchainType::Red, 2, 4)),
                EnumCard::Blockchain(IBlockchain::new("Osmosis", EnumBlockchainType::Pink, 1, 1)),
                EnumCard::Blockchain(IBlockchain::new("Polkadot", EnumBlockchainType::Pink, 1, 1)),
                EnumCard::Blockchain(IBlockchain::new("Polygon", EnumBlockchainType::Purple, 2, 3)),
                EnumCard::Blockchain(IBlockchain::new("Scroll", EnumBlockchainType::Yellow, 2, 3)),
                EnumCard::Blockchain(IBlockchain::new("Solana", EnumBlockchainType::Purple, 2, 3)),
                EnumCard::Blockchain(
                    IBlockchain::new("Starknet", EnumBlockchainType::DarkBlue, 3, 4)
                ),
                EnumCard::Blockchain(IBlockchain::new("Taiko", EnumBlockchainType::Pink, 1, 1)),
                EnumCard::Blockchain(IBlockchain::new("Ton", EnumBlockchainType::Blue, 1, 1)),
                EnumCard::Blockchain(IBlockchain::new("ZKSync", EnumBlockchainType::Grey, 1, 2)),
                // Actions.
                // EnumCard::PriorityFee(IPriorityFee::new(1, 10)),
                // EnumCard::ClaimYield(IClaimYield::new(2, 3)),
                // EnumCard::MajorityAttack(IMajorityAttack::new(Option::None, Option::None, 5, 1)),
                // EnumCard::FrontRun(IFrontRun::new(Option::None, Option::None, 3, 3)),
                EnumCard::GasFee(
                    IGasFee::new(
                        EnumPlayerTarget::All,
                        EnumGasFeeType::AgainstTwo(
                            (EnumBlockchainType::DarkBlue, EnumBlockchainType::Red)
                        ),
                        array![],
                        1,
                        2
                    )
                ),
                EnumCard::GasFee(
                    IGasFee::new(
                        EnumPlayerTarget::All,
                        EnumGasFeeType::AgainstTwo(
                            (EnumBlockchainType::Yellow, EnumBlockchainType::Purple)
                        ),
                        array![],
                        1,
                        2
                    )
                ),
                EnumCard::GasFee(
                    IGasFee::new(
                        EnumPlayerTarget::All,
                        EnumGasFeeType::AgainstTwo(
                            (EnumBlockchainType::Green, EnumBlockchainType::LightBlue)
                        ),
                        array![],
                        1,
                        2
                    )
                ),
                EnumCard::GasFee(
                    IGasFee::new(
                        EnumPlayerTarget::All,
                        EnumGasFeeType::AgainstTwo(
                            (EnumBlockchainType::Grey, EnumBlockchainType::Pink)
                        ),
                        array![],
                        1,
                        2
                    )
                ),
                EnumCard::GasFee(
                    IGasFee::new(
                        EnumPlayerTarget::All,
                        EnumGasFeeType::AgainstTwo(
                            (EnumBlockchainType::Blue, EnumBlockchainType::Gold)
                        ),
                        array![],
                        1,
                        2
                    )
                ),
                EnumCard::GasFee(
                    IGasFee::new(
                        EnumPlayerTarget::None,
                        EnumGasFeeType::Any(EnumBlockchainType::Blue),
                        array![],
                        3,
                        3
                    )
                ),
                // EnumCard::ReplayAttack(IReplayAttack::new(1, 2)),
            // EnumCard::ChainReorg(IChainReorg::new(3, 3)),
            // EnumCard::HardFork(IHardFork::new(3, 3)),
            // EnumCard::SoftFork(ISoftFork::new(3, 3)),
            // EnumCard::MEVBoost(IMEVBoost::new(3, 3)),
            ];

            return cards_in_order;
        }

        fn dojo_init(ref self: ContractState) {
            let mut world = self.world_default();
            let cards_in_order = Self::_create_cards();
            let dealer: ComponentDealer = IDealer::new(
                world.dispatcher.contract_address, cards_in_order
            );
            world.write_model(@dealer);
        }
    }
}
