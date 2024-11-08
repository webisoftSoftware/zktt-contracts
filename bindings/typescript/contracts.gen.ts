import { DojoProvider } from "@dojoengine/core";
import { Account } from "starknet";
import * as models from "./models.gen";

export async function setupWorld(provider: DojoProvider) {

	const action_system_draw = async (account: Account, drawsFive: boolean) => {
		try {
			return await provider.execute(
				account,
				{
					contractName: "action_system",
					entryPoint: "draw",
					calldata: [drawsFive],
				}
			);
		} catch (error) {
			console.error(error);
		}
	};

	const action_system_play = async (account: Account, card: models.EnumCard) => {
		try {
			return await provider.execute(
				account,
				{
					contractName: "action_system",
					entryPoint: "play",
					calldata: [card],
				}
			);
		} catch (error) {
			console.error(error);
		}
	};

	const action_system_move = async (account: Account, card: models.EnumCard) => {
		try {
			return await provider.execute(
				account,
				{
					contractName: "action_system",
					entryPoint: "move",
					calldata: [card],
				}
			);
		} catch (error) {
			console.error(error);
		}
	};

	const action_system_payFee = async (account: Account, pay: Array<EnumCard>, recipient: string, payee: string) => {
		try {
			return await provider.execute(
				account,
				{
					contractName: "action_system",
					entryPoint: "pay_fee",
					calldata: [pay, recipient, payee],
				}
			);
		} catch (error) {
			console.error(error);
		}
	};

	const game_system_start = async (account: Account) => {
		try {
			return await provider.execute(
				account,
				{
					contractName: "game_system",
					entryPoint: "start",
					calldata: [],
				}
			);
		} catch (error) {
			console.error(error);
		}
	};

	const game_system_endTurn = async (account: Account) => {
		try {
			return await provider.execute(
				account,
				{
					contractName: "game_system",
					entryPoint: "end_turn",
					calldata: [],
				}
			);
		} catch (error) {
			console.error(error);
		}
	};

	const player_system_join = async (account: Account, username: string) => {
		try {
			return await provider.execute(
				account,
				{
					contractName: "player_system",
					entryPoint: "join",
					calldata: [username],
				}
			);
		} catch (error) {
			console.error(error);
		}
	};

	const player_system_leave = async (account: Account) => {
		try {
			return await provider.execute(
				account,
				{
					contractName: "player_system",
					entryPoint: "leave",
					calldata: [],
				}
			);
		} catch (error) {
			console.error(error);
		}
	};

	return {
		action_system: {
			draw: action_system_draw,
			play: action_system_play,
			move: action_system_move,
			payFee: action_system_payFee,
		},
		game_system: {
			start: game_system_start,
			endTurn: game_system_endTurn,
		},
		player_system: {
			join: player_system_join,
			leave: player_system_leave,
		},
	};
}