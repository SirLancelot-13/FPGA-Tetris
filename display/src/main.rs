/* We'll be considering the signal from the board as <Magic Bytes><Game Over?><Score><Board State><Checksum for validating the packet> */
use ratatui::{
    Frame,
    layout::{Constraint, Layout, Rect},
    style::{Color, Modifier, Style, Stylize},
    text::{Line, Span},
    widgets::{Block, BorderType, Paragraph},
};

use std::{
    error::Error,
    io::{self, Read},
    sync::mpsc,
    thread,
    time::Duration,
};

use ratatui::crossterm::event::{self, Event, KeyCode};

#[derive(Clone, Copy)]
struct GameState {
    game_over : bool,
    score: u16,
    board_state: [u8; 120]
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
            board_state: [0u8; 120]
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
        let game_board = &self.data[5..35];
        let checksum = ((self.data[35] as u16)<<8)+(self.data[36] as u16);

        if (checksum == crc(&self.data[2..35],0xFFFF)){
            return (game_over, score, game_board)
        }
        return (2, 0, &[])
    }

    fn parse_packet(&self) -> ([u8;1000],u16){
        return ([0u8;1000], 0);
    }
    fn serialize(&mut self, port: &mut dyn serialport::SerialPort)->Result<(),Box<dyn Error>>{
        let mut b=[0u8;256];
        let ret_val = match port.read(&mut b) {
            Ok(n)  => { self.data.extend_from_slice(&b[..n]) }
            Err(e) if e.kind() == io::ErrorKind::TimedOut => { /* Nothing on the wire */ }
            Err(e) => return Err(e.into())
        };
        Ok(ret_val)
    }
}



const BW: u16 = BOARD_WIDTH as u16 * 2 + 2;
const BH: u16 = BOARD_HEIGHT as u16 + 2;
const SIDE_W: u16 = 24;

fn board_lines(board: &[u8; 120]) -> Vec<Line<'static>> {
    let (w, h) = (BOARD_WIDTH as usize, BOARD_HEIGHT as usize);
    (0..h).map(|y| {
        let row = h - 1 - y;
        let spawn = row >= h - 2;
        Line::from((0..w).map(|x| match board[row * w + x] {
            2 => Span::styled("  ", Style::new().bg(Color::Yellow)),
            1 => Span::styled("  ", Style::new().bg(Color::Cyan)),
            _ if spawn => Span::styled(" ·", Style::new().fg(Color::DarkGray).bg(Color::Indexed(236))),
            _ => Span::styled(" ·", Style::new().fg(Color::DarkGray)),
        }).collect::<Vec<_>>())
    }).collect()
}

fn side_lines(g: &GameState, live: bool, best: Option<i64>) -> Vec<Line<'static>> {
    let status = match (live, g.game_over) {
        (false, _) => Span::styled("WAITING FOR BOARD...", Style::new().fg(Color::Yellow).add_modifier(Modifier::SLOW_BLINK)),
        (true, true) => Span::styled("GAME OVER", Style::new().fg(Color::Red).bold()),
        (true, false) => Span::styled("PLAYING", Style::new().fg(Color::Green).bold()),
    };
    let key = |k: &'static str, d: &'static str| Line::from(vec![Span::styled(k, Style::new().fg(Color::Cyan).bold()), Span::raw(d).dark_gray()]);
    vec![
        Line::from("SCORE").dark_gray(),
        Line::from(if live { g.score.to_string() } else { "-".into() }).fg(Color::Yellow).bold(),
        Line::from(vec![Span::raw("BEST ").dark_gray(), Span::raw(best.map_or("-".into(), |b| b.to_string())).fg(Color::Magenta).bold()]),
        Line::from(""),
        Line::from(status),
        Line::from(""),
        key("W       ", "rotate"),
        key("A / D   ", "move"),
        key("S       ", "drop"),
        key("centre  ", "reset"),
        key("q       ", "quit"),
    ]
}

