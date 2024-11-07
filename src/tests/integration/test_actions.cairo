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

use crate::models::enums::EnumCard;
use crate::systems::actions::action_system;
use crate::systems::actions::{IActionSystemDispatcher, IActionSystemDispatcherTrait};
use crate::systems::game::{IGameSystemDispatcher, IGameSystemDispatcherTrait, game_system};
use crate::systems::player::{IPlayerSystemDispatcher, IPlayerSystemDispatcherTrait};
use crate::models::components::{ComponentGame, ComponentHand, ComponentDeposit, ComponentPlayer, ComponentDeck, ComponentDealer};
use crate::models::traits::{ComponentPlayerDisplay, IDealer, IAsset};
use crate::tests::utils::namespace_def;
use crate::tests::integration::test_game::deploy_game;
use crate::tests::integration::test_player::deploy_player;

use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest, ModelValueStorageTest};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorage, WorldStorageTrait};
use dojo_cairo_test::{spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, WorldStorageTestTrait};

// Deploy world with supplied components registered.
pub fn deploy_actions(ref world: WorldStorage) -> IActionSystemDispatcher {

    let (contract_address, _) = world.dns(@"action_system").unwrap();

    let system: IActionSystemDispatcher = IActionSystemDispatcher { contract_address };

    let system_def = ContractDefTrait::new(@"zktt", @"action_system")
                            .with_writer_of([dojo::utils::bytearray_hash(@"zktt")].span());

    world.sync_perms_and_inits([system_def].span());

    return system;
}

#[test]
fn test_draw() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let action_system: IActionSystemDispatcher = deploy_actions(ref world);
    let game_system: IGameSystemDispatcher = deploy_game(ref world);
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Set player one as the next caller
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");

    // Provide deterministic seed
    starknet::testing::set_block_timestamp(240);
    starknet::testing::set_nonce(0x111);

    game_system.start();

    let mut dealer: ComponentDealer = world.read_model(world.dispatcher.contract_address);
    assert!(!dealer.m_cards.is_empty(), "Dealer should have cards!");

    // Set player one as the next caller
    starknet::testing::set_contract_address(first_caller);

    // Draw cards
    action_system.draw(false);

    // Verify hand size increased
    let hand: ComponentHand = world.read_model(first_caller);
    assert!(hand.m_cards.len() == 7, "Player should have 7 cards after drawing");

    // Verify player state updated
    let player: ComponentPlayer = world.read_model(first_caller);
    assert!(player.m_has_drawn, "Player should be marked as having drawn");
}

#[test]
#[should_panic(expected: ("Cannot draw mid-turn", 'ENTRYPOINT_FAILED'))]
fn test_draw_twice_in_turn() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let action_system: IActionSystemDispatcher = deploy_actions(ref world);
    let game_system: IGameSystemDispatcher = deploy_game(ref world);
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Setup game with two players
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");

    // Provide deterministic seed
    starknet::testing::set_block_timestamp(240);
    starknet::testing::set_nonce(0x111);

    game_system.start();

    // Set player one as the next caller
    starknet::testing::set_contract_address(first_caller);

    // First draw - should succeed
    action_system.draw(false);

    // Verify first draw succeeded
    let hand: ComponentHand = world.read_model(first_caller);
    assert!(hand.m_cards.len() == 7, "Should have 7 cards after first draw");

    let player: ComponentPlayer = world.read_model(first_caller);
    assert!(player.m_has_drawn, "Player should be marked as having drawn");

    // Second draw - should panic
    action_system.draw(false);
}

#[test]
fn test_play() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let action_system: IActionSystemDispatcher = deploy_actions(ref world);
    let game_system: IGameSystemDispatcher = deploy_game(ref world);
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Setup game state
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");
    game_system.start();

    // Set player one as the next caller
    starknet::testing::set_contract_address(first_caller);

    // Draw cards first
    action_system.draw(false);

    // Get a card to play
    let hand: ComponentHand = world.read_model(first_caller);
    let card: EnumCard = hand.m_cards.at(0).clone();

    // Play the card
    action_system.play(card);

    // Verify player state
    let player: ComponentPlayer = world.read_model(first_caller);
    assert!(player.m_moves_remaining < 3, "Move should be consumed");

    // Verify card moved to appropriate location
    let hand: ComponentHand = world.read_model(first_caller);
    assert!(hand.m_cards.len() == 6, "Card should be removed from hand");
}

#[test]
fn test_move() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let action_system: IActionSystemDispatcher = deploy_actions(ref world);
    let game_system: IGameSystemDispatcher = deploy_game(ref world);
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Setup game state
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");
    game_system.start();

    // Set player one as the next caller
    starknet::testing::set_contract_address(first_caller);

    // Draw cards first
    action_system.draw(false);

    // Get a card to move
    let hand: ComponentHand = world.read_model(first_caller);
    let card: EnumCard = hand.m_cards.at(0).clone();

    // Move the card
    action_system.move(card);

    // Verify player state unchanged since move doesn't consume moves
    let player: ComponentPlayer = world.read_model(first_caller);
    assert!(player.m_moves_remaining == 3, "Moves should not be consumed by move action");
}

#[test]
fn test_pay_fee() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let game_system: IGameSystemDispatcher = deploy_game(ref world);
    let action_system: IActionSystemDispatcher = deploy_actions(ref world);
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Setup game with two players
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");
    game_system.start();

    // Set player one as the next caller
    starknet::testing::set_contract_address(first_caller);

    // Setup debt and payment cards
    let payment_cards: Array<EnumCard> = array![
        EnumCard::Asset(IAsset::new("ETH [1]", 1, 1)),
        EnumCard::Asset(IAsset::new("ETH [1]", 1, 1))
    ];
    let mut player_deposit: ComponentDeposit = world.read_model(first_caller);
    player_deposit.m_cards = payment_cards.clone();
    world.write_model_test(@player_deposit);

    let mut player: ComponentPlayer = world.read_model(first_caller);
    player.m_in_debt = Option::Some(2);
    world.write_model_test(@player);

    let mut deposit: ComponentDeposit = world.read_model(first_caller);
    
    deposit.m_cards = payment_cards.clone();
    world.write_model_test(@deposit);

    // Execute payment
    action_system.pay_fee(payment_cards, second_caller, first_caller);

    // Verify debt cleared
    let player: ComponentPlayer = world.read_model(first_caller);
    assert!(player.m_in_debt.is_none(), "Debt should be cleared");

    // Verify card transfer
    let payer_deposit: ComponentDeposit = world.read_model(first_caller);
    let recipient_deposit: ComponentDeposit = world.read_model(second_caller);
    assert!(payer_deposit.m_cards.is_empty(), "Payer deposit should be empty");
    assert!(recipient_deposit.m_cards.len() == 2, "Recipient should have received cards");
}