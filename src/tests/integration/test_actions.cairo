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

use crate::models::enums::{EnumCard, EnumGameState};
use crate::systems::actions::action_system;
use crate::systems::actions::{IActionSystemDispatcher, IActionSystemDispatcherTrait};
use crate::systems::game::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait};
use crate::systems::player::{IPlayerSystemDispatcher, IPlayerSystemDispatcherTrait};
use crate::models::components::{
    ComponentGame, ComponentHand, ComponentDeposit, ComponentPlayer, ComponentDeck, ComponentDealer
};
use crate::models::traits::{
    ComponentPlayerDisplay, ComponentHandDisplay, IDealer, IAsset, IClaimYield, IHand,
    PriorityFeeDefault, EnumCardDisplay, EnumCardEq
};
use crate::tests::utils::{deploy_world, namespace_def};
use crate::tests::integration::test_game::deploy_game;
use crate::tests::integration::test_player::deploy_player;

use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest, ModelValueStorageTest};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorage, WorldStorageTrait};
use dojo_cairo_test::{
    spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, WorldStorageTestTrait
};

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
    let mut world: WorldStorage = deploy_world();
    let action_system: IActionSystemDispatcher = deploy_actions(ref world);
    let (addr, _game_system): (ContractAddress, IGameSystemDispatcher) = deploy_game(ref world);
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Provide deterministic seed
    starknet::testing::set_block_timestamp(240);
    starknet::testing::set_nonce(0x111);

    // Set player one as the next caller
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1", addr);
    player_system.set_ready(true, addr);
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2", addr);
    player_system.set_ready(true, addr);

    let mut dealer: ComponentDealer = world.read_model(addr);
    assert!(!dealer.m_cards.is_empty(), "Dealer should have cards!");

    // Set player one as the next caller
    starknet::testing::set_contract_address(first_caller);

    // Draw cards
    action_system.draw(false, addr);

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
    let mut world: WorldStorage = deploy_world();
    let action_system: IActionSystemDispatcher = deploy_actions(ref world);
    let (addr, _game_system): (ContractAddress, IGameSystemDispatcher) = deploy_game(ref world);
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Provide deterministic seed
    starknet::testing::set_block_timestamp(240);
    starknet::testing::set_nonce(0x111);

    // Setup game with two players
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1", addr);
    player_system.set_ready(true, addr);
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2", addr);
    player_system.set_ready(true, addr);

    // Set player one as the next caller
    starknet::testing::set_contract_address(first_caller);

    // First draw - should succeed
    action_system.draw(false, addr);

    // Verify first draw succeeded
    let hand: ComponentHand = world.read_model(first_caller);
    assert!(hand.m_cards.len() == 7, "Should have 7 cards after first draw");

    let player: ComponentPlayer = world.read_model(first_caller);
    assert!(player.m_has_drawn, "Player should be marked as having drawn");

    // Second draw - should panic
    action_system.draw(false, addr);
}

#[test]
fn test_play() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = deploy_world();
    let action_system: IActionSystemDispatcher = deploy_actions(ref world);
    let (addr, _game_system): (ContractAddress, IGameSystemDispatcher) = deploy_game(ref world);
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Setup game state
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1", addr);
    player_system.set_ready(true, addr);
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2", addr);
    player_system.set_ready(true, addr);

    let hand: ComponentHand = world.read_model(first_caller);
    assert!(hand.m_cards.len() == 5, "Player should have 5 cards before drawing");

    // Set player one as the next caller
    starknet::testing::set_contract_address(first_caller);

    // Draw cards first
    action_system.draw(false, addr);

    // Get a card to play
    let hand: ComponentHand = world.read_model(first_caller);
    let card: EnumCard = hand.m_cards.at(0).clone();

    assert!(hand.m_cards.len() == 7, "Player should have 7 cards after drawing");

    // Play the card
    action_system.play(card.clone(), addr);

    // Verify player state
    let player: ComponentPlayer = world.read_model(first_caller);
    assert!(player.m_moves_remaining < 3, "Move should be consumed");

    // Verify card moved to appropriate location
    let hand: ComponentHand = world.read_model(first_caller);

    if card == EnumCard::PriorityFee(Default::default()) {
        assert!(hand.m_cards.len() == 8, "Player should have 8 cards after playing");
    } else {
        assert!(hand.m_cards.len() == 6, "Player should have 6 cards after playing");
    }
}

