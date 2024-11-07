// Copyright (c) 2024 zkTT
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software
// is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
////////////////////////////////////////////////////////////////////////////////////////////////////


#[cfg(test)]
mod tests {
    use starknet::ContractAddress;
    use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest};
    use dojo::world::{WorldStorage, WorldStorageTrait};
    use dojo::world::{IWorldDispatcherTrait};
    use dojo::world::IWorldDispatcher;
    use dojo_cairo_test::WorldStorageTestTrait;
    use dojo::model::Model;
    use dojo_cairo_test::{spawn_test_world, NamespaceDef, TestResource, ContractDefTrait};

    // import test utils
    use zktt::{
        systems::{game::{table, ITableDispatcher, ITableDispatcherTrait}},
        models::components::{ComponentGame, ComponentPlayer, ComponentDealer, ComponentHand,
         ComponentDeck, m_ComponentGame, m_ComponentPlayer, m_ComponentDealer, m_ComponentDeck,
         m_ComponentHand, EnumGameState, IDealer, IPlayer}
    };

    fn namespace_def() -> NamespaceDef {
        let ndef = NamespaceDef {
            namespace: "zktt", resources: [
                TestResource::Model(m_ComponentGame::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(m_ComponentPlayer::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(m_ComponentDealer::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(m_ComponentHand::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Model(m_ComponentDeck::TEST_CLASS_HASH.try_into().unwrap()),
                TestResource::Contract(table::TEST_CLASS_HASH)
            ].span()
        };

        ndef
    }

    // Deploy world with supplied components registered.
    fn deploy_world() -> (ITableDispatcher, WorldStorage) {
         // NOTE: All model names somehow get converted to snake case, but you have to import the
         // snake case versions from the same path where the components are from.
        let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
        let (contract_address, _) = world.dns(@"table").unwrap();

        // Deploys a contract with systems.
        // Arg 2: Calldata for constructor.
        let table: ITableDispatcher = ITableDispatcher { contract_address };

        let table_def = ContractDefTrait::new(@"zktt", @"table")
                                .with_writer_of([dojo::utils::bytearray_hash(@"zktt")].span());

        world.sync_perms_and_inits([table_def].span());

        return (table, world);
    }

    fn set_up_cards(ref world: WorldStorage) {
        let unique_cards_in_order = table::_create_cards();
        let all_cards_in_order = table::_flatten(unique_cards_in_order);

        let dealer: ComponentDealer = IDealer::new(world.dispatcher.contract_address, all_cards_in_order);
        world.write_model_test(@dealer);
    }

    #[test]
    fn test_dummy_player() {
        let (mut table, world) = deploy_world();
        // Join player one.
        table.join("Player 1");

        let second_caller = starknet::contract_address_const::<0x0b>();
        // Set unknown player as the next caller.
        starknet::testing::set_contract_address(second_caller);

        let unknown_player: ComponentPlayer = world.read_model(second_caller);
        println!("{0}", unknown_player);
        assert!(unknown_player.m_ent_owner == second_caller, "Dummy player created...!");
    }

    #[test]
    fn test_join() {
        let second_caller = starknet::contract_address_const::<0x0b>();
        let (mut table, mut world) = deploy_world();

        // Join player one.
        table.join("Player 1");

        // Set player two as the next caller.
        starknet::testing::set_contract_address(second_caller);

        // Join player two.
        table.join("Player 2");

        let game: ComponentGame = world.read_model(world.dispatcher.contract_address);
        assert!(game.m_players.len() == 2, "Players should have joined!");
    }

    #[test]
    #[should_panic(expected: ("Dealer should have 95 cards after distributing to 2 players!",))]
    fn test_start() {
       let first_caller = starknet::contract_address_const::<0x0a>();
       let second_caller = starknet::contract_address_const::<0x0b>();
       let (mut table, mut world) = deploy_world();

       set_up_cards(ref world);

       let mut dealer: ComponentDealer = world.read_model(world.dispatcher.contract_address);
       assert!(!dealer.m_cards.is_empty(), "Dealer should have cards!");

       // Set player one as the next caller.
       starknet::testing::set_contract_address(first_caller);

       // Make two players join.
       // Join player one.
       table.join("Player 1");

       // Set player two as the next caller.
       starknet::testing::set_contract_address(second_caller);

       // Join player two.
       table.join("Player 2");

       // Provide a deterministic seed.
       starknet::testing::set_block_timestamp(240);
       starknet::testing::set_nonce(0x111);


       // Start the game.
       table.start();

       // Check players' hands.
       let player1_hand: ComponentHand = world.read_model(first_caller);
       println!("Caller {0}", player1_hand);
       assert!(player1_hand.m_cards.len() == 5, "Player 1 should have received 5 cards!");
       let player2_hand: ComponentHand = world.read_model(second_caller);
       println!("Caller {0}", player2_hand);
       assert!(player2_hand.m_cards.len() == 5, "Player 1 should have received 5 cards!");

       let game: ComponentGame = world.read_model(world.dispatcher.contract_address);
       assert!(game.m_state == EnumGameState::Started, "Game should have started!");

       println!("{0}", dealer.m_cards.len());
       assert!(dealer.m_cards.len() == 95, "Dealer should have 95 cards after distributing to 2 players!");
    }

    #[test]
    fn test_new_turn() {
       let first_caller = starknet::contract_address_const::<0x0a>();
       let second_caller = starknet::contract_address_const::<0x0b>();
       let (mut table, mut world) = deploy_world();

       // Set player one as the next caller.
       starknet::testing::set_contract_address(first_caller);

       // Make two players join.
       // Join player one.
       table.join("Player 1");

       // Set player two as the next caller.
       starknet::testing::set_contract_address(second_caller);

       // Join player two.
       table.join("Player 2");

       table.start();

       let game: ComponentGame = world.read_model(world.dispatcher.contract_address);
       assert!(game.m_player_in_turn == first_caller, "Player 1 should have started their turn!");
    }

    #[test]
    #[should_panic(expected: ("Cannot draw mid-turn", 'ENTRYPOINT_FAILED'))]
    fn test_draw() {
       let first_caller = starknet::contract_address_const::<0x0a>();
       let second_caller = starknet::contract_address_const::<0x0b>();
       let (mut table, mut world) = deploy_world();

       set_up_cards(ref world);

       // Set player one as the next caller.
       starknet::testing::set_contract_address(first_caller);

       // Make two players join.
       // Join player one.
       table.join("Player 1");

       // Set player two as the next caller.
       starknet::testing::set_contract_address(second_caller);

       // Join player two.
       table.join("Player 2");

       table.start();

       let mut dealer: ComponentDealer = world.read_model(world.dispatcher.contract_address);
       assert!(!dealer.m_cards.is_empty(), "Dealer should have cards!");

       // Set player one as the next caller.
       starknet::testing::set_contract_address(first_caller);

       table.draw(false);

       let hand: ComponentHand = world.read_model(first_caller);
       assert!(hand.m_cards.len() == 7, "Player 1 should have two more cards at this point!");

       // Should panic.
       table.draw(false);
    }
}
