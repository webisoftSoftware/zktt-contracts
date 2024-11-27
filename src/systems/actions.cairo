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
    EnumCard, EnumGameState, EnumGasFeeType, EnumPlayerTarget, EnumColor
};


#[starknet::interface]
trait IActionSystem<T> {
    fn draw(ref self: T, draws_five: bool, table: ContractAddress) -> ();
    fn play(ref self: T, card: EnumCard, table: ContractAddress) -> ();
    fn move(ref self: T, card: EnumCard, table: ContractAddress) -> ();
    fn pay_fee(
        ref self: T, pay: Array<EnumCard>, recipient: ContractAddress, payee: ContractAddress,
        table: ContractAddress
    ) -> ();
}

#[dojo::contract]
mod action_system {
    use super::{EnumCard, EnumGameState, ContractAddress};
    use zktt::models::components::{
        ComponentGame, ComponentCard, ComponentHand, ComponentDeck, ComponentDeposit,
        ComponentPlayer, ComponentDealer, ComponentDiscardPile
    };
    use zktt::models::traits::{
        IEnumCard, IPlayer, IDeck, IDealer, IHand, IGasFee, IAssetGroup, IGame, IAsset,
        IBlockchain, IDeposit
    };
    use zktt::models::enums::{EnumGasFeeType, EnumPlayerTarget, EnumColor};
    use dojo::world::IWorldDispatcher;
    use starknet::get_caller_address;
    use dojo::model::ModelStorage;

    #[abi(embed_v0)]
    impl ActionSystemImpl of super::IActionSystem<ContractState> {
        //////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////
        /////////////////////////////// EXTERNAL /////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////

        /// Adds two new cards from the dealer's deck to the active caller's hand, during their
        /// turn.
        /// This can only happen once per turn, at the beginning of it (first move).
        ///
        /// Inputs:
        /// *world*: The mutable reference of the world to write components to.
        /// *draws_five*: Flag indicating if the active caller can draw five cards from the deck
        /// instead of the typical two. This behavior can only happend if the player has no more
        /// cards left in their hand at the end of their last turn.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn draw(ref self: ContractState, draws_five: bool, table: ContractAddress) -> () {
            let mut world = self.world_default();
            let caller = get_caller_address();
            let mut hand: ComponentHand = world.read_model(caller);
            let mut player: ComponentPlayer = world.read_model(caller);
            let game: ComponentGame = world.read_model(table);

            assert!(game.m_state != EnumGameState::WaitingForRent, "Game is paused");
            assert!(game.m_state == EnumGameState::Started, "Game has not started yet");
            assert!(game.m_player_in_turn == caller, "Not player's turn");
            assert!(!player.m_has_drawn, "Cannot draw mid-turn");

            let mut dealer: ComponentDealer = world.read_model(table);

            if draws_five {
                assert!(hand.m_cards.len() == 0, "Cannot draw five, hand not empty");
                let mut index: usize = 0;
                while index < 5 {
                    if dealer.m_cards.is_empty() {
                        panic!("Dealer has no more cards");
                    }
                    let card_index = dealer.pop_card().unwrap();
                    let card_component: ComponentCard = world.read_model(card_index);
                    hand.add(card_component.m_card_info);
                    index += 1;
                }
            } else {
                let card1_opt = dealer.pop_card();
                let card2_opt = dealer.pop_card();
                assert!(
                    card1_opt.is_some() && card2_opt.is_some(), "Deck does not have any more cards!"
                );
                let card1_info: ComponentCard = world.read_model(card1_opt.unwrap());
                let card2_info: ComponentCard = world.read_model(card2_opt.unwrap());

                hand.add(card1_info.m_card_info);
                hand.add(card2_info.m_card_info);
            }

            player.m_has_drawn = true;
            world.write_model(@hand);
            world.write_model(@dealer);
            world.write_model(@player);
        }

