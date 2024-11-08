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

use crate::systems::player::player_system;
use crate::systems::game::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
use crate::systems::player::{IPlayerSystemDispatcher, IPlayerSystemDispatcherTrait};
use crate::models::components::{
    ComponentGame, ComponentPlayer, ComponentDealer, ComponentHand, ComponentDeck, ComponentDeposit
};
use crate::models::traits::{ComponentPlayerDisplay, IDealer};
use crate::tests::utils::namespace_def;
use crate::tests::integration::test_game::deploy_game;

use dojo::model::{ModelStorage, ModelValueStorage};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorage, WorldStorageTrait};
use dojo_cairo_test::{
    spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, WorldStorageTestTrait
};

use starknet::ContractAddress;

// Deploy world with supplied components registered.
pub fn deploy_player(ref world: WorldStorage) -> IPlayerSystemDispatcher {
    let (contract_address, _) = world.dns(@"player_system").unwrap();

    let system: IPlayerSystemDispatcher = IPlayerSystemDispatcher { contract_address };

    let system_def = ContractDefTrait::new(@"zktt", @"player_system")
        .with_writer_of([dojo::utils::bytearray_hash(@"zktt")].span());

    world.sync_perms_and_inits([system_def].span());
    return system;
}

#[test]
fn test_join_first_player() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Join first player
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");

    // Verify player was added to game
    let game: ComponentGame = world.read_model(world.dispatcher.contract_address);
    assert!(game.m_players.len() == 1, "Player should be added to game");

    // Verify player component created
    let player: ComponentPlayer = world.read_model(first_caller);
    assert!(player.m_username == "Player 1", "Player username should be set");
    assert!(player.m_moves_remaining == 3, "Player should have 3 moves initially");
}

#[test]
fn test_join_multiple_players() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Join first player
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");

    // Join second player
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");

    // Verify both players added
    let game: ComponentGame = world.read_model(world.dispatcher.contract_address);
    assert!(game.m_players.len() == 2, "Both players should be added");

    // Verify player order
    assert!(game.m_players.at(0) == @first_caller, "First player should be in position 0");
    assert!(game.m_players.at(1) == @second_caller, "Second player should be in position 1");
}

#[test]
#[should_panic(expected: ("Lobby already full", 'ENTRYPOINT_FAILED'))]
fn test_join_full_lobby() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let third_caller: ContractAddress = starknet::contract_address_const::<0x0c>();
    let fourth_caller: ContractAddress = starknet::contract_address_const::<0x0d>();
    let fifth_caller: ContractAddress = starknet::contract_address_const::<0x0e>();
    let sixth_caller: ContractAddress = starknet::contract_address_const::<0x0f>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Join first player
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");

    // Join second player
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");

    // Join third player
    starknet::testing::set_contract_address(third_caller);
    player_system.join("Player 3");

    // Join fourth player
    starknet::testing::set_contract_address(fourth_caller);
    player_system.join("Player 4");

    // Join fifth player
    starknet::testing::set_contract_address(fifth_caller);
    player_system.join("Player 5");

    // Verify 5 players are in the game
    let game: ComponentGame = world.read_model(world.dispatcher.contract_address);
    assert!(game.m_players.len() == 5, "Should have 5 players");

    // Try to join with 6th player - should panic
    starknet::testing::set_contract_address(sixth_caller);
    player_system.join("Player 6");
}

#[test]
fn test_leave_game() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);
    let game_system: IGameSystemDispatcher = deploy_game(ref world);

    // Setup game with two players
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");

    game_system.start();

    // First player leaves
    starknet::testing::set_contract_address(first_caller);
    player_system.leave();

    // Verify player removed from game
    let game: ComponentGame = world.read_model(world.dispatcher.contract_address);
    assert!(game.m_players.len() == 1, "Player should be removed from game");
    assert!(game.m_players.at(0) == @second_caller, "Remaining player should be player 2");

    // Verify player components cleaned up
    let hand: ComponentHand = world.read_model(first_caller);
    assert!(hand.m_cards.is_empty(), "Player hand should be empty");

    let deck: ComponentDeck = world.read_model(first_caller);
    assert!(deck.m_cards.is_empty(), "Player deck should be empty");

    let deposit: ComponentDeposit = world.read_model(first_caller);
    assert!(deposit.m_cards.is_empty(), "Player deposit should be empty");
}

#[test]
#[should_panic(expected: ("Game has not started yet", 'ENTRYPOINT_FAILED'))]
fn test_leave_before_game_starts() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Try to leave before game starts
    starknet::testing::set_contract_address(first_caller);
    player_system.leave();
}

#[test]
#[should_panic(expected: ("Player not found", 'ENTRYPOINT_FAILED'))]
fn test_leave_nonexistent_player() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let third_caller: ContractAddress = starknet::contract_address_const::<0x0c>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);
    let game_system: IGameSystemDispatcher = deploy_game(ref world);

    // Setup game with one player
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");
    game_system.start();

    // Try to leave with non-existent player
    starknet::testing::set_contract_address(third_caller);
    player_system.leave();
}

#[test]
#[should_panic(expected: ("Game has already started", 'ENTRYPOINT_FAILED'))]
fn test_join_after_game_starts() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let third_caller: ContractAddress = starknet::contract_address_const::<0x0c>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);
    let game_system: IGameSystemDispatcher = deploy_game(ref world);

    // Setup and start game
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");
    game_system.start();

    // Try to join after game started
    starknet::testing::set_contract_address(third_caller);
    player_system.join("Player 3");
}
