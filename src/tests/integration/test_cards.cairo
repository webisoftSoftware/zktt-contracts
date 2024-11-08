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
use crate::models::structs::StructBlockchain;
use crate::models::enums::{
    EnumCard, EnumGameState, EnumBlockchainType, EnumGasFeeType, EnumPlayerTarget
};
use crate::models::components::{
    ComponentGame, ComponentHand, ComponentDeposit, ComponentPlayer, ComponentDeck, ComponentDealer
};
use crate::models::traits::{
    IAsset, IBlockchain, IClaimYield, ISandwichAttack, IGasFee, IPriorityFee, IFrontRun,
    IFiftyOnePercentAttack, IChainReorg, IHand, IDeck, ComponentDeckDisplay
};
use crate::tests::utils::namespace_def;
use crate::tests::integration::test_game::deploy_game;
use crate::tests::integration::test_player::deploy_player;
use crate::tests::integration::test_actions::deploy_actions;

use crate::systems::game::{IGameSystemDispatcher, IGameSystemDispatcherTrait};
use crate::systems::player::{IPlayerSystemDispatcher, IPlayerSystemDispatcherTrait};
use crate::systems::actions::{IActionSystemDispatcher, IActionSystemDispatcherTrait};

use dojo::model::{ModelStorage, ModelStorageTest};
use dojo::world::WorldStorage;
use dojo_cairo_test::{spawn_test_world, WorldStorageTestTrait};

#[test]
fn test_asset_card() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let action_system = deploy_actions(ref world);
    let _game_system = deploy_game(ref world);
    let player_system = deploy_player(ref world);

    // Setup game with two players
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");
    _game_system.start();

    // Set player one as the next caller
    starknet::testing::set_contract_address(first_caller);

    // Draw cards first
    action_system.draw(false);

    // Create and play asset card
    let mut hand: ComponentHand = world.read_model(first_caller);
    let asset_card = EnumCard::Asset(IAsset::new("ETH [1]", 1, 1));
    hand.add(asset_card.clone());
    world.write_model_test(@hand);

    // Play asset card
    action_system.play(asset_card);

    // Verify asset added to deposit
    let deposit: ComponentDeposit = world.read_model(first_caller);
    assert!(deposit.m_total_value == 1, "Asset value should be added to deposit");
}

#[test]
fn test_blockchain_card() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let action_system = deploy_actions(ref world);
    let _game_system = deploy_game(ref world);
    let player_system = deploy_player(ref world);

    // Setup game with two players
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");
    _game_system.start();

    // Set player one as the next caller and draw cards
    starknet::testing::set_contract_address(first_caller);
    action_system.draw(false);

    // Create and play blockchain card
    let mut hand: ComponentHand = world.read_model(first_caller);
    let blockchain_card = EnumCard::Blockchain(
        IBlockchain::new("Ethereum", EnumBlockchainType::DarkBlue, 3, 4)
    );
    hand.add(blockchain_card.clone());
    world.write_model_test(@hand);

    // Play blockchain card
    action_system.play(blockchain_card);

    // Verify blockchain added to deck
    let deck: ComponentDeck = world.read_model(first_caller);
    assert!(deck.m_cards.len() == 1, "Blockchain should be added to deck");
}

#[test]
fn test_claim_yield_card() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let action_system = deploy_actions(ref world);
    let _game_system = deploy_game(ref world);
    let player_system = deploy_player(ref world);

    // Setup game with two players
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");
    _game_system.start();

    // Set player one as the next caller and draw cards first
    starknet::testing::set_contract_address(first_caller);
    action_system.draw(false);

    // Play ClaimYield card
    let mut hand: ComponentHand = world.read_model(first_caller);
    let claim_yield_card = EnumCard::ClaimYield(IClaimYield::new(2, 3));
    hand.add(claim_yield_card.clone());
    world.write_model_test(@hand);
    action_system.play(claim_yield_card);

    // Verify effects
    let game: ComponentGame = world.read_model(world.dispatcher.contract_address);
    assert!(game.m_state == EnumGameState::WaitingForRent, "Game should be waiting for rent");

    let player2: ComponentPlayer = world.read_model(second_caller);
    assert!(player2.m_in_debt == Option::Some(2), "Player 2 should be in debt for 2 ETH");
}

