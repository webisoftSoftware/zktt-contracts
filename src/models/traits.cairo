////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

use starknet::ContractAddress;
use core::fmt::{Display, Formatter, Error};
use origami_random::deck::{Deck, DeckTrait};
use zktt::models::structs::{
    StructAsset, StructBlockchain, StructAssetGroup, StructHybridBlockchain
};
use zktt::models::actions::{
    ActionChainReorg, ActionClaimYield, ActionFrontrun, ActionPriorityFee,
    ActionReplayAttack, ActionGasFee, ActionFiftyOnePercentAttack, ActionSandwichAttack,
    ActionHardFork, ActionMEVBoost, ActionSoftFork
};
use zktt::models::enums::{
    EnumCard, EnumColor, EnumGasFeeType, EnumMoveError, EnumPlayerTarget, EnumHardForkErrors
};
use zktt::models::components::{
    ComponentDealer, ComponentCard, ComponentDeck, ComponentPlayer, ComponentHand, ComponentGame,
    ComponentDeposit
};


///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////
/////////////////////////////// PARTIALEQ /////////////////////////////////
///////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////

impl ActionFrontrunEq of PartialEq<ActionFrontrun> {
    fn eq(lhs: @ActionFrontrun, rhs: @ActionFrontrun) -> bool {
        return true;
    }
}

impl ActionGasFeeEq of PartialEq<ActionGasFee> {
    fn eq(lhs: @ActionGasFee, rhs: @ActionGasFee) -> bool {
        return true;
    }
}

