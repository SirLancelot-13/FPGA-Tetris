`timescale 1ns/1ps

module line_clear_tb;
`include "tb_util.vh"

reg clk = 0;
always #5 clk = ~clk;

reg [1:0] game_state = `MOVE_STATE;
reg [15:0] score = 0;
reg [GN-1:0] in_grid = 0;
wire [GN-1:0] out_grid;
wire [1:0] out_state;
wire [15:0] out_score;

line_clear dut (
    .game_state(game_state), .score(score), .clk(clk), .input_grid(in_grid),
    .output_grid(out_grid), .changed_game_state(out_state), .changed_score(out_score)
);

// Apply inputs, let one clock edge pass, then look at the registered outputs
task step(input [1:0] s, input [15:0] sc, input [GN-1:0] g);
begin
    game_state = s; score = sc; in_grid = g;
    @(posedge clk); #1;
end
endtask

reg [GN-1:0] g, e;
integer r;
localparam D = `DEAD_TETRIMINO_BLOCK;
localparam A = `ACTIVE_TETRIMINO_BLOCK;

initial begin
    // Outside CLEAR_STATE the module is a pass-through, even with a full row
    g = fillrow(0, 0, D);
    step(`MOVE_STATE, 16'd7, g);
    check(out_grid === g, "MOVE_STATE: grid untouched");
    check(out_state === `MOVE_STATE, "MOVE_STATE: state untouched");
    check(out_score === 16'd7, "MOVE_STATE: score untouched");
    step(`SPAWN_STATE, 16'd7, g);
    check(out_grid === g && out_state === `SPAWN_STATE, "SPAWN_STATE: pass-through");
    step(`GAMEOVER_STATE, 16'd7, g);
    check(out_grid === g && out_state === `GAMEOVER_STATE, "GAMEOVER_STATE: pass-through");

    // CLEAR_STATE with nothing to clear: back to spawn, grid and score unchanged
    g = setc(setc(0, 0, 0, D), 3, 4, D);
    g = setc(g, 5, 5, A);
    step(`CLEAR_STATE, 16'd100, g);
    check(out_grid === g, "no full row: grid unchanged");
    check(out_state === `SPAWN_STATE, "no full row: goes to SPAWN_STATE");
    check(out_score === 16'd100, "no full row: score unchanged");

    // A row with 9 of 10 blocks is not full
    g = fillrow(0, 0, D);
    g = setc(g, 0, 6, `EMPTY_BLOCK);
    step(`CLEAR_STATE, 16'd0, g);
    check(out_grid === g && out_score === 16'd0, "9/10 row is kept");

    // Empty board
    step(`CLEAR_STATE, 16'd5, 0);
    check(out_grid === 0 && out_state === `SPAWN_STATE && out_score === 16'd5, "empty board");

    // One full row at the bottom; blocks above fall by one
    g = fillrow(0, 0, D);
    g = setc(g, 1, 3, D);
    g = setc(g, 2, 3, D);
    g = setc(g, 4, 9, D);
    e = setc(setc(setc(0, 0, 3, D), 1, 3, D), 3, 9, D);
    step(`CLEAR_STATE, 16'd0, g);
    check(out_grid === e, "1 line at bottom: rows above shift down");
    check(out_score === 16'd100, "1 line: +100");
    check(out_state === `SPAWN_STATE, "1 line: SPAWN_STATE");
    if (out_grid !== e) begin $display("  got:"); dump(out_grid); $display("  expected:"); dump(e); end

    // Full row in the middle: rows below must not move, rows above fall
    g = fillrow(0, 2, D);
    g = setc(g, 0, 5, D);
    g = setc(g, 1, 1, D);
    g = setc(g, 3, 7, D);
    g = setc(g, 4, 0, D);
    e = setc(setc(setc(setc(0, 0, 5, D), 1, 1, D), 2, 7, D), 3, 0, D);
    step(`CLEAR_STATE, 16'd1000, g);
    check(out_grid === e, "1 line in middle: below stays, above falls");
    check(out_score === 16'd1100, "score accumulates onto existing score");
    if (out_grid !== e) begin $display("  got:"); dump(out_grid); $display("  expected:"); dump(e); end

    // Two non-adjacent full rows: blocks fall by 1 or 2 depending on position
    g = fillrow(fillrow(0, 0, D), 2, D);
    g = setc(g, 1, 1, D);
    g = setc(g, 3, 4, D);
    e = setc(setc(0, 0, 1, D), 1, 4, D);
    step(`CLEAR_STATE, 16'd0, g);
    check(out_grid === e, "2 split lines: each block drops by lines cleared below it");
    check(out_score === 16'd250, "2 lines: +250");
    if (out_grid !== e) begin $display("  got:"); dump(out_grid); $display("  expected:"); dump(e); end

    // Two adjacent rows
    g = fillrow(fillrow(0, 3, D), 4, D);
    g = setc(g, 5, 2, D);
    e = setc(0, 3, 2, D);
    step(`CLEAR_STATE, 16'd0, g);
    check(out_grid === e && out_score === 16'd250, "2 adjacent lines");

    // Three lines
    g = fillrow(fillrow(fillrow(0, 0, D), 1, D), 2, D);
    g = setc(g, 3, 0, D);
    e = setc(0, 0, 0, D);
    step(`CLEAR_STATE, 16'd0, g);
    check(out_grid === e, "3 lines cleared");
    check(out_score === 16'd400, "3 lines: +400");

    // Four lines (tetris)
    g = fillrow(fillrow(fillrow(fillrow(0, 0, D), 1, D), 2, D), 3, D);
    g = setc(g, 4, 9, D);
    e = setc(0, 0, 9, D);
    step(`CLEAR_STATE, 16'd0, g);
    check(out_grid === e, "4 lines cleared");
    check(out_score === 16'd600, "4 lines: +600");

    // Active (falling) blocks never count towards a full row
    g = fillrow(0, 0, A);
    step(`CLEAR_STATE, 16'd0, g);
    check(out_score === 16'd0, "full row of active blocks is not cleared");

    // Top rows (the spawn area) are handled as well
    g = fillrow(0, `BOARD_HEIGHT-1, D);
    step(`CLEAR_STATE, 16'd0, g);
    check(out_grid === 0 && out_score === 16'd100, "full row in the topmost row");

    // Every row full
    g = 0;
    for (r = 0; r < `BOARD_HEIGHT; r = r + 1) g = fillrow(g, r, D);
    step(`CLEAR_STATE, 16'd0, g);
    check(out_grid !== g, "completely full board does not stay full");

    // Clearing is idempotent once the board is settled: a second pass changes nothing
    g = fillrow(0, 0, D);
    g = setc(g, 1, 2, D);
    step(`CLEAR_STATE, 16'd0, g);
    e = out_grid;
    step(`CLEAR_STATE, out_score, e);
    check(out_grid === e, "second clear pass leaves a cleared board alone");

    finish_test("line_clear");
end

initial begin
    #1_000_000;
    $display("FAIL: line_clear timeout");
    $finish;
end

endmodule