#[test]
fn test_sandwich_attack_card() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let action_system = deploy_actions(ref world);
    let _game_system = deploy_game(ref world);
    let player_system = deploy_player(ref world);

    // Setup game with two players
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");
    _game_system.start();

    // Set player one as the next caller and draw cards
    starknet::testing::set_contract_address(first_caller);
    action_system.draw(false);

    // Play SandwichAttack card
    let mut hand: ComponentHand = world.read_model(first_caller);
    let sandwich_attack_card = EnumCard::SandwichAttack(ISandwichAttack::new(3, 3));
    hand.add(sandwich_attack_card.clone());
    world.write_model_test(@hand);
    action_system.play(sandwich_attack_card);

    // Verify effects
    let game: ComponentGame = world.read_model(world.dispatcher.contract_address);
    assert!(game.m_state == EnumGameState::WaitingForRent, "Game should be waiting for rent");

    let player2: ComponentPlayer = world.read_model(second_caller);
    assert!(player2.m_in_debt == Option::Some(5), "Player 2 should be in debt for 5 ETH");
}

#[test]
fn test_gas_fee_card() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let action_system = deploy_actions(ref world);
    let _game_system = deploy_game(ref world);
    let player_system = deploy_player(ref world);

    // Setup game with two players
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");
    _game_system.start();

    // Set player one as the next caller and draw cards
    starknet::testing::set_contract_address(first_caller);
    action_system.draw(false);

    // Create GasFee card targeting specific color
    let mut hand: ComponentHand = world.read_model(first_caller);
    let mut gas_fee_card = EnumCard::GasFee(
        IGasFee::new(
            EnumPlayerTarget::All,
            EnumGasFeeType::Any,
            array![
                StructBlockchain {
                    m_name: "Ethereum",
                    m_bc_type: EnumBlockchainType::DarkBlue,
                    m_fee: 3,
                    m_value: 4
                }
            ],
            3,
            3
        )
    );

    hand.add(gas_fee_card.clone());
    world.write_model_test(@hand);

    // Play GasFee card
    action_system.play(gas_fee_card);

    // Verify effects
    let game: ComponentGame = world.read_model(world.dispatcher.contract_address);
    assert!(game.m_state == EnumGameState::WaitingForRent, "Game should be waiting for rent");
}

#[test]
fn test_priority_fee_card() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let action_system = deploy_actions(ref world);
    let _game_system = deploy_game(ref world);
    let player_system = deploy_player(ref world);

    // Setup game with two players
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");
    _game_system.start();

    // Set player one as the next caller and draw cards
    starknet::testing::set_contract_address(first_caller);
    action_system.draw(false);

    // Play PriorityFee card
    let mut hand: ComponentHand = world.read_model(first_caller);
    let priority_fee_card = EnumCard::PriorityFee(IPriorityFee::new(1, 10));
    hand.add(priority_fee_card.clone());
    world.write_model_test(@hand);

    let initial_hand_size = hand.m_cards.len();
    action_system.play(priority_fee_card);

    // Verify player drew 2 additional cards
    let hand_after: ComponentHand = world.read_model(first_caller);
    assert!(
        hand_after.m_cards.len() == initial_hand_size + 1,
        "Player should have drawn 2 additional cards"
    );
}

#[test]
fn test_frontrun_card() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let action_system = deploy_actions(ref world);
    let _game_system = deploy_game(ref world);
    let player_system = deploy_player(ref world);

    // Setup game with two players
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");
    _game_system.start();

    // Setup target blockchain in player 2's deck
    let target_blockchain = EnumCard::Blockchain(
        IBlockchain::new("Ethereum", EnumBlockchainType::DarkBlue, 3, 4)
    );
    let mut player2_deck: ComponentDeck = world.read_model(second_caller);
    player2_deck.add(target_blockchain.clone());
    world.write_model_test(@player2_deck);

    // Set player one as the next caller and draw cards first
    starknet::testing::set_contract_address(first_caller);
    action_system.draw(false);

    // Play FrontRun card from player 1
    let mut hand: ComponentHand = world.read_model(first_caller);
    let frontrun_card = EnumCard::FrontRun(IFrontRun::new("Ethereum", 3, 3));
    hand.add(frontrun_card.clone());
    world.write_model_test(@hand);
    action_system.play(frontrun_card);

    // Verify blockchain was stolen
    let player1_deck: ComponentDeck = world.read_model(first_caller);
    let player2_deck_after: ComponentDeck = world.read_model(second_caller);
    assert!(player1_deck.m_cards.len() == 1, "Player 1 should have stolen blockchain");
    assert!(player2_deck_after.m_cards.is_empty(), "Player 2 should have lost blockchain");
}

