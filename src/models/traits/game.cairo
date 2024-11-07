////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

#[generate_trait]
impl StructAssetImpl of IAsset {
    fn new(name: ByteArray, value: u8, copies_left: u8) -> StructAsset nopanic {
        return StructAsset {
            m_name: name,
            m_value: value,
            m_index: copies_left
        };
    }
}

#[generate_trait]
impl StructAssetGroupImpl of IAssetGroup {
    fn new(blockchains: Array<StructBlockchain>, total_fee_value: u8) -> StructAssetGroup nopanic {
        return StructAssetGroup {
            m_set: blockchains,
            m_total_fee_value: total_fee_value
        };
    }
}

#[generate_trait]
impl StructBlockchainImpl of IBlockchain {
    fn new(name: ByteArray, bc_type: EnumBlockchainType, fee: u8, value: u8) -> StructBlockchain nopanic {
        return StructBlockchain {
            m_name: name,
            m_bc_type: bc_type,
            m_fee: fee,
            m_value: value
        };
    }
}

#[generate_trait]
impl StructPriorityFeeImpl of IDraw {
    fn new(value: u8, copies_left: u8) -> ActionPriorityFee nopanic {
        return ActionPriorityFee {
            m_value: value,
            m_index: copies_left
        };
    }
}

#[generate_trait]
impl DealerImpl of IDealer {
    fn new(owner: ContractAddress, cards: Array<EnumCard>) -> ComponentDealer nopanic {
        return ComponentDealer {
            m_ent_owner: owner,
            m_cards: cards
        };
    }

    fn shuffle(ref self: ComponentDealer, seed: felt252) -> () {
        let mut shuffled_cards: Array<EnumCard> = ArrayTrait::new();
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

    fn pop_card(ref self: ComponentDealer) -> Option<EnumCard> {
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

        self.m_cards.append(bc);
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
        };
        return found;
    }

    fn contains_type(self: @ComponentDeck, bc_type : @EnumBlockchainType) -> Option<usize> {
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
            let mut new_array = ArrayTrait::new();

            let mut index = 0;
            while let Option::Some(card) = self.m_cards.pop_front() {
                if index == index_found {
                    continue;
                }

                new_array.append(card);
                index += 1;
            };
        }
    }

    fn get_asset_group_for(self: @ComponentDeck, bc: @StructBlockchain) -> Option<Array<StructBlockchain>> {
        let mut index: usize = 0;
        let mut asset_group_array: Array<StructBlockchain> = ArrayTrait::new();
        let mut asset_group: Option<Array<StructBlockchain>> = Option::None;
        let mut total_fee: u8 = 0;

        while let Option::Some(card) = self.m_cards.get(index) {
            match card.unbox() {
                EnumCard::Blockchain(bc_struct) => {
                    if bc_struct.m_bc_type == bc.m_bc_type{
                        total_fee += *bc.m_fee;
                        asset_group_array.append(bc.clone());
                    }
                },
                _ => {}
            };

            index += 1;
        };

        if self.check_complete_set(asset_group_array.span(), bc.m_bc_type) {
            asset_group = Option::Some(asset_group_array);
        }
        return asset_group;
    }

    fn check_complete_set(self: @ComponentDeck, asset_group_array: Span<StructBlockchain>,
            bc_type: @EnumBlockchainType) -> bool {
        return match bc_type {
            EnumBlockchainType::Blue(_) | EnumBlockchainType::DarkBlue(_) | EnumBlockchainType::Gold(_) => {
                if asset_group_array.len() == 2 {
                    return true;
                }
                return false;
            },
            EnumBlockchainType::LightBlue(_) => {
                if asset_group_array.len() == 4 {
                    return true;
                }
                return false;
            },
            _ => {
                if asset_group_array.len() == 3 {
                    return true;
                }
                return false;
            }
        };
    }
}

#[generate_trait]
impl EnumBlockchainTypeImpl of IEnumBlockchainType {
    fn get_boost_array(self: @EnumBlockchainType) -> Array<u8> {
        return match self {
            EnumBlockchainType::Blue => {
                return array![1, 2];
            },
            EnumBlockchainType::DarkBlue => {
                return array![3, 8];
            },
            EnumBlockchainType::Gold => {
                return array![1, 2];
            },
            EnumBlockchainType::Green => {
                return array![1, 3, 5];
            },
            EnumBlockchainType::Grey => {
                return array![1, 2, 4];
            },
            EnumBlockchainType::LightBlue => {
                return array![1, 2, 3, 4];
            },
            EnumBlockchainType::Pink => {
                return array![1, 2, 3];
            },
            EnumBlockchainType::Purple => {
                return array![2, 4, 6];
            },
            EnumBlockchainType::Red => {
                return array![2, 4, 7];
            },
            EnumBlockchainType::Yellow => {
                return array![2, 3, 6];
            },
        };
    }
}

#[generate_trait]
impl EnumCardImpl of IEnumCard {
    fn distribute(ref self: EnumCard, in_container: Array<EnumCard>) -> Array<EnumCard> {
        assert!(self.get_index() > 0, "No more indices left for {0}", self);

        let mut new_array = ArrayTrait::new();
        while self.get_index() != 0 {
            new_array.append(self.remove_one_index());
        };
        return new_array;
    }

