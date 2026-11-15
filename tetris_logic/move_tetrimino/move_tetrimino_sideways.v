`timescale 1ns/1ps

`include "../constants.vh"

module move_tetrimino_sideways(
    input signed [31:0] dx, // Difference in x, should be -1, 0 or 1
    input [7:0] in_central_x_x2,
    input [7:0] in_central_y_x2,
    input [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] input_grid,
    output reg [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] output_grid,
    output reg [7:0] out_central_x_x2,
    output reg [7:0] out_central_y_x2
);

reg [1:0] grid [0:`BOARD_HEIGHT-1][0:`BOARD_WIDTH-1];

integer i, j;
reg can_move = 1;
always @(*) begin
    // Default values
    out_central_x_x2 <= in_central_x_x2;
    out_central_y_x2 <= in_central_y_x2;
    output_grid <= input_grid;

    if (dx != 0) begin
        for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
            for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                grid[i][j] = input_grid[2*(i*`BOARD_WIDTH+j) +: 2];
            end
        end

        can_move = 1;

        for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
            for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                if (grid[i][j] == `ACTIVE_TETRIMINO_BLOCK && (j + dx < 0 || j + dx >= `BOARD_WIDTH || grid[i][j+dx] == `DEAD_TETRIMINO_BLOCK)) begin
                    can_move = 0;
                end
            end
        end

        if (can_move == 1) begin
            if (dx == -1) begin
                for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
                    for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                        if (grid[i][j] == `ACTIVE_TETRIMINO_BLOCK) begin
                            grid[i][j] = `EMPTY_BLOCK;
                            grid[i][j+dx] = `ACTIVE_TETRIMINO_BLOCK;
                        end
                    end
                end
            end else begin
                for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
                    for (j = `BOARD_WIDTH - 1; j >= 0; j = j - 1) begin
                        if (grid[i][j] == `ACTIVE_TETRIMINO_BLOCK) begin
                            grid[i][j] = `EMPTY_BLOCK;
                            grid[i][j+dx] = `ACTIVE_TETRIMINO_BLOCK;
                        end
                    end
                end
            end

            out_central_x_x2 <= in_central_x_x2 + 2 * dx;

            for (i = 0; i < `BOARD_HEIGHT; i = i + 1) begin
                for (j = 0; j < `BOARD_WIDTH; j = j + 1) begin
                    output_grid[2*(i*`BOARD_WIDTH+j) +: 2] <= grid[i][j];
                end
            end
        end
    end
end

endmodule