impl ActionHardForkEq of PartialEq<ActionHardFork> {
    fn eq(lhs: @ActionHardFork, rhs: @ActionHardFork) -> bool {
        return lhs.m_owner == rhs.m_owner;
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

impl ActionMEVBoostEq of PartialEq<ActionMEVBoost> {
    fn eq(lhs: @ActionMEVBoost, rhs: @ActionMEVBoost) -> bool {
        return true;
    }
}

impl ActionPriorityFeeEq of PartialEq<ActionPriorityFee> {
    fn eq(lhs: @ActionPriorityFee, rhs: @ActionPriorityFee) -> bool {
        return true;
    }
}

impl ActionReplayAttackEq of PartialEq<ActionReplayAttack> {
    fn eq(lhs: @ActionReplayAttack, rhs: @ActionReplayAttack) -> bool {
        return lhs.m_owner == rhs.m_owner && lhs.m_value == rhs.m_value;
    }
}

impl ActionSoftForkEq of PartialEq<ActionSoftFork> {
    fn eq(lhs: @ActionSoftFork, rhs: @ActionSoftFork) -> bool {
        return true;
    }
}

impl EnumCardEq of PartialEq<EnumCard> {
    fn eq(lhs: @EnumCard, rhs: @EnumCard) -> bool {
        return match (lhs, rhs) {
            (EnumCard::Asset(data1), EnumCard::Asset(data2)) => data1 == data2,
            (EnumCard::Blockchain(data1), EnumCard::Blockchain(data2)) => data1 == data2,
            (EnumCard::ChainReorg(data1), EnumCard::ChainReorg(data2)) => data1 == data2,
            (EnumCard::ClaimYield(data1), EnumCard::ClaimYield(data2)) => data1 == data2,
            (EnumCard::FiftyOnePercentAttack(data1), EnumCard::FiftyOnePercentAttack(data2)) => data1 == data2,
            (EnumCard::FrontRun(data1), EnumCard::FrontRun(data2)) => data1 == data2,
            (EnumCard::GasFee(data1), EnumCard::GasFee(data2)) => data1 == data2,
            (EnumCard::HardFork(data1), EnumCard::HardFork(data2)) => data1 == data2,
            (EnumCard::HybridBlockchain(data1), EnumCard::HybridBlockchain(data2)) => data1 == data2,
            (EnumCard::MEVBoost(data1), EnumCard::MEVBoost(data2)) => data1 == data2,
            (EnumCard::PriorityFee(data1), EnumCard::PriorityFee(data2)) => data1 == data2,
            (EnumCard::ReplayAttack(data1), EnumCard::ReplayAttack(data2)) => data1 == data2,
            (EnumCard::SandwichAttack(data1), EnumCard::SandwichAttack(data2)) => data1 == data2,
            (EnumCard::SoftFork(data1), EnumCard::SoftFork(data2)) => data1 == data2,
            _ => false
        };
    }
}

impl HandPartialEq of PartialEq<ComponentHand> {
    fn eq(lhs: @ComponentHand, rhs: @ComponentHand) -> bool {
        let mut index: usize = 0;
        if lhs.m_cards.len() != rhs.m_cards.len() {
            return false;
        }

        return loop {
            if index >= lhs.m_cards.len() {
                break true;
            }

            if lhs.m_cards.at(index) != rhs.m_cards.at(index) {
                break false;
            }
            index += 1;
        };
    }
}

impl StructAssetEq of PartialEq<StructAsset> {
    fn eq(lhs: @StructAsset, rhs: @StructAsset) -> bool {
        return lhs.m_name == rhs.m_name;
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

impl StructHybridBlockchainEq of PartialEq<StructHybridBlockchain> {
    fn eq(lhs: @StructHybridBlockchain, rhs: @StructHybridBlockchain) -> bool {
        return lhs.m_bcs[0] == rhs.m_bcs[0] && lhs.m_bcs[1] == rhs.m_bcs[1];
    }
}

/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////// DISPLAY /////////////////////////////////
/////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////

impl ActionChainReorgDisplay of Display<ActionChainReorg> {
    fn fmt(self: @ActionChainReorg, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Chain Reorg: Value {0}, Index {1}", *self.m_value, *self.m_index
        );
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ActionClaimYieldDisplay of Display<ActionClaimYield> {
    fn fmt(self: @ActionClaimYield, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Claim Yield: Value {0}, Index {1}", *self.m_value, *self.m_index
        );
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ActionFiftyOnePercentAttackDisplay of Display<ActionFiftyOnePercentAttack> {
    fn fmt(self: @ActionFiftyOnePercentAttack, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Steal Asset Group: Value {0}, Index: {1}", *self.m_value, *self.m_index
        );
        f.buffer.append(@str);
        
        let mut index = 0;
        while index < self.m_set.len() {
            if let Option::Some(bc) = self.m_set.get(index) {
                let str: ByteArray = format!("\nBlockchain: {0}", bc.unbox());
                f.buffer.append(@str);
            }
        };

        return Result::Ok(());
    }
}

impl ActionFrontrunDisplay of Display<ActionFrontrun> {
    fn fmt(self: @ActionFrontrun, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Steal Blockchain: Blockchain: {0}, Value {1}, Index: {2}",
            self.m_blockchain_name,
            *self.m_value,
            *self.m_index
        );
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ActionGasFeeDisplay of Display<ActionGasFee> {
    fn fmt(self: @ActionGasFee, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Gas Fee: Targeted Blockchain: {0}, Value {1}, Index {2}",
            self.m_blockchain_type_affected,
            *self.m_value,
            *self.m_index
        );
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ActionHardForkDisplay of Display<ActionHardFork> {
    fn fmt(self: @ActionHardFork, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Hardfork: Last used: {0}, Value: {1}, Index: {2}",
            self.m_timestamp_used,
            *self.m_value,
            *self.m_index
        );
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ActionMEVBoostDisplay of Display<ActionMEVBoost> {
    fn fmt(self: @ActionMEVBoost, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Add [3] ETH onto asset group: Value: {0}, Index: {1}", *self.m_value, *self.m_index
        );
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ActionPriorityFeeDisplay of Display<ActionPriorityFee> {
    fn fmt(self: @ActionPriorityFee, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Draw Two Cards: Value {0}, Index {1}", *self.m_value, *self.m_index
        );
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ActionReplayAttackDisplay of Display<ActionReplayAttack> {
    fn fmt(self: @ActionReplayAttack, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Replay Attack: Value {0}, Index {1}", *self.m_value, *self.m_index
        );
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ActionSandwichAttackDisplay of Display<ActionSandwichAttack> {
    fn fmt(self: @ActionSandwichAttack, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Force any player to give you 5 ETH: Value: {0}, Index: {1}", *self.m_value, *self.m_index
        );
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ActionSoftForkDisplay of Display<ActionSoftFork> {
    fn fmt(self: @ActionSoftFork, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Add [4] ETH onto asset group: Value: {0}, Index: {1}", *self.m_value, *self.m_index
        );
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ComponentDealerDisplay of Display<ComponentDealer> {
    fn fmt(self: @ComponentDealer, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Dealer {0}:\n\tCards:", starknet::contract_address_to_felt252(*self.m_ent_owner)
        );
        f.buffer.append(@str);

        let mut index: usize = 0;
        while index < self.m_cards.len() {
            let str: ByteArray = format!("\n\t\t{0}", self.m_cards.at(index));
            f.buffer.append(@str);
            index += 1;
        };
        return Result::Ok(());
    }
}

impl ComponentDeckDisplay of Display<ComponentDeck> {
    fn fmt(self: @ComponentDeck, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "{0}'s Deck:", starknet::contract_address_to_felt252(*self.m_ent_owner)
        );
        f.buffer.append(@str);

        let mut index: usize = 0;
        while index < self.m_cards.len() {
            let str: ByteArray = format!("\n\t\t{0}", self.m_cards.at(index));
            f.buffer.append(@str);
            index += 1;
        };
        let str: ByteArray = format!("\n\tSets: {0}", self.m_sets);
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ComponentHandDisplay of Display<ComponentHand> {
    fn fmt(self: @ComponentHand, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "{0}'s Hand:", starknet::contract_address_to_felt252(*self.m_ent_owner)
        );
        f.buffer.append(@str);

        let mut index: usize = 0;
        while index < self.m_cards.len() {
            let str: ByteArray = format!("\n\t\t{0}", self.m_cards.at(index));
            f.buffer.append(@str);
            index += 1;
        };

        return Result::Ok(());
    }
}

impl ComponentPlayerDisplay of Display<ComponentPlayer> {
    fn fmt(self: @ComponentPlayer, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Owner: {0}, Player: {1}, Moves remaining: {2}, Score: {3}",
            starknet::contract_address_to_felt252(*self.m_ent_owner),
            self.m_username,
            *self.m_moves_remaining,
            *self.m_score
        );
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl EnumCardDisplay of Display<EnumCard> {
    fn fmt(self: @EnumCard, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumCard::Asset(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            },
            EnumCard::Blockchain(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            },
            EnumCard::ChainReorg(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            },
            EnumCard::ClaimYield(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            },
            EnumCard::FiftyOnePercentAttack(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            },
            EnumCard::FrontRun(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            },
            EnumCard::GasFee(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            },
            EnumCard::HardFork(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            },
            EnumCard::HybridBlockchain(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            },
            EnumCard::MEVBoost(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            },
            EnumCard::PriorityFee(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            },
            EnumCard::ReplayAttack(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            },
            EnumCard::SandwichAttack(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            },
            EnumCard::SoftFork(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            }
        };
        return Result::Ok(());
    }
}

impl EnumColorDisplay of Display<EnumColor> {
    fn fmt(self: @EnumColor, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumColor::Immutable(_) => {
                let str: ByteArray = format!("Immutable");
                f.buffer.append(@str);
            },
            EnumColor::Blue(_) => {
                let str: ByteArray = format!("Blue");
                f.buffer.append(@str);
            },
            EnumColor::DarkBlue(_) => {
                let str: ByteArray = format!("Dark Blue");
                f.buffer.append(@str);
            },
            EnumColor::Gold(_) => {
                let str: ByteArray = format!("Gold");
                f.buffer.append(@str);
            },
            EnumColor::Green(_) => {
                let str: ByteArray = format!("Green");
                f.buffer.append(@str);
            },
            EnumColor::Grey(_) => {
                let str: ByteArray = format!("Grey");
                f.buffer.append(@str);
            },
            EnumColor::LightBlue(_) => {
                let str: ByteArray = format!("Light Blue");
                f.buffer.append(@str);
            },
            EnumColor::Pink(_) => {
                let str: ByteArray = format!("Pink");
                f.buffer.append(@str);
            },
            EnumColor::Purple(_) => {
                let str: ByteArray = format!("Purple");
                f.buffer.append(@str);
            },
            EnumColor::Red(_) => {
                let str: ByteArray = format!("Red");
                f.buffer.append(@str);
            },
            EnumColor::Yellow(_) => {
                let str: ByteArray = format!("Yellow");
                f.buffer.append(@str);
            },
        };
        return Result::Ok(());
    }
}

impl EnumGasFeeTypeDisplay of Display<EnumGasFeeType> {
    fn fmt(self: @EnumGasFeeType, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumGasFeeType::Any(_) => {
                let str: ByteArray = format!("Against Any Color");
                f.buffer.append(@str);
            },
            EnumGasFeeType::AgainstTwo((
                color1, color2
            )) => {
                let str: ByteArray = format!("Against Two: {0}, {1}", color1, color2);
                f.buffer.append(@str);
            }
        };

        return Result::Ok(());
    }
}

impl EnumMoveErrorDisplay of Display<EnumMoveError> {
    fn fmt(self: @EnumMoveError, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumMoveError::CardAlreadyPresent(_) => {
                let str: ByteArray = format!("Card Already Present!");
                f.buffer.append(@str);
            },
            EnumMoveError::CardNotFound(_) => {
                let str: ByteArray = format!("Card Not found!");
                f.buffer.append(@str);
            },
            EnumMoveError::NotEnoughMoves(_) => {
                let str: ByteArray = format!("Not Enough Moves to Proceed!");
                f.buffer.append(@str);
            },
            EnumMoveError::SetAlreadyPresent(_) => {
                let str: ByteArray = format!("asset Group Already Present!");
                f.buffer.append(@str);
            }
        };
        return Result::Ok(());
    }
}

impl StructAssetDisplay of Display<StructAsset> {
    fn fmt(self: @StructAsset, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Asset: {0}, Value: {1}, Index: {2}", self.m_name, *self.m_value, *self.m_index
        );
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl StructBlockchainDisplay of Display<StructBlockchain> {
    fn fmt(self: @StructBlockchain, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Blockchain: {0}, Type: {1}, Fee: {2}, Value {3}",
            self.m_name,
            self.m_bc_type,
            *self.m_fee,
            *self.m_value
        );
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl StructHybridBlockchainDisplay of Display<StructHybridBlockchain> {
    fn fmt(self: @StructHybridBlockchain, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!(
            "Hybrid Blockchain: {0}, Facing Up: {1}",
            self.m_name,
            self.m_bc_facing_up_index
        );
        f.buffer.append(@str);
        return Result::Ok(());
    }
}


////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/////////////////////////////// INTO ///////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

impl EnumCardInto of Into<@EnumCard, ByteArray> {
    fn into(self: @EnumCard) -> ByteArray {
        return match self {
            EnumCard::Asset(asset_struct) => format!("{0}", asset_struct.m_name),
            EnumCard::Blockchain(bc_struct) => format!("{0}", bc_struct.m_name),
            EnumCard::ChainReorg(_) => "Chain Reorg",
            EnumCard::ClaimYield(_) => "Claim Yield",
            EnumCard::GasFee(_) => "Gas Fee",
            EnumCard::HardFork(_) => "HardFork",
            EnumCard::HybridBlockchain(hybrid_bc_struct) => format!("{0}", hybrid_bc_struct.m_name),
            EnumCard::MEVBoost(_) => "MEV Boost",
            EnumCard::PriorityFee(_) => "Priority Fee",
            EnumCard::ReplayAttack(_) => "Replay Attack",
            EnumCard::SoftFork(_) => "Soft Fork",
            EnumCard::FrontRun(_) => "Frontrun",
            EnumCard::FiftyOnePercentAttack(_) => "51% Attack",
            EnumCard::SandwichAttack(_) => "Sandwich Attack"
        };
    }
}


////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/////////////////////////////// IMPLS //////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

#[generate_trait]
impl AssetImpl of IAsset {
    fn new(name: ByteArray, value: u8, copies_left: u8) -> StructAsset nopanic {
        return StructAsset { m_name: name, m_value: value, m_index: copies_left };
    }
}

#[generate_trait]
impl AssetGroupImpl of IAssetGroup {
    fn new(blockchains: Array<StructBlockchain>, total_fee_value: u8) -> StructAssetGroup nopanic {
        return StructAssetGroup { m_set: blockchains, m_total_fee_value: total_fee_value };
    }
}

#[generate_trait]
impl BlockchainImpl of IBlockchain {
    fn new(
        name: ByteArray, bc_type: EnumColor, fee: u8, value: u8
    ) -> StructBlockchain nopanic {
        return StructBlockchain { m_name: name, m_bc_type: bc_type, m_fee: fee, m_value: value };
    }
}

#[generate_trait]
impl ChainReorgImpl of IChainReorg {
    fn new(
        self_blockchain_name: ByteArray,
        opponent_blockchain_name: ByteArray,
        opponent_address: ContractAddress,
        value: u8,
        copies_left: u8
    ) -> ActionChainReorg nopanic {
        return ActionChainReorg {
            m_self_blockchain_name: self_blockchain_name,
            m_opponent_blockchain_name: opponent_blockchain_name,
            m_opponent_address: opponent_address,
            m_value: value,
            m_index: copies_left
        };
    }
}

#[generate_trait]
impl ClaimYieldImpl of IClaimYield {
    fn new(value: u8, copies_left: u8) -> ActionClaimYield nopanic {
        return ActionClaimYield { m_value: value, m_index: copies_left };
    }
}

#[generate_trait]
impl ComponentCardImpl of ICard {
    fn new(index: u32, card: EnumCard) -> ComponentCard nopanic {
        return ComponentCard { m_ent_index: index, m_card_info: card };
    }
}

#[generate_trait]
impl DealerImpl of IDealer {
    fn new(owner: ContractAddress, cards: Array<u32>) -> ComponentDealer nopanic {
        return ComponentDealer { m_ent_owner: owner, m_cards: cards };
    }

    fn shuffle(ref self: ComponentDealer, seed: felt252) -> () {
        let mut shuffled_cards: Array<u32> = ArrayTrait::new();
        let mut deck = DeckTrait::new(seed, self.m_cards.len());

        while deck.remaining > 0 {
            // Draw a random number from 0 to 105.
            let card_index: u8 = deck.draw();

            if let Option::Some(_) = self.m_cards.get(card_index.into()) {
                shuffled_cards.append(self.m_cards[card_index.into()].clone());
                
            }
        };
        self.m_cards = shuffled_cards;
    }

    fn pop_card(ref self: ComponentDealer) -> Option<u32> {
        if self.m_cards.is_empty() {
            return Option::None;
        }

        return self.m_cards.pop_front();
    }
}

#[generate_trait]
impl DeckImpl of IDeck {
    fn add(ref self: ComponentDeck, mut bc: EnumCard) -> () {
        if let Option::Some(_) = self.contains(@bc.get_name()) {
            panic!("{0}", EnumMoveError::CardAlreadyPresent);
        }

        // Add the card first
        self.m_cards.append(bc.clone());

        // Check for completed sets only if it's a blockchain card
        match bc {
            EnumCard::Blockchain(bc_struct) => {
                // Get all matching blockchains including the newly added one
                let mut matching_bcs = ArrayTrait::new();
                let mut index = 0;

                while index < self.m_cards.len() {
                    if let Option::Some(card) = self.m_cards.get(index) {
                        match card.unbox() {
                            EnumCard::Blockchain(other_bc) => {
                                if other_bc.m_bc_type == @bc_struct.m_bc_type {
                                    matching_bcs.append(other_bc.clone());
                                }
                            },
                            _ => {}
                        }
                    }
                    index += 1;
                };

                // Check if we have a complete set
                if self.check_complete_set(matching_bcs, @bc_struct.m_bc_type) {
                    self.m_sets += 1;
                }
            },
            _ => {}
        }
    }

    fn contains(self: @ComponentDeck, bc_name: @ByteArray) -> Option<usize> {
        let mut index = 0;
        let mut found = Option::None;

        while index < self.m_cards.len() {
            if let Option::Some(bc_found) = self.m_cards.get(index) {
                let bc_found = bc_found.unbox();
                if bc_name == @bc_found.get_name() {
                    found = Option::Some(index);
                    break;
                }
            }
            index += 1;
        };
        return found;
    }

    fn contains_type(self: @ComponentDeck, bc_type: @EnumColor) -> Option<usize> {
        let mut index = 0;
        let mut found = Option::None;

        while let Option::Some(card) = self.m_cards.get(index) {
            match card.unbox() {
                EnumCard::Blockchain(bc_struct) => {
                    if bc_type == bc_struct.m_bc_type {
                        found = Option::Some(index);
                        break;
                    }
                },
                _ => {}
            };
            index += 1;
        };
        return found;
    }

    fn remove(ref self: ComponentDeck, card_name: @ByteArray) -> () {
        if let Option::Some(index_found) = self.contains(card_name) {
            // Check if this card is part of a complete set before removing it
            let card_to_remove = self.m_cards.at(index_found);
            let mut was_part_of_set = false;

            // Only check sets if it's a blockchain card
            match card_to_remove {
                EnumCard::Blockchain(bc_struct) => {
                    // Get all matching blockchains before removal
                    let mut matching_bcs = ArrayTrait::new();
                    let mut index = 0;

                    while index < self.m_cards.len() {
                        if let Option::Some(card) = self.m_cards.get(index) {
                            match card.unbox() {
                                EnumCard::Blockchain(other_bc) => {
                                    if other_bc.m_bc_type == bc_struct.m_bc_type {
                                        matching_bcs.append(other_bc.clone());
                                    }
                                },
                                _ => {}
                            }
                        }
                        index += 1;
                    };

                    // Check if these cards formed a complete set
                    was_part_of_set = self.check_complete_set(matching_bcs, bc_struct.m_bc_type);
                },
                _ => {}
            };

            // Remove the card
            let mut new_array = ArrayTrait::new();
            let mut index = 0;
            while let Option::Some(card) = self.m_cards.pop_front() {
                if index == index_found {
                    index += 1;
                    continue;
                }
                new_array.append(card);
                index += 1;
            };
            self.m_cards = new_array;

            // If card was part of a complete set, decrement the set counter
            if was_part_of_set {
                self.m_sets -= 1;
            }
        }
    }

    fn get_asset_group_for(
        self: @ComponentDeck, bc: @StructBlockchain
    ) -> Option<Array<StructBlockchain>> {
        let mut index: usize = 0;
        let mut asset_group_array: Array<StructBlockchain> = ArrayTrait::new();
        let mut asset_group: Option<Array<StructBlockchain>> = Option::None;
        let mut total_fee: u8 = 0;

        while let Option::Some(card) = self.m_cards.get(index) {
            match card.unbox() {
                EnumCard::Blockchain(bc_struct) => {
                    if bc_struct.m_bc_type == bc.m_bc_type {
                        total_fee += *bc.m_fee;
                        asset_group_array.append(bc.clone());
                    }
                },
                _ => {}
            };

            index += 1;
        };

        if self.check_complete_set(asset_group_array.clone(), bc.m_bc_type) {
            asset_group = Option::Some(asset_group_array);
        }
        return asset_group;
    }

    fn check_complete_set(
        self: @ComponentDeck,
        asset_group_array: Array<StructBlockchain>,
        bc_type: @EnumColor
    ) -> bool {
        let required_count = match bc_type {
            EnumColor::Blue(_) | EnumColor::DarkBlue(_) |
            EnumColor::Gold(_) => 2,
            EnumColor::LightBlue(_) => 4,
            _ => 3
        };

        return asset_group_array.len() == required_count;
    }
}

#[generate_trait]
impl DepositImpl of IDeposit {
    fn new(owner: ContractAddress, cards: Array<EnumCard>, value: u8) -> ComponentDeposit {
        return ComponentDeposit { m_ent_owner: owner, m_cards: cards, m_total_value: value };
    }

    fn add(ref self: ComponentDeposit, mut card: EnumCard) -> () {
        assert!(!card.is_blockchain(), "Blockchains cannot be added to money pile");
        self.m_total_value += card.get_value();
        self.m_cards.append(card);
        return ();
    }

    fn contains(self: @ComponentDeposit, card_name: @ByteArray) -> Option<usize> {
        let mut index: usize = 0;

        return loop {
            if index >= self.m_cards.len() {
                break Option::None;
            }

            if @self.m_cards.at(index).get_name() == card_name {
                break Option::Some(index);
            }

            index += 1;
        };
    }

    fn remove(ref self: ComponentDeposit, card_name: @ByteArray) -> () {
        if let Option::Some(index_found) = self.contains(card_name) {
            if self.m_total_value < self.m_cards.at(index_found).get_value() {
                self.m_total_value = 0;
            } else {
                self.m_total_value -= self.m_cards.at(index_found).get_value();
            }
            let mut new_array: Array<EnumCard> = ArrayTrait::new();
            let mut index: usize = 0;
            while let Option::Some(card) = self.m_cards.pop_front() {
                if index == index_found {
                    index += 1;
                    continue;
                }

                new_array.append(card);
                index += 1;
            };
            self.m_cards = new_array;
        }
        return ();
    }
}

#[generate_trait]
impl EnumColorImpl of IEnumColor {
    fn get_boost_array(self: @EnumColor) -> Array<u8> {
        return match self {
            EnumColor::Immutable => { return array![]; },
            EnumColor::Blue => { return array![1, 2]; },
            EnumColor::DarkBlue => { return array![3, 8]; },
            EnumColor::Gold => { return array![1, 2]; },
            EnumColor::Green => { return array![1, 3, 5]; },
            EnumColor::Grey => { return array![1, 2, 4]; },
            EnumColor::LightBlue => { return array![1, 2, 3, 4]; },
            EnumColor::Pink => { return array![1, 2, 3]; },
            EnumColor::Purple => { return array![2, 4, 6]; },
            EnumColor::Red => { return array![2, 4, 7]; },
            EnumColor::Yellow => { return array![2, 3, 6]; },
        };
    }
}

#[generate_trait]
impl EnumCardImpl of IEnumCard {
    fn get_index(self: @EnumCard) -> u8 {
        return match self {
            EnumCard::Asset(data) => { return *data.m_index; },
            EnumCard::ChainReorg(data) => { return *data.m_index; },
            EnumCard::ClaimYield(data) => { return *data.m_index; },
            EnumCard::FrontRun(data) => { return *data.m_index; },
            EnumCard::GasFee(data) => { return *data.m_index; },
            EnumCard::HardFork(data) => { return *data.m_index; },
            EnumCard::MEVBoost(data) => { return *data.m_index; },
            EnumCard::PriorityFee(data) => { return *data.m_index; },
            EnumCard::ReplayAttack(data) => { return *data.m_index; },
            EnumCard::SandwichAttack(data) => { return *data.m_index; },
            EnumCard::SoftFork(data) => { return *data.m_index; },
            _ => { return 1; },
        };
    }

    fn get_name(self: @EnumCard) -> ByteArray {
        return self.into();
    }

    fn get_value(self: @EnumCard) -> u8 {
        return match self {
            EnumCard::Asset(data) => { return *data.m_value; },
            EnumCard::Blockchain(data) => { return *data.m_value; },
            EnumCard::ChainReorg(data) => { return *data.m_value; },
            EnumCard::ClaimYield(data) => { return *data.m_value; },
            EnumCard::FiftyOnePercentAttack(data) => { return *data.m_value; },
            EnumCard::FrontRun(data) => { return *data.m_value; },
            EnumCard::GasFee(data) => { return *data.m_value; },
            EnumCard::HardFork(data) => { return *data.m_value; },
            EnumCard::HybridBlockchain(data) => { return *data.m_bcs[(*data.m_bc_facing_up_index).into()].m_value; },
            EnumCard::MEVBoost(data) => { return *data.m_value; },
            EnumCard::PriorityFee(data) => { return *data.m_value; },
            EnumCard::ReplayAttack(data) => { return *data.m_value; },
            EnumCard::SandwichAttack(data) => { return *data.m_value; },
            EnumCard::SoftFork(data) => { return *data.m_value; },
        };
    }

    fn remove_one_index(ref self: EnumCard) -> () {
        assert!(self.get_index() > 0, "No more indices left for {0}", self);
        
        let new_card: EnumCard = match self.clone() {
            EnumCard::Asset(mut data) => {
                data.m_index -= 1;
                EnumCard::Asset(data)
            },
            EnumCard::ChainReorg(mut data) => {
                data.m_index -= 1;
                EnumCard::ChainReorg(data)
            },
            EnumCard::ClaimYield(mut data) => {
                data.m_index -= 1;
                EnumCard::ClaimYield(data)
            },
            EnumCard::FiftyOnePercentAttack(mut data) => {
                data.m_index -= 1;
                EnumCard::FiftyOnePercentAttack(data)
            },
            EnumCard::FrontRun(mut data) => {
                data.m_index -= 1;
                EnumCard::FrontRun(data)
            },
            EnumCard::GasFee(mut data) => {
                data.m_index -= 1;
                EnumCard::GasFee(data)
            },
            EnumCard::HardFork(mut data) => {
                data.m_index -= 1;
                EnumCard::HardFork(data)
            },
            EnumCard::MEVBoost(mut data) => {
                data.m_index -= 1;
                EnumCard::MEVBoost(data)
            },
            EnumCard::PriorityFee(mut data) => {
                data.m_index -= 1;
                EnumCard::PriorityFee(data)
            },
            EnumCard::ReplayAttack(mut data) => {
                data.m_index -= 1;
                EnumCard::ReplayAttack(data)
            },
            EnumCard::SoftFork(mut data) => {
                data.m_index -= 1;
                EnumCard::SoftFork(data)
            },
            EnumCard::SandwichAttack(mut data) => {
                data.m_index -= 1;
                EnumCard::SandwichAttack(data)
            },
            _ => { self.clone() }
        };
        self = new_card;
    }

    fn is_asset(self: @EnumCard) -> bool {
        return match self {
            EnumCard::Asset(_) => true,
            _ => false
        };
    }

    fn is_blockchain(self: @EnumCard) -> bool {
        return match self {
            EnumCard::Blockchain(_) => true,
            EnumCard::HybridBlockchain(_) => true,
            _ => false
        };
    }
}

#[generate_trait]
impl FiftyOnePercentAttackImpl of IFiftyOnePercentAttack {
    fn new(player_targeted: ContractAddress, set: Array<StructBlockchain>, value: u8, copies_left: u8
    ) -> ActionFiftyOnePercentAttack nopanic {
        return ActionFiftyOnePercentAttack {
            m_player_targeted: player_targeted,
            m_set: set,
            m_value: value,
            m_index: copies_left
        };
    }
}

#[generate_trait]
impl FrontRunImpl of IFrontRun {
    fn new(player_targeted: ContractAddress, blockchain_name: ByteArray, value: u8, copies_left: u8) -> ActionFrontrun nopanic {
        return ActionFrontrun {
            m_player_targeted: player_targeted,
            m_blockchain_name: blockchain_name,
            m_value: value,
            m_index: copies_left
        };
    }
}

#[generate_trait]
impl GameImpl of IGame {
    fn add_player(ref self: ComponentGame, mut new_player: ContractAddress) -> () {
        assert!(self.contains_player(@new_player).is_none(), "Player already exists");
        self.m_players.append(new_player);
        return ();
    }

    fn contains_player(self: @ComponentGame, player: @ContractAddress) -> Option<usize> {
        let mut index = 0;
        let mut found = Option::None;

        while index < self.m_players.len() {
            if let Option::Some(player_found) = self.m_players.get(index) {
                if player == player_found.unbox() {
                    found = Option::Some(index);
                    break;
                }
            }
            index += 1;
        };
        return found;
    }

    fn remove_player(ref self: ComponentGame, player: @ContractAddress) -> () {
        if let Option::Some(index_found) = self.contains_player(player) {
            let mut new_array = ArrayTrait::new();

            let mut index = 0;
            while let Option::Some(player) = self.m_players.pop_front() {
                if index == index_found {
                    index += 1;
                    continue;
                }

                new_array.append(player);
                index += 1;
            };
            self.m_players = new_array;
        }
    }

    fn assign_next_turn(ref self: ComponentGame, is_start: bool) -> () {
        if is_start {
            assert!(!self.m_players.is_empty(), "No players in game");
            self.m_player_in_turn = *self.m_players.at(0);
            return;
        }

        if let Option::Some(position) = self.contains_player(@self.m_player_in_turn) {
            if position + 1 == self.m_players.len() {
                self.m_player_in_turn = *self.m_players.at(0);
                return;
            }
            assert!(self.m_players.get(position + 1).is_some(), "Player not found");
            self.m_player_in_turn = *self.m_players.at(position + 1);
        }
    }
}

#[generate_trait]
impl GasFeeImpl of IGasFee {
    fn new(
        players_affected: EnumPlayerTarget,
        bc_affected: EnumGasFeeType,
        set_applied: Array<StructBlockchain>,
        value: u8,
        copies_left: u8
    ) -> ActionGasFee nopanic {
        return ActionGasFee {
            m_owner: starknet::contract_address_const::<0x0>(),
            m_players_affected: players_affected,
            m_set_applied: set_applied,
            m_blockchain_type_affected: bc_affected,
            m_value: value,
            m_index: copies_left
        };
    }

    fn get_fee(self: @ActionGasFee) -> u8 {
        return *self.m_set_applied.at(0).m_bc_type.get_boost_array().at(self.m_set_applied.len());
    }
}


#[generate_trait]
impl HandImpl of IHand {
    fn new(owner: ContractAddress, cards: Array<EnumCard>) -> ComponentHand {
        return ComponentHand { m_ent_owner: owner, m_cards: cards };
    }

    fn add(ref self: ComponentHand, mut card: EnumCard) -> () {
        if self.m_cards.len() == 9 {
            return panic!("Too many cards held");
        }

        self.m_cards.append(card);
    }

    fn contains(self: @ComponentHand, card_name: @ByteArray) -> Option<usize> {
        let mut index: usize = 0;

        return loop {
            if index >= self.m_cards.len() {
                break Option::None;
            }

            if @self.m_cards.at(index).get_name() == card_name {
                break Option::Some(index);
            }
            index += 1;
        };
    }

    fn remove(ref self: ComponentHand, card_name: @ByteArray) -> () {
        if let Option::Some(index_found) = self.contains(card_name) {
            let mut index: usize = 0;
            let mut new_array: Array<EnumCard> = ArrayTrait::new();
            while let Option::Some(card) = self.m_cards.pop_front() {
                if index == index_found {
                    index += 1;
                    continue;
                }
                new_array.append(card);
                index += 1;
            };
            self.m_cards = new_array;
        }
    }
}

#[generate_trait]
impl HardForkImpl of IHardFork {
    fn new(owner: ContractAddress, timestamp_used: u64, value: u8, copies: u8) -> ActionHardFork nopanic {
        return ActionHardFork {
            m_owner: owner,
            m_timestamp_used: timestamp_used,
            m_value: value,
            m_index: copies
        };
    }

    fn is_cancelable(self: @ActionHardFork, card: @EnumCard) -> bool {
        return match card {
            EnumCard::ClaimYield(_) => true,
            EnumCard::FrontRun(frontrun_struct) => {
                return frontrun_struct.m_player_targeted == self.m_owner;
            },
            EnumCard::GasFee(_) => true,
            EnumCard::HardFork(_) => true,
            EnumCard::SandwichAttack(sandwich_struct) => {
                return sandwich_struct.m_player_targeted == self.m_owner;
            },
            EnumCard::FiftyOnePercentAttack(fifty_percent_attack_struct) => {
                return fifty_percent_attack_struct.m_player_targeted == self.m_owner;
            },
            _ => false
        };
    }
}

#[generate_trait]
impl HybridBlockchainImpl of IHybridBlockchain {
    fn new(
        name: ByteArray, bcs: Array<StructBlockchain>, bc_facing_up_index: u8
    ) -> StructHybridBlockchain nopanic {
        return StructHybridBlockchain { 
            m_name: name, 
            m_bcs: bcs, 
            m_bc_facing_up_index: bc_facing_up_index 
        };
    }
}

#[generate_trait]
impl MEVBoostImpl of IMEVBoost {
    fn new(set: StructAssetGroup, value: u8, copies_left: u8) -> ActionMEVBoost nopanic {
        return ActionMEVBoost {
            m_set: set,
            m_value: value,
            m_index: copies_left
        };
    }
}

#[generate_trait]
impl PlayerImpl of IPlayer {
    fn new(owner: ContractAddress, username: ByteArray) -> ComponentPlayer {
        return ComponentPlayer {
            m_ent_owner: owner,
            m_username: username,
            m_moves_remaining: 3,
            m_score: 0,
            m_has_drawn: false,
            m_is_ready: false,
            m_in_debt: Option::None
        };
    }

    fn get_debt(self: @ComponentPlayer) -> Option<u8> {
        return self.m_in_debt.clone();
    }
}

#[generate_trait]
impl PriorityFeeImpl of IPriorityFee {
    fn new(value: u8, copies_left: u8) -> ActionPriorityFee nopanic {
        return ActionPriorityFee { m_value: value, m_index: copies_left };
    }
}

#[generate_trait]
impl ReplayAttackImpl of IReplayAttack {
    fn new(owner: ContractAddress, value: u8, copies: u8) -> ActionReplayAttack nopanic {
        return ActionReplayAttack {
            m_owner: owner,
            m_value: value,
            m_index: copies
        };
    }
}

#[generate_trait]
impl SandwichAttackImpl of ISandwichAttack {
    fn new(player_targeted: ContractAddress, value: u8, copies_left: u8) -> ActionSandwichAttack nopanic {
        return ActionSandwichAttack {
            m_player_targeted: player_targeted,
            m_value: value,
            m_index: copies_left
        };
    }
}

#[generate_trait]
impl SoftForkImpl of ISoftFork {
    fn new(set: StructAssetGroup, value: u8, copies_left: u8) -> ActionSoftFork nopanic {
        return ActionSoftFork {
            m_set: set,
            m_value: value,
            m_index: copies_left
        };
    }
}


////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
/////////////////////////////// DEFAULT ////////////////////////////////
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////

impl ChainReorgDefault of Default<ActionChainReorg> {
    fn default() -> ActionChainReorg nopanic {
        return ActionChainReorg {
            m_self_blockchain_name: "",
            m_opponent_blockchain_name: "",
            m_opponent_address: starknet::contract_address_const::<0x0>(),
            m_value: 3,
            m_index: 3
        };
    }
}

impl ClaimYieldDefault of Default<ActionClaimYield> {
    fn default() -> ActionClaimYield nopanic {
        return ActionClaimYield {
            m_value: 2,
            m_index: 3
        };
    }
}

impl FiftyOnePercentAttackDefault of Default<ActionFiftyOnePercentAttack> {
    fn default() -> ActionFiftyOnePercentAttack nopanic {
        return ActionFiftyOnePercentAttack {
            m_player_targeted: starknet::contract_address_const::<0x0>(),
            m_set: array![],
            m_value: 5,
            m_index: 1
        };
    }
}

impl FrontrunDefault of Default<ActionFrontrun> {
    fn default() -> ActionFrontrun nopanic {
        return ActionFrontrun {
            m_player_targeted: starknet::contract_address_const::<0x0>(),
            m_blockchain_name: "",
            m_value: 3,
            m_index: 3
        };
    }
}

impl HardForkDefault of Default<ActionHardFork> {
    fn default() -> ActionHardFork nopanic {
        return ActionHardFork {
            m_owner: starknet::contract_address_const::<0x0>(),
            m_timestamp_used: 0,
            m_value: 3,
            m_index: 3
        };
    }
}

impl MEVBoostDefault of Default<ActionMEVBoost> {
    fn default() -> ActionMEVBoost nopanic {
        return ActionMEVBoost {
            m_set: StructAssetGroup {
                m_set: array![],
                m_total_fee_value: 0
            },
            m_value: 4,
            m_index: 3
        };
    }
}

impl PriorityFeeDefault of Default<ActionPriorityFee> {
    fn default() -> ActionPriorityFee nopanic {
        return ActionPriorityFee {
            m_value: 1,
            m_index: 10
        };
    }
}

impl ReplayAttackDefault of Default<ActionReplayAttack> {
    fn default() -> ActionReplayAttack nopanic {
        return ActionReplayAttack {
            m_owner: starknet::contract_address_const::<0x0>(),
            m_value: 1,
            m_index: 2
        };
    }
}

impl SandwichAttackDefault of Default<ActionSandwichAttack> {
    fn default() -> ActionSandwichAttack nopanic {
        return ActionSandwichAttack {
            m_player_targeted: starknet::contract_address_const::<0x0>(),
            m_value: 3,
            m_index: 3
        };
    }
}

impl SoftForkDefault of Default<ActionSoftFork> {
    fn default() -> ActionSoftFork nopanic {
        return ActionSoftFork {
            m_set: StructAssetGroup {
                m_set: array![],
                m_total_fee_value: 0
            },
            m_value: 3,
            m_index: 3
        };
    }
}

impl AssetGroupDefault of Default<StructAssetGroup> {
    fn default() -> StructAssetGroup nopanic {
        return StructAssetGroup {
            m_set: array![],
            m_total_fee_value: 0
        };
    }
}

