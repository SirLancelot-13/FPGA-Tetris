`timescale 1ns/1ps

module clock_gen(
    input enable,
    output reg clk
);
    parameter FREQ = 1000; // in MHZ
    parameter DUTY = 50; // in percentage (how much the clock stays on)

    parameter real clk_period = 1.0 / (FREQ * 1e6) * 1e9; 	// convert to ns
    real clk_on = DUTY / 100.0 * clk_period;
    real clk_off = (100.0 - DUTY) / 100.0 * clk_period;

    initial begin
        $display("FREQ      = %0d MHz", FREQ);
        $display("DUTY      = %0d %%",  DUTY);
        $display("PERIOD    = %0.3f ns", clk_period);
        $display("CLK_ON    = %0.3f ns", clk_on);
        $display("CLK_OFF   = %0.3f ns", clk_off);
    end

    // Initialize variables to zero
    initial begin
        clk = 0;
    end

    always @(posedge enable) begin
        while (enable) begin
            clk = 1; #(clk_on);
            clk = 0; #(clk_off);
        end
    end
endmodule
