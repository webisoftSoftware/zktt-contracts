////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

mod components;
mod enums;
mod structs;
mod traits;

// TODO: Add comments to each component

pub use components::{
    ComponentGame,
    ComponentDealer,
    ComponentDeck,
    ComponentDeposit,
    ComponentHand,
    ComponentPlayer
};

pub use enums::{
    EnumCard,
    EnumGameState,
    EnumMoveError,
    EnumPlayerTarget,
    EnumGasFeeType,
    EnumBlockchainType
};

pub use structs::{
    StructAsset,
    StructBlockchain,
    StructAssetGroup
};

pub use traits::{
    game::{
        IGame, IAsset, IBlockchain, IDeck, IDealer, IPlayer, IHand, 
        IGasFee, IAssetGroup, IDraw
    },
    display::IDisplay,
    into::EnumCardInto,
    partialeq::{
        HandPartialEq,
        StructAssetEq,
        StructAssetGroupEq,
        StructBlockchainEq,
        ActionFrontrunEq,
        ActionGasFeeEq,
        ActionMajorityAttackEq
    }
};

use starknet::ContractAddress;
use origami_random::deck::{Deck, DeckTrait};
use core::fmt::{Display, Formatter, Error};
use debug::PrintTrait;