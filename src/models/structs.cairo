////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

use starknet::ContractAddress;
use zktt::models::enums::{
    EnumCard, EnumBlockchainType, EnumGasFeeType, EnumMoveError, EnumPlayerTarget
};

///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
/////////////////////////////// PARTIALEQ /////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

impl StructAssetEq of PartialEq<StructAsset> {
    fn eq(lhs: @StructAsset, rhs: @StructAsset) -> bool {
        return lhs.m_name == rhs.m_name && lhs.m_index == rhs.m_index;
    }
}

impl StructAssetGroupEq of PartialEq<StructAssetGroup> {
    fn eq(lhs: @StructAssetGroup, rhs: @StructAssetGroup) -> bool {
        let mut index: usize = 0;
        return loop {
            if index >= lhs.m_set.len() {
                break true;
            }

            if lhs.m_set.at(index) != rhs.m_set.at(index) {
                break false;
            }
            index += 1;
        };
    }
}

impl StructBlockchainEq of PartialEq<StructBlockchain> {
    fn eq(lhs: @StructBlockchain, rhs: @StructBlockchain) -> bool {
        return lhs.m_name == rhs.m_name;
    }
}

impl ActionFrontrunEq of PartialEq<ActionFrontrun> {
    fn eq(lhs: @ActionFrontrun, rhs: @ActionFrontrun) -> bool {
        return lhs.m_index == rhs.m_index;
    }
}

impl ActionGasFeeEq of PartialEq<ActionGasFee> {
    fn eq(lhs: @ActionGasFee, rhs: @ActionGasFee) -> bool {
        return lhs.m_index == rhs.m_index;
    }
}

impl ActionFiftyOnePercentAttackEq of PartialEq<ActionFiftyOnePercentAttack> {
    fn eq(lhs: @ActionFiftyOnePercentAttack, rhs: @ActionFiftyOnePercentAttack) -> bool {
        let mut index: usize = 0;
        return loop {
            if index >= lhs.m_set.len() {
                break true;
            }

            if lhs.m_set.at(index) != rhs.m_set.at(index) {
                break false;
            }
            index += 1;
        };
    }
}

#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
struct ActionChainReorg {
    m_self_blockchain_name: ByteArray,
    m_opponent_blockchain_name: ByteArray,
    m_value: u8,
    m_index: u8
}

#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
struct ActionClaimYield {
    m_value: u8,
    m_index: u8
}

#[derive(Drop, Serde, Clone, Introspect, Debug)]
struct ActionFrontrun {
    m_blockchain_name: ByteArray,
    m_value: u8,
    m_index: u8
}

#[derive(Drop, Serde, Clone, Introspect, Debug)]
struct ActionGasFee {
    m_players_affected: EnumPlayerTarget,
    // First blockchain (target one player), second blockchain (Target all players).
    m_blockchain_type_affected: EnumGasFeeType,
    m_set_applied: Array<StructBlockchain>,
    m_color_chosen: Option<EnumBlockchainType>,
    m_value: u8,
    m_index: u8
}

/*
#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
struct ActionHardFork {
    m_value: u8,
    m_index: u8
}
\*/

#[derive(Drop, Serde, Clone, Introspect, Debug)]
struct ActionFiftyOnePercentAttack {
    m_owner: ContractAddress,
    m_set: Array<ByteArray>,
    m_value: u8,
    m_index: u8
}

#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
struct ActionPriorityFee {
    m_value: u8,
    m_index: u8
}

#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
struct ActionReplayAttack {
    m_value: u8,
    m_index: u8
}

#[derive(Drop, Serde, Clone, Introspect, Debug)]
pub struct StructAsset {
    m_name: ByteArray,
    m_value: u8,
    m_index: u8
}

#[derive(Drop, Serde, Clone, Introspect, Debug)]
pub struct StructAssetGroup {
    m_set: Array<StructBlockchain>,
    m_total_fee_value: u8
}

#[derive(Drop, Serde, Clone, Introspect, Debug)]
pub struct StructBlockchain {
    m_name: ByteArray,
    m_bc_type: EnumBlockchainType,
    m_fee: u8,
    m_value: u8
}
