/* We'll be considering the signal from the board as <Magic Bytes><Game Over?><Score><Board State><Checksum for validating the packet> */
use ratatui::{
    layout::Constraint,
    style::{Color, Style},
    widgets::{Cell, Row, Table},
};

use std::{
    error::Error,
    io::{self, Read},
    sync::mpsc,
    thread,
    time::Duration,
};

use ratatui::crossterm::{
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
    board_state: [u8; 100]
}

struct Packet{
    data: Vec<u8>
}

const MAGIC: [u8; 2] = [0xA5,0x5A];
const PACKET_LENGTH : u8 = 37;
const CRC_POLYNOMIAL: u16 = 0x1021;
const BOARD_HEIGHT: u8 = 12;
const BOARD_WIDTH: u8 = 10;

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
    return crc;
}

impl GameState {
    fn new() -> Self {
        Self {
            game_over : false,
            score: 0,
            board_state: [0u8; 100]
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

    fn check_packet(&self) -> (u8, u16, &[u8]){
        if self.data.len()!=PACKET_LENGTH as usize||!self.check_magic(){return (2, 0, &[])}
        let game_over = self.data[2] as u8;
        let score = u16::from_be_bytes([self.data[3],self.data[4]]);
        let game_board = &self.data[5..105];
        let checksum = ((self.data[105] as u16)<<8)+(self.data[106] as u16);

        if (checksum == crc(&self.data[2..105],0xFFFF)){
            return (game_over, score, game_board)
        }
        return (2, 0, &[])
    }

    fn parse_packet(&self) -> ([u8;1000],u16){
        return ([0u8;1000], 0);
    }
    fn serialize(&mut self)->Result<(),Box<dyn Error>>{
        let mut port = serialport::new("/dev/ttyUSB0", 115_200).timeout(Duration::from_millis(100)).open()?;
        let mut b=[0u8;256];
        let ret_val = match port.read(&mut b) {
            Ok(n)  => { self.data.extend_from_slice(&b[..n]) }
            Err(e) if e.kind() == io::ErrorKind::TimedOut => { /* Nothing on the wire */ }
            Err(e) => return Err(e.into())
        };
        Ok(ret_val)
    }
}



fn render_board(board: &[u8; 100]) -> Table<'static> {
    let temp_board = board;
    let rows = (0..10).map(|y| {
        let cells = (0..10).map(|x| {
            let occupied = temp_board[y * 10 + x] != 0;

            if occupied {
                Cell::from("  ").style(
                    Style::default().bg(Color::Cyan)
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

fn main() -> Result<(), Box<dyn Error>> {
    let mut t = ratatui::init();
    let mut p = Packet::initialize();
    let mut board = [0u8; 100];
    loop {
        if let Err(e) = p.serialize() { ratatui::restore(); return Err(e) }
        while p.data.len() >= 107 {
            let rest = p.data.split_off(107);
            let (o, _, b) = p.check_packet();
            if o < 2 { board.copy_from_slice(b); p.data.clear(); } else { p.data.remove(0); }
            p.data.extend(rest);
        }
        t.draw(|f| f.render_widget(render_board(&board), f.area())).ok();
        if event::poll(Duration::ZERO)? {
            if let Event::Key(k) = event::read()? {
                if k.code == KeyCode::Char('q') { break }
            }
        }
    }
    ratatui::restore();
    Ok(())
}
