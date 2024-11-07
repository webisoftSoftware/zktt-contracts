////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

impl ComponentDeckDisplay of Display<ComponentDeck> {
    fn fmt(self: @ComponentDeck, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("{0}'s Deck:", starknet::contract_address_to_felt252(*self.m_ent_owner));
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

impl ComponentHandDisplay of Display<ComponentHand> {
    fn fmt(self: @ComponentHand, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("{0}'s Hand:", starknet::contract_address_to_felt252(*self.m_ent_owner));
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
        let str: ByteArray = format!("Owner: {0}, Player: {1}, Asset Groups Owned: {2}, Moves remaining: {3}, Score: {4}",
         starknet::contract_address_to_felt252(*self.m_ent_owner), self.m_username, *self.m_sets,
          *self.m_moves_remaining, *self.m_score);
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl StructAssetDisplay of Display<StructAsset> {
    fn fmt(self: @StructAsset, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("Asset: {0}, Value: {1}, Index: {2}",
         self.m_name, *self.m_value, *self.m_index);
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl StructBlockchainDisplay of Display<StructBlockchain> {
    fn fmt(self: @StructBlockchain, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("Blockchain: {0}, Type: {1}, Fee: {2}, Value {3}",
         self.m_name, self.m_bc_type, *self.m_fee, *self.m_value);
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

// TODO: Change name of component

impl ActionChainReorgDisplay of Display<ActionChainReorg> {
    fn fmt(self: @ActionChainReorg, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("Chain Reorg: Value {0}, Index {1}", *self.m_value,
        *self.m_index);
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ActionClaimYieldDisplay of Display<ActionClaimYield> {
    fn fmt(self: @ActionClaimYield, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("Claim Yield: Value {0}, Index {1}", *self.m_value,
        *self.m_index);
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ActionFrontrunDisplay of Display<ActionFrontrun> {
    fn fmt(self: @ActionFrontrun, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("Steal Blockchain: Blockchain: {0},
        Value {1}, Index: {2}", self.m_blockchain_name, *self.m_value, *self.m_index);
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ActionHardForkDisplay of Display<ActionHardFork> {
    fn fmt(self: @ActionHardFork, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("Deny: Value {0}, Index {1}", *self.m_value,
        *self.m_index);
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ActionMEVBoostDisplay of Display<ActionMEVBoost> {
    fn fmt(self: @ActionMEVBoost, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("MEV Boost: Value {0}, Index {1}", *self.m_value,
        *self.m_index);
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ActionPriorityFeeDisplay of Display<ActionPriorityFee> {
    fn fmt(self: @ActionPriorityFee, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("Draw Two Cards: Value {0}, Index {1}",
         *self.m_value, *self.m_index);
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ActionReplayAttackDisplay of Display<ActionReplayAttack> {
    fn fmt(self: @ActionReplayAttack, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("Replay Attack: Value {0}, Index {1}", *self.m_value,
        *self.m_index);
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ActionSoftForkDisplay of Display<ActionSoftFork> {
    fn fmt(self: @ActionSoftFork, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("Soft Fork: Value {0}, Index {1}", *self.m_value,
        *self.m_index);
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
            EnumCard::GasFee(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            },
            EnumCard::HardFork(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            },
            EnumCard::PriorityFee(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            },
            EnumCard::FrontRun(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            },
            EnumCard::MajorityAttack(data) => {
                let str: ByteArray = format!("{data}");
                f.buffer.append(@str);
            },
            _ => {}
        };
        return Result::Ok(());
    }
}

impl EnumBlockchainTypeDisplay of Display<EnumBlockchainType> {
    fn fmt(self: @EnumBlockchainType, ref f: Formatter) -> Result<(), Error> {
        match self {
            EnumBlockchainType::Immutable(_) => {
                let str: ByteArray = format!("Immutable");
                f.buffer.append(@str);
            },
            EnumBlockchainType::Blue(_) => {
                let str: ByteArray = format!("Blue");
                f.buffer.append(@str);
            },
            EnumBlockchainType::DarkBlue(_) => {
                let str: ByteArray = format!("Dark Blue");
                f.buffer.append(@str);
            },
            EnumBlockchainType::Gold(_) => {
                let str: ByteArray = format!("Gold");
                f.buffer.append(@str);
            },
            EnumBlockchainType::Green(_) => {
                let str: ByteArray = format!("Green");
                f.buffer.append(@str);
            },
            EnumBlockchainType::Grey(_) => {
                let str: ByteArray = format!("Grey");
                f.buffer.append(@str);
            },
            EnumBlockchainType::LightBlue(_) => {
                let str: ByteArray = format!("Light Blue");
                f.buffer.append(@str);
            },
            EnumBlockchainType::Pink(_) => {
                let str: ByteArray = format!("Pink");
                f.buffer.append(@str);
            },
            EnumBlockchainType::Purple(_) => {
                let str: ByteArray = format!("Purple");
                f.buffer.append(@str);
            },
            EnumBlockchainType::Red(_) => {
                let str: ByteArray = format!("Red");
                f.buffer.append(@str);
            },
            EnumBlockchainType::Yellow(_) => {
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
            EnumGasFeeType::Any(color) => {
                let str: ByteArray = format!("Against One: {0}", color);
                f.buffer.append(@str);
            },
            EnumGasFeeType::AgainstTwo((color1, color2)) => {
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

impl ActionGasFeeDisplay of Display<ActionGasFee> {
    fn fmt(self: @ActionGasFee, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = format!("Gas Fee: Targeted Blockchain: {0}, Value {1}, Index {2}",
        self.m_blockchain_type_affected, *self.m_value, *self.m_index);
        f.buffer.append(@str);
        return Result::Ok(());
    }
}

impl ActionMajorityAttackDisplay of Display<ActionMajorityAttack> {
    fn fmt(self: @ActionMajorityAttack, ref f: Formatter) -> Result<(), Error> {
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