`timescale 1ns/1ps

module uart_tx_tb;
`include "tb_util.vh"

localparam CPB = 8;          // clocks per bit, small to keep the sim short
localparam T = 10;           // clock period in ns

reg clk = 0;
always #(T/2) clk = ~clk;

reg tx_start = 0;
reg [7:0] tx_data = 0;
wire tx_line, tx_done;

uart_tx #(.CLKS_PER_BIT(CPB)) dut (
    .clk(clk), .tx_start(tx_start), .tx_data(tx_data),
    .tx_line(tx_line), .tx_done(tx_done)
);

integer done_count = 0;
always @(posedge tx_done) done_count = done_count + 1;

// Starts a transmission and decodes the line by sampling the middle of every bit.
task send_and_decode(input [7:0] d, output [7:0] got, output stop_ok, output integer frame_clks);
    integer k;
    time t0;
begin
    @(negedge clk);
    tx_data = d;
    tx_start = 1;
    @(negedge tx_line);
    t0 = $time;
    tx_start = 0;
    #(CPB*T/2);                   // middle of start bit
    check(tx_line === 1'b0, "start bit is low");
    for (k = 0; k < 8; k = k + 1) begin
        #(CPB*T);
        got[k] = tx_line;         // LSB first
    end
    #(CPB*T);
    stop_ok = (tx_line === 1'b1);
    @(posedge tx_done);
    frame_clks = ($time - t0) / T;
end
endtask

reg [7:0] got;
reg stop_ok;
integer frame_clks, i;
reg [7:0] vectors [0:5];

initial begin
    vectors[0] = 8'h00; vectors[1] = 8'hFF; vectors[2] = 8'hA5;
    vectors[3] = 8'h5A; vectors[4] = 8'h01; vectors[5] = 8'h80;

    repeat (3) @(posedge clk);
    check(tx_line === 1'b1, "line idles high");
    check(tx_done === 1'b0, "tx_done idle low");

    // Nothing is sent without tx_start
    repeat (5*CPB) @(posedge clk);
    check(tx_line === 1'b1, "line stays high without start");
    check(done_count == 0, "no done without start");

    for (i = 0; i < 6; i = i + 1) begin
        send_and_decode(vectors[i], got, stop_ok, frame_clks);
        check(got === vectors[i], "decoded byte matches sent byte");
        if (got !== vectors[i]) $display("    sent %h got %h", vectors[i], got);
        check(stop_ok, "stop bit is high");
        // start + 8 data + stop = 10 bit times; the line falls one clock after
        // being requested, tx_done fires on the last stop-bit clock
        check(frame_clks == 10*CPB - 1, "frame length is 10 bit times");
        if (frame_clks != 10*CPB - 1) $display("    frame_clks=%0d", frame_clks);
        repeat (3) @(posedge clk);
        check(done_count == i + 1, "exactly one tx_done pulse per byte");
        check(tx_done === 1'b0, "tx_done is a pulse");
        check(tx_line === 1'b1, "line returns to idle");
    end

    // tx_start held for many cycles must not re-trigger a second frame before it ends
    @(negedge clk);
    tx_data = 8'h3C; tx_start = 1;
    @(posedge tx_done);
    tx_start = 0;
    repeat (3) @(posedge clk);
    check(done_count == 7, "single frame for a single start");

    finish_test("uart_tx");
end

initial begin
    #5_000_000;
    $display("FAIL: uart_tx timeout");
    $finish;
end

endmodule
