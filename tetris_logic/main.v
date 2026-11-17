`timescale 1ns/1ps

`include "constants.vh"

module main #(
    parameter DEBOUNCE = `CLOCK_FREQUENCY * 10000 // Clocks a button has to be stable for (10 ms)
) (
    input [4:0] pb, input clk,
    output usb_uart_txd
);

wire game_clk;

// Buttons are asynchronous and bounce, so sync them into clk with 2 flops and only
// take a new level once it has been stable for DEBOUNCE clocks
reg [4:0] pb_m = 0, pb_s = 0;
reg [3:0] key = 0, key_q = 0; // Debounced {d, a, s, w} and its value one clock ago
reg [$clog2(DEBOUNCE+1)-1:0] db_cnt [0:3];
integer k;
initial for (k = 0; k < 4; k = k + 1) db_cnt[k] = 0;

always @(posedge clk) begin
    pb_m <= pb;
    pb_s <= pb_m;
    key_q <= key;
    for (k = 0; k < 4; k = k + 1)
        if (pb_s[k] == key[k]) db_cnt[k] <= 0;
        else if (db_cnt[k] == DEBOUNCE) begin key[k] <= pb_s[k]; db_cnt[k] <= 0; end
        else db_cnt[k] <= db_cnt[k] + 1;
end

wire wkey = key[0], skey = key[1], akey = key[2], dkey = key[3], rst = pb_s[4];
// One clock pulses on a press
wire rot_press = wkey & ~key_q[0], dn_press = skey & ~key_q[1];
wire sd_press = (dkey ^ akey) & ~(key_q[3] ^ key_q[2]);

// Board state
reg [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] grid = `EMPTY_BLOCK;
reg [1:0] game_state = `SPAWN_STATE;
reg [7:0] cx2 = 0; // Double of central coordinates (can't use floats)
reg [7:0] cy2 = 0;
reg [15:0] score = 0;
reg gc = 0, tick = 0, wrote = 0;

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

// user outputs, always computed so they have settled long before a press is taken
wire [2*`BOARD_HEIGHT*`BOARD_WIDTH-1:0] rot_grid, dn_grid, sd_grid;
wire [7:0] dn_cx2, sd_cx2;
wire [7:0] dn_cy2, sd_cy2;

clock_gen clock_gen_inst (
	.clk     (clk),
	.game_clk(game_clk)
);

// spawn and gravity run on clk (not the divided game_clk) so every path is timed against
// one clock, their outputs follow grid one clock later and main takes them on a tick
spawn_tetrimino spawn_tetrimino (
	.game_state        (game_state),
	.clk               (clk),
	.game_clk          (clk),
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
	.game_clk          (clk),
	.in_central_x_x2   (cx2),
	.in_central_y_x2   (cy2),
	.input_grid        (grid),
	.output_grid       (mv_grid),
	.out_central_x_x2  (mv_cx2),
	.out_central_y_x2  (mv_cy2),
	.changed_game_state(mv_game_state)
);

rotate_tetrimino rotate_tetrimino (
	.rotate         (1'b1),
	.in_central_x_x2(cx2),
	.in_central_y_x2(cy2),
	.input_grid     (grid),
	.output_grid    (rot_grid)
);

move_tetrimino_down move_tetrimino_down (
	.move_down       (1'b1),
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

// Main owns the state. Presses only count while a piece is moving. A game tick is held
// until main wrote nothing the clock before, so the spawn/gravity outputs are up to date
always @(posedge clk) begin
    gc <= game_clk;
    if (game_clk && !gc) tick <= 1;
    wrote <= 1;
    if (rst) begin
        {grid,game_state,score} <= 0; tick <= 0;
    end else if (game_state == `MOVE_STATE && rot_press) begin
        grid <= rot_grid;
    end else if (game_state == `MOVE_STATE && dn_press) begin
        grid <= dn_grid; cx2 <= dn_cx2; cy2 <= dn_cy2;
    end else if (game_state == `MOVE_STATE && sd_press) begin
        grid <= sd_grid; cx2 <= sd_cx2; cy2 <= sd_cy2;
    end else if (tick && !wrote) begin
        tick <= 0;
        case (game_state)
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
    end else wrote <= 0;
end

endmodule
