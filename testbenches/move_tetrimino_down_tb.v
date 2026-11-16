`timescale 1ns/1ps

module move_tetrimino_down_tb;
`include "tb_util.vh"

reg move_down = 0;
reg [7:0] cx2 = 9, cy2 = 15;
reg [GN-1:0] in_grid = 0;
wire [GN-1:0] out_grid;
wire [7:0] ocx2, ocy2;

move_tetrimino_down dut (
    .move_down(move_down), .in_central_x_x2(cx2), .in_central_y_x2(cy2),
    .input_grid(in_grid), .output_grid(out_grid),
    .out_central_x_x2(ocx2), .out_central_y_x2(ocy2)
);

task apply(input m, input [GN-1:0] g);
begin
    move_down = m; in_grid = g;
    #1;
end
endtask

localparam D = `DEAD_TETRIMINO_BLOCK;
reg [GN-1:0] g;

initial begin
    // Without the key, nothing moves
    g = act4(6,3, 6,4, 6,5, 6,6);
    apply(0, g);
    check(out_grid === g, "key released: grid unchanged");
    check(ocx2 === cx2 && ocy2 === cy2, "key released: centre unchanged");

    // Pressed: one row down, centre y - 2
    apply(1, g);
    check(out_grid === act4(5,3, 5,4, 5,5, 5,6), "key pressed: piece moves down one row");
    check(ocy2 === cy2 - 2, "centre y decreases by 2");
    check(ocx2 === cx2, "centre x unchanged");

    // Vertical piece (several rows) moves as a whole without smearing
    g = act4(4,2, 5,2, 6,2, 7,2);
    apply(1, g);
    check(out_grid === act4(3,2, 4,2, 5,2, 6,2), "vertical I piece moves down as a whole");

    // On the floor: blocked
    g = act4(0,3, 0,4, 0,5, 0,6);
    apply(1, g);
    check(out_grid === g, "piece on the floor cannot move down");
    check(ocy2 === cy2, "centre unchanged when blocked by the floor");

    // One block touching the floor blocks the whole piece
    g = act4(0,3, 1,3, 2,3, 2,4);
    apply(1, g);
    check(out_grid === g, "any block on the floor blocks the piece");

    // Blocked by a dead block directly below
    g = setc(act4(5,3, 5,4, 5,5, 5,6), 4, 5, D);
    apply(1, g);
    check(out_grid === g, "dead block below blocks the move");
    check(ocy2 === cy2, "centre unchanged when blocked by dead block");

    // Dead block diagonal / beside the piece does not block
    g = setc(act4(5,3, 5,4, 5,5, 5,6), 4, 7, D);
    apply(1, g);
    check(out_grid === setc(act4(4,3, 4,4, 4,5, 4,6), 4, 7, D), "dead block not below the piece does not block");

    // Dead blocks elsewhere on the board are preserved
    g = setc(act4(5,3, 5,4, 5,5, 5,6), 0, 0, D);
    apply(1, g);
    check(getc(out_grid, 0, 0) === D && countc(out_grid, D) == 1, "dead blocks are preserved");

    // Piece one row above the dead stack moves down to touch it
    g = setc(act4(6,3, 6,4, 6,5, 6,6), 4, 4, D);
    apply(1, g);
    check(out_grid === setc(act4(5,3, 5,4, 5,5, 5,6), 4, 4, D), "moves down until touching the stack");

    finish_test("move_tetrimino_down");
end

endmodule
