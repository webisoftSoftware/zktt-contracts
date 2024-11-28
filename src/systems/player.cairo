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
trait IPlayerSystem<T> {
    fn join(ref self: T, username: ByteArray, table: ContractAddress) -> ();
    fn set_ready(ref self: T, ready: bool, table: ContractAddress) -> ();
    fn leave(ref self: T, table: ContractAddress) -> ();
}

#[dojo::contract]
mod player_system {
    use zktt::models::components::{
        ComponentGame, ComponentHand, ComponentDeck, ComponentDeposit, ComponentPlayer,
        ComponentDealer, ComponentDiscardPile
    };
    use zktt::models::traits::{
        IEnumCard, IPlayer, IDeck, IDealer, IHand, IGasFee, IAssetGroup, IGame, IAsset, IBlockchain,
        IDeposit
    };
    use zktt::models::enums::{EnumGasFeeType, EnumPlayerTarget, EnumGameState};
    use dojo::world::IWorldDispatcher;
    use starknet::ContractAddress;
    use zktt::systems::game::{IGameSystemDispatcher, IGameSystemDispatcherTrait};
    use starknet::get_caller_address;
    use dojo::model::ModelStorage;

    #[abi(embed_v0)]
    impl PlayerSystemImpl of super::IPlayerSystem<ContractState> {
        //////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////
        /////////////////////////////// EXTERNAL /////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////

        /// Allows a player to join the table deployed, as long as the game hasn't started/ended
        /// yet.
        ///
        /// Inputs:
        /// *self*: The mutable reference of the contract to write components to.
        /// *username*: The user-selected displayed name identifyinh the current player's name.
        /// Note that the current implementation allows for multiple users to have the same
        /// username.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn join(ref self: ContractState, username: ByteArray, table: ContractAddress) -> () {
            let mut world = InternalImpl::world_default(@self);
            let mut game: ComponentGame = world.read_model(table);
            assert!(game.m_state != EnumGameState::Started, "Game has already started");
            assert!(game.m_players.len() < 5, "Lobby full");

            let caller = get_caller_address();
            let player = IPlayer::new(caller, username);
            game.add_player(caller);
            world.write_model(@game);
            world.write_model(@player);
        }

        /// Allows a player to set their ready status for the upcoming game. Once every player is
        /// ready, we start the game. Cannot be called once the game has already started.
        ///
        /// Inputs:
        /// *self*: The mutable reference of the contract to write components to.
        /// *ready*: Toggle readyness.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn set_ready(ref self: ContractState, ready: bool, table: ContractAddress) -> () {
            let mut world = InternalImpl::world_default(@self);
            let mut game: ComponentGame = world.read_model(table);
            assert!(game.m_state != EnumGameState::Started, "Game has already started");

            let mut player: ComponentPlayer = world.read_model(get_caller_address());
            player.m_is_ready = ready;
            world.write_model(@player);

            // Start the game if everyone is ready.
            if game.m_players.len() >= 2 && InternalImpl::_is_everyone_ready(@world, table) {
                let mut game_system: IGameSystemDispatcher = IGameSystemDispatcher {
                    contract_address: table
                };
                game_system.start(table);
            }
        }

        /// Make current caller leave the ongoing pre-game lobby OR ongoing game. The player gives
        /// back all the cards they own to the table in the discard pile upon exiting.
        ///
        /// Once a player leaves they CANNOT come back to the table IF the game has started.
        ///
        /// Inputs:
        /// *self*: The mutable reference of the contract to write components to.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn leave(ref self: ContractState, table: ContractAddress) -> () {
            let mut world = InternalImpl::world_default(@self);
            let mut game: ComponentGame = world.read_model(table);
            assert!(game.contains_player(@get_caller_address()).is_some(), "Player not found");

            let caller = get_caller_address();
            // Give all cards back to the board.
            InternalImpl::_relinquish_assets(caller, table, ref world);
            game.remove_player(@caller);

            // Check if there's at least two players left, otherwise end the ongoing game.
            if game.m_players.len() < 2 && game.m_state == EnumGameState::Started {
                let mut game_system: IGameSystemDispatcher = IGameSystemDispatcher {
                    contract_address: table
                };
                game_system.end(table);
            }

            world.write_model(@game);
            return ();
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

        /// Check if every player at the table is ready to start the game. Game will only start if
        /// ALL players are ready (Might impl a timer of some sort to prevent griefing in the front
        /// end.
        ///
        /// Inputs:
        /// *world*: The immutable reference of the world to read components from.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn _is_everyone_ready(world: @dojo::world::WorldStorage, table: ContractAddress) -> bool {
            let game: ComponentGame = world.read_model(table);
            let mut everyone_ready: bool = true;

            for addr in game
                .m_players {
                    let player: ComponentPlayer = world.read_model(addr);
                    if !player.m_is_ready {
                        everyone_ready = false;
                    }
                };
            return everyone_ready;
        }

        /// Take all cards owned by player and put them in the discard pile, effectively
        /// re-possessing all player cards back. Normally after player leaves or game ends.
        ///
        /// Inputs:
        /// *player_address*: The contract address of the player in question.
        /// *world*: The mutable reference of the world to write components to.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn _relinquish_assets(
            player_address: ContractAddress,
            table: ContractAddress,
            ref world: dojo::world::WorldStorage
        ) -> () {
            let mut hand: ComponentHand = world.read_model(player_address);
            let mut deck: ComponentDeck = world.read_model(player_address);
            let mut deposit: ComponentDeposit = world.read_model(player_address);
            let mut discard_pile: ComponentDiscardPile = world.read_model(table);

            // Put everything owned into discard pile.
            for card in hand.m_cards.span() {
                discard_pile.m_cards.append(card.clone());
            };

            for card in deck.m_cards.span() {
                discard_pile.m_cards.append(card.clone());
            };

            for card in deposit.m_cards.span() {
                discard_pile.m_cards.append(card.clone());
            };

            // Delete all model references of player.
            world.erase_model(@hand);
            world.erase_model(@deck);
            world.erase_model(@deposit);

            world.write_model(@discard_pile);
        }
    }
}
