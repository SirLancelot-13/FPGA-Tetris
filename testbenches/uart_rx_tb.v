`timescale 1ns/1ps

module uart_rx_tb;
`include "tb_util.vh"

localparam CPT = 4;             // clocks per tick, 16 ticks per bit
localparam BIT = 16*CPT;        // clocks per bit
localparam T = 10;

reg clk = 0;
always #(T/2) clk = ~clk;

reg rst_n = 0;
reg rx = 1;
wire [7:0] data_out;
wire data_valid;

uart_rx #(.CLKS_PER_TICK(CPT)) dut (
    .clk(clk), .rst_n(rst_n), .rx(rx),
    .data_out(data_out), .data_valid(data_valid)
);

integer n_valid = 0;
reg [7:0] last_byte;
always @(posedge clk) if (data_valid) begin
    n_valid = n_valid + 1;
    last_byte = data_out;
end

task send_byte(input [7:0] d, input integer stop_bits);
    integer k;
begin
    rx = 0; repeat (BIT) @(posedge clk);
    for (k = 0; k < 8; k = k + 1) begin
        rx = d[k]; repeat (BIT) @(posedge clk);
    end
    rx = 1; repeat (stop_bits*BIT) @(posedge clk);
end
endtask

integer n_prev, i;
reg [7:0] vectors [0:7];

initial begin
    vectors[0] = 8'h00; vectors[1] = 8'hFF; vectors[2] = 8'hA5; vectors[3] = 8'h5A;
    vectors[4] = 8'h01; vectors[5] = 8'h80; vectors[6] = 8'h3C; vectors[7] = 8'hC3;

    repeat (5) @(posedge clk);
    #1 check(data_valid === 1'b0, "data_valid low in reset");
    check(data_out === 8'h00, "data_out cleared by reset");
    rst_n = 1;
    repeat (BIT) @(posedge clk);
    check(n_valid == 0, "nothing received from an idle line");

    // Ordinary frames, with slack after each
    for (i = 0; i < 8; i = i + 1) begin
        n_prev = n_valid;
        send_byte(vectors[i], 2);
        check(n_valid == n_prev + 1, "one data_valid per frame");
        check(last_byte === vectors[i], "received byte matches");
        if (last_byte !== vectors[i]) $display("    sent %h got %h", vectors[i], last_byte);
    end

    // data_valid is a single-cycle pulse
    n_prev = n_valid;
    send_byte(8'h42, 2);
    check(n_valid == n_prev + 1, "data_valid pulses once");

    // A start bit lasting only 3 ticks is noise and must be rejected
    n_prev = n_valid;
    rx = 0; repeat (3*CPT) @(posedge clk);
    rx = 1; repeat (4*BIT) @(posedge clk);
    check(n_valid == n_prev, "short glitch on rx is ignored");

    // ...and the receiver is still usable afterwards
    send_byte(8'hB7, 2);
    check(n_valid == n_prev + 1 && last_byte === 8'hB7, "receiver recovers after a glitch");

    // Back-to-back frames with a single stop bit
    n_prev = n_valid;
    send_byte(8'h11, 1);
    send_byte(8'h22, 1);
    send_byte(8'h33, 2);
    check(n_valid == n_prev + 3, "three back-to-back frames all received");
    check(last_byte === 8'h33, "last back-to-back byte is correct");

    // Asynchronous reset mid-frame drops the byte
    n_prev = n_valid;
    rx = 0; repeat (BIT) @(posedge clk);
    rx = 1; repeat (BIT) @(posedge clk);
    rst_n = 0; #1;
    check(data_out === 8'h00, "reset clears data_out");
    rx = 1; repeat (3) @(posedge clk);
    rst_n = 1;
    repeat (2*BIT) @(posedge clk);
    check(n_valid == n_prev, "frame aborted by reset is not delivered");

    finish_test("uart_rx");
end

initial begin
    #20_000_000;
    $display("FAIL: uart_rx timeout");
    $finish;
end

endmodule
