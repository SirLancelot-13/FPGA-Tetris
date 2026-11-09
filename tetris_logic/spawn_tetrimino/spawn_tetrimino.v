`timescale 1ns/1ps

`include "../constants.vh"

module spawn_tetrimino(
    input [1:0] game_state,
    input clk,
    input game_clk,
    input [7:0] in_central_x_x2,
    input [7:0] in_central_y_x2,
    input [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] input_grid,
    output reg [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] output_grid,
    output reg [7:0] out_central_x_x2,
    output reg [7:0] out_central_y_x2,
    output reg [1:0] changed_game_state
);

wire [2:0] tetrimino_id;
reg [1:0] grid [0:`BOARD_HEIGHT-1][0:`BOARD_WIDTH-1];

// Randomizing the tetriminoes through a linear feedback shift register
lfsr lfsr (
	.clk(clk),
	.random_number(tetrimino_id)
);

integer i, j;
always @(posedge game_clk) begin
    // Default values
    changed_game_state <= game_state;
    out_central_x_x2 <= in_central_x_x2;
    out_central_y_x2 <= in_central_y_x2;
    for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
        for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
            output_grid[2*(i*`BOARD_WIDTH+j) +: 2] <= input_grid[2*(i*`BOARD_WIDTH+j) +: 2];
        end
    end

    // Implement the tetrimino bag for more even spawning
    if (game_state == `SPAWN_STATE) begin
        for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
            for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                grid[i][j] = input_grid[2*(i*`BOARD_WIDTH+j) +: 2];
            end
        end
        
        case (tetrimino_id)
            `IID : begin
                out_central_y_x2 <= `BOARD_HEIGHT * 2 - 5;
                out_central_x_x2 <= `BOARD_WIDTH - 1;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2-2] = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2-1] = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2]   = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2+1] = `ACTIVE_TETRIMINO_BLOCK;
            end
            `JID : begin
                out_central_y_x2 <= `BOARD_HEIGHT * 2 - 4;
                out_central_x_x2 <= `BOARD_WIDTH - 2;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2-2] = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-1][`BOARD_WIDTH/2-2] = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2-1] = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2]   = `ACTIVE_TETRIMINO_BLOCK;
            end
            `LID : begin
                out_central_y_x2 <= `BOARD_HEIGHT * 2 - 4;
                out_central_x_x2 <= `BOARD_WIDTH - 2;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2-2] = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2-1] = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2]   = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-1][`BOARD_WIDTH/2]   = `ACTIVE_TETRIMINO_BLOCK;
            end
            `OID : begin
                out_central_y_x2 <= `BOARD_HEIGHT * 2 - 3;
                out_central_x_x2 <= `BOARD_WIDTH - 1;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2-1] = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-1][`BOARD_WIDTH/2-1] = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2]   = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-1][`BOARD_WIDTH/2]   = `ACTIVE_TETRIMINO_BLOCK;
            end
            `SID : begin
                out_central_y_x2 <= `BOARD_HEIGHT * 2 - 4;
                out_central_x_x2 <= `BOARD_WIDTH - 2;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2-2] = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2-1] = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-1][`BOARD_WIDTH/2-1] = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-1][`BOARD_WIDTH/2]   = `ACTIVE_TETRIMINO_BLOCK;
            end
            `ZID : begin
                out_central_y_x2 <= `BOARD_HEIGHT * 2 - 4;
                out_central_x_x2 <= `BOARD_WIDTH - 2;
                grid[`BOARD_HEIGHT-1][`BOARD_WIDTH/2-2] = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2-1] = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-1][`BOARD_WIDTH/2-1] = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2]   = `ACTIVE_TETRIMINO_BLOCK;
            end
            `TID : begin
                out_central_y_x2 <= `BOARD_HEIGHT * 2 - 4;
                out_central_x_x2 <= `BOARD_WIDTH - 2;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2-2] = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2-1] = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-1][`BOARD_WIDTH/2-1] = `ACTIVE_TETRIMINO_BLOCK;
                grid[`BOARD_HEIGHT-2][`BOARD_WIDTH/2]   = `ACTIVE_TETRIMINO_BLOCK;
            end
            default : begin
                // This should never happen
            end
        endcase

        for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
            for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                output_grid[2*(i*`BOARD_WIDTH+j) +: 2] <= grid[i][j];
            end
        end

        changed_game_state <= `MOVE_STATE;
    end
end

endmodule