#[test]
fn test_move() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = deploy_world();
    let action_system: IActionSystemDispatcher = deploy_actions(ref world);
    let (addr, _game_system): (ContractAddress, IGameSystemDispatcher) = deploy_game(ref world);
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Setup game state
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1", addr);
    player_system.set_ready(true, addr);
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2", addr);
    player_system.set_ready(true, addr);

    // Set player one as the next caller
    starknet::testing::set_contract_address(first_caller);

    // Draw cards first
    action_system.draw(false, addr);

    // Get a card to move
    let hand: ComponentHand = world.read_model(first_caller);
    let card: EnumCard = hand.m_cards.at(0).clone();

    // Move the card
    action_system.move(card, addr);

    // Verify player state unchanged since move doesn't consume moves
    let player: ComponentPlayer = world.read_model(first_caller);
    assert!(player.m_moves_remaining == 3, "Moves should not be consumed by move action");
}

#[test]
fn test_claim_yield_and_pay_fee() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = deploy_world();
    let (addr, _game_system): (ContractAddress, IGameSystemDispatcher) = deploy_game(ref world);
    let action_system: IActionSystemDispatcher = deploy_actions(ref world);
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Setup game with two players
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1", addr);
    player_system.set_ready(true, addr);
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2", addr);
    player_system.set_ready(true, addr);

    // Set player one as the next caller and draw cards
    starknet::testing::set_contract_address(first_caller);
    action_system.draw(false, addr);

    // Get ClaimYield card and play it
    let mut hand: ComponentHand = world.read_model(first_caller);
    let claim_yield_card = EnumCard::ClaimYield(IClaimYield::new(2, 3));
    hand.add(claim_yield_card.clone());
    world.write_model_test(@hand);

    // Play ClaimYield card
    action_system.play(claim_yield_card, addr);

    // Verify game is paused and players are in debt
    let game: ComponentGame = world.read_model(addr);
    assert!(game.m_state == EnumGameState::WaitingForRent, "Game should be paused");

    let player2: ComponentPlayer = world.read_model(second_caller);
    assert!(player2.m_in_debt == Option::Some(2), "Player 2 should be in debt");

    // Setup payment cards for player 2
    let payment_cards: Array<EnumCard> = array![
        EnumCard::Asset(IAsset::new("ETH [1]", 1, 1)), EnumCard::Asset(IAsset::new("ETH [1]", 1, 1))
    ];
    let mut player2_deposit: ComponentDeposit = world.read_model(second_caller);
    player2_deposit.m_cards = payment_cards.clone();
    world.write_model_test(@player2_deposit);

    // Pay the debt
    action_system.pay_fee(payment_cards, first_caller, second_caller, addr);

    // Verify game resumed and debt cleared
    let game_after: ComponentGame = world.read_model(addr);
    assert!(game_after.m_state == EnumGameState::Started, "Game should resume after payment");

    let player2_after: ComponentPlayer = world.read_model(second_caller);
    assert!(player2_after.m_in_debt.is_none(), "Debt should be cleared");

    // Verify creditor received payment
    let creditor_deposit_after: ComponentDeposit = world.read_model(first_caller);
    assert!(creditor_deposit_after.m_total_value == 2, "Creditor should receive payment");

    // Verify debtor's deposit decreased
    let debtor_deposit_after: ComponentDeposit = world.read_model(second_caller);
    assert!(debtor_deposit_after.m_total_value == 0, "Debtor's deposit should be empty");

    // Verify can play cards again after debt cleared
    let mut hand2: ComponentHand = world.read_model(first_caller);
    let new_asset = EnumCard::Asset(IAsset::new("ETH [2]", 2, 1));
    hand2.add(new_asset.clone());
    world.write_model_test(@hand2);
    action_system.play(new_asset, addr); // Should not panic
}

#[test]
#[should_panic(expected: ("Game is paused", 'ENTRYPOINT_FAILED'))]
fn test_actions_blocked_during_debt() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = deploy_world();
    let (addr, _game_system): (ContractAddress, IGameSystemDispatcher) = deploy_game(ref world);
    let action_system: IActionSystemDispatcher = deploy_actions(ref world);
    let player_system: IPlayerSystemDispatcher = deploy_player(ref world);

    // Setup game with two players
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1", addr);
    player_system.set_ready(true, addr);
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2", addr);
    player_system.set_ready(true, addr);

    // Player 1 plays ClaimYield
    starknet::testing::set_contract_address(first_caller);
    action_system.draw(false, addr);

    let mut hand: ComponentHand = world.read_model(first_caller);
    let claim_yield_card = EnumCard::ClaimYield(IClaimYield::new(2, 3));
    hand.add(claim_yield_card.clone());
    world.write_model_test(@hand);
    action_system.play(claim_yield_card, addr);

    // Player 2 tries to play a card while in debt - should fail
    starknet::testing::set_contract_address(second_caller);
    let test_asset = EnumCard::Asset(IAsset::new("ETH [1]", 1, 1));
    let mut hand2: ComponentHand = world.read_model(second_caller);
    hand2.add(test_asset.clone());
    world.write_model_test(@hand2);
    action_system.play(test_asset, addr); // This should panic
}
