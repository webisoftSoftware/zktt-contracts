////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

impl EnumCardInto of Into<@EnumCard, ByteArray> {
    fn into(self: @EnumCard) -> ByteArray {
        return match self {
            EnumCard::Asset(asset_struct) => format!("{0}", asset_struct.m_name),
            EnumCard::Blockchain(bc_struct) => format!("{0}", bc_struct.m_name),
            EnumCard::ChainReorg(_) => "Chain Reorg",
            EnumCard::ClaimYield(_) => "Claim Yield",
            EnumCard::GasFee(_) => "Gas Fee",
            EnumCard::HardFork(_) => "Hardfork",
            EnumCard::PriorityFee(_) => "Priority Fee",
            EnumCard::ReplayAttack(_) => "Replay Attack",
            EnumCard::FrontRun(_) => "Frontrun",
            EnumCard::FiftyOnePercentAttack(_) => "51% Attack",
        };
    }
}
