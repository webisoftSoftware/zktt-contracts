////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

use starknet::ContractAddress;
use dojo::world::IWorldDispatcher;
use zktt::models::components{
    EnumCard, EnumGameState, ComponentGame, ComponentHand, ComponentDeck, 
    ComponentDeposit, ComponentPlayer
};
use zktt::models::enums::{EnumMoveError, EnumPlayerTarget, EnumGasFeeType};

#[starknet::interface]
trait IActionSystem<T> {
    fn play(ref self: T, card: EnumCard) -> ();
    fn move(ref self: T, card: EnumCard) -> ();
    fn pay_fee(ref self: T, pay: Array<EnumCard>, recipient: ContractAddress, payee: ContractAddress) -> ();
}

#[dojo::contract]
mod action_system {
    use super::*;
    use starknet::get_caller_address;
    use dojo::model::ModelStorage;

    #[storage]
    struct Storage {
        world: IWorldDispatcher,
    }

    #[constructor]
    fn constructor(ref self: ContractState, world: IWorldDispatcher) {
        self.world.write(world);
    }

    #[abi(embed_v0)]
    impl ActionSystemImpl of super::IActionSystem<ContractState> {
        /// Adds two new cards from the dealer's deck to the active caller's hand, during their turn.
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
        fn play(ref self: ContractState, card: EnumCard) -> () {
            let mut world = self.world_default();
            let game: ComponentGame = world.read_model(world.dispatcher.contract_address);
            assert!(game.m_state == EnumGameState::Started, "Game has not started yet");
            
            let caller = get_caller_address();
            assert!(game.m_player_in_turn == caller, "Not player's turn");

            let mut player: ComponentPlayer = world.read_model(caller);
            assert!(player.m_has_drawn, "Player needs to draw cards first");
            assert!(player.m_moves_remaining != 0, "No moves left");
            assert!(self._is_owner(@card.get_name(), @caller), "Player does not own card");

            self._use_card(@caller, card);
            player.m_moves_remaining -= 1;
            world.write_model(@player);
        }

