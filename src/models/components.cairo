////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

// TODO: Add comments to each component

use starknet::ContractAddress;
use super::enums::{EnumCard, EnumGameState};

#[derive(Drop, Serde, Clone, Debug)]
#[dojo::model]
pub struct ComponentGame {
    #[key]
    pub m_ent_seed: felt252,
    pub m_state: EnumGameState,
    pub m_players: Array<ContractAddress>,
    pub m_player_in_turn: ContractAddress
}

#[derive(Drop, Serde, Clone, Debug)]
#[dojo::model]
pub struct ComponentDealer {
    #[key]
    pub m_ent_owner: ContractAddress,
    pub m_cards: Array<EnumCard>
}

#[derive(Drop, Serde, Clone, Debug)]
#[dojo::model]
pub struct ComponentDeck {
    #[key]
    pub m_ent_owner: ContractAddress,
    pub m_cards: Array<EnumCard>
}

#[derive(Drop, Serde, Clone, Debug)]
#[dojo::model]
pub struct ComponentDeposit {
    #[key]
    pub m_ent_owner: ContractAddress,
    pub m_cards: Array<EnumCard>,
    pub m_total_value: u8
}

#[derive(Drop, Serde, Clone, Debug)]
#[dojo::model]
pub struct ComponentHand {
    #[key]
    pub m_ent_owner: ContractAddress,
    pub m_cards: Array<EnumCard>
}

#[derive(Drop, Serde, Clone, Debug)]
#[dojo::model]
pub struct ComponentPlayer {
    #[key]
    pub m_ent_owner: ContractAddress,
    pub m_username: ByteArray,
    pub m_moves_remaining: u8,
    pub m_score: u32,
    pub m_sets: u8,
    pub m_has_drawn: bool,
    pub m_in_debt: Option<u8>
}
