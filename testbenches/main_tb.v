`timescale 1ns/1ps

// Whole-game integration test of `main`: spawn -> fall -> buttons -> lock ->
// line clear -> game over, plus the UART packet stream.
//
// The real game clock has a half period of 25M clocks, so the clock divider is
// forced to a short value (clock_gen_tb checks the real constant).
module main_tb;
`include "tb_util.vh"

localparam HALF = 100;       // forced game_clk half period in clocks
localparam T = 20;           // 50 MHz
localparam CPB = 67;         // uart_tx default
localparam PKT = 37;

reg clk = 0;
always #(T/2) clk = ~clk;

reg [4:0] pb = 0;            // pb[0]=w rotate, pb[1]=s down, pb[2]=a left, pb[3]=d right
wire txd;

main dut (.pb(pb), .clk(clk), .usb_uart_txd(txd));

initial force dut.clock_gen_inst.half_period = HALF;

localparam D = `DEAD_TETRIMINO_BLOCK;
localparam A = `ACTIVE_TETRIMINO_BLOCK;

// ---- UART capture ----------------------------------------------------------
reg [7:0] rx_bytes [0:511];
integer n_rx = 0;
reg [7:0] sh;
integer kk;
initial begin
    forever begin
        @(negedge txd);
        #(CPB*T/2);
        for (kk = 0; kk < 8; kk = kk + 1) begin
            #(CPB*T);
            sh[kk] = txd;
        end
        #(CPB*T);
        rx_bytes[n_rx] = sh;
        n_rx = n_rx + 1;
    end
end

function [15:0] crc16(input [15:0] c, input [7:0] b);
    integer q;
