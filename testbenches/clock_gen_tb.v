`timescale 1ns/1ps

module clock_gen_tb;
`include "tb_util.vh"

reg clk = 0;
always #10 clk = ~clk;      // 50 MHz, matching CLOCK_FREQUENCY
wire game_clk;

clock_gen dut (.clk(clk), .game_clk(game_clk));

integer cycles_since, i;
integer HALF = 6;

initial begin
    // The real half period is 25,000,000 clocks (0.5 s at 50 MHz). Check the
    // constant, then force a short one so the toggling logic simulates quickly.
    check(dut.half_period === (`CLOCK_FREQUENCY * 1000000 / 2), "half_period derived from CLOCK_FREQUENCY");
    check(dut.half_period === 32'd25_000_000, "half_period is 25M clocks at 50 MHz");
    check(game_clk === 1'b0, "game_clk starts low");

    force dut.half_period = HALF;

    // Wait for the first rising edge and then measure several half periods
    @(game_clk);
    check(game_clk === 1'b1, "first toggle is a rising edge");
    for (i = 0; i < 6; i = i + 1) begin
        cycles_since = 0;
        fork : measure
            begin : counter
                forever begin @(posedge clk); cycles_since = cycles_since + 1; end
            end
            begin
                @(game_clk);
                disable counter;
            end
        join
        check(cycles_since == HALF, "game_clk toggles every half_period clocks");
        if (cycles_since != HALF) $display("    measured %0d clocks, expected %0d", cycles_since, HALF);
    end
    check(game_clk === 1'b1, "after an even number of further toggles game_clk is high again");

    finish_test("clock_gen");
end

initial begin
    #1_000_000;
    $display("FAIL: clock_gen timeout");
    $finish;
end

endmodule
