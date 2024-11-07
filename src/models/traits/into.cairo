////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

use core::fmt::{Display, Formatter, Error};
use zktt::models::components::{ComponentDeck, ComponentHand, ComponentPlayer};
use zktt::models::enums::{EnumCard, EnumBlockchainType, EnumGasFeeType, EnumMoveError};
use zktt::models::structs::{
    ActionChainReorg, ActionClaimYield, ActionFrontrun, ActionHardFork, ActionMEVBoost,
    ActionPriorityFee, ActionReplayAttack, ActionSoftFork, ActionGasFee, ActionMajorityAttack,
    StructAsset, StructBlockchain
};

// TODO: Remove MEVBoost and fix MajorityAttack so it says FiftyOnePercentAttack

impl EnumCardInto of Into<@EnumCard, ByteArray> {
    fn into(self: @EnumCard) -> ByteArray {
        return match self {
            EnumCard::Asset(asset_struct) => format!("{0}", asset_struct.m_name),
            EnumCard::Blockchain(bc_struct) => format!("{0}", bc_struct.m_name),
            EnumCard::ChainReorg(_) => "Chain Reorg",
            EnumCard::ClaimYield(_) => "Claim Yield",
            EnumCard::GasFee(_) => "Gas Fee",
            EnumCard::HardFork(_) => "Hardfork",
            EnumCard::MEVBoost(_) => "MEV Boost",
            EnumCard::PriorityFee(_) => "Priority Fee",
            EnumCard::ReplayAttack(_) => "Replay Attack",
            EnumCard::SoftFork(_) => "Soft Fork",
            EnumCard::FrontRun(_) => "Frontrun",
            EnumCard::MajorityAttack(_) => "51% Attack",
        };
    }
}
