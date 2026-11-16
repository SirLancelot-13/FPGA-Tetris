`timescale 1ns/1ps

module tetrimino_gravity_tb;
`include "tb_util.vh"

reg game_clk = 0;
reg [1:0] game_state = `MOVE_STATE;
reg [7:0] cx2 = 9, cy2 = 21;
reg [GN-1:0] in_grid = 0;
wire [GN-1:0] out_grid;
wire [7:0] ocx2, ocy2;
wire [1:0] out_state;

tetrimino_gravity dut (
    .game_state(game_state), .game_clk(game_clk),
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
localparam A = `ACTIVE_TETRIMINO_BLOCK;
reg [GN-1:0] g, e;
integer n;

initial begin
    // O piece in free air falls one row per game tick, centre y follows
    g = act4(8,4, 9,4, 8,5, 9,5);
    tick(`MOVE_STATE, g);
    check(out_grid === act4(7,4, 8,4, 7,5, 8,5), "free piece falls one row");
    check(out_state === `MOVE_STATE, "still MOVE_STATE while falling");
    check(ocy2 === cy2 - 2, "centre y decreases by 2 (half-units)");
    check(ocx2 === cx2, "centre x unchanged");

    // Fall to the floor, step by step
    g = act4(10,4, 11,4, 10,5, 11,5);
    for (n = 0; n < 10; n = n + 1) begin
        tick(`MOVE_STATE, g);
        g = out_grid;
        cy2 = ocy2;
    end
    check(out_grid === act4(0,4, 1,4, 0,5, 1,5), "piece reaches the floor after 10 ticks");
    check(out_state === `MOVE_STATE, "piece resting on the floor is not locked until the next tick");

    // On the floor: the next tick locks the piece and requests line clearing
    tick(`MOVE_STATE, g);
    e = g; // same cells but dead
    e = setc(setc(setc(setc(0, 0,4, D), 1,4, D), 0,5, D), 1,5, D);
    check(out_grid === e, "piece on floor turns into dead blocks");
    check(out_state === `CLEAR_STATE, "locking moves to CLEAR_STATE");
    check(countc(out_grid, A) == 0, "no active blocks left after locking");

    // Landing on top of dead blocks
    g = setc(setc(0, 0, 4, D), 0, 5, D);
    g = setc(setc(g, 1, 4, A), 1, 5, A);
    tick(`MOVE_STATE, g);
    e = setc(setc(setc(setc(0, 0,4, D), 0,5, D), 1,4, D), 1,5, D);
    check(out_grid === e && out_state === `CLEAR_STATE, "piece lands on dead blocks and locks");

    // Only part of the piece is blocked: the whole piece still locks
    g = setc(act4(4,0, 4,1, 4,2, 4,3), 3, 0, D);   // dead block under the left end of an I piece
    tick(`MOVE_STATE, g);
    check(countc(out_grid, A) == 0 && countc(out_grid, D) == 5, "partially supported piece locks as a whole");
    check(out_state === `CLEAR_STATE, "partial support: CLEAR_STATE");

    // Not in MOVE_STATE: no movement, state is passed through
    g = act4(8,4, 9,4, 8,5, 9,5);
    tick(`SPAWN_STATE, g);
    check(out_grid === g && out_state === `SPAWN_STATE && ocy2 === cy2, "SPAWN_STATE: pass-through");
    tick(`CLEAR_STATE, g);
    check(out_grid === g && out_state === `CLEAR_STATE, "CLEAR_STATE: pass-through");
    tick(`GAMEOVER_STATE, g);
    check(out_grid === g && out_state === `GAMEOVER_STATE, "GAMEOVER_STATE: pass-through");

    // Existing dead blocks far from the piece are left alone
    g = act4(8,4, 9,4, 8,5, 9,5);
    g = setc(g, 0, 0, D);
    tick(`MOVE_STATE, g);
    check(getc(out_grid, 0, 0) === D, "unrelated dead block preserved");
    check(countc(out_grid, A) == 4, "piece keeps four blocks while falling");

    finish_test("tetrimino_gravity");
end

endmodule