begin
    crc16 = c ^ {b, 8'b0};
    for (q = 0; q < 8; q = q + 1)
        crc16 = crc16[15] ? (crc16 << 1) ^ 16'h1021 : crc16 << 1;
end
endfunction

// ---- helpers ---------------------------------------------------------------
function integer mincol(input [GN-1:0] g);
    integer i, j;
begin
    mincol = 99;
    for (i = 0; i < `BOARD_HEIGHT; i = i + 1)
        for (j = 0; j < `BOARD_WIDTH; j = j + 1)
            if (getc(g, i, j) === A && j < mincol) mincol = j;
end
endfunction

function integer maxrow(input [GN-1:0] g);
    integer i, j;
begin
    maxrow = -1;
    for (i = 0; i < `BOARD_HEIGHT; i = i + 1)
        for (j = 0; j < `BOARD_WIDTH; j = j + 1)
            if (getc(g, i, j) === A && i > maxrow) maxrow = i;
end
endfunction

task press(input integer bit_idx, input integer hold_clks);
begin
    pb[bit_idx] = 1;
    repeat (hold_clks) @(posedge clk);
    pb[bit_idx] = 0;
    repeat (4) @(posedge clk);
end
endtask

// Wait just after a game_clk rising edge, then a few clocks more so state has settled
task after_tick;
begin
    @(posedge dut.game_clk);
    repeat (10) @(posedge clk);
end
endtask

task wait_state(input [1:0] s, input integer max_clks);
    integer c;
begin
    c = 0;
    while (dut.game_state !== s && c < max_clks) begin @(posedge clk); c = c + 1; end
    check(dut.game_state === s, "reached expected game state");
end
endtask

reg [GN-1:0] g0, g1, e;
integer col0, row0, c, packets_ok, p, b;
reg [15:0] crc;
reg [15:0] score_before;

initial begin
    #1;

    // ---- reset values --------------------------------------------------------
    check(dut.game_state === `SPAWN_STATE, "game starts in SPAWN_STATE");
    check(dut.score === 16'd0, "score starts at 0");
    check(dut.grid === 0, "board starts empty");

    // ---- line clearing through the full pipeline -----------------------------
    // Pretend a piece just locked: bottom row full, one dead block sitting on it
    dut.grid = setc(fillrow(0, 0, D), 1, 3, D);
    dut.game_state = `CLEAR_STATE;
    wait_state(`SPAWN_STATE, 20*HALF);
    check(dut.score === 16'd100, "clearing one line scores 100 through main");
    check(dut.grid === setc(0, 0, 3, D), "block above the cleared line falls down");

    // ---- spawn ---------------------------------------------------------------
    wait_state(`MOVE_STATE, 20*HALF);
    after_tick;
    g0 = dut.grid;
    check(countc(g0, A) == 4, "a piece with 4 active blocks is on the board");
    check(countc(g0, D) == 1, "the earlier dead block is still there");
    check(dut.cy2 !== 8'd0, "centre y was set by the spawner");

    // ---- gravity -------------------------------------------------------------
    row0 = maxrow(dut.grid);
    @(posedge dut.game_clk); repeat (10) @(posedge clk);
    check(maxrow(dut.grid) == row0 - 1, "piece falls one row per game tick");
    check(countc(dut.grid, A) == 4, "piece stays intact while falling");

    // ---- buttons -------------------------------------------------------------
    // Left
    after_tick;
    g0 = dut.grid; col0 = mincol(g0);
    press(2, 30);                 // held for 30 clocks: must count as a single press
    g1 = dut.grid;
    // If this fails with the piece going RIGHT: `.dx(dkey-akey)` in main.v is evaluated
    // 1 bit wide by Icarus (0-1 = 1), so 'a' and 'd' both give dx=+1.
    check(mincol(g1) == col0 - 1, "'a' moves the piece one column left (held key = one move)");
    if (mincol(g1) != col0 - 1) $display("    min column before %0d, after %0d", col0, mincol(g1));
    check(maxrow(g1) == maxrow(g0), "moving sideways does not drop the piece");
    // Right, twice
    press(3, 5);
    press(3, 5);
    check(mincol(dut.grid) == col0 + 1, "'d' pressed twice moves the piece two columns right");
    // Down
    after_tick;
    g0 = dut.grid;
    press(1, 5);
    check(maxrow(dut.grid) == maxrow(g0) - 1, "'s' soft-drops the piece one row");
    check(mincol(dut.grid) == mincol(g0), "soft drop keeps the column");
    // Both left and right at once cancel
    after_tick;
    g0 = dut.grid;
    pb[2] = 1; pb[3] = 1; repeat (10) @(posedge clk); pb[2] = 0; pb[3] = 0; repeat (4) @(posedge clk);
    check(mincol(dut.grid) === mincol(g0) || mincol(dut.grid) === mincol(g0) - 1 || mincol(dut.grid) === mincol(g0) + 1,
          "pressing both sideways keys leaves a sane piece");
    check(countc(dut.grid, A) == 4, "piece still intact after both sideways keys");
    // Rotate
    after_tick;
    g0 = dut.grid;
    press(0, 5);
    check(countc(dut.grid, A) == 4, "'w' rotation keeps 4 active blocks");
    check(dut.game_state === `MOVE_STATE, "rotation does not change game state");

    // ---- let it play out: pieces stack in the middle until game over --------
    c = 0;
    while (dut.game_state !== `GAMEOVER_STATE && c < 400*HALF*2*30) begin
        @(posedge clk); c = c + 1;
    end
    check(dut.game_state === `GAMEOVER_STATE, "stacking pieces in the middle eventually ends the game");
    $display("    game over after %0d clocks, score %0d", c, dut.score);

    // Game over is terminal
    g0 = dut.grid; score_before = dut.score;
    repeat (6*HALF*2) @(posedge clk);
    check(dut.game_state === `GAMEOVER_STATE, "game over is sticky");
    check(dut.grid === g0, "board frozen after game over");
    check(dut.score === score_before, "score frozen after game over");
    // buttons do nothing useful: board must not gain/lose active blocks (none at game over?)
    check(countc(dut.grid, A) <= 4, "no extra active blocks appear");

    // ---- UART stream ---------------------------------------------------------
    // Wait until the stream is long enough for 2 packets and the last packet reports game over
    c = 0;
    while (n_rx < 2*PKT && c < 3_000_000) begin @(posedge clk); c = c + 1; end
    check(n_rx >= 2*PKT, "at least two packets were transmitted");

    packets_ok = 1;
    for (p = 0; p < 2; p = p + 1) begin
        if (rx_bytes[p*PKT] !== 8'hA5 || rx_bytes[p*PKT+1] !== 8'h5A) packets_ok = 0;
        crc = 16'hFFFF;
        for (b = 2; b <= 34; b = b + 1) crc = crc16(crc, rx_bytes[p*PKT+b]);
        if ({rx_bytes[p*PKT+35], rx_bytes[p*PKT+36]} !== crc) packets_ok = 0;
    end
    check(packets_ok == 1, "transmitted packets are framed (A5 5A) and have valid CRC");

    // Eventually a packet with game_over set and the final score must arrive.
    // Keep listening until a complete packet appears that matches the final state.
    c = 0; e = 0;
    while (c < 6_000_000) begin
        @(posedge clk); c = c + 1;
        if (n_rx >= PKT && (n_rx % PKT) == 0) begin
            if (rx_bytes[n_rx-PKT+2] === 8'h01 && {rx_bytes[n_rx-PKT+3], rx_bytes[n_rx-PKT+4]} === dut.score) begin
                for (b = 0; b < 30; b = b + 1) e[8*b +: 8] = rx_bytes[n_rx-PKT+5+b];
                c = 99_000_000;
            end
        end
    end
    check(c == 99_000_000, "a game-over packet with the final score was transmitted");
    check(e === dut.grid, "game-over packet carries the final board");

    finish_test("main");
end

initial begin
    #2_000_000_000;
    $display("FAIL: main timeout (state=%0d)", dut.game_state);
    $finish;
end

endmodule
