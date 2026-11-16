`timescale 1ns/1ps

`include "constants.vh"

module main(
    input [4:0] pb, input clk,
    output usb_uart_txd
);

wire game_clk, wkey = pb[0], skey = pb[1], akey = pb[2], dkey = pb[3];

// Board state
reg [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] grid = `EMPTY_BLOCK;
reg [1:0] game_state = `SPAWN_STATE;
reg [7:0] cx2 = 0; // Double of central coordinates (can't use floats)
reg [7:0] cy2 = 0;
reg [15:0] score = 0;
reg gc = 0, rot_pulse = 0, dn_pulse = 0, sd_pulse = 0;

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

// clear outputs
wire [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] cl_grid;
wire [1:0] cl_game_state;
wire [15:0] cl_score;

// user outputs
wire [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] rot_grid, dn_grid, sd_grid;
wire [7:0] dn_cx2, sd_cx2;
wire [7:0] dn_cy2, sd_cy2;

clock_gen clock_gen_inst (
	.clk     (clk),
	.game_clk(game_clk)
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

rotate_tetrimino rotate_tetrimino (
	.rotate         (wkey),
	.in_central_x_x2(cx2),
	.in_central_y_x2(cy2),
	.input_grid     (grid),
	.output_grid    (rot_grid)
);

move_tetrimino_down move_tetrimino_down (
	.move_down       (skey),
	.in_central_x_x2 (cx2),
	.in_central_y_x2 (cy2),
	.input_grid      (grid),
	.output_grid     (dn_grid),
	.out_central_x_x2(dn_cx2),
	.out_central_y_x2(dn_cy2)
);

move_tetrimino_sideways move_tetrimino_sideways (
	.dx              (dkey-akey+0),
	.in_central_x_x2 (cx2),
	.in_central_y_x2 (cy2),
	.input_grid      (grid),
	.output_grid     (sd_grid),
	.out_central_x_x2(sd_cx2),
	.out_central_y_x2(sd_cy2)
);

line_clear line_clear (
	.game_state        (game_state),
	.score             (score),
	.clk               (clk),
	.input_grid        (grid),
	.output_grid       (cl_grid),
	.changed_game_state(cl_game_state),
	.changed_score     (cl_score)
);

wire tx_start, tx_done;
wire [7:0] tx_data;

packetizer packetizer (.clk(clk), .game_over(game_state == `GAMEOVER_STATE), .score(score), .grid(grid), .tx_line(usb_uart_txd), .tx_done(tx_done), .tx_start(tx_start), .tx_data(tx_data));
uart_tx uart_tx (.clk(clk), .tx_start(tx_start), .tx_data(tx_data), .tx_line(usb_uart_txd), .tx_done(tx_done));

// Main owns the state, it takes the module outputs once after each game_clk edge
always @(posedge clk) begin
    gc <= game_clk;
    rot_pulse <= wkey;
    dn_pulse <= skey;
    sd_pulse <= dkey ^ akey;
    if (wkey == ~rot_pulse && wkey == 1) begin
        grid <= rot_grid;
    end else if (skey == ~dn_pulse && skey == 1) begin
        grid <= dn_grid; cx2 <= dn_cx2; cy2 <= dn_cy2;
    end else if ((dkey ^ akey == ~sd_pulse) && (dkey ^ akey == 1)) begin
        grid <= sd_grid; cx2 <= sd_cx2; cy2 <= sd_cy2;
    end else if (game_clk == ~gc && game_clk == 1) case (game_state) // 1 in 50 million chance player hits something and this gets skipped
        `SPAWN_STATE : begin
            grid <= sp_grid; game_state <= sp_game_state; cx2 <= sp_cx2; cy2 <= sp_cy2;
        end
        `MOVE_STATE : begin
            grid <= mv_grid; game_state <= mv_game_state; cx2 <= mv_cx2; cy2 <= mv_cy2;
        end
        `CLEAR_STATE : begin
            grid <= cl_grid; game_state <= cl_game_state; score <= cl_score;
        end
        default : begin

        end
    endcase
end

endmodule
