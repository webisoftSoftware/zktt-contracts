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
    ActionChainReorg, ActionClaimYield, ActionFrontrun, ActionPriorityFee, ActionReplayAttack,
    ActionGasFee, ActionFiftyOnePercentAttack, ActionSandwichAttack, StructAsset, StructBlockchain,
};

///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////
/////////////////////////////// ENUMS /////////////////////////////////
///////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////

#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
pub enum EnumCard {
    Asset: StructAsset,
    Blockchain: StructBlockchain,
    ChainReorg: ActionChainReorg,
    ClaimYield: ActionClaimYield,
    GasFee: ActionGasFee,
    PriorityFee: ActionPriorityFee,
    ReplayAttack: ActionReplayAttack,
    FrontRun: ActionFrontrun,
    FiftyOnePercentAttack: ActionFiftyOnePercentAttack,
    SandwichAttack: ActionSandwichAttack,
}

#[derive(Drop, Copy, Serde, PartialEq, Introspect, Debug)]
pub enum EnumGameState {
    WaitingForPlayers: (),
    WaitingForRent: (),
    Started: (),
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
    Any: (),
    AgainstTwo: (EnumBlockchainType, EnumBlockchainType),
}

#[derive(Drop, Serde, Copy, PartialEq, Introspect, Debug)]
pub enum EnumBlockchainType {
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
