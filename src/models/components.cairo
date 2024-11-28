////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

use starknet::ContractAddress;
use zktt::models::enums::{EnumCard, EnumGameState};

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////////////////////// COMPONENTS /////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

#[derive(Drop, Serde, Clone, Debug)]
#[dojo::model]
pub struct ComponentCard {
    #[key]
    pub m_ent_index: u32,
    pub m_card_info: EnumCard
}

/// Component that represents the Pile of cards in the middle of the board, not owned by any player
/// yet.
///
/// Per table.
#[derive(Drop, Serde, Clone, Debug)]
#[dojo::model]
pub struct ComponentDealer {
    #[key]
    pub m_ent_owner: ContractAddress,
    pub m_cards: Array<u32>
}

/// Component that represents the deck containing all blockchains not in the player's hand.
///
/// Per player.
#[derive(Drop, Serde, Clone, Debug)]
#[dojo::model]
pub struct ComponentDeck {
    #[key]
    pub m_ent_owner: ContractAddress,
    pub m_cards: Array<EnumCard>,
    pub m_sets: u8
}

/// Component that represents the pile of assets that each player owns in the game.
///
/// Per player.
#[derive(Drop, Serde, Clone, Debug)]
#[dojo::model]
pub struct ComponentDeposit {
    #[key]
    pub m_ent_owner: ContractAddress,
    pub m_cards: Array<EnumCard>,
    pub m_total_value: u8
}

/// Component that represents the pile of played cards that pile up next to the board deck.
///
/// Per table.
#[derive(Drop, Serde, Clone, Debug)]
#[dojo::model]
pub struct ComponentDiscardPile {
    #[key]
    pub m_owner: ContractAddress,
    pub m_cards: Array<EnumCard>
}

/// Component that represents the cards held in hand of a player in the game.
///
/// Per player.
#[derive(Drop, Serde, Clone, Debug)]
#[dojo::model]
pub struct ComponentHand {
    #[key]
    pub m_ent_owner: ContractAddress,
    pub m_cards: Array<EnumCard>
}

/// Component that represents the game state and acts as storage to keep track of the number of
/// players currently at the table.
///
/// Per table.
#[derive(Drop, Serde, Clone, Debug)]
#[dojo::model]
pub struct ComponentGame {
    #[key]
    pub m_ent_seed: felt252,
    pub m_state: EnumGameState,
    pub m_players: Array<ContractAddress>,
    pub m_player_in_turn: ContractAddress
}

/// Component that represents a player in the game. Note that the username is not unique, only the
/// address is.
///
/// Per player.
#[derive(Drop, Serde, Clone, Debug)]
#[dojo::model]
pub struct ComponentPlayer {
    #[key]
    pub m_ent_owner: ContractAddress,
    pub m_username: ByteArray,
    pub m_moves_remaining: u8,
    pub m_score: u32,
    pub m_has_drawn: bool,
    pub m_is_ready: bool,
    pub m_in_debt: Option<u8>
}
