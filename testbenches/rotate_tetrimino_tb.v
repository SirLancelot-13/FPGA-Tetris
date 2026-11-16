`timescale 1ns/1ps

module rotate_tetrimino_tb;
`include "tb_util.vh"

reg rotate = 0;
reg [7:0] cx2 = 0, cy2 = 0;
reg [GN-1:0] in_grid = 0;
wire [GN-1:0] out_grid;

rotate_tetrimino dut (
    .rotate(rotate), .in_central_x_x2(cx2), .in_central_y_x2(cy2),
    .input_grid(in_grid), .output_grid(out_grid)
);

task apply(input r, input [7:0] x2, input [7:0] y2, input [GN-1:0] g);
begin
    rotate = r; cx2 = x2; cy2 = y2; in_grid = g;
    #1;
end
endtask

localparam D = `DEAD_TETRIMINO_BLOCK;
reg [GN-1:0] g, e, cur;
integer k;

// Rotate n times in a row about a fixed centre, feeding each result back in
task spin(input integer n, input [7:0] x2, input [7:0] y2, input [GN-1:0] start);
    integer q;
begin
    cur = start;
    for (q = 0; q < n; q = q + 1) begin
        apply(1, x2, y2, cur);
        cur = out_grid;
    end
end
endtask

initial begin
    // I piece as spawned: row 10, cols 3..6, centre (4.5, 9.5) -> x2=9, y2=19
    g = act4(10,3, 10,4, 10,5, 10,6);

    apply(0, 9, 19, g);
    check(out_grid === g, "rotate low: nothing changes");

    apply(1, 9, 19, g);
    e = act4(8,4, 9,4, 10,4, 11,4);
    check(out_grid === e, "I piece rotates from horizontal to vertical");
    if (out_grid !== e) begin $display("  got:"); dump(out_grid); $display("  expected:"); dump(e); end
    check(countc(out_grid, `ACTIVE_TETRIMINO_BLOCK) == 4, "rotation keeps 4 blocks");

    // Second rotation goes back to horizontal, one row lower
    spin(2, 9, 19, g);
    check(cur === act4(9,3, 9,4, 9,5, 9,6), "second rotation gives horizontal again");
    if (cur !== act4(9,3, 9,4, 9,5, 9,6)) dump(cur);

    // Four rotations return to the start (centre is on a lattice point/half point)
    spin(4, 9, 19, g);
    check(cur === g, "I piece: 4 rotations is the identity");

    // O piece (2x2, centre (4.5, 10.5) -> 9, 21) is rotation invariant
    g = act4(10,4, 11,4, 10,5, 11,5);
    apply(1, 9, 21, g);
    check(out_grid === g, "O piece is unchanged by rotation");

    // T piece spawned shape; centre (4, 10) -> x2=8, y2=20
    g = act4(10,3, 10,4, 11,4, 10,5);
    spin(1, 8, 20, g);
    check(cur === act4(9,4, 10,4, 11,4, 10,5) || cur === act4(9,4, 10,4, 11,4, 10,3),
          "T piece rotates a quarter turn about its centre block");
    if (!(cur === act4(9,4, 10,4, 11,4, 10,5) || cur === act4(9,4, 10,4, 11,4, 10,3))) begin
        $display("  got:"); dump(cur);
    end
    spin(4, 8, 20, g);
    check(cur === g, "T piece: 4 rotations is the identity");

    // Every spawn shape survives 4 rotations unchanged
    g = act4(10,3, 11,3, 10,4, 10,5); spin(4, 8, 20, g);
    check(cur === g, "J piece: 4 rotations is the identity");
    g = act4(10,3, 10,4, 10,5, 11,5); spin(4, 8, 20, g);
    check(cur === g, "L piece: 4 rotations is the identity");
    g = act4(10,3, 10,4, 11,4, 11,5); spin(4, 8, 20, g);
    check(cur === g, "S piece: 4 rotations is the identity");
    g = act4(11,3, 10,4, 11,4, 10,5); spin(4, 8, 20, g);
    check(cur === g, "Z piece: 4 rotations is the identity");

    // Dead blocks elsewhere are kept
    g = setc(act4(10,3, 10,4, 10,5, 10,6), 0, 0, D);
    apply(1, 9, 19, g);
    check(getc(out_grid, 0, 0) === D && countc(out_grid, D) == 1, "dead blocks preserved by rotation");
    check(countc(out_grid, `ACTIVE_TETRIMINO_BLOCK) == 4, "active block count preserved with dead blocks present");

    // Blocked by a dead block where a rotated block would land
    g = setc(act4(10,3, 10,4, 10,5, 10,6), 9, 4, D);
    apply(1, 9, 19, g);
    check(out_grid === g, "grid identical after blocked rotation");

    // Blocked by the floor: horizontal I on row 0 would rotate below the board
    g = act4(0,3, 0,4, 0,5, 0,6);
    apply(1, 9, 1, g);
    check(out_grid === g, "rotation below the floor is rejected");

    // Blocked by the right wall: vertical I in the last column
    g = act4(2,9, 3,9, 4,9, 5,9);
    apply(1, 19, 7, g);     // centre (9.5, 3.5)
    check(out_grid === g, "rotation through the right wall is rejected");

    // Blocked by the top of the board
    g = act4(11,3, 11,4, 11,5, 11,6);
    apply(1, 9, 23, g);     // centre (4.5, 11.5): vertical result would span rows 11..14
    check(out_grid === g, "rotation above the ceiling is rejected");

    finish_test("rotate_tetrimino");
end

endmodule
