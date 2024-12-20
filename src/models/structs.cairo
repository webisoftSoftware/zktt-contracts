////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

use starknet::ContractAddress;
use zktt::models::enums::{EnumCard, EnumColor, EnumGasFeeType, EnumMoveError, EnumPlayerTarget};

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////// STRUCTS /////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

/// Card containing the info about an asset (card that only has monetary value).
#[derive(Drop, Serde, Clone, Introspect, Debug)]
pub struct StructAsset {
    m_name: ByteArray,
    m_value: u8,
    m_index: u8
}

/// Card containing the info about a specific asset group (set of matching blockchains).
#[derive(Drop, Serde, Clone, Introspect, Debug)]
pub struct StructAssetGroup {
    m_set: Array<StructBlockchain>,
    m_total_fee_value: u8
}

/// Card containing the info about a specific blockchain.
#[derive(Drop, Serde, Clone, Introspect, Debug)]
pub struct StructBlockchain {
    m_name: ByteArray,
    m_bc_type: EnumColor,
    m_fee: u8,
    m_value: u8
}

/// Card containing the info about a specific hybrid blockchain.
#[derive(Drop, Serde, Clone, Introspect, Debug)]
pub struct StructHybridBlockchain {
    m_name: ByteArray,
    m_bcs: Array<StructBlockchain>,
    m_bc_facing_up_index: u8
}
