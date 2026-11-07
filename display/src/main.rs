/* We'll be considering the signal from the board as <Game Over?><Score><Board State> */
use ratatui::*;

struct GameState {
    game_over : bool,
    score: u16,
    board_state: [u8; 1000]
}



fn main() {
    println!("Hello, world!");
}
