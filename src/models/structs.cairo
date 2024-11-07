////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

// TODO: Add comments to each component

#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
pub struct ActionChainReorg {
    m_self_blockchain_name: ByteArray,
    m_opponent_blockchain_name: ByteArray,
    m_value: u8,
    m_index: u8
}

#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
pub struct ActionClaimYield {
    m_value: u8,
    m_index: u8
}

#[derive(Drop, Serde, Clone, Introspect, Debug)]
pub struct ActionFrontrun {
    m_blockchain_name: ByteArray,
    m_value: u8,
    m_index: u8
}

#[derive(Drop, Serde, Clone, Introspect, Debug)]
pub struct ActionGasFee {
    m_players_affected: EnumPlayerTarget,
    m_blockchain_type_affected: EnumGasFeeType,
    m_set_applied: Array<StructBlockchain>,
    m_color_chosen: Option<EnumBlockchainType>,
    m_value: u8,
    m_index: u8
}

#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
pub struct ActionHardFork {
    m_value: u8,
    m_index: u8
}

#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
pub struct ActionMEVBoost {
    m_full_set: Array<ByteArray>,
    m_value: u8,
    m_index: u8
}


#[derive(Drop, Serde, Clone, Introspect, Debug)]
pub struct ActionMajorityAttack {
    m_owner: ContractAddress,
    m_set: Array<ByteArray>,
    m_value: u8,
    m_index: u8
}


#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
pub struct ActionPriorityFee {
    m_value: u8,
    m_index: u8
}

// TODO: Review ReplayAttack and SoftFork

#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
pub struct ActionReplayAttack {
    m_value: u8,
    m_index: u8
}

#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
pub struct ActionSoftFork {
    m_full_set: Array<ByteArray>,
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
