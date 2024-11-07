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
use crate::systems::game::game_system;
use crate::systems::player::{IPlayerSystemDispatcher, IPlayerSystemDispatcherTrait};
use crate::models::components::{ComponentGame, ComponentPlayer, ComponentDealer};
use crate::models::traits::{ComponentPlayerDisplay, IDealer};
use crate::tests::utils::namespace_def;

use dojo::model::{ModelStorage, ModelValueStorage};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorage, WorldStorageTrait};
use dojo_cairo_test::{spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, WorldStorageTestTrait};

// Deploy world with supplied components registered.
pub fn deploy_player() -> (IPlayerSystemDispatcher, dojo::world::WorldStorage) {
     // NOTE: All model names somehow get converted to snake case, but you have to import the
     // snake case versions from the same path where the components are from.
    let mut world: dojo::world::WorldStorage = spawn_test_world([namespace_def(player_system::TEST_CLASS_HASH)].span());

    let (contract_address, _) = world.dns(@"player_system").unwrap();

    // Deploys a contract with systems.
    // Arg 2: Calldata for constructor.
    let mut system: IPlayerSystemDispatcher = IPlayerSystemDispatcher { contract_address };

    let system_def = ContractDefTrait::new(@"zktt", @"player_system")
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
    fn test_dummy_player() {
        let (mut player_system, mut world) = deploy_player();
        // Join player one.
        player_system.join("Player 1");

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
        let (mut player_system, mut world) = deploy_player();

        // Join player one.
        player_system.join("Player 1");

        // Set player two as the next caller.
        starknet::testing::set_contract_address(second_caller);

        // Join player two.
        player_system.join("Player 2");

        let game: ComponentGame = world.read_model(world.dispatcher.contract_address);
        assert!(game.m_players.len() == 2, "Players should have joined!");
    }