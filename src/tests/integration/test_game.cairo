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


use starknet::ContractAddress;
use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest};
use dojo::world::{WorldStorage, WorldStorageTrait};
use dojo::world::{IWorldDispatcherTrait};
use dojo::world::IWorldDispatcher;
use dojo_cairo_test::WorldStorageTestTrait;
use dojo::model::Model;
use dojo_cairo_test::{spawn_test_world, NamespaceDef, TestResource, ContractDefTrait};

use crate::tests::utils::namespace_def;
use crate::tests::integration::test_player::deploy_player;
use crate::tests::integration::test_actions::deploy_actions;

use crate::systems::game::game_system;
use crate::systems::game::{IGameSystemDispatcher, IGameSystemDispatcherTrait};
use crate::systems::player::{IPlayerSystemDispatcher, IPlayerSystemDispatcherTrait};
use crate::systems::actions::{IActionSystemDispatcher, IActionSystemDispatcherTrait};

use crate::models::components::{ComponentGame, ComponentDealer, ComponentHand};
use crate::models::enums::{EnumGameState};
use crate::models::traits::{ComponentPlayerDisplay, IDealer};

// Deploy world with supplied components registered.
pub fn deploy_game() -> (IGameSystemDispatcher, WorldStorage) {
     // NOTE: All model names somehow get converted to snake case, but you have to import the
     // snake case versions from the same path where the components are from.
    let mut world: WorldStorage = spawn_test_world([namespace_def(game_system::TEST_CLASS_HASH)].span());

    let (contract_address, _) = world.dns(@"game_system").unwrap();

     // Deploys a contract with systems.
    // Arg 2: Calldata for constructor.
    let system: IGameSystemDispatcher = IGameSystemDispatcher { contract_address };

    let system_def = ContractDefTrait::new(@"zktt", @"game_system")
                            .with_writer_of([dojo::utils::bytearray_hash(@"zktt")].span());

    world.sync_perms_and_inits([system_def].span());
    let cards_in_order =  game_system::InternalImpl::_create_cards();
    let dealer: ComponentDealer = IDealer::new(
        world.dispatcher.contract_address, cards_in_order
    );
    world.write_model(@dealer);

    return (system, world);
}

#[test]
#[should_panic(expected: ("Dealer should have 95 cards after distributing to 2 players!",))]
fn test_start() {
   let first_caller = starknet::contract_address_const::<0x0a>();
   let second_caller = starknet::contract_address_const::<0x0b>();
   let (mut game_system, mut world) = deploy_game();
   let (mut player_system, _): (IPlayerSystemDispatcher, WorldStorage) = deploy_player();

   let mut dealer: ComponentDealer = world.read_model(world.dispatcher.contract_address);
   assert!(!dealer.m_cards.is_empty(), "Dealer should have cards!");

   // Set player one as the next caller.
   starknet::testing::set_contract_address(first_caller);

   // Make two players join.
   // Join player one.
   player_system.join("Player 1");

   // Set player two as the next caller.
   starknet::testing::set_contract_address(second_caller);

   // Join player two.
   player_system.join("Player 2");

   // Provide a deterministic seed.
   starknet::testing::set_block_timestamp(240);
   starknet::testing::set_nonce(0x111);


   // Start the game.
   game_system.start();

   // Check players' hands.
   let player1_hand: ComponentHand = world.read_model(first_caller);
   assert!(player1_hand.m_cards.len() == 5, "Player 1 should have received 5 cards!");
   let player2_hand: ComponentHand = world.read_model(second_caller);
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
   let (mut game_system, mut world) = deploy_game();
   let (mut player_system, _): (IPlayerSystemDispatcher, WorldStorage) = deploy_player();

   // Set player one as the next caller.
   starknet::testing::set_contract_address(first_caller);

   // Make two players join.
   // Join player one.
   player_system.join("Player 1");

   // Set player two as the next caller.
   starknet::testing::set_contract_address(second_caller);

   // Join player two.
   player_system.join("Player 2");

   game_system.start();

   let game: ComponentGame = world.read_model(world.dispatcher.contract_address);
   assert!(game.m_player_in_turn == first_caller, "Player 1 should have started their turn!");
}

#[test]
#[should_panic(expected: ("Cannot draw mid-turn", 'ENTRYPOINT_FAILED'))]
fn test_draw() {
   let first_caller = starknet::contract_address_const::<0x0a>();
   let second_caller = starknet::contract_address_const::<0x0b>();
   let (mut game_system, mut world) = deploy_game();
   let (mut player_system, _): (IPlayerSystemDispatcher, WorldStorage) = deploy_player();
   let (mut actions_system, _): (IActionSystemDispatcher, WorldStorage) = deploy_actions();

   // Set player one as the next caller.
   starknet::testing::set_contract_address(first_caller);

   // Make two players join.
   // Join player one.
   player_system.join("Player 1");

   // Set player two as the next caller.
   starknet::testing::set_contract_address(second_caller);

   // Join player two.
   player_system.join("Player 2");

   game_system.start();

   let mut dealer: ComponentDealer = world.read_model(world.dispatcher.contract_address);
   assert!(!dealer.m_cards.is_empty(), "Dealer should have cards!");

   // Set player one as the next caller.
   starknet::testing::set_contract_address(first_caller);

   actions_system.draw(false);

   let hand: ComponentHand = world.read_model(first_caller);
   assert!(hand.m_cards.len() == 7, "Player 1 should have two more cards at this point!");

   // Should panic.
   actions_system.draw(false);
}