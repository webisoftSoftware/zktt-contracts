////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////  ______  __  __   ______  ______   ////////////////////////////////
//////////////////////////////// /\___  \/\ \/ /  /\__  _\/\__  _\  ////////////////////////////////
//////////////////////////////// \/_/  /_\ \  _`-.\/_/\ \/\/_/\ \/  ////////////////////////////////
////////////////////////////////   /\_____\ \_\ \_\  \ \_\   \ \_\  ////////////////////////////////
////////////////////////////////   \/_____/\/_/\/_/   \/_/    \/_/  ////////////////////////////////
////////////////////////////////                                    ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

mod models {
    mod structs;
    mod actions;
    mod traits;
    mod enums;
    mod components;
}

mod systems {
    mod actions;
    mod game;
    mod player;
}

#[cfg(test)] // Only compile when testing (sozo test).
mod tests {
    mod utils;
    mod integration {
        mod test_game;
        mod test_actions;
        mod test_player;
        mod test_cards;
    }
    mod unit {}
}
