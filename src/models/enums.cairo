////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

use starknet::ContractAddress;
use zktt::models::structs::{
    ActionChainReorg, ActionClaimYield, ActionFrontrun, ActionHardFork, ActionMEVBoost,
    ActionPriorityFee, ActionReplayAttack, ActionSoftFork, ActionGasFee, ActionMajorityAttack,
    StructAsset, StructBlockchain
};
// TODO: Add comments to each component
// TODO: Remove MEVBoost and change names per C designs

#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
pub enum EnumCard {
    Asset: StructAsset,
    Blockchain: StructBlockchain,
    ChainReorg: ActionChainReorg,
    ClaimYield: ActionClaimYield,
    GasFee: ActionGasFee,
    HardFork: ActionHardFork,
    MEVBoost: ActionMEVBoost,
    PriorityFee: ActionPriorityFee,
    SoftFork: ActionSoftFork,
    ReplayAttack: ActionReplayAttack,
    FrontRun: ActionFrontrun,
    MajorityAttack: ActionMajorityAttack
}

#[derive(Drop, Copy, Serde, PartialEq, Introspect, Debug)]
pub enum EnumGameState {
    WaitingForPlayers: (),
    Started: ()
}

#[derive(Drop, Copy, Serde, PartialEq, Introspect, Debug)]
pub enum EnumMoveError {
    CardAlreadyPresent,
    CardNotFound,
    NotEnoughMoves,
    SetAlreadyPresent
}

#[derive(Drop, Copy, Serde, PartialEq, Introspect, Debug)]
pub enum EnumPlayerTarget {
    All: (),
    None: (),
    One: ContractAddress,
}

#[derive(Drop, Copy, Serde, PartialEq, Introspect, Debug)]
pub enum EnumGasFeeType {
    Any: EnumBlockchainType,
    AgainstTwo: (EnumBlockchainType, EnumBlockchainType),
}

// TODO: Remove Immutable from enum

#[derive(Drop, Serde, Copy, PartialEq, Introspect, Debug)]
pub enum EnumBlockchainType {
    Immutable,
    Blue,
    DarkBlue,
    Gold,
    Green,
    Grey,
    LightBlue,
    Pink,
    Purple,
    Red,
    Yellow,
}
