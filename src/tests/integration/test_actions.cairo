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

use crate::systems::actions::action_system;
use crate::systems::actions::{IActionSystemDispatcher, IActionSystemDispatcherTrait};
use crate::systems::game::game_system;
use crate::models::components::{ComponentDealer};
use crate::models::traits::{IDealer};
use crate::tests::utils::namespace_def;

use dojo::model::{ModelStorage, ModelValueStorage};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait, WorldStorage, WorldStorageTrait};
use dojo_cairo_test::{spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, WorldStorageTestTrait};

// Deploy world with supplied components registered.
pub fn deploy_actions() -> (IActionSystemDispatcher, dojo::world::WorldStorage) {
     // NOTE: All model names somehow get converted to snake case, but you have to import the
     // snake case versions from the same path where the components are from.
    let mut world: dojo::world::WorldStorage = spawn_test_world([namespace_def(action_system::TEST_CLASS_HASH)].span());

    let (contract_address, _) = world.dns(@"action_system").unwrap();

    // Deploys a contract with systems.
    // Arg 2: Calldata for constructor.
    let system: IActionSystemDispatcher = IActionSystemDispatcher { contract_address };

    let system_def = ContractDefTrait::new(@"zktt", @"action_system")
                            .with_writer_of([dojo::utils::bytearray_hash(@"zktt")].span());

    world.sync_perms_and_inits([system_def].span());
    let cards_in_order =  game_system::InternalImpl::_create_cards();
    let dealer: ComponentDealer = IDealer::new(
        world.dispatcher.contract_address, cards_in_order
    );
    world.write_model(@dealer);

    return (system, world);
}