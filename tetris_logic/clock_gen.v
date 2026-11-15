`timescale 1ns/1ps

`include "constants.vh"

module clock_gen(
    input clk,
    output reg game_clk = 0
);

// Values are setup to give clock period (20 ns in this case to do 1 -> 0 -> 1)
wire [31:0] half_period = `CLOCK_FREQUENCY * 1000000 / 2; // in Hz

reg [31:0] counter = 0;
always @(posedge clk) begin
    if (counter == half_period - 1) begin
        counter <= 0;
        game_clk <= ~game_clk;
    end else begin
        counter <= counter + 1;
    end
end

endmodule
