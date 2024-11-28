import { DojoProvider } from "@dojoengine/core";
import { Account } from "starknet";
import * as models from "./models.gen";

export async function setupWorld(provider: DojoProvider) {

	const game_system_start = async (snAccount: Account, table: string) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "game_system",
					entrypoint: "start",
					calldata: [table],
				},
				"zktt",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const game_system_endTurn = async (snAccount: Account, table: string) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "game_system",
					entrypoint: "end_turn",
					calldata: [table],
				},
				"zktt",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const game_system_end = async (snAccount: Account, table: string) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "game_system",
					entrypoint: "end",
					calldata: [table],
				},
				"zktt",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const action_system_draw = async (snAccount: Account, drawsFive: boolean, table: string) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "action_system",
					entrypoint: "draw",
					calldata: [drawsFive, table],
				},
				"zktt",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const action_system_play = async (snAccount: Account, card: models.EnumCard, table: string) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "action_system",
					entrypoint: "play",
					calldata: [card, table],
				},
				"zktt",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const action_system_move = async (snAccount: Account, card: models.EnumCard, table: string) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "action_system",
					entrypoint: "move",
					calldata: [card, table],
				},
				"zktt",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const action_system_payFee = async (snAccount: Account, pay: Array<models.EnumCard>, recipient: string, payee: string, table: string) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "action_system",
					entrypoint: "pay_fee",
					calldata: [pay, recipient, payee, table],
				},
				"zktt",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const player_system_join = async (snAccount: Account, username: string, table: string) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "player_system",
					entrypoint: "join",
					calldata: [username, table],
				},
				"zktt",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const player_system_setReady = async (snAccount: Account, ready: boolean, table: string) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "player_system",
					entrypoint: "set_ready",
					calldata: [ready, table],
				},
				"zktt",
			);
		} catch (error) {
			console.error(error);
		}
	};

	const player_system_leave = async (snAccount: Account, table: string) => {
		try {
			return await provider.execute(
				snAccount,
				{
					contractName: "player_system",
					entrypoint: "leave",
					calldata: [table],
				},
				"zktt",
			);
		} catch (error) {
			console.error(error);
		}
	};

	return {
		game_system: {
			start: game_system_start,
			endTurn: game_system_endTurn,
			end: game_system_end,
		},
		action_system: {
			draw: action_system_draw,
			play: action_system_play,
			move: action_system_move,
			payFee: action_system_payFee,
		},
		player_system: {
			join: player_system_join,
			setReady: player_system_setReady,
			leave: player_system_leave,
		},
	};
}