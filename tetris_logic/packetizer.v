`include "constants.vh"

// Packet: A5 5A | status | score(2) | board(30) | crc(2), crc over bytes 2..34
module packetizer #(parameter HB = 27000000) (
    input clk, game_over,
    input [15:0] score,
    input [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] grid,
    input tx_line, tx_done,
    output reg tx_start = 0,
    output reg [7:0] tx_data
);

localparam N = 2*`BOARD_HEIGHT*`BOARD_WIDTH;
reg [N+16:0] snap, last = 0; // {game_over, score, grid}
reg [1:0] st = 0;
reg [5:0] idx = 0;
reg [15:0] crc = 16'hFFFF;
reg [25:0] t = 0;

function [15:0] crc8(input [15:0] c, input [7:0] b);
    integer k;
    begin
        crc8 = c ^ {b, 8'b0};
        for (k = 0; k < 8; k = k + 1)
            crc8 = crc8[15] ? (crc8 << 1) ^ 16'h1021 : crc8 << 1;
    end
endfunction

always @* case (idx)
    0 : tx_data = 8'hA5;
    1 : tx_data = 8'h5A;
    2 : tx_data = {7'b0, snap[N+16]};
    3 : tx_data = snap[N+15:N+8];
    4 : tx_data = snap[N+7:N];
    35 : tx_data = crc[15:8];
    36 : tx_data = crc[7:0];
    default : tx_data = snap[8*(idx-5) +: 8];
endcase

// Send when the state changes, or every HB clocks
always @(posedge clk) begin
    t <= t + 1;
    case (st)
        0 : if ({game_over, score, grid} != last || t == HB) begin
            snap <= {game_over, score, grid};
            idx <= 0; crc <= 16'hFFFF; t <= 0; tx_start <= 1; st <= 1;
        end
        1 : if (!tx_line) begin tx_start <= 0; st <= 2; end // uart took the byte
        2 : if (tx_done) begin
            if (idx >= 2 && idx <= 34) crc <= crc8(crc, tx_data);
            if (idx == 36) begin last <= snap; st <= 0; end
            else begin idx <= idx + 1; tx_start <= 1; st <= 1; end
        end
    endcase
end

endmodule
