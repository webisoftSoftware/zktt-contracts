////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

#[starknet::interface]
trait IPlayerSystem<T> {
    fn join(ref self: T, username: ByteArray) -> ();
    fn leave(ref self: T) -> ();
}

#[dojo::contract]
mod player_system {
    use zktt::models::components::{
        ComponentGame, ComponentHand, ComponentDeck, ComponentDeposit, ComponentPlayer,
        ComponentDealer
    };
    use zktt::models::traits::{
        IEnumCard, IPlayer, IDeck, IDealer, IHand, IGasFee, IAssetGroup, IDraw, IGame, IAsset,
        IBlockchain, IDeposit
    };
    use zktt::models::enums::{EnumGasFeeType, EnumPlayerTarget, EnumGameState};
    use dojo::world::IWorldDispatcher;
    use starknet::get_caller_address;
    use dojo::model::ModelStorage;

    #[abi(embed_v0)]
    impl PlayerSystemImpl of super::IPlayerSystem<ContractState> {

        //////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////
        /////////////////////////////// EXTERNAL /////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////

        /// Allows a player to join the table deployed, as long as the game hasn't started/ended yet.
        ///
        /// Inputs:
        /// *world*: The mutable reference of the world to write components to.
        /// *username*: The user-selected displayed name identifyinh the current player's name.
        /// Note that the current implementation allows for multiple users to have the same username.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn join(ref self: ContractState, username: ByteArray) -> () {
            let mut world = self.world_default();
            let mut game: ComponentGame = world.read_model(world.dispatcher.contract_address);
            assert!(game.m_state != EnumGameState::Started, "Game has already started");
            assert!(game.m_players.len() < 5, "Lobby already full");

            let caller = get_caller_address();
            let player = IPlayer::new(caller, username);
            game.add_player(caller);
            world.write_model(@game);
            world.write_model(@player);
        }

        /// Make the caller's player leave the table and surrender all cards to the discard pile.
        ///
        /// Inputs:
        /// *world*: The mutable reference of the world to write components to.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn leave(ref self: ContractState) -> () {
            let mut world = self.world_default();
            let mut game: ComponentGame = world.read_model(world.dispatcher.contract_address);
            assert!(game.m_state == EnumGameState::Started, "Game has not started yet");
            assert!(game.contains_player(@get_caller_address()).is_some(), "Player not found");

            let mut hand: ComponentHand = world.read_model(get_caller_address());
            let mut deck: ComponentDeck = world.read_model(get_caller_address());
            let mut deposit: ComponentDeposit = world.read_model(get_caller_address());

            // TODO: Cleanup after player by setting all card owner's to 0.
            // hand.discard_cards();
            // deck.discard_cards();
            // deposit.discard_cards();

            game.remove_player(@get_caller_address());
            world.erase_model(@hand);
            world.erase_model(@deck);
            world.erase_model(@deposit);
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
    }
}
