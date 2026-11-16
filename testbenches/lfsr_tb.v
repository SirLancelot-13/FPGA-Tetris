`timescale 1ns/1ps

module lfsr_tb;
`include "tb_util.vh"

reg clk = 0;
always #5 clk = ~clk;

wire [2:0] rnd;
lfsr dut (.clk(clk), .random_number(rnd));

integer seen [0:7];
integer i, distinct;
reg [2:0] prev;
integer repeats;

initial begin
    for (i = 0; i < 8; i = i + 1) seen[i] = 0;
    repeats = 0;
    #1;
    check(rnd === 3'd0, "starts at 0 before the first clock");

    @(posedge clk); #1;
    prev = rnd;
    for (i = 0; i < 2000; i = i + 1) begin
        @(posedge clk); #1;
        check(rnd !== 3'bxxx, "output is never X");
        seen[rnd] = seen[rnd] + 1;
        if (rnd === prev) repeats = repeats + 1;
        prev = rnd;
    end

    check(seen[`INVALID_ID] == 0, "never produces the invalid piece id");
    distinct = 0;
    for (i = 0; i < 7; i = i + 1) begin
        check(seen[i] > 0, "every valid piece id shows up");
        if (seen[i] > 0) distinct = distinct + 1;
    end
    check(distinct == 7, "all 7 tetrimino ids are generated");
    // not stuck: the sequence must keep moving
    check(repeats < 1000, "output is not stuck on one value");

    $display("    distribution over 2000 samples (id: count)");
    for (i = 0; i < 7; i = i + 1) $display("      %0d: %0d", i, seen[i]);

    finish_test("lfsr");
end

endmodule
