`timescale 1ns/1ps

// uart_tx wired straight into uart_rx. The rx oversamples 16x, so its tick
// divider is set to CPB/16 to match the transmitter's baud rate.
module uart_loopback_tb;
`include "tb_util.vh"

localparam CPT = 4;
localparam CPB = 16*CPT;

reg clk = 0;
always #5 clk = ~clk;

reg rst_n = 0;
reg tx_start = 0;
reg [7:0] tx_data = 0;
wire line, tx_done;
wire [7:0] rx_data;
wire rx_valid;

uart_tx #(.CLKS_PER_BIT(CPB)) tx (
    .clk(clk), .tx_start(tx_start), .tx_data(tx_data),
    .tx_line(line), .tx_done(tx_done)
);

uart_rx #(.CLKS_PER_TICK(CPT)) rx (
    .clk(clk), .rst_n(rst_n), .rx(line),
    .data_out(rx_data), .data_valid(rx_valid)
);

reg [7:0] got [0:255];
integer n_got = 0;
always @(posedge clk) if (rx_valid) begin
    got[n_got] = rx_data;
    n_got = n_got + 1;
end

task send(input [7:0] d);
begin
    @(negedge clk);
    tx_data = d; tx_start = 1;
    @(negedge line);
    tx_start = 0;
    @(posedge tx_done);
    @(posedge clk); @(posedge clk);
end
endtask

integer i;
reg [7:0] exp;

initial begin
    repeat (4) @(posedge clk);
    rst_n = 1;
    repeat (4) @(posedge clk);

    for (i = 0; i < 256; i = i + 1) send(i[7:0]);   // every possible byte

    repeat (3*CPB) @(posedge clk);
    check(n_got == 256, "all 256 bytes received");
    for (i = 0; i < n_got; i = i + 1) begin
        exp = i[7:0];
        if (got[i] !== exp) begin
            check(0, "byte value mismatch");
            $display("    index %0d: sent %h got %h", i, exp, got[i]);
        end
    end
    check(tb_errors == 0, "no mismatches in loopback");

    finish_test("uart_loopback");
end

initial begin
    #200_000_000;
    $display("FAIL: uart_loopback timeout");
    $finish;
end

endmodule