#[test]
fn test_chain_reorg_card() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let action_system = deploy_actions(ref world);
    let _game_system = deploy_game(ref world);
    let player_system = deploy_player(ref world);

    // Setup game with two players
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");
    _game_system.start();

    // Set player one as the next caller and draw cards
    starknet::testing::set_contract_address(first_caller);
    action_system.draw(false);

    // Setup blockchains to swap
    let blockchain1 = EnumCard::Blockchain(
        IBlockchain::new("Ethereum", EnumBlockchainType::DarkBlue, 3, 4)
    );
    let blockchain2 = EnumCard::Blockchain(
        IBlockchain::new("Bitcoin", EnumBlockchainType::Gold, 1, 2)
    );

    // Add blockchains to respective decks
    let mut player1_deck: ComponentDeck = world.read_model(first_caller);
    let mut player2_deck: ComponentDeck = world.read_model(second_caller);
    player1_deck.add(blockchain1.clone());
    player2_deck.add(blockchain2.clone());
    world.write_model_test(@player1_deck);
    world.write_model_test(@player2_deck);

    // Play ChainReorg card
    let mut hand: ComponentHand = world.read_model(first_caller);
    let chain_reorg_card = EnumCard::ChainReorg(
        IChainReorg::new("Ethereum", "Bitcoin", second_caller, 3, 3)
    );

    hand.add(chain_reorg_card.clone());
    world.write_model_test(@hand);
    action_system.play(chain_reorg_card);

    // Verify blockchains were swapped
    let player1_deck_after: ComponentDeck = world.read_model(first_caller);
    let player2_deck_after: ComponentDeck = world.read_model(second_caller);
    assert!(player1_deck_after.contains(@"Bitcoin").is_some(), "Player 1 should have Bitcoin");
    assert!(player2_deck_after.contains(@"Ethereum").is_some(), "Player 2 should have Ethereum");
}

#[test]
fn test_fifty_one_percent_attack_card() {
    let first_caller: ContractAddress = starknet::contract_address_const::<0x0a>();
    let second_caller: ContractAddress = starknet::contract_address_const::<0x0b>();
    let mut world: WorldStorage = spawn_test_world([namespace_def()].span());
    let action_system = deploy_actions(ref world);
    let _game_system = deploy_game(ref world);
    let player_system = deploy_player(ref world);

    // Setup game with two players
    starknet::testing::set_contract_address(first_caller);
    player_system.join("Player 1");
    starknet::testing::set_contract_address(second_caller);
    player_system.join("Player 2");
    _game_system.start();

    // Setup target asset group in player 2's deck
    let blockchain_set: Array<StructBlockchain> = array![
        IBlockchain::new("Ethereum", EnumBlockchainType::DarkBlue, 3, 4),
        IBlockchain::new("Starknet", EnumBlockchainType::DarkBlue, 3, 4)
    ];

    let mut player2_deck: ComponentDeck = world.read_model(second_caller);
    player2_deck
        .add(
            EnumCard::Blockchain(IBlockchain::new("Ethereum", EnumBlockchainType::DarkBlue, 3, 4))
        );
    player2_deck
        .add(
            EnumCard::Blockchain(IBlockchain::new("Starknet", EnumBlockchainType::DarkBlue, 3, 4))
        );
    world.write_model_test(@player2_deck);

    // Set player one as the next caller and draw cards first
    starknet::testing::set_contract_address(first_caller);
    action_system.draw(false);

    // Play FiftyOnePercentAttack card
    let mut hand: ComponentHand = world.read_model(first_caller);
    let fifty_one_percent_card = EnumCard::FiftyOnePercentAttack(
        IFiftyOnePercentAttack::new(second_caller, blockchain_set, 5, 1)
    );
    hand.add(fifty_one_percent_card.clone());
    world.write_model_test(@hand);
    action_system.play(fifty_one_percent_card);

    // Verify asset group was stolen
    let player1_deck: ComponentDeck = world.read_model(first_caller);
    let player2_deck_after: ComponentDeck = world.read_model(second_caller);
    assert!(player1_deck.m_cards.len() == 2, "Player 1 should have stolen both blockchains");
    assert!(player2_deck_after.m_cards.is_empty(), "Player 2 should have lost both blockchains");

    assert!(player1_deck.m_sets == 1, "Player 1 should gain a set");
    assert!(player2_deck_after.m_sets == 0, "Player 2 should lose a set");
}
