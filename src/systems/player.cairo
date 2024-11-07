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
    fn draw(ref self: T, draws_five: bool) -> ();
    fn leave(ref self: T) -> ();
}

#[dojo::contract]
mod player_system {
    use starknet::ContractAddress;
    use zktt::models::components::{ComponentPlayer, ComponentHand, ComponentDealer, ComponentGame, ComponentDeposit};
    use zktt::models::enums::{EnumGameState, EnumCard};
    use zktt::models::traits::game::{IGame, IPlayer, IHand, IDealer};
    use dojo::world::IWorldDispatcher;
    use starknet::get_caller_address;
    use dojo::model::ModelStorage;

    #[storage]
    struct Storage {
        world: IWorldDispatcher,
    }

    #[constructor]
    fn constructor(ref self: ContractState, world: IWorldDispatcher) {
        self.world.write(world);
    }

    #[abi(embed_v0)]
    impl PlayerSystemImpl of super::IPlayerSystem<ContractState> {
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

        fn draw(ref self: ContractState, draws_five: bool) -> () {
            let mut world = self.world_default();
            let caller = get_caller_address();
            let mut hand: ComponentHand = world.read_model(caller);
            let mut player: ComponentPlayer = world.read_model(caller);
            let game: ComponentGame = world.read_model(world.dispatcher.contract_address);

            assert!(game.m_state == EnumGameState::Started, "Game has not started yet");
            assert!(game.m_player_in_turn == caller, "Not player's turn");
            assert!(!player.m_has_drawn, "Cannot draw mid-turn");

            let mut dealer: ComponentDealer = world.read_model(world.dispatcher.contract_address);
            
            if draws_five {
                assert!(hand.m_cards.len() == 0, "Cannot draw five, hand not empty");
                let mut index: usize = 0;
                while index < 5 {
                    if dealer.m_cards.is_empty() {
                        panic!("Dealer has no more cards");
                    }
                    let card = dealer.pop_card().unwrap();
                    hand.add(card);
                    index += 1;
                }
            } else {
                let card1_opt = dealer.pop_card();
                let card2_opt = dealer.pop_card();
                assert!(card1_opt.is_some() && card2_opt.is_some(), "Deck does not have any more cards!");
                hand.add(card1_opt.unwrap());
                hand.add(card2_opt.unwrap());
            }

            player.m_has_drawn = true;
            world.write_model(@hand);
            world.write_model(@dealer);
            world.write_model(@player);
        }

        fn leave(ref self: ContractState) -> () {
            let mut world = self.world_default();
            let mut game: ComponentGame = world.read_model(world.dispatcher.contract_address);
            let caller = get_caller_address();
            assert!(game.m_state == EnumGameState::Started, "Game has not started yet");
            assert!(game.contains_player(@caller).is_some(), "Player not found");

            game.remove_player(@caller);
            world.erase_model::<ComponentHand>(caller);
            world.erase_model::<ComponentDeck>(caller);
            world.erase_model::<ComponentDeposit>(caller);
            world.write_model(@game);
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"zktt")
        }
    }
}