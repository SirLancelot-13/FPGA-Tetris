`timescale 1ns/1ps

`include "constants.vh"

module line_clear(
    input [1:0] game_state,
    input clk,
    input [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] input_grid,
    output reg [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] output_grid,
    output reg [1:0] changed_game_state
);

reg [1:0] grid [0:`BOARD_HEIGHT-1][0:`BOARD_WIDTH-1];

reg [3:0] i, j;
reg [3:0] push_down = 0, blocks_present;
always @(posedge clk) begin
    // Default values
    output_grid <= input_grid;
    changed_game_state <= game_state;

    if (game_state == `CLEAR_STATE) begin
        for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
            for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                grid[i][j] = input_grid[2*(i*`BOARD_WIDTH+j) +: 2];
            end
        end
    
        push_down = 0;
    
        for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
            blocks_present = 0;
            for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                if (grid[i][j] == `DEAD_TETRIMINO_BLOCK) begin
                    blocks_present = blocks_present + 1;
                end
            end
            if (blocks_present == `BOARD_WIDTH) begin
                push_down = push_down + 1;
                for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                    grid[i][j] = `EMPTY_BLOCK;
                end
            end else if (push_down > 0) begin
                for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                    if (grid[i][j] == `DEAD_TETRIMINO_BLOCK) begin
                        grid[i][j] = `EMPTY_BLOCK;
                        grid[i-push_down][j] = `DEAD_TETRIMINO_BLOCK;
                    end
                end
            end
        end

        changed_game_state <= `SPAWN_STATE;

        for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
            for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                output_grid[2*(i*`BOARD_WIDTH+j) +: 2] <= grid[i][j];
            end
        end
    end
end

endmodule
