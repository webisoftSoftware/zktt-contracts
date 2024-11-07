use zktt::{
        systems::game::{game_system, IGameSystemDispatcher, IGameSystemDispatcherTrait},
        models::components::{ComponentGame, ComponentPlayer, ComponentDealer, ComponentHand,
         ComponentDeck, m_ComponentGame, m_ComponentPlayer, m_ComponentDealer, m_ComponentDeck, m_ComponentHand},
         models::enums::{EnumGameState},
         models::traits::{IDealer, IPlayer}
    };

use starknet::ContractAddress;
use dojo::model::{ModelStorage, ModelValueStorage, ModelStorageTest};
use dojo::world::{WorldStorage, WorldStorageTrait};
use dojo::world::{IWorldDispatcherTrait};
use dojo::world::IWorldDispatcher;
use dojo_cairo_test::WorldStorageTestTrait;
use dojo::model::Model;
use dojo_cairo_test::{spawn_test_world, NamespaceDef, TestResource, ContractDefTrait};

pub fn namespace_def(test_class_hash: felt252) -> NamespaceDef {
    let ndef = NamespaceDef {
        namespace: "zktt", resources: [
            TestResource::Model(m_ComponentGame::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ComponentPlayer::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ComponentDealer::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ComponentHand::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Model(m_ComponentDeck::TEST_CLASS_HASH.try_into().unwrap()),
            TestResource::Contract(test_class_hash)
        ].span()
    };

    ndef
}