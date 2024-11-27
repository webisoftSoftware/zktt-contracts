////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////


use starknet::ContractAddress;
use zktt::models::structs::{StructBlockchain, StructAssetGroup};
use zktt::models::enums::{EnumGasFeeType, EnumPlayerTarget};


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
    m_opponent_address: ContractAddress,
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

/// Force any player to pay you 5 ETH.
///
/// Fields:
/// *m_player_targeted*: The player forced to pay.
/// *m_value*: Value of the card itself, in case we want to give it as eth.
/// *m_index*: The card index from all of its duplicates in the deck.
#[derive(Drop, Serde, Clone, Introspect, PartialEq, Debug)]
struct ActionSandwichAttack {
    m_player_targeted: ContractAddress,
    m_value: u8,
    m_index: u8
}

/// Steal an asset group from an opponent.
///
/// Fields:
/// *m_player_targeted*: The player having to give up an asset group.
/// *m_set*: A array of blockchain names, pointing to which blockchains should this apply for.
/// *m_value*: Value of the card itself, in case we want to give it as eth.
/// *m_index*: The card index from all of its duplicates in the deck.
#[derive(Drop, Serde, Clone, Introspect, Debug)]
struct ActionFiftyOnePercentAttack {
    m_player_targeted: ContractAddress,
    m_set: Array<StructBlockchain>,
    m_value: u8,
    m_index: u8
}

/// Card that allows a player to steal a blockchain from another player's deck.
///
/// Fields:
/// *m_player_targeted*: Player having to let go of the blockchain.
/// *m_blockchain_name*: Name of the card to be stolen.
/// *m_value*: Value of the card itself, in case we want to give it as eth.
/// *m_index*: The card index from all of its duplicates in the deck.
#[derive(Drop, Serde, Clone, Introspect, Debug)]
struct ActionFrontrun {
    m_player_targeted: ContractAddress,
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
    m_owner: ContractAddress,
    m_players_affected: EnumPlayerTarget,
    // First blockchain (target one player), second blockchain (Target all players).
    m_blockchain_type_affected: EnumGasFeeType,
    m_set_applied: Array<StructBlockchain>,
    m_value: u8,
    m_index: u8
}

/// Useable within 10 seconds of certain Onchain Events - cancels other players Onchain Event card.
///
/// Fields:
/// *m_owner*: Which player (or dealer) owns this card.
/// *m_timestamp_used: Timestamp in seconds of when the player used this card after the last action
/// played against them. Used to verify that it is within 10 seconds, otherwise penalize the
/// player somehow.
/// *m_value*: Value of the card itself, in case we want to give it as eth.
/// *m_index*: The card index from all of its duplicates in the deck.
#[derive(Drop, Serde, Clone, Introspect, Debug)]
struct ActionHardFork {
    m_owner: ContractAddress,
    m_timestamp_used: u64,
    m_value: u8,
    m_index: u8
}

/// Add onto any full blockchain set owned to add 3 ETH to value.
///
/// Fields:
/// *m_set*: Which set to apply this bonus to.
/// *m_value*: Value of the card itself, in case we want to give it as eth.
/// *m_index*: The card index from all of its duplicates in the deck.
#[derive(Drop, Serde, Clone, Introspect, Debug)]
struct ActionMEVBoost {
    m_set: StructAssetGroup,
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
    m_owner: ContractAddress,
    m_value: u8,
    m_index: u8
}

/// Add onto any full blockchain set owned to add 4 ETH to value.
///
/// Fields:
/// *m_set*: Which set to apply this bonus to.
/// *m_value*: Value of the card itself, in case we want to give it as eth.
/// *m_index*: The card index from all of its duplicates in the deck.
#[derive(Drop, Serde, Clone, Introspect, Debug)]
struct ActionSoftFork {
    m_set: StructAssetGroup,
    m_value: u8,
    m_index: u8
}