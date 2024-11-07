////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

use zktt::models::components::{EnumCard, EnumGameState, ComponentGame, ComponentDealer, ComponentPlayer};
use starknet::ContractAddress;
use dojo::world::IWorldDispatcher;

#[starknet::interface]
trait IGameSystem<T> {
    fn start(ref self: T) -> ();
    fn end_turn(ref self: T) -> ();
}

#[dojo::contract]
mod game_system {
    use super::*;
    use starknet::{get_block_timestamp, get_tx_info, get_caller_address};
    use core::poseidon::poseidon_hash_span;
    use dojo::model::ModelStorage;

    #[storage]
    struct Storage {
        world: IWorldDispatcher,
    }

    #[constructor]
    fn constructor(ref self: ContractState, world: IWorldDispatcher) {
        self.world.write(world);
        // Initialize game state
        self.dojo_init();
    }

    #[abi(embed_v0)]
    impl GameSystemImpl of super::IGameSystem<ContractState> {
        /// Starts the game and denies any new players from joining, as long as there are at
        /// least two players that have joined for up to a maximum of 5 players.
        ///
        /// Inputs:
        /// *world*: The mutable reference of the world to write components to.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn start(ref self: ContractState) -> () {
            let mut world = self.world_default();
            let seed = world.dispatcher.contract_address;
            let mut game: ComponentGame = world.read_model(seed);

            assert!(game.m_state != EnumGameState::Started, "Game has already started");
            assert!(game.m_players.len() >= 2, "Missing at least a player before starting");

            game.m_state = EnumGameState::Started;

            let seed: felt252 = self._generate_seed(@world.dispatcher.contract_address, @game.m_players);
            let mut dealer: ComponentDealer = world.read_model(world.dispatcher.contract_address);
            dealer.shuffle(seed);

            self._distribute_cards(ref game.m_players, ref dealer.m_cards);

            game.assign_next_turn(true);
            world.write_model(@dealer);
            world.write_model(@game);
        }

        /// Signal the end of a turn for the caller. This renders all other moves forbidden until
        /// next turn.
        ///
        /// Inputs:
        /// *world*: The mutable reference of the world to write components to.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
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

        /// Create the seed to provide to the randomizer for shuffling cards in the deck at the beginning
        /// of the game. The seed is meant to be a deterministic ranzomized hash, in the event that the
        /// game needs to be inspected and verified for proof.
        ///
        /// Inputs:
        /// *world*: The mutable reference of the world to write components to.
        /// *players: The array of all the players that have joined in the world.
        ///
        /// Output:
        /// The resulting seed hash.
        /// Can Panic?: yes
        fn _generate_seed(world_address: @ContractAddress, players: @Array<ContractAddress>) -> felt252 {
            let mut array_of_felts: Array<felt252> = array![get_block_timestamp().into(), get_tx_info().nonce];
            let mut index: usize = 0;
            while index < players.len() {
                array_of_felts.append(starknet::contract_address_to_felt252(*players.at(index)));
                index += 1;
            };
            poseidon_hash_span(array_of_felts.span())
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
        fn _distribute_cards(ref self: ContractState, ref players: Array<ContractAddress>, ref cards: Array<EnumCard>) -> () {
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
                }
                index += 1;
                world.write_model(@player_hand);
            }
        }

        /// Create the initial deck of cards for the game and assign them to the dealer. Only ran once
        /// when the contract deploys (sort of acting as a singleton).
        ///
        /// Inputs:
        /// *world*: The mutable reference of the world to write components to.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn dojo_init(ref self: ContractState) {
            let mut world = self.world_default();
            let cards_in_order = _create_cards();
            let dealer: ComponentDealer = IDealer::new(world.dispatcher.contract_address, cards_in_order);
            world.write_model(@dealer);
        }
    }
}