        /// Adds two new cards from the dealer's deck to the active caller's hand, during their
        /// turn.
        /// This can only happen once per turn, at the beginning of it (first move).
        ///
        /// Inputs:
        /// *world*: The mutable reference of the world to write components to.
        /// *draws_five*: Flag indicating if the active caller can draw five cards from the deck
        /// instead of the typical two. This behavior can only happend if the player has no more
        /// cards left in their hand at the end of their last turn.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn play(ref self: ContractState, card: EnumCard, table: ContractAddress) -> () {
            let mut world = self.world_default();
            let game: ComponentGame = world.read_model(table);
            assert!(game.m_state != EnumGameState::WaitingForRent, "Game is paused");
            assert!(game.m_state == EnumGameState::Started, "Game has not started yet");

            let caller = get_caller_address();
            assert!(game.m_player_in_turn == caller, "Not player's turn");

            let mut player: ComponentPlayer = world.read_model(caller);
            assert!(player.m_has_drawn, "Player needs to draw cards first");
            assert!(player.m_moves_remaining != 0, "No moves left");
            assert!(self._is_owner(@card.get_name(), @caller), "Player does not own card");

            self._use_card(@caller, card, table);
            player.m_moves_remaining -= 1;
            world.write_model(@player);
        }

        /// Move around cards in the caller's deck, without it counting as a move. Can only happen
        /// during the caller's turn. This system is for when a player wants to stack/unstack
        /// blockchains together to form/break asset groups, depending on their strategy.
        /// As expected, only matching colors can be stacked on top of each other (or immutable
        /// card).
        ///
        /// Inputs:
        /// *world*: The mutable reference of the world to write components to.
        /// *card*: Card to move.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn move(ref self: ContractState, card: EnumCard, table: ContractAddress) -> () {
            let mut world = self.world_default();
            let game: ComponentGame = world.read_model(table);
            assert!(game.m_state != EnumGameState::WaitingForRent, "Game is paused");
            assert!(game.m_state == EnumGameState::Started, "Game has not started yet");

            let caller = get_caller_address();
            assert!(game.m_player_in_turn == caller, "Not player's turn");

            let mut player: ComponentPlayer = world.read_model(caller);
            assert!(player.m_has_drawn, "Player needs to draw cards first");
            assert!(self._is_owner(@card.get_name(), @caller), "Player does not own card");

            // TODO: Move card around in deck.
            world.write_model(@player);
        }

        /// Make the caller pay the recipient the amount owed. This happens when the recipient plays
        /// the 'Claim' action card beforehand and targets this caller with it. Once the recipient's
        /// turn is over, the payee(s) will have a status of 'InDebt' which will prompt them to pay
        /// the fees upon their turn. The payee(s) cannot initiate
        /// turns until the amount owed has been payed, either partially (if they do not have
        /// enough funds) or fully.
        ///
        /// Inputs:
        /// *world*: The mutable reference of the world to write components to.
        /// *card*: Card to move.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn pay_fee(
            ref self: ContractState,
            mut pay: Array<EnumCard>,
            recipient: ContractAddress,
            payee: ContractAddress,
            table: ContractAddress
        ) -> () {
            let mut world = self.world_default();
            let mut game: ComponentGame = world.read_model(table);
            assert!(game.m_state == EnumGameState::WaitingForRent, "Game must be waiting for rent");

            let mut player: ComponentPlayer = world.read_model(payee);
            let mut payee_stash: ComponentDeposit = world.read_model(payee);
            let mut payee_deck: ComponentDeck = world.read_model(payee);
            assert!(player.get_debt().is_some(), "Player is not in debt");

            let mut recipient_stash: ComponentDeposit = world.read_model(recipient);
            let mut recipient_deck: ComponentDeck = world.read_model(recipient);
            while let Option::Some(card) = pay.pop_front() {
                if !card.is_blockchain() {
                    payee_stash.remove(@card.get_name());
                    recipient_stash.add(card);
                } else {
                    payee_deck.remove(@card.get_name());
                    recipient_deck.add(card);
                }
            };
            player.m_in_debt = Option::None;
            world.write_model(@recipient_stash);
            world.write_model(@recipient_deck);
            world.write_model(@payee_stash);
            world.write_model(@payee_deck);
            world.write_model(@player);
            game.m_state = EnumGameState::Started;
            world.write_model(@game);
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        //////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////
        /////////////////////////////// INTERNAL /////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////

        /// Use the default namespace "zktt". This function is handy since the ByteArray
        /// can't be const.
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"zktt")
        }

        /// Check to see if the caller has the right to play or move around a card.
        ///
        /// Inputs:
        /// *world*: The immutable reference of the world to retrieve components from.
        /// *caller: The player requesting to use or move the card.
        /// *card*: The immutable reference to the card in question.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn _is_owner(
            ref self: ContractState, card_name: @ByteArray, caller: @ContractAddress
        ) -> bool {
            let mut world = self.world_default();
            let hand: ComponentHand = world.read_model(*caller);
            let deck: ComponentDeck = world.read_model(*caller);
            let deposit: ComponentDeposit = world.read_model(*caller);

            hand.contains(card_name).is_some()
                || deck.contains(card_name).is_some()
                || deposit.contains(card_name).is_some()
        }

        /// Take card from player's hand and put it in the discard pile after applying it's action.
        /// Once a card has been played, it cannot be retrieved back from the discard pile.
        ///
        /// Inputs:
        /// *world*: The mutable reference of the world to write components to.
        /// *caller: The player requesting to use the card.
        /// *card*: The card being played.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn _use_card(ref self: ContractState, caller: @ContractAddress, card: EnumCard, table: ContractAddress) -> () {
            let mut world = self.world_default();
            let mut hand: ComponentHand = world.read_model(*caller);
            let mut deck: ComponentDeck = world.read_model(*caller);
            let mut deposit: ComponentDeposit = world.read_model(*caller);
            let mut discard_pile: ComponentDiscardPile = world.read_model(table);
            assert!(hand.contains(@card.get_name()).is_some(), "Card not in player's hand");
            hand.remove(@card.get_name());

            match @card {
                EnumCard::Asset(asset) => {
                    deposit.add(EnumCard::Asset(asset.clone()));
                    world.write_model(@deposit);
                },
                EnumCard::Blockchain(blockchain_struct) => {
                    deck.add(EnumCard::Blockchain(blockchain_struct.clone()));
                    world.write_model(@deck);
                },
                EnumCard::ChainReorg(chain_reorg_struct) => {
                    let mut opponent_deck: ComponentDeck = world
                        .read_model(*chain_reorg_struct.m_opponent_address);

                    // First find and remove opponent's blockchain
                    if let Option::Some(opp_index) = opponent_deck
                        .contains(chain_reorg_struct.m_opponent_blockchain_name) {
                        let opp_bc = opponent_deck.m_cards.at(opp_index).clone();
                        opponent_deck.remove(chain_reorg_struct.m_opponent_blockchain_name);

                        // Then find and remove self blockchain
                        if let Option::Some(self_index) = deck
                            .contains(chain_reorg_struct.m_self_blockchain_name) {
                            let self_bc = deck.m_cards.at(self_index).clone();
                            deck.remove(chain_reorg_struct.m_self_blockchain_name);

                            // Finally add each blockchain to the other player's deck
                            deck.add(opp_bc);
                            opponent_deck.add(self_bc);

                            world.write_model(@deck);
                            world.write_model(@opponent_deck);
                        }
                    }
                },
                EnumCard::ClaimYield(_claim_yield_struct) => {
                    let mut game: ComponentGame = world.read_model(table);
                    game.m_state = EnumGameState::WaitingForRent;
                    for player in game.m_players.span() {
                        let mut player_component: ComponentPlayer = world.read_model(*player);
                        player_component.m_in_debt = Option::Some(2);
                        world.write_model(@player_component);
                    };
                    world.write_model(@game);
                },
                EnumCard::FiftyOnePercentAttack(asset_group_struct) => {
                    assert!(*asset_group_struct.m_player_targeted != starknet::contract_address_const::<0x0>(),
                        "No player targeted");
                    let mut opponent_deck: ComponentDeck = world.read_model(*asset_group_struct.m_player_targeted);

                    // Verify opponent has sets to steal
                    assert!(opponent_deck.m_sets > 0, "Opponent has no sets");

                    // Get all matching blockchains of the target type
                    let mut index: usize = 0;
                    let target_type = asset_group_struct.m_set.at(0).m_bc_type;
                    let mut blockchains_to_steal = ArrayTrait::new();

                    // First collect all matching blockchains
                    while index < opponent_deck.m_cards.len() {
                        let bc = opponent_deck.m_cards.at(index);
                        match bc {
                            EnumCard::Blockchain(bc_struct) => {
                                if bc_struct.m_bc_type == target_type {
                                    blockchains_to_steal.append(bc.clone());
                                }
                            },
                            _ => {}
                        }
                        index += 1;
                    };

                    // Then move all collected blockchains from opponent to self
                    while let Option::Some(bc) = blockchains_to_steal.pop_front() {
                        deck.add(bc.clone());
                        opponent_deck.remove(@bc.get_name());
                    };

                    world.write_model(@deck);
                    world.write_model(@opponent_deck);
                },
                EnumCard::FrontRun(frontrun_struct) => {
                    assert!(*frontrun_struct.m_player_targeted != starknet::contract_address_const::<0x0>(),
                            "No player targeted");
                    let bc_owner = self._get_owner(frontrun_struct.m_blockchain_name, table);
                    assert!(bc_owner.is_some(), "Blockchain in Frontrun card has no owner");

                    let mut opponent_deck: ComponentDeck = world.read_model(*frontrun_struct.m_player_targeted);
                    if let Option::Some(card_index) = opponent_deck
                        .contains(frontrun_struct.m_blockchain_name) {
                        deck.add(opponent_deck.m_cards.at(card_index).clone());
                        opponent_deck.remove(frontrun_struct.m_blockchain_name);
                        world.write_model(@deck);
                        world.write_model(@deck);
                        world.write_model(@opponent_deck);
                    } else {
                        panic!("Invalid Frontrun move: Opponent blockchain not found");
                    }
                },
                EnumCard::GasFee(gas_fee_struct) => {
                    match gas_fee_struct.m_blockchain_type_affected {
                        EnumGasFeeType::Any(_) => {},
                        EnumGasFeeType::AgainstTwo((
                            color1, color2
                        )) => {
                            let mut color_found: bool = false;
                            let mut index: usize = 0;
                            while index < gas_fee_struct.m_set_applied.len() {
                                let blockchain = gas_fee_struct.m_set_applied.at(index);
                                if blockchain.m_bc_type == color1
                                    || blockchain.m_bc_type == color2 {
                                    color_found = true;
                                }
                                index += 1;
                            };
                            if !color_found {
                                return ();
                            }
                        }
                    };

                    let fee: u8 = gas_fee_struct.get_fee();
                    let mut game: ComponentGame = world.read_model(table);
                    game.m_state = EnumGameState::WaitingForRent;
                    // Make every affected player in debt for their next turn.
                    match gas_fee_struct.m_players_affected {
                        EnumPlayerTarget::All(_) => {
                            let mut index = 0;

                            while index < game.m_players.len() {
                                let mut player_component: ComponentPlayer = world
                                    .read_model(*game.m_players.at(index));
                                player_component.m_in_debt = Option::Some(fee);
                                world.write_model(@player_component);
                                index += 1;
                            };
                        },
                        EnumPlayerTarget::One(player) => {
                            let mut player_component: ComponentPlayer = world.read_model(*player);
                            player_component.m_in_debt = Option::Some(fee);
                            world.write_model(@player_component);
                        },
                        _ => panic!("Invalid Gas Fee move: No players targeted")
                    };
                    world.write_model(@game);
                },
                EnumCard::PriorityFee(_priority_fee_struct) => {
                    let mut dealer: ComponentDealer = world.read_model(table);
                    assert!(!dealer.m_cards.is_empty(), "Dealer has no more cards");

                    let card_component1: ComponentCard = world
                        .read_model(dealer.pop_card().unwrap());
                    let card_component2: ComponentCard = world
                        .read_model(dealer.pop_card().unwrap());
                    hand.add(card_component1.m_card_info);
                    hand.add(card_component2.m_card_info);
                    world.write_model(@hand);
                    world.write_model(@dealer);
                },
                EnumCard::ReplayAttack(replay_attack_struct) => {
                    // Retrieve last card played by player from the discard pile.
                    if let Option::Some(last_card) = discard_pile.m_cards.get(discard_pile.m_cards.len() - 1) {
                        let unboxed_card = last_card.unbox();
                        match unboxed_card {
                            EnumCard::GasFee(gas_fee_struct) => {
                                if gas_fee_struct.m_owner == replay_attack_struct.m_owner {
                                    let fee = gas_fee_struct.get_fee() * 2;
                                    match gas_fee_struct.m_players_affected {
                                        EnumPlayerTarget::All(_) => {
                                            let mut index = 0;
                                            let game: ComponentGame = world.read_model(table);

                                            while index < game.m_players.len() {
                                                let mut player_component: ComponentPlayer = world
                                                    .read_model(*game.m_players.at(index));
                                                player_component.m_in_debt = Option::Some(fee);
                                                world.write_model(@player_component);
                                                index += 1;
                                            };
                                        },
                                        EnumPlayerTarget::One(player) => {
                                            let mut player_component: ComponentPlayer = world.read_model(*player);
                                            player_component.m_in_debt = Option::Some(fee);
                                            world.write_model(@player_component);
                                        },
                                        _ => panic!("Invalid Gas Fee move: No players targeted")
                                    };
                                } else {
                                    // Card played too late, potentially punish player...
                                }
                            },
                            _ => {
                                // Invalid card played with it, potentially punish player...
                            }
                        };
                    }
                },
                EnumCard::SandwichAttack(_sandwich_attack_struct) => {
                    let mut game: ComponentGame = world.read_model(table);
                    game.m_state = EnumGameState::WaitingForRent;
                    for player in game
                        .m_players
                        .span() {
                            let mut player_component: ComponentPlayer = world.read_model(*player);
                            player_component.m_in_debt = Option::Some(5);
                            world.write_model(@player_component);
                        };
                    world.write_model(@game);
                },
                _ => panic!("Invalid or illegal move!")
            };

            discard_pile.m_cards.append(card);
            world.write_model(@discard_pile);
            world.write_model(@hand);
            return ();
        }

        fn _get_owner(ref self: ContractState, card_name: @ByteArray, table: ContractAddress) -> Option<ContractAddress> {
            let mut world = self.world_default();
            let game: ComponentGame = world.read_model(table);
            assert!(game.m_state == EnumGameState::Started, "Game has not started yet");

            let mut index = 0;
            let mut owner = Option::None;

            while index < game.m_players.len() {
                let hand: ComponentHand = world.read_model(*game.m_players.at(index));
                let deck: ComponentDeck = world.read_model(*game.m_players.at(index));
                let deposit: ComponentDeposit = world.read_model(*game.m_players.at(index));

                if let Option::Some(_) = hand.contains(card_name) {
                    owner = Option::Some(*game.m_players.at(index));
                    break;
                }

                if let Option::Some(_) = deck.contains(card_name) {
                    owner = Option::Some(*game.m_players.at(index));
                    break;
                }

                if let Option::Some(_) = deposit.contains(card_name) {
                    owner = Option::Some(*game.m_players.at(index));
                    break;
                }

                index += 1;
            };

            return owner;
        }
    }
}
