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

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////// ACTIONS /////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

/// Swap a single blockchain with a player.
///
/// Fields:
/// *m_self_blockchain_name*: The name of the blockchain from the caller to be swapped.
/// *m_opponent_blockchain_name*: The name of the blockchain to look up from the opponent to be
/// swapped.
/// *m_value*: Value of the card itself, in case we want to give it as eth.
/// *m_index*: The card index from all of its duplicates in the deck.
#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
struct ActionChainReorg {
    m_self_blockchain_name: ByteArray,
    m_opponent_blockchain_name: ByteArray,
    m_value: u8,
    m_index: u8
}

/// All other players pay you 2 ETH.
///
/// Fields:
/// *m_value*: Value of the card itself, in case we want to give it as eth.
/// *m_index*: The card index from all of its duplicates in the deck.
#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
struct ActionClaimYield {
    m_value: u8,
    m_index: u8
}

/// All other players pay you 5 ETH.
///
/// Fields:
/// *m_value*: Value of the card itself, in case we want to give it as eth.
/// *m_index*: The card index from all of its duplicates in the deck.
#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
struct ActionSandwichAttack {
    m_value: u8,
    m_index: u8
}

/// Card that allows a player to steal a blockchain from another player's deck.
///
/// Fields:
/// *m_blockchain_name*: Name of the card to be stolen.
/// *m_value*: Value of the card itself, in case we want to give it as eth.
/// *m_index*: The card index from all of its duplicates in the deck.
#[derive(Drop, Serde, Clone, Introspect, Debug)]
struct ActionFrontrun {
    m_blockchain_name: ByteArray,
    m_value: u8,
    m_index: u8
}

/// One player pays a gas fee for each blockchain you own in a selected color.
/// OR
/// Every player pays a gas fee for each blockchain you own in either color.
///
/// Fields:
/// *m_players_affected*: Enum indicating who is the target(s) of this action (owing).
/// *m_blockchain_type_affected*: Enum Specifying what type of gas fee this action is.
///   If the action is targeted at everyone, one of two colors can be used.
///   If the action targets only one opponent, only one color can be used.
/// *m_count*: How the fee will be calculated depnding on how many cards of the same color.
/// *m_value*: Value of the card itself, in case we want to give it as eth.
/// *m_index*: The card index from all of its duplicates in the deck.
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

/// Steal an asset group from an opponent.
///
/// Fields:
/// *m_full_set*: A array of blockchain names, pointing to which blockchains should this apply for.
/// *m_value*: Value of the card itself, in case we want to give it as eth.
/// *m_index*: The card index from all of its duplicates in the deck.
#[derive(Drop, Serde, Clone, Introspect, Debug)]
struct ActionFiftyOnePercentAttack {
    m_owner: ContractAddress,
    m_set: Array<ByteArray>,
    m_value: u8,
    m_index: u8
}

/// Card that allows a player to draw two additional cards, and make it only count as one move.
///
/// Fields:
/// *m_value*: Value of the card itself, in case we want to give it as eth.
/// *m_index*: The card index from all of its duplicates in the deck.
#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
struct ActionPriorityFee {
    m_value: u8,
    m_index: u8
}

/// Played before Gas Fee card, doubles amount of ETH paid to player.
///
/// Fields:
/// *m_value*: Value of the card itself, in case we want to give it as eth.
/// *m_index*: The card index from all of its duplicates in the deck.
#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
struct ActionReplayAttack {
    m_value: u8,
    m_index: u8
}

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
    m_bc_type: EnumBlockchainType,
    m_fee: u8,
    m_value: u8
}
