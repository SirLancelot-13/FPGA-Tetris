`timescale 1ns/1ps

module spawn_tetrimino_tb;
`include "tb_util.vh"

reg clk = 0;
always #5 clk = ~clk;
reg game_clk = 0;

reg [1:0] game_state = `SPAWN_STATE;
reg [7:0] cx2 = 0, cy2 = 0;
reg [GN-1:0] in_grid = 0;
wire [GN-1:0] out_grid;
wire [7:0] ocx2, ocy2;
wire [1:0] out_state;

spawn_tetrimino dut (
    .game_state(game_state), .clk(clk), .game_clk(game_clk),
    .in_central_x_x2(cx2), .in_central_y_x2(cy2), .input_grid(in_grid),
    .output_grid(out_grid), .out_central_x_x2(ocx2), .out_central_y_x2(ocy2),
    .changed_game_state(out_state)
);

task tick(input [1:0] s, input [GN-1:0] g);
begin
    game_state = s; in_grid = g;
    #1 game_clk = 1; #1 game_clk = 0; #1;
end
endtask

localparam D = `DEAD_TETRIMINO_BLOCK;
reg [GN-1:0] g, e;
integer id, n, rows_ok, cols_ok, i, j;
integer seen_i, seen_o, seen_other;

// Expected spawn shapes, taken from the shape table in spawn_tetrimino.v
function [GN-1:0] shape(input integer id);
    case (id)
        `IID: shape = act4(10,3, 10,4, 10,5, 10,6);
        `JID: shape = act4(10,3, 11,3, 10,4, 10,5);
        `LID: shape = act4(10,3, 10,4, 10,5, 11,5);
        `OID: shape = act4(10,4, 11,4, 10,5, 11,5);
        `SID: shape = act4(10,3, 10,4, 11,4, 11,5);
        `ZID: shape = act4(11,3, 10,4, 11,4, 10,5);
        `TID: shape = act4(10,3, 10,4, 11,4, 10,5);
        default: shape = 0;
    endcase
endfunction

initial begin
    // Each tetrimino id spawns the right blocks at the right centre
    for (id = 0; id < 7; id = id + 1) begin
        force dut.tetrimino_id = id;
        tick(`SPAWN_STATE, 0);
        check(out_grid === shape(id), "spawned shape matches its id");
        if (out_grid !== shape(id)) begin
            $display("    id %0d got:", id); dump(out_grid);
        end
        check(out_state === `MOVE_STATE, "spawn moves to MOVE_STATE");
        case (id)
            `IID:  check(ocx2 === 9 && ocy2 === 19, "I centre (4.5, 9.5)");
            `OID:  check(ocx2 === 9 && ocy2 === 21, "O centre (4.5, 10.5)");
            default: check(ocx2 === 8 && ocy2 === 20, "3-wide piece centre (4, 10)");
        endcase
    end
    release dut.tetrimino_id;

    // Spawning keeps dead blocks that are lower on the board
    g = setc(setc(0, 0, 0, D), 5, 5, D);
    force dut.tetrimino_id = `OID;
    tick(`SPAWN_STATE, g);
    check(out_grid === (shape(`OID) | g), "spawn leaves existing dead blocks alone");
    check(out_state === `MOVE_STATE, "dead blocks below the spawn area: no game over");
    release dut.tetrimino_id;

    // Game over when the spawn rows (top two) already contain dead blocks
    g = setc(0, `BOARD_HEIGHT-1, 4, D);
    tick(`SPAWN_STATE, g);
    check(out_state === `GAMEOVER_STATE, "dead block in the top row: game over");
    g = setc(0, `BOARD_HEIGHT-2, 7, D);
    tick(`SPAWN_STATE, g);
    check(out_state === `GAMEOVER_STATE, "dead block in the second row from the top: game over");
    g = setc(0, `BOARD_HEIGHT-3, 4, D);
    tick(`SPAWN_STATE, g);
    check(out_state === `MOVE_STATE, "dead block just below the spawn area: still playable");

    // Not in SPAWN_STATE: pass-through
    g = setc(0, 3, 3, D);
    cx2 = 12; cy2 = 34;
    tick(`MOVE_STATE, g);
    check(out_grid === g && out_state === `MOVE_STATE && ocx2 === 12 && ocy2 === 34, "MOVE_STATE: pass-through");
    tick(`CLEAR_STATE, g);
    check(out_grid === g && out_state === `CLEAR_STATE, "CLEAR_STATE: pass-through");
    tick(`GAMEOVER_STATE, g);
    check(out_grid === g && out_state === `GAMEOVER_STATE, "GAMEOVER_STATE: pass-through");
    cx2 = 0; cy2 = 0;

    // With the real LFSR: 60 spawns at irregular times always give a legal piece
    seen_i = 0; seen_o = 0; seen_other = 0;
    for (n = 0; n < 60; n = n + 1) begin
        repeat ($urandom_range(1, 13)) @(posedge clk);
        tick(`SPAWN_STATE, 0);
        check(countc(out_grid, `ACTIVE_TETRIMINO_BLOCK) == 4, "random spawn has exactly 4 active blocks");
        check(out_state === `MOVE_STATE, "random spawn goes to MOVE_STATE");
        rows_ok = 1; cols_ok = 1;
        for (i = 0; i < `BOARD_HEIGHT; i = i + 1)
            for (j = 0; j < `BOARD_WIDTH; j = j + 1)
                if (getc(out_grid, i, j) === `ACTIVE_TETRIMINO_BLOCK) begin
                    if (i < `BOARD_HEIGHT-2) rows_ok = 0;
                    if (j < 3 || j > 6) cols_ok = 0;
                end
        check(rows_ok == 1, "random spawn stays in the top two rows");
        check(cols_ok == 1, "random spawn stays in the central columns");
        if (ocx2 === 9 && ocy2 === 19) seen_i = seen_i + 1;
        else if (ocx2 === 9 && ocy2 === 21) seen_o = seen_o + 1;
        else if (ocx2 === 8 && ocy2 === 20) seen_other = seen_other + 1;
        else check(0, "random spawn has a legal centre");
    end
    check(seen_i + seen_o + seen_other == 60, "every random spawn is a known piece");
    check(seen_other > 0, "random spawns include 3-wide pieces");
    check(seen_i + seen_o > 0, "random spawns include I or O pieces");

    finish_test("spawn_tetrimino");
end

endmodule
