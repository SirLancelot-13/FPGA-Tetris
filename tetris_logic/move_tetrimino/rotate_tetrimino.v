`timescale 1ns/1ps

`include "../constants.vh"

module rotate_tetrimino(
    input rotate,
    input [7:0] in_central_x_x2,
    input [7:0] in_central_y_x2,
    input [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] input_grid,
    output reg [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] output_grid
);

reg [1:0] grid [0:`BOARD_HEIGHT-1][0:`BOARD_WIDTH-1];
reg [1:0] grid_final [0:`BOARD_HEIGHT-1][0:`BOARD_WIDTH-1];

task rotate_point(
    input [7:0] in_x,
    input [7:0] in_y,
    input [7:0] center_x_x2,
    input [7:0] center_y_x2,
    output [7:0] out_x,
    output [7:0] out_y
);

reg [7:0] temp_x;
reg [7:0] temp_y;

begin
    temp_x = 2 * in_x - center_x_x2;
    temp_y = 2 * in_y - center_y_x2;
    
    out_x = -temp_y + center_x_x2;
    out_y = temp_x + center_y_x2;
    
    out_x = out_x / 2;
    out_y = out_y / 2;
end

endtask

reg [7:0] i;
reg [7:0] j;
reg can_rotate = 1;
reg [7:0] out_x;
reg [7:0] out_y;
always @(*) begin
    // Default values
    output_grid <= input_grid;
    
    if (rotate == 1) begin
        for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
            for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                grid[i][j] = input_grid[2*(i*`BOARD_WIDTH+j) +: 2];
            end
        end

        can_rotate = 1;

        for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
            for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                if (grid[i][j] == `ACTIVE_TETRIMINO_BLOCK) begin
                    rotate_point(j, i, in_central_x_x2, in_central_y_x2, out_x, out_y);
                    if (out_x >= `BOARD_WIDTH || out_y >= `BOARD_HEIGHT || grid[out_y][out_x] == `DEAD_TETRIMINO_BLOCK) begin
                        can_rotate = 0;
                    end
                end
            end
        end

        if (can_rotate == 1) begin
            for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
                for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                    grid_final[i][j] = `EMPTY_BLOCK;
                end
            end
            
            for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
                for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                    if (grid[i][j] == `ACTIVE_TETRIMINO_BLOCK) begin
                        grid[i][j] = `EMPTY_BLOCK;
                        rotate_point(j, i, in_central_x_x2, in_central_y_x2, out_x, out_y);
                        grid_final[out_y][out_x] = `ACTIVE_TETRIMINO_BLOCK;
                    end
                end
            end

            for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
                for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                    output_grid[2*(i*`BOARD_WIDTH+j) +: 2] <= grid[i][j];
                    if (grid_final[i][j] == `ACTIVE_TETRIMINO_BLOCK) begin
                        output_grid[2*(i*`BOARD_WIDTH+j) +: 2] <= `ACTIVE_TETRIMINO_BLOCK;
                    end
                end
            end
        end
    end
end

endmodule
