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

use crate::tests::utils::{deploy_world, namespace_def};
use crate::tests::integration::test_player::deploy_player;
use crate::tests::integration::test_actions::deploy_actions;

use crate::systems::game::game_system;
use crate::systems::game::{IGameSystemDispatcher, IGameSystemDispatcherTrait};
use crate::systems::player::{IPlayerSystemDispatcher, IPlayerSystemDispatcherTrait};
use crate::systems::actions::{IActionSystemDispatcher, IActionSystemDispatcherTrait};

use crate::models::components::{ComponentGame, ComponentDealer, ComponentHand, ComponentPlayer};
use crate::models::enums::{EnumGameState};
use crate::models::traits::{ComponentPlayerDisplay, IDealer};

// Deploy world with supplied components registered.
pub fn deploy_game(ref world: WorldStorage) -> (ContractAddress, IGameSystemDispatcher) {
    let (contract_address, _) = world.dns(@"game_system").unwrap();

    let system: IGameSystemDispatcher = IGameSystemDispatcher { contract_address };

    let system_def = ContractDefTrait::new(@"zktt", @"game_system")
        .with_writer_of([dojo::utils::bytearray_hash(@"zktt")].span());

    world.sync_perms_and_inits([system_def].span());
    let cards_in_order = game_system::InternalImpl::_create_cards();
    let mut flattened_cards = game_system::InternalImpl::_flatten(ref world, cards_in_order);
    let mut dealer: ComponentDealer = IDealer::new(world.dispatcher.contract_address, array![]);

    let mut index = 0;
    while index < flattened_cards.len() {
        dealer.m_cards.append(index);
        index += 1;
    };
    world.write_model(@dealer);

    return (contract_address, system);
}

#[test]
fn test_start() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = deploy_world();
    let (addr, _game_system): (ContractAddress, IGameSystemDispatcher) = deploy_game(ref world);
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    let mut dealer: ComponentDealer = world.read_model(world.dispatcher.contract_address);
    assert!(!dealer.m_cards.is_empty(), "Dealer should have cards!");

    // Provide deterministic seed
    starknet::testing::set_block_timestamp(240);
    starknet::testing::set_nonce(0x111);

    // Set player one as the next caller.
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1", addr);
    player_system.set_ready(true, addr);
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2", addr);
    player_system.set_ready(true, addr);

    let game: ComponentGame = world.read_model(addr);
    assert!(game.m_state == EnumGameState::Started, "Game should have started!");

    // Check players' hands.
    let player1_hand: ComponentHand = world.read_model(first_caller);
    assert!(player1_hand.m_cards.len() == 5, "Player 1 should have received 5 cards!");
    let player2_hand: ComponentHand = world.read_model(second_caller);
    assert!(player2_hand.m_cards.len() == 5, "Player 2 should have received 5 cards!");
}

#[test]
fn test_new_turn() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = deploy_world();
    let (addr, _game_system): (ContractAddress, IGameSystemDispatcher) = deploy_game(ref world);
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Set player one as the next caller.
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1", addr);
    player_system.set_ready(true, addr);
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2", addr);
    player_system.set_ready(true, addr);

    let game: ComponentGame = world.read_model(addr);
    assert!(game.m_player_in_turn == first_caller, "Player 1 should have started their turn!");
}

#[test]
fn test_end_turn() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = deploy_world();
    let (addr, _game_system): (ContractAddress, IGameSystemDispatcher) = deploy_game(ref world);
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Setup game with two players
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1", addr);
    player_system.set_ready(true, addr);
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2", addr);
    player_system.set_ready(true, addr);

    // Verify initial turn
    let game: ComponentGame = world.read_model(addr);
    assert!(game.m_player_in_turn == first_caller, "Player 1 should start");

    // End turn as first player
    starknet::testing::set_contract_address(first_caller);
    _game_system.end_turn(addr);

    // Verify turn passed to second player
    let game: ComponentGame = world.read_model(addr);
    assert!(game.m_player_in_turn == second_caller, "Turn should pass to Player 2");
}

#[test]
#[should_panic(expected: ("Game has not started yet", 'ENTRYPOINT_FAILED'))]
fn test_end_turn_before_game_starts() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let mut world: WorldStorage = deploy_world();
    let (addr, _game_system): (ContractAddress, IGameSystemDispatcher) = deploy_game(ref world);
    starknet::testing::set_contract_address(first_caller);
    _game_system.end_turn(addr);
}

#[test]
#[should_panic(expected: ("Not player's turn", 'ENTRYPOINT_FAILED'))]
fn test_end_turn_wrong_player() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = deploy_world();
    let (addr, _game_system): (ContractAddress, IGameSystemDispatcher) = deploy_game(ref world);
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Setup game with two players
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1", addr);
    player_system.set_ready(true, addr);
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2", addr);
    player_system.set_ready(true, addr);

    // Try to end turn as second player when it's first player's turn
    starknet::testing::set_contract_address(second_caller);
    _game_system.end_turn(addr);
}

#[test]
#[should_panic(expected: ("Missing at least a player before starting", 'ENTRYPOINT_FAILED'))]
fn test_start_with_one_player() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let mut world: WorldStorage = deploy_world();
    let (addr, _game_system): (ContractAddress, IGameSystemDispatcher) = deploy_game(ref world);
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Try to start with just one player
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1", addr);
    player_system.set_ready(true, addr);

    starknet::testing::set_contract_address(starknet::contract_address_const::<0x0>());
    _game_system.start(addr);
}

#[test]
#[should_panic(expected: ("Game has already started or invalid game ID", 'ENTRYPOINT_FAILED'))]
fn test_start_game_twice() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = deploy_world();
    let (addr, _game_system): (ContractAddress, IGameSystemDispatcher) = deploy_game(ref world);
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Setup and start game normally
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1", addr);
    player_system.set_ready(true, addr);
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2", addr);
    player_system.set_ready(true, addr);

    // Try to start again
    _game_system.start(addr);
}

#[test]
fn test_full_turn_cycle() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = deploy_world();
    let (addr, _game_system): (ContractAddress, IGameSystemDispatcher) = deploy_game(ref world);
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Setup game with two players
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1", addr);
    player_system.set_ready(true, addr);
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2", addr);
    player_system.set_ready(true, addr);

    // Complete a full turn cycle
    starknet::testing::set_contract_address(first_caller);
    _game_system.end_turn(addr);

    starknet::testing::set_contract_address(second_caller);
    _game_system.end_turn(addr);

    // Verify turn returned to first player
    let game: ComponentGame = world.read_model(addr);
    assert!(game.m_player_in_turn == first_caller, "Turn should cycle back to Player 1");
}