        /// Move around cards in the caller's deck, without it counting as a move. Can only happen
        /// during the caller's turn. This system is for when a player wants to stack/unstack
        /// blockchains together to form/break asset groups, depending on their strategy.
        /// As expected, only matching colors can be stacked on top of each other (or immutable card).
        ///
        /// Inputs:
        /// *world*: The mutable reference of the world to write components to.
        /// *card*: Card to move.
        ///
        /// Output:
        /// None.
        /// Can Panic?: yes
        fn move(ref self: ContractState, card: EnumCard) -> () {
            let mut world = self.world_default();
            let game: ComponentGame = world.read_model(world.dispatcher.contract_address);
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
        /// the fees upon their turn (unless 'HardFork' is played). The payee(s) cannot initiate
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
        fn pay_fee(ref self: ContractState, mut pay: Array<EnumCard>, recipient: ContractAddress, payee: ContractAddress) -> () {
            let mut world = self.world_default();
            let game: ComponentGame = world.read_model(world.dispatcher.contract_address);
            assert!(game.m_state == EnumGameState::Started, "Game has not started yet");

            let mut player: ComponentPlayer = world.read_model(payee);
            let mut payee_stash: ComponentDeposit = world.read_model(payee);
            let mut payee_deck: ComponentDeck = world.read_model(payee);
            assert!(player.get_debt().is_some(), "Player is not in debt");

            let mut recipient_stash: ComponentDeposit = world.read_model(recipient);
            let mut recipient_deck: ComponentDeposit = world.read_model(recipient);

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
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
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
        fn _is_owner(ref self: ContractState, card_name: @ByteArray, caller: @ContractAddress) -> bool {
            let mut world = self.world_default();
            let hand: ComponentHand = world.read_model(*caller);
            let deck: ComponentDeck = world.read_model(*caller);
            let deposit: ComponentDeposit = world.read_model(*caller);

            hand.contains(card_name).is_some() || 
            deck.contains(card_name).is_some() ||
            deposit.contains(card_name).is_some()
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
        fn _use_card(ref self: ContractState, caller: @ContractAddress, card: EnumCard) -> () {
            let mut world = self.world_default();
            let mut hand: ComponentHand = world.read_model(*caller);
            let mut deck: ComponentDeck = world.read_model(*caller);
            let mut deposit: ComponentDeposit = world.read_model(*caller);
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
                    deck.add(EnumCard::ChainReorg(chain_reorg_struct.clone()));
                    world.write_model(@deck);
                },
                EnumCard::ClaimYield(_claim_yield_struct) => {},
                EnumCard::GasFee(gas_fee_struct) => {
                    assert!(gas_fee_struct.m_color_chosen.is_some(), "Invalid Gas Fee move: No color specified");
                    match gas_fee_struct.m_blockchain_type_affected {
                        EnumGasFeeType::Any(color) =>  {
                            if color != @(*gas_fee_struct.m_color_chosen).unwrap() {
                                panic!("Invalid Gas Fee move: Color does not match allowed colors");
                            }
                        },
                        EnumGasFeeType::AgainstTwo((color1, color2)) => {
                            if color1 != @(*gas_fee_struct.m_color_chosen).unwrap() && color2 !=
                                @(*gas_fee_struct.m_color_chosen).unwrap() {
                                panic!("Invalid Gas Fee move: Color does not match allowed colors");
                            }
                        }
                    };

                    let fee: u8 = gas_fee_struct.get_fee();

                    match gas_fee_struct.m_players_affected {
                        EnumPlayerTarget::All(_) => {
                            let mut index = 0;
                            let game: ComponentGame = world.read_model(world.dispatcher.contract_address);

                            while index < game.m_players.len() {
                                let mut player_component: ComponentPlayer = world.read_model(*game.m_players.at(index));
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
                },
                EnumCard::HardFork(_hardfork_struct) => {

                    //let mut discard_pile = world.read_model(world.dispatcher.contract_address), (ComponentDiscardPile));
                    //let last_card = discard_pile.m_cards.at(discard_pile.m_cards.len() - 1);

                    // Revert last move for this player.
                    //let revert_action = last_card.revert();
                },
                EnumCard::PriorityFee(_priority_fee_struct) => {
                     let mut dealer: ComponentDealer = world.read_model(world.dispatcher.contract_address);
                     assert!(!dealer.m_cards.is_empty(), "Dealer has no more cards");

                     hand.add(dealer.pop_card().unwrap());
                     hand.add(dealer.pop_card().unwrap());
                     world.write_model(@hand);
                     world.write_model(@dealer);
                },
                EnumCard::ReplayAttack(_replay_attack_struct) => {},
                EnumCard::FrontRun(frontrun_struct) => {
                    let bc_owner = self._get_owner(frontrun_struct.m_blockchain_name);
                    assert!(bc_owner.is_some(), "Blockchain in Frontrun card has no owner");

                    let mut opponent_deck: ComponentDeck = world.read_model(bc_owner.unwrap());
                    if let Option::Some(card_index) = opponent_deck.contains(frontrun_struct.m_blockchain_name) {
                        deck.add(opponent_deck.m_cards.at(card_index).clone());
                        opponent_deck.remove(frontrun_struct.m_blockchain_name);
                        world.write_model(@deck);
                        world.write_model(@deck);
                        world.write_model(@opponent_deck);
                    } else {
                        panic!("Invalid FrontRun move: Opponent Blockchain not found");
                    }
                },
                EnumCard::FiftyOnePercentAttack(asset_group_struct) => {
                    let mut opponent_deck: ComponentDeck = world.read_model(*asset_group_struct.m_owner);
                    let mut player: ComponentPlayer = world.read_model(*caller);
                    let mut opponent_player: ComponentPlayer = world.read_model(*asset_group_struct.m_owner);

                    player.m_sets += 1;
                    opponent_player.m_sets -= 1;

                    let mut index: usize = 0;
                    while let Option::Some(bc_name) = asset_group_struct.m_set.get(index) {
                        if let Option::Some(blockchain_index) = opponent_deck.contains(bc_name.unbox()) {
                            deck.add(opponent_deck.m_cards.at(blockchain_index).clone());
                            opponent_deck.remove(bc_name.unbox());
                        }
                        index += 1;
                    };
                    world.write_model(@player);
                    world.write_model(@deck);
                    world.write_model(@opponent_deck);
                },
                _ => panic!("Invalid or illegal move!")
            };

            return ();
        }
    }
}