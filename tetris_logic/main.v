`timescale 1ns/1ps

`include "constants.vh"

module main(
    input wkey, akey, skey, dkey,
    output out
);

reg clk = 0;
wire game_clk;

// Board state
reg [`BOARD_HEIGHT*`BOARD_WIDTH-1:0] grid = `EMPTY_BLOCK;
reg [1:0] game_state = `SPAWN_STATE;
reg [7:0] cx2 = 0; // Double of central coordinates (can't use floats)
reg [7:0] cy2 = 0;

// spawn outputs
wire [`BOARD_HEIGHT*`BOARD_WIDTH-1:0] sp_grid;
wire [1:0] sp_game_state;
wire [7:0] sp_cx2;
wire [7:0] sp_cy2;

// move outputs
wire [`BOARD_HEIGHT*`BOARD_WIDTH-1:0] mv_grid;
wire [1:0] mv_game_state;
wire [7:0] mv_cx2;
wire [7:0] mv_cy2;

always #1 clk = ~clk;

clock_gen clock_gen0 (
	.enable(clk),
	.clk   (game_clk)
);

spawn_tetrimino spawn_tetrimino (
	.game_state        (game_state),
	.clk               (clk),
	.game_clk          (game_clk),
	.in_central_x_x2   (cx2),
	.in_central_y_x2   (cy2),
	.input_grid        (grid),
	.output_grid       (sp_grid),
	.out_central_x_x2  (sp_cx2),
	.out_central_y_x2  (sp_cy2),
	.changed_game_state(sp_game_state)
);

// Probably will need to refactor this for clk stuff
always @(posedge clk) begin
    case (game_state)
        `SPAWN_STATE : begin
            
        end
        `MOVE_STATE : begin
            
        end
        default : begin
            
        end
    endcase
end

endmodule