    fn get_index(self: @EnumCard) -> u8 {
        return match self {
            EnumCard::Asset(data) => {
                return *data.m_index;
            },
            EnumCard::Blockchain(_data) => {
                return 1;
            },
            EnumCard::ChainReorg(data) => {
                return *data.m_index;
            },
            EnumCard::ClaimYield(data) => {
                return *data.m_index;
            },
            EnumCard::GasFee(data) => {
                return *data.m_index;
            },
            EnumCard::HardFork(data) => {
                return *data.m_index;
            },
            EnumCard::PriorityFee(data) => {
                return *data.m_index;
            },
            EnumCard::ReplayAttack(data) => {
                return *data.m_index;
            },
            EnumCard::FrontRun(data) => {
                return *data.m_index;
            },
            EnumCard::FiftyOnePercentAttack(_) => {
                return 0;
            }
        };
    }

    fn get_name(self: @EnumCard) -> ByteArray {
        return self.into();
    }

    fn get_value(self: @EnumCard) -> u8 {
        return match self {
            EnumCard::Asset(data) => {
                return *data.m_value;
            },
            EnumCard::Blockchain(data) => {
                return *data.m_value;
            },
            EnumCard::ChainReorg(data) => {
                return *data.m_value;
            },
            EnumCard::ClaimYield(data) => {
                return *data.m_value;
            },
            EnumCard::GasFee(data) => {
                return *data.m_value;
            },
            EnumCard::HardFork(data) => {
                return *data.m_value;
            },
            EnumCard::PriorityFee(data) => {
                return *data.m_value;
            },
            EnumCard::ReplayAttack(data) => {
                return *data.m_value;
            },
            EnumCard::FrontRun(data) => {
                return *data.m_value;
            },
            EnumCard::FiftyOnePercentAttack(data) => {
                return *data.m_value;
            }
        };
    }

    fn remove_one_index(self: @EnumCard) -> EnumCard {
        return match self.clone() {
            EnumCard::Asset(mut data) => {
                assert!(data.m_index > 0, "No more indices left for {0}", data);
                data.m_index -= 1;
                return EnumCard::Asset(data);
            },
            EnumCard::ChainReorg(mut data) => {
                assert!(data.m_index > 0, "No more indices left for {0}", data);
                data.m_index -= 1;
                return EnumCard::ChainReorg(data);
            },
            EnumCard::ClaimYield(mut data) => {
                assert!(data.m_index > 0, "No more indices left for {0}", data);
                data.m_index -= 1;
                return EnumCard::ClaimYield(data);
            },
            EnumCard::GasFee(mut data) => {
                assert!(data.m_index > 0, "No more indices left for {0}", data);
                data.m_index -= 1;
                return EnumCard::GasFee(data);
            },
            EnumCard::HardFork(mut data) => {
                assert!(data.m_index > 0, "No more indices left for {0}", data);
                data.m_index -= 1;
                return EnumCard::HardFork(data);
            },
            EnumCard::PriorityFee(mut data) => {
                assert!(data.m_index > 0, "No more indices left for {0}", data);
                data.m_index -= 1;
                return EnumCard::PriorityFee(data);
            },
            EnumCard::ReplayAttack(mut data) => {
                assert!(data.m_index > 0, "No more indices left for {0}", data);
                data.m_index -= 1;
                return EnumCard::ReplayAttack(data);
            },
            EnumCard::FrontRun(mut data) => {
                assert!(data.m_index > 0, "No more indices left for {0}", data);
                data.m_index -= 1;
                return EnumCard::FrontRun(data);
            },
            EnumCard::FiftyOnePercentAttack(mut data) => {
                assert!(data.m_index > 0, "No more indices left for {0}", data);
                data.m_index -= 1;
                return EnumCard::FiftyOnePercentAttack(data);
            },
            _ => { return self.clone(); }
        };
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
            _ => false
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
                    continue;
                }

                new_array.append(player);
                index += 1;
            };
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
    fn new(players_affected: EnumPlayerTarget, bc_affected: EnumGasFeeType,
        set_applied: Array<StructBlockchain>, value: u8, copies_left: u8) -> ActionGasFee nopanic {
        return ActionGasFee {
            m_players_affected: players_affected,
            m_set_applied: set_applied,
            m_blockchain_type_affected: bc_affected,
            m_color_chosen: Option::None,
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
        return ComponentHand {
            m_ent_owner: owner,
            m_cards: cards
        };
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
impl DepositImpl of IDeposit {
    fn new(owner: ContractAddress, cards: Array<EnumCard>, value: u8) -> ComponentDeposit {
        return ComponentDeposit {
            m_ent_owner: owner,
            m_cards: cards,
            m_total_value: value
        };
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
            self.m_total_value -= self.m_cards.at(index_found).get_value();
            let mut new_array: Array<EnumCard> = ArrayTrait::new();
            let mut index: usize = 0;
            while let Option::Some(card) = self.m_cards.pop_front() {
                if index == index_found {
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
impl PlayerImpl of IPlayer {
    fn new(owner: ContractAddress, username: ByteArray) -> ComponentPlayer {
        return ComponentPlayer {
            m_ent_owner: owner,
            m_username: username,
            m_moves_remaining: 3,
            m_score: 0,
            m_sets: 0,
            m_has_drawn: false,
            m_in_debt: Option::None
        };
    }

    fn get_debt(self: @ComponentPlayer) -> Option<u8> {
        return self.m_in_debt.clone();
    }
}
