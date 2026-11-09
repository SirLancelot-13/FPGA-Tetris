`timescale 1ns/1ps

`include "constants.vh"

module main(
    input wkey, akey, skey, dkey,
    output out
);

reg clk = 0;
wire game_clk;

// Board state
reg [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] grid = `EMPTY_BLOCK;
reg [1:0] game_state = `SPAWN_STATE;
reg [7:0] cx2 = 0; // Double of central coordinates (can't use floats)
reg [7:0] cy2 = 0;
reg [15:0] score = 0;
reg gc = 0, gc2 = 0;

// spawn outputs
wire [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] sp_grid;
wire [1:0] sp_game_state;
wire [7:0] sp_cx2;
wire [7:0] sp_cy2;

// move outputs
wire [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] mv_grid;
wire [1:0] mv_game_state;
wire [7:0] mv_cx2;
wire [7:0] mv_cy2;

always #1 clk = ~clk;

clock_gen #(10) clock_gen0 (
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

tetrimino_gravity tetrimino_gravity (
	.game_state        (game_state),
	.game_clk          (game_clk),
	.in_central_x_x2   (cx2),
	.in_central_y_x2   (cy2),
	.input_grid        (grid),
	.output_grid       (mv_grid),
	.out_central_x_x2  (mv_cx2),
	.out_central_y_x2  (mv_cy2),
	.changed_game_state(mv_game_state)
);

// Main owns the state, it takes the module outputs once after each game_clk edge
always @(posedge clk) begin
    gc <= game_clk; gc2 <= gc;
    if (gc & ~gc2) case (game_state)
        `SPAWN_STATE : begin
            grid <= sp_grid; game_state <= sp_game_state; cx2 <= sp_cx2; cy2 <= sp_cy2;
        end
        `MOVE_STATE : begin
            grid <= mv_grid; game_state <= mv_game_state; cx2 <= mv_cx2; cy2 <= mv_cy2;
            if (mv_game_state == `SPAWN_STATE) score <= score + 1;
        end
        default : begin
            
        end
    endcase
end

endmodule
