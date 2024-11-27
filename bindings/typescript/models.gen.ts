import type { SchemaType } from "@dojoengine/sdk";

// Type definition for `zktt::models::structs::ActionReplayAttack` struct
export interface ActionReplayAttack {
	fieldOrder: string[];
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::components::ComponentCardValue` struct
export interface ComponentCardValue {
	fieldOrder: string[];
	m_card_info: EnumCard;
}

// Type definition for `zktt::models::components::ComponentCard` struct
export interface ComponentCard {
	fieldOrder: string[];
	m_ent_index: number;
	m_card_info: EnumCard;
}

// Type definition for `zktt::models::structs::ActionFrontrun` struct
export interface ActionFrontrun {
	fieldOrder: string[];
	m_blockchain_name: string;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionFiftyOnePercentAttack` struct
export interface ActionFiftyOnePercentAttack {
	fieldOrder: string[];
	m_owner: string;
	m_set: Array<StructBlockchain>;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionClaimYield` struct
export interface ActionClaimYield {
	fieldOrder: string[];
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionGasFee` struct
export interface ActionGasFee {
	fieldOrder: string[];
	m_players_affected: EnumPlayerTarget;
	m_blockchain_type_affected: EnumGasFeeType;
	m_set_applied: Array<StructBlockchain>;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionChainReorg` struct
export interface ActionChainReorg {
	fieldOrder: string[];
	m_self_blockchain_name: string;
	m_opponent_blockchain_name: string;
	m_opponent_address: string;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionPriorityFee` struct
export interface ActionPriorityFee {
	fieldOrder: string[];
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::StructAsset` struct
export interface StructAsset {
	fieldOrder: string[];
	m_name: string;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::StructBlockchain` struct
export interface StructBlockchain {
	fieldOrder: string[];
	m_name: string;
	m_bc_type: EnumColor;
	m_fee: number;
	m_value: number;
}

// Type definition for `zktt::models::structs::ActionSandwichAttack` struct
export interface ActionSandwichAttack {
	fieldOrder: string[];
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::components::ComponentDealer` struct
export interface ComponentDealer {
	fieldOrder: string[];
	m_ent_owner: string;
	m_cards: Array<number>;
}

// Type definition for `zktt::models::components::ComponentDealerValue` struct
export interface ComponentDealerValue {
	fieldOrder: string[];
	m_cards: Array<number>;
}

// Type definition for `zktt::models::structs::StructAsset` struct
export interface StructAsset {
	fieldOrder: string[];
	m_name: string;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionClaimYield` struct
export interface ActionClaimYield {
	fieldOrder: string[];
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::components::ComponentDeckValue` struct
export interface ComponentDeckValue {
	fieldOrder: string[];
	m_cards: Array<EnumCard>;
	m_sets: number;
}

// Type definition for `zktt::models::structs::ActionChainReorg` struct
export interface ActionChainReorg {
	fieldOrder: string[];
	m_self_blockchain_name: string;
	m_opponent_blockchain_name: string;
	m_opponent_address: string;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::components::ComponentDeck` struct
export interface ComponentDeck {
	fieldOrder: string[];
	m_ent_owner: string;
	m_cards: Array<EnumCard>;
	m_sets: number;
}

// Type definition for `zktt::models::structs::StructBlockchain` struct
export interface StructBlockchain {
	fieldOrder: string[];
	m_name: string;
	m_bc_type: EnumColor;
	m_fee: number;
	m_value: number;
}

// Type definition for `zktt::models::structs::ActionPriorityFee` struct
export interface ActionPriorityFee {
	fieldOrder: string[];
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionFrontrun` struct
export interface ActionFrontrun {
	fieldOrder: string[];
	m_blockchain_name: string;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionReplayAttack` struct
export interface ActionReplayAttack {
	fieldOrder: string[];
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionFiftyOnePercentAttack` struct
export interface ActionFiftyOnePercentAttack {
	fieldOrder: string[];
	m_owner: string;
	m_set: Array<StructBlockchain>;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionGasFee` struct
export interface ActionGasFee {
	fieldOrder: string[];
	m_players_affected: EnumPlayerTarget;
	m_blockchain_type_affected: EnumGasFeeType;
	m_set_applied: Array<StructBlockchain>;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionSandwichAttack` struct
export interface ActionSandwichAttack {
	fieldOrder: string[];
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionChainReorg` struct
export interface ActionChainReorg {
	fieldOrder: string[];
	m_self_blockchain_name: string;
	m_opponent_blockchain_name: string;
	m_opponent_address: string;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionClaimYield` struct
export interface ActionClaimYield {
	fieldOrder: string[];
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionFrontrun` struct
export interface ActionFrontrun {
	fieldOrder: string[];
	m_blockchain_name: string;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionReplayAttack` struct
export interface ActionReplayAttack {
	fieldOrder: string[];
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::components::ComponentDeposit` struct
export interface ComponentDeposit {
	fieldOrder: string[];
	m_ent_owner: string;
	m_cards: Array<EnumCard>;
	m_total_value: number;
}

// Type definition for `zktt::models::structs::ActionPriorityFee` struct
export interface ActionPriorityFee {
	fieldOrder: string[];
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::StructBlockchain` struct
export interface StructBlockchain {
	fieldOrder: string[];
	m_name: string;
	m_bc_type: EnumColor;
	m_fee: number;
	m_value: number;
}

// Type definition for `zktt::models::structs::StructAsset` struct
export interface StructAsset {
	fieldOrder: string[];
	m_name: string;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionSandwichAttack` struct
export interface ActionSandwichAttack {
	fieldOrder: string[];
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionFiftyOnePercentAttack` struct
export interface ActionFiftyOnePercentAttack {
	fieldOrder: string[];
	m_owner: string;
	m_set: Array<StructBlockchain>;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionGasFee` struct
export interface ActionGasFee {
	fieldOrder: string[];
	m_players_affected: EnumPlayerTarget;
	m_blockchain_type_affected: EnumGasFeeType;
	m_set_applied: Array<StructBlockchain>;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::components::ComponentDepositValue` struct
export interface ComponentDepositValue {
	fieldOrder: string[];
	m_cards: Array<EnumCard>;
	m_total_value: number;
}

// Type definition for `zktt::models::components::ComponentGameValue` struct
export interface ComponentGameValue {
	fieldOrder: string[];
	m_state: EnumGameState;
	m_players: Array<string>;
	m_player_in_turn: string;
}

// Type definition for `zktt::models::components::ComponentGame` struct
export interface ComponentGame {
	fieldOrder: string[];
	m_ent_seed: number;
	m_state: EnumGameState;
	m_players: Array<string>;
	m_player_in_turn: string;
}

// Type definition for `zktt::models::structs::ActionFrontrun` struct
export interface ActionFrontrun {
	fieldOrder: string[];
	m_blockchain_name: string;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionFiftyOnePercentAttack` struct
export interface ActionFiftyOnePercentAttack {
	fieldOrder: string[];
	m_owner: string;
	m_set: Array<StructBlockchain>;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionGasFee` struct
export interface ActionGasFee {
	fieldOrder: string[];
	m_players_affected: EnumPlayerTarget;
	m_blockchain_type_affected: EnumGasFeeType;
	m_set_applied: Array<StructBlockchain>;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::components::ComponentHandValue` struct
export interface ComponentHandValue {
	fieldOrder: string[];
	m_cards: Array<EnumCard>;
}

// Type definition for `zktt::models::structs::ActionPriorityFee` struct
export interface ActionPriorityFee {
	fieldOrder: string[];
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::components::ComponentHand` struct
export interface ComponentHand {
	fieldOrder: string[];
	m_ent_owner: string;
	m_cards: Array<EnumCard>;
}

// Type definition for `zktt::models::structs::StructAsset` struct
export interface StructAsset {
	fieldOrder: string[];
	m_name: string;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::StructBlockchain` struct
export interface StructBlockchain {
	fieldOrder: string[];
	m_name: string;
	m_bc_type: EnumColor;
	m_fee: number;
	m_value: number;
}

// Type definition for `zktt::models::structs::ActionChainReorg` struct
export interface ActionChainReorg {
	fieldOrder: string[];
	m_self_blockchain_name: string;
	m_opponent_blockchain_name: string;
	m_opponent_address: string;
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionSandwichAttack` struct
export interface ActionSandwichAttack {
	fieldOrder: string[];
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionReplayAttack` struct
export interface ActionReplayAttack {
	fieldOrder: string[];
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::structs::ActionClaimYield` struct
export interface ActionClaimYield {
	fieldOrder: string[];
	m_value: number;
	m_index: number;
}

// Type definition for `zktt::models::components::ComponentPlayer` struct
export interface ComponentPlayer {
	fieldOrder: string[];
	m_ent_owner: string;
	m_username: string;
	m_moves_remaining: number;
	m_score: number;
	m_has_drawn: boolean;
	m_in_debt: Option;
}

// Type definition for `zktt::models::components::ComponentPlayerValue` struct
export interface ComponentPlayerValue {
	fieldOrder: string[];
	m_username: string;
	m_moves_remaining: number;
	m_score: number;
	m_has_drawn: boolean;
	m_in_debt: Option;
}

// Type definition for `zktt::models::enums::EnumColor` enum
export enum EnumColor {
	Blue,
	DarkBlue,
	Gold,
	Green,
	Grey,
	LightBlue,
	Pink,
	Purple,
	Red,
	Yellow,
}

// Type definition for `zktt::models::enums::EnumCard` enum
export enum EnumCard {
	Asset,
	Blockchain,
	ChainReorg,
	ClaimYield,
	GasFee,
	PriorityFee,
	ReplayAttack,
	FrontRun,
	FiftyOnePercentAttack,
	SandwichAttack,
}

// Type definition for `zktt::models::enums::EnumGasFeeType` enum
export enum EnumGasFeeType {
	Any,
	AgainstTwo,
}

// Type definition for `zktt::models::enums::EnumPlayerTarget` enum
export enum EnumPlayerTarget {
	All,
	None,
	One,
}

// Type definition for `zktt::models::enums::EnumGameState` enum
export enum EnumGameState {
	WaitingForPlayers,
	WaitingForRent,
	Started,
	Ended,
}

export interface ZkttSchemaType extends SchemaType {
	zktt: {
		ActionReplayAttack: ActionReplayAttack,
		ComponentCardValue: ComponentCardValue,
		ComponentCard: ComponentCard,
		ActionFrontrun: ActionFrontrun,
		ActionFiftyOnePercentAttack: ActionFiftyOnePercentAttack,
		ActionClaimYield: ActionClaimYield,
		ActionGasFee: ActionGasFee,
		ActionChainReorg: ActionChainReorg,
		ActionPriorityFee: ActionPriorityFee,
		StructAsset: StructAsset,
		StructBlockchain: StructBlockchain,
		ActionSandwichAttack: ActionSandwichAttack,
		ComponentDealer: ComponentDealer,
		ComponentDealerValue: ComponentDealerValue,
		ComponentDeckValue: ComponentDeckValue,
		ComponentDeck: ComponentDeck,
		ComponentDeposit: ComponentDeposit,
		ComponentDepositValue: ComponentDepositValue,
		ComponentGameValue: ComponentGameValue,
		ComponentGame: ComponentGame,
		ComponentHandValue: ComponentHandValue,
		ComponentHand: ComponentHand,
		ComponentPlayer: ComponentPlayer,
		ComponentPlayerValue: ComponentPlayerValue,
		ERC__Balance: ERC__Balance,
		ERC__Token: ERC__Token,
		ERC__Transfer: ERC__Transfer,
	},
}
export const schema: ZkttSchemaType = {
	zktt: {
		ActionReplayAttack: {
			fieldOrder: ['m_value', 'm_index'],
			m_value: 0,
			m_index: 0,
		},
		ComponentCardValue: {
			fieldOrder: ['m_card_info'],
			m_card_info: EnumCard.Asset,
		},
		ComponentCard: {
			fieldOrder: ['m_ent_index', 'm_card_info'],
			m_ent_index: 0,
			m_card_info: EnumCard.Asset,
		},
		ActionFrontrun: {
			fieldOrder: ['m_blockchain_name', 'm_value', 'm_index'],
			m_blockchain_name: "",
			m_value: 0,
			m_index: 0,
		},
		ActionFiftyOnePercentAttack: {
			fieldOrder: ['m_owner', 'm_set', 'm_value', 'm_index'],
			m_owner: "",
			m_set: [{ fieldOrder: ['m_name', 'm_bc_type', 'm_fee', 'm_value'], m_name: "", m_bc_type: EnumColor, m_fee: 0, m_value: 0, }],
			m_value: 0,
			m_index: 0,
		},
		ActionClaimYield: {
			fieldOrder: ['m_value', 'm_index'],
			m_value: 0,
			m_index: 0,
		},
		ActionGasFee: {
			fieldOrder: ['m_players_affected', 'm_blockchain_type_affected', 'm_set_applied', 'm_value', 'm_index'],
			m_players_affected: EnumPlayerTarget.All,
			m_blockchain_type_affected: EnumGasFeeType.Any,
			m_set_applied: [{ fieldOrder: ['m_name', 'm_bc_type', 'm_fee', 'm_value'], m_name: "", m_bc_type: EnumColor, m_fee: 0, m_value: 0, }],
			m_value: 0,
			m_index: 0,
		},
		ActionChainReorg: {
			fieldOrder: ['m_self_blockchain_name', 'm_opponent_blockchain_name', 'm_opponent_address', 'm_value', 'm_index'],
			m_self_blockchain_name: "",
			m_opponent_blockchain_name: "",
			m_opponent_address: "",
			m_value: 0,
			m_index: 0,
		},
		ActionPriorityFee: {
			fieldOrder: ['m_value', 'm_index'],
			m_value: 0,
			m_index: 0,
		},
		StructAsset: {
			fieldOrder: ['m_name', 'm_value', 'm_index'],
			m_name: "",
			m_value: 0,
			m_index: 0,
		},
		StructBlockchain: {
			fieldOrder: ['m_name', 'm_bc_type', 'm_fee', 'm_value'],
			m_name: "",
			m_bc_type: EnumColor.Blue,
			m_fee: 0,
			m_value: 0,
		},
		ActionSandwichAttack: {
			fieldOrder: ['m_value', 'm_index'],
			m_value: 0,
			m_index: 0,
		},
		ComponentDealer: {
			fieldOrder: ['m_ent_owner', 'm_cards'],
			m_ent_owner: "",
			m_cards: [0],
		},
		ComponentDealerValue: {
			fieldOrder: ['m_cards'],
			m_cards: [0],
		},
		ComponentDeckValue: {
			fieldOrder: ['m_cards', 'm_sets'],
			m_cards: [EnumCard.Asset],
			m_sets: 0,
		},
		ComponentDeck: {
			fieldOrder: ['m_ent_owner', 'm_cards', 'm_sets'],
			m_ent_owner: "",
			m_cards: [EnumCard.Asset],
			m_sets: 0,
		},
		ComponentDeposit: {
			fieldOrder: ['m_ent_owner', 'm_cards', 'm_total_value'],
			m_ent_owner: "",
			m_cards: [EnumCard.Asset],
			m_total_value: 0,
		},
		ComponentDepositValue: {
			fieldOrder: ['m_cards', 'm_total_value'],
			m_cards: [EnumCard.Asset],
			m_total_value: 0,
		},
		ComponentGameValue: {
			fieldOrder: ['m_state', 'm_players', 'm_player_in_turn'],
			m_state: EnumGameState.WaitingForPlayers,
			m_players: [""],
			m_player_in_turn: "",
		},
		ComponentGame: {
			fieldOrder: ['m_ent_seed', 'm_state', 'm_players', 'm_player_in_turn'],
			m_ent_seed: 0,
			m_state: EnumGameState.WaitingForPlayers,
			m_players: [""],
			m_player_in_turn: "",
		},
		ComponentHandValue: {
			fieldOrder: ['m_cards'],
			m_cards: [EnumCard.Asset],
		},
		ComponentHand: {
			fieldOrder: ['m_ent_owner', 'm_cards'],
			m_ent_owner: "",
			m_cards: [EnumCard.Asset],
		},
		ComponentPlayer: {
			fieldOrder: ['m_ent_owner', 'm_username', 'm_moves_remaining', 'm_score', 'm_has_drawn', 'm_in_debt'],
			m_ent_owner: "",
			m_username: "",
			m_moves_remaining: 0,
			m_score: 0,
			m_has_drawn: false,
			m_in_debt: Option,
		},
		ComponentPlayerValue: {
			fieldOrder: ['m_username', 'm_moves_remaining', 'm_score', 'm_has_drawn', 'm_in_debt'],
			m_username: "",
			m_moves_remaining: 0,
			m_score: 0,
			m_has_drawn: false,
			m_in_debt: Option,
		},
		ERC__Balance: {
			fieldOrder: ['balance', 'type', 'tokenmetadata'],
			balance: '',
			type: 'ERC20',
			tokenMetadata: {
				fieldOrder: ['name', 'symbol', 'tokenId', 'decimals', 'contractAddress'],
				name: '',
				symbol: '',
				tokenId: '',
				decimals: '',
				contractAddress: '',
			},
		},
		ERC__Token: {
			fieldOrder: ['name', 'symbol', 'tokenId', 'decimals', 'contractAddress'],
			name: '',
			symbol: '',
			tokenId: '',
			decimals: '',
			contractAddress: '',
		},
		ERC__Transfer: {
			fieldOrder: ['from', 'to', 'amount', 'type', 'executed', 'tokenMetadata'],
			from: '',
			to: '',
			amount: '',
			type: 'ERC20',
			executedAt: '',
			tokenMetadata: {
				fieldOrder: ['name', 'symbol', 'tokenId', 'decimals', 'contractAddress'],
				name: '',
				symbol: '',
				tokenId: '',
				decimals: '',
				contractAddress: '',
			},
			transactionHash: '',
		},

	},
};
// Type definition for ERC__Balance struct
export type ERC__Type = 'ERC20' | 'ERC721';
export interface ERC__Balance {
    fieldOrder: string[];
    balance: string;
    type: string;
    tokenMetadata: ERC__Token;
}
export interface ERC__Token {
    fieldOrder: string[];
    name: string;
    symbol: string;
    tokenId: string;
    decimals: string;
    contractAddress: string;
}
export interface ERC__Transfer {
    fieldOrder: string[];
    from: string;
    to: string;
    amount: string;
    type: string;
    executedAt: string;
    tokenMetadata: ERC__Token;
    transactionHash: string;
}