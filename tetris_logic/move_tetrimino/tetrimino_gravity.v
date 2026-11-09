`timescale 1ns/1ps

`include "../constants.vh"

module tetrimino_gravity(
    input [1:0] game_state,
    input game_clk,
    input [7:0] in_central_x_x2,
    input [7:0] in_central_y_x2,
    input [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] input_grid,
    output reg [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] output_grid,
    output reg [7:0] out_central_x_x2,
    output reg [7:0] out_central_y_x2,
    output reg [1:0] changed_game_state
);

reg [1:0] grid [0:`BOARD_HEIGHT-1][0:`BOARD_WIDTH-1];

integer i, j;
reg should_fall = 1;
always @(posedge game_clk) begin
    // Default values
    changed_game_state <= game_state;
    out_central_x_x2 <= in_central_x_x2;
    out_central_y_x2 <= in_central_y_x2;
    output_grid <= input_grid;
    
    if (game_state == `MOVE_STATE) begin
        for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
            for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                grid[i][j] = input_grid[2*(i*`BOARD_WIDTH+j) +: 2];
            end
        end

        should_fall = 1;

        for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
            for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                if (grid[i][j] == `ACTIVE_TETRIMINO_BLOCK && (i == 0 || grid[i-1][j] == `DEAD_TETRIMINO_BLOCK)) begin
                    should_fall = 0;
                end
            end
        end

        if (should_fall == 1) begin
            for (i = 1; i < `BOARD_HEIGHT; i = i + 1) begin
                for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                    if (grid[i][j] == `ACTIVE_TETRIMINO_BLOCK) begin
                        grid[i][j] = `EMPTY_BLOCK;
                        grid[i-1][j] = `ACTIVE_TETRIMINO_BLOCK;
                    end
                end
            end
            
            out_central_y_x2 <= in_central_y_x2 - 2;
        end else begin
            for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
                for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                    if (grid[i][j] == `ACTIVE_TETRIMINO_BLOCK) begin
                        grid[i][j] = `DEAD_TETRIMINO_BLOCK;
                    end
                end
            end
            
            changed_game_state <= `SPAWN_STATE;
        end

        for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
            for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                output_grid[2*(i*`BOARD_WIDTH+j) +: 2] <= grid[i][j];
            end
        end
    end
end

endmodule
