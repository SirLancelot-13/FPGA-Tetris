/* We'll be considering the signal from the board as <Magic Bytes><Game Over?><Score><Board State><Checksum for validating the packet> */
use ratatui::*;
use std::{
    error::Error,
    io::{self, Read},
    sync::mpsc,
    thread,
    time::Duration,
};

use crossterm::{
    event::{self, Event, KeyCode},
    execute,
    terminal::{
        disable_raw_mode, enable_raw_mode,
        EnterAlternateScreen, LeaveAlternateScreen,
    },
};

#[derive(Clone, Copy)]
struct GameState {
    game_over : bool,
    score: u16,
    board_state: [u8; 1000]
}

struct Packet{
    data: Vec<u8>
}

//TODO: Add magic value here
const MAGIC: [u8; 2] = [0,0];
const PACKET_LENGTH : u8 = 125;
const CRC_POLYNOMIAL: u16 = 67;

//CRC-16 to check if the packet is corrupted or not.
fn crc(data: &[u8], init: u16) -> u16 {
    let mut crc = init;
    for &byte in data {
        crc^= (byte as u16) << 8;
        for _ in 0..8{
            if (crc & 0x8000 != 0) {crc = (crc<<1)^CRC_POLYNOMIAL;}
            else {crc<<=1;}
        }
    }
    return 0;
}

impl GameState {
    fn new() -> Self {
        Self {
            game_over : false,
            score: 0,
            board_state: [0u8; 1000]
        }
    }
}

impl Packet {
    fn initialize() -> Self {
        Self {
            data: Vec::new()
        }
    }
    fn check_magic(&self) -> bool {
        return self.data[..2]==MAGIC;
    }

    fn check_packet(&self){

    }

    fn parse_packet(&self) -> ([u8;1000],u16){
        return ([0u8;1000], 0);
    }
}



fn render_board(board: &[u8; 100]) -> Table<'static> {
    let temp_board = board.try_into().unwrap();
    let rows = (0..10).map(|y| {
        let cells = (0..10).map(|x| {
            let occupied = temp_board[y * 10 + x] != 0;

            if occupied {
                Cell::from(" ").style(
                    Style::default().fg(Color::Cyan)
                )
            } else {
                Cell::from("  ").style(
                    Style::default().fg(Color::DarkGray)
                )
            }
        });

        Row::new(cells)
    });

    let widths = vec![ratatui::layout::Constraint::Length(2); 10];

    Table::new(rows, widths)
        .style(Style::default().bg(Color::Black))
}

fn main() {
    println!("Hello, world!");
}
