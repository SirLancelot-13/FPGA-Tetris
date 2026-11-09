`timescale 1ns/1ps

`include "../constants.vh"

module lfsr(
    input clk,
    output reg [2:0] random_number = 0
);

reg [7:0] number = 8'b0100101;

always @(posedge clk) begin
    number = { number[0] ^ number[2] ^ number[3] ^ number[4], number[7:1] };
    random_number <= number[2:0];

    // Make better later to unbiased
    if (number[2:0] == `INVALID_ID) begin
        random_number <= `IID;
    end
end

endmodule
