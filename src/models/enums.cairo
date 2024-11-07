////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

#[derive(Drop, Serde, Clone, PartialEq, Introspect, Debug)]
pub enum EnumCard {
    Asset: StructAsset,
    Blockchain: StructBlockchain,
    ClaimYield: ActionClaimYield,
    GasFee: ActionGasFee,
    Hardfork: ActionHardfork,
    PriorityFee: ActionPriorityFee,
    ChainReorg: ActionChainReorg,
    ReplayAttack: ActionReplayAttack,
    FrontRun: ActionFrontrun,
    FiftyOnePercentAttack: ActionFiftyOnePercentAttack
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