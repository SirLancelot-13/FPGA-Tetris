`timescale 1ns/1ps

// packetizer driving a real uart_tx; the serial line is decoded and the
// 37-byte packet is checked: A5 5A | status | score(2) | board(30) | crc(2)
module packetizer_tb;
`include "tb_util.vh"

localparam CPB = 8;
localparam HB  = 20000;          // heartbeat in clocks (a packet takes ~3000)
localparam T = 10;
localparam PKT = 37;

reg clk = 0;
always #(T/2) clk = ~clk;

reg game_over = 0;
reg [15:0] score = 0;
reg [GN-1:0] grid = 0;
wire tx_line, tx_done, tx_start;
wire [7:0] tx_data;

// uart_tx drives tx_done with blocking assignments in a clocked block, so when
// it is set/cleared relative to the packetizer's own posedge sampling depends on
// the simulator's evaluation order (the packetizer can miss the one-clock pulse
// and hang waiting for it). In hardware that output is a flop, so the packetizer
// sees the pulse on the edge after it is raised. Re-time it on the falling edge
// to get that behaviour deterministically in simulation.
reg tx_done_q = 0;
always @(negedge clk) tx_done_q <= tx_done;

packetizer #(.HB(HB)) pk (
    .clk(clk), .game_over(game_over), .score(score), .grid(grid),
    .tx_line(tx_line), .tx_done(tx_done_q), .tx_start(tx_start), .tx_data(tx_data)
);

uart_tx #(.CLKS_PER_BIT(CPB)) u (
    .clk(clk), .tx_start(tx_start), .tx_data(tx_data),
    .tx_line(tx_line), .tx_done(tx_done)
);

// ---- serial decoder: collects every byte seen on the line -----------------
reg [7:0] rx_bytes [0:1023];
time rx_times [0:1023];
integer n_rx = 0;
reg [7:0] sh;
integer k;
initial begin
    forever begin
        @(negedge tx_line);
        #(CPB*T/2);
        for (k = 0; k < 8; k = k + 1) begin
            #(CPB*T);
            sh[k] = tx_line;
        end
        #(CPB*T);
        rx_bytes[n_rx] = sh;
        rx_times[n_rx] = $time;
        n_rx = n_rx + 1;
    end
end

// CRC-16/CCITT-FALSE, init FFFF, poly 1021, same as the DUT intends
function [15:0] crc16(input [15:0] c, input [7:0] b);
    integer q;
begin
    crc16 = c ^ {b, 8'b0};
    for (q = 0; q < 8; q = q + 1)
        crc16 = crc16[15] ? (crc16 << 1) ^ 16'h1021 : crc16 << 1;
end
endfunction

// Check packet number p (0-based) against what the inputs were at its time
task check_packet(input integer p, input go, input [15:0] sc, input [GN-1:0] gr);
    integer base, b;
    reg [15:0] crc;
    reg [GN-1:0] board;
begin
    base = p * PKT;
    check(rx_bytes[base+0] === 8'hA5, "sync byte 0 = A5");
    check(rx_bytes[base+1] === 8'h5A, "sync byte 1 = 5A");
    check(rx_bytes[base+2] === {7'b0, go}, "status byte carries game_over");
    check({rx_bytes[base+3], rx_bytes[base+4]} === sc, "score is big-endian");
    for (b = 0; b < 30; b = b + 1) board[8*b +: 8] = rx_bytes[base+5+b];
    check(board === gr, "board bytes match grid (byte 0 = grid[7:0])");
    crc = 16'hFFFF;
    for (b = 2; b <= 34; b = b + 1) crc = crc16(crc, rx_bytes[base+b]);
    check({rx_bytes[base+35], rx_bytes[base+36]} === crc, "CRC covers bytes 2..34");
    if ({rx_bytes[base+35], rx_bytes[base+36]} !== crc)
        $display("    crc got %h%h expected %h", rx_bytes[base+35], rx_bytes[base+36], crc);
end
endtask

task wait_bytes(input integer n);
    integer guard;
begin
    guard = 0;
    while (n_rx < n && guard < 400000) begin @(posedge clk); guard = guard + 1; end
    check(n_rx >= n, "expected bytes arrived in time");
end
endtask

integer t_start, gap;

initial begin
    repeat (10) @(posedge clk);
    check(tx_start === 1'b0, "no transmit request at start");

    // Nothing changes, so nothing is sent until the heartbeat fires
    repeat (HB/2) @(posedge clk);
    check(n_rx == 0, "quiet while the inputs are unchanged");

    // First packet = the heartbeat, with all-zero state
    wait_bytes(PKT);
    check(n_rx == PKT, "exactly one packet");
    check_packet(0, 0, 16'h0000, 0);
    repeat (500) @(posedge clk);

    // A score change is sent immediately, long before the next heartbeat
    t_start = $time / T;
    @(negedge clk); score = 16'h1234;
    wait_bytes(2*PKT);
    check(($time / T) - t_start < HB/2, "state change is sent right away, not on heartbeat");
    check_packet(1, 0, 16'h1234, 0);
    check(n_rx == 2*PKT, "one packet per change");
    repeat (500) @(posedge clk);

    // A grid change with a recognisable pattern in each byte
    @(negedge clk);
    grid = setc(setc(setc(0, 0, 0, `DEAD_TETRIMINO_BLOCK), 5, 5, `ACTIVE_TETRIMINO_BLOCK), 11, 9, `DEAD_TETRIMINO_BLOCK);
    wait_bytes(3*PKT);
    check_packet(2, 0, 16'h1234, grid);
    repeat (500) @(posedge clk);

    // Game over flag
    @(negedge clk); game_over = 1;
    wait_bytes(4*PKT);
    check_packet(3, 1, 16'h1234, grid);
    repeat (500) @(posedge clk);

    // Dense data so every byte lane and the CRC see non-trivial values
    @(negedge clk);
    score = 16'hFFFF;
    for (k = 0; k < GN; k = k + 1) grid[k] = ($urandom % 2);
    wait_bytes(5*PKT);
    check_packet(4, 1, 16'hFFFF, grid);
    check(n_rx == 5*PKT, "still one packet per change");

    // With no further changes the packet is repeated as a heartbeat roughly every HB clocks
    wait_bytes(6*PKT);
    check_packet(5, 1, 16'hFFFF, grid);
    gap = (rx_times[5*PKT+PKT-1] - rx_times[4*PKT+PKT-1]) / T;
    check(gap > HB - 200 && gap < HB + 4000, "heartbeat interval is about HB clocks");
    if (!(gap > HB - 200 && gap < HB + 4000)) $display("    heartbeat gap = %0d clocks", gap);

    // Two quick successive changes while a packet is in flight: the final state must get through
    @(negedge clk); score = 16'h0001;
    repeat (200) @(posedge clk);          // mid-packet
    @(negedge clk); score = 16'h0002;
    wait_bytes(8*PKT);
    check_packet(7, 1, 16'h0002, grid);

    finish_test("packetizer");
end

initial begin
    #200_000_000;
    $display("FAIL: packetizer timeout (n_rx=%0d)", n_rx);
    $finish;
end

endmodule