fn draw(f: &mut Frame, g: &GameState, live: bool, best: Option<i64>) {
    let area = f.area();
    if area.width < BW || area.height < BH {
        f.render_widget(Paragraph::new("terminal too small").red().centered(), area.centered_vertically(Constraint::Length(1)));
        return;
    }
    let wide = area.width > BW + SIDE_W;
    let [board_area, _, side_area] = if wide {
        Layout::horizontal([Constraint::Length(BW), Constraint::Length(1), Constraint::Length(SIDE_W)])
            .areas(area.centered(Constraint::Length(BW + 1 + SIDE_W), Constraint::Length(BH)))
    } else { [area.centered(Constraint::Length(BW), Constraint::Length(BH)), Rect::ZERO, Rect::ZERO] };
    let mut board = Block::bordered().border_type(BorderType::Rounded)
        .border_style(Style::new().fg(if g.game_over { Color::Red } else { Color::Blue }))
        .title(Line::from(" TETRIS ").bold().centered());
    if !wide {
        let s = if !live { " waiting... ".into() } else if g.game_over { format!(" {} OVER ", g.score) } else { format!(" {} ", g.score) };
        board = board.title_bottom(Line::from(s).bold().centered());
    }
    f.render_widget(Paragraph::new(board_lines(&g.board_state)).block(board), board_area);
    if wide {
        let side = Block::bordered().border_type(BorderType::Rounded).border_style(Style::new().dark_gray()).title(" INFO ");
        f.render_widget(Paragraph::new(side_lines(g, live, best)).block(side), side_area);
    }
}

fn best_score(db: &rusqlite::Connection) -> Option<i64> {
    db.query_row("SELECT MAX(score) FROM scores", [], |r| r.get::<_, Option<i64>>(0)).ok().flatten()
}

fn main() -> Result<(), Box<dyn Error>> {
    let db = rusqlite::Connection::open("scores.db")?;
    db.execute("CREATE TABLE IF NOT EXISTS scores (id INTEGER PRIMARY KEY, score INTEGER, at DATETIME DEFAULT CURRENT_TIMESTAMP)", ())?;
    let (tx, rx) = mpsc::channel::<Result<GameState, String>>();
    thread::spawn(move || {
        let mut p = Packet::initialize();
        let mut port = match serialport::new("/dev/ttyUSB0", 115_200).timeout(Duration::from_millis(100)).open() {
            Ok(x) => x,
            Err(e) => { tx.send(Err(e.to_string())).ok(); return }
        };
        loop {
            if let Err(e) = p.serialize(&mut *port) { tx.send(Err(e.to_string())).ok(); return }
            while p.data.len() >= 37 {
                let rest = p.data.split_off(37);
                let (o, s, b) = p.check_packet();
                if o < 2 {
                    let mut g = GameState::new();
                    g.game_over = o == 1;
                    g.score = s;
                    for k in 0..120 { g.board_state[k] = b[k / 4] >> 2 * (k % 4) & 3 }
                    if tx.send(Ok(g)).is_err() { return }
                    p.data.clear();
                } else { p.data.remove(0); }
                p.data.extend(rest);
            }
        }
    });
    let mut t = ratatui::init();
    let mut g = GameState::new();
    let mut live = false;
    let mut best = best_score(&db);
    loop {
        while let Ok(m) = rx.try_recv() {
            match m {
                Ok(n) => {
                    if n.game_over && !g.game_over { db.execute("INSERT INTO scores (score) VALUES (?1)", [n.score]).unwrap(); best = best_score(&db); }
                    g = n;
                    live = true;
                }
                Err(e) => { ratatui::restore(); return Err(e.into()) }
            }
        }
        t.draw(|f| draw(f, &g, live, best)).ok();
        if event::poll(Duration::from_millis(50))? {
            if let Event::Key(k) = event::read()? {
                if k.code == KeyCode::Char('q') { break }
            }
        }
    }
    ratatui::restore();
    Ok(())
}
