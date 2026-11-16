`timescale 1ns/1ps

module move_tetrimino_sideways_tb;
`include "tb_util.vh"

reg signed [31:0] dx = 0;
reg [7:0] cx2 = 9, cy2 = 15;
reg [GN-1:0] in_grid = 0;
wire [GN-1:0] out_grid;
wire [7:0] ocx2, ocy2;

move_tetrimino_sideways dut (
    .dx(dx), .in_central_x_x2(cx2), .in_central_y_x2(cy2),
    .input_grid(in_grid), .output_grid(out_grid),
    .out_central_x_x2(ocx2), .out_central_y_x2(ocy2)
);

task apply(input signed [31:0] d, input [GN-1:0] g);
begin
    dx = d; in_grid = g;
    #1;
end
endtask

localparam D = `DEAD_TETRIMINO_BLOCK;
reg [GN-1:0] g;

initial begin
    g = act4(6,3, 6,4, 6,5, 6,6);

    apply(0, g);
    check(out_grid === g && ocx2 === cx2 && ocy2 === cy2, "dx=0: nothing changes");

    apply(1, g);
    check(out_grid === act4(6,4, 6,5, 6,6, 6,7), "dx=+1: piece moves right");
    check(ocx2 === cx2 + 2, "dx=+1: centre x + 2");
    check(ocy2 === cy2, "dx=+1: centre y unchanged");

    apply(-1, g);
    check(out_grid === act4(6,2, 6,3, 6,4, 6,5), "dx=-1: piece moves left");
    check(ocx2 === cx2 - 2, "dx=-1: centre x - 2");
    check(ocy2 === cy2, "dx=-1: centre y unchanged");

    // Moves must not smear or duplicate blocks (a 2x2 square, both directions)
    g = act4(3,4, 4,4, 3,5, 4,5);
    apply(1, g);
    check(out_grid === act4(3,5, 4,5, 3,6, 4,6), "square moves right intact");
    apply(-1, g);
    check(out_grid === act4(3,3, 4,3, 3,4, 4,4), "square moves left intact");

    // Walls
    g = act4(6,0, 6,1, 6,2, 6,3);
    apply(-1, g);
    check(out_grid === g && ocx2 === cx2, "left wall blocks dx=-1");
    apply(1, g);
    check(out_grid === act4(6,1, 6,2, 6,3, 6,4), "touching left wall can still go right");

    g = act4(6,6, 6,7, 6,8, 6,9);
    apply(1, g);
    check(out_grid === g && ocx2 === cx2, "right wall blocks dx=+1");
    apply(-1, g);
    check(out_grid === act4(6,5, 6,6, 6,7, 6,8), "touching right wall can still go left");

    // A single block of a tall piece against the wall blocks the whole piece
    g = act4(2,0, 3,0, 4,0, 4,1);
    apply(-1, g);
    check(out_grid === g, "one block on the wall blocks the whole piece");

    // Dead blocks
    g = setc(act4(6,3, 6,4, 6,5, 6,6), 6, 7, D);
    apply(1, g);
    check(out_grid === g && ocx2 === cx2, "dead block to the right blocks dx=+1");
    apply(-1, g);
    check(out_grid === setc(act4(6,2, 6,3, 6,4, 6,5), 6, 7, D), "dead block on the far side does not block");

    g = setc(act4(6,3, 6,4, 6,5, 6,6), 6, 2, D);
    apply(-1, g);
    check(out_grid === g && ocx2 === cx2, "dead block to the left blocks dx=-1");

    // Dead block in a different row does not block
    g = setc(act4(6,3, 6,4, 6,5, 6,6), 5, 7, D);
    apply(1, g);
    check(out_grid === setc(act4(6,4, 6,5, 6,6, 6,7), 5, 7, D), "dead block in another row does not block");

    // Blocks hidden in the middle of a piece: only the leading edge matters
    g = setc(act4(3,4, 4,4, 3,5, 4,5), 2, 4, D);
    apply(1, g);
    check(out_grid === setc(act4(3,5, 4,5, 3,6, 4,6), 2, 4, D), "dead block below the piece does not block sideways");

    // Dead blocks elsewhere are untouched
    g = setc(act4(6,3, 6,4, 6,5, 6,6), 0, 0, D);
    apply(1, g);
    check(getc(out_grid, 0, 0) === D && countc(out_grid, D) == 1, "dead blocks preserved on move");

    finish_test("move_tetrimino_sideways");
end

endmodule
