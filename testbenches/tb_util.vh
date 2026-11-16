// Shared helpers for the testbenches. `include this INSIDE a testbench module.
`include "constants.vh"

localparam GN = 2*`BOARD_HEIGHT*`BOARD_WIDTH;

integer tb_errors = 0;
integer tb_checks = 0;

task check(input cond, input [8*64-1:0] msg);
begin
    tb_checks = tb_checks + 1;
    if (cond !== 1'b1) begin // !== so that X/Z fail instead of silently passing
        tb_errors = tb_errors + 1;
        $display("FAIL: %0s (t=%0t)", msg, $time);
    end
end
endtask

task finish_test(input [8*32-1:0] name);
begin
    if (tb_errors == 0) $display("PASS: %0s (%0d checks)", name, tb_checks);
    else                $display("FAIL: %0s (%0d of %0d checks failed)", name, tb_errors, tb_checks);
    $finish;
end
endtask

// Row 0 is the bottom of the board, column 0 the left.
function [GN-1:0] setc(input [GN-1:0] g, input integer r, input integer c, input [1:0] v);
begin
    setc = g;
    setc[2*(r*`BOARD_WIDTH+c) +: 2] = v;
end
endfunction

function [1:0] getc(input [GN-1:0] g, input integer r, input integer c);
    getc = g[2*(r*`BOARD_WIDTH+c) +: 2];
endfunction

function integer countc(input [GN-1:0] g, input [1:0] v);
    integer k;
begin
    countc = 0;
    for (k = 0; k < `BOARD_HEIGHT*`BOARD_WIDTH; k = k + 1)
        if (g[2*k +: 2] === v) countc = countc + 1;
end
endfunction

function [GN-1:0] fillrow(input [GN-1:0] g, input integer r, input [1:0] v);
    integer c;
begin
    fillrow = g;
    for (c = 0; c < `BOARD_WIDTH; c = c + 1)
        fillrow = setc(fillrow, r, c, v);
end
endfunction

// A grid holding only four active blocks, given as (row, col) pairs.
function [GN-1:0] act4(input integer r0, input integer c0, input integer r1, input integer c1,
                       input integer r2, input integer c2, input integer r3, input integer c3);
begin
    act4 = {GN{1'b0}};
    act4 = setc(act4, r0, c0, `ACTIVE_TETRIMINO_BLOCK);
    act4 = setc(act4, r1, c1, `ACTIVE_TETRIMINO_BLOCK);
    act4 = setc(act4, r2, c2, `ACTIVE_TETRIMINO_BLOCK);
    act4 = setc(act4, r3, c3, `ACTIVE_TETRIMINO_BLOCK);
end
endfunction

// Top row printed first, '.' empty, '#' dead, 'o' active.
task dump(input [GN-1:0] g);
    integer r, c;
    reg [1:0] v;
begin
    for (r = `BOARD_HEIGHT-1; r >= 0; r = r - 1) begin
        $write("    ");
        for (c = 0; c < `BOARD_WIDTH; c = c + 1) begin
            v = getc(g, r, c);
            $write("%s", v == `EMPTY_BLOCK ? "." : v == `DEAD_TETRIMINO_BLOCK ? "#" : "o");
        end
        $write("\n");
    end
end
endtask
