module uart_rx (
    input  wire clk,
    input  wire rst_n,
    input  wire rx,
    output reg [7:0] data_out,
    output reg data_valid
);
    parameter CLKS_PER_TICK = 27;
    localparam IDLE=0, START=1, DATA=2, STOP=3;
    reg [1:0] state;
    reg [4:0] tick_cnt;
    reg [2:0] bit_cnt;
    reg [7:0] tick_div, shift_reg;
    reg tick;

/* Making a reciever is more nuanced than making a transmitter lol, because of the mismatch of clock cycles we need to make
 a tick generator which samples every signal multiple times in order to make sure the signal is not noise, and to remove clock
 mismatch discrepancies. */

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tick_div <= 0;
            tick <= 0;
        end
        else if (tick_div == CLKS_PER_TICK-1) begin
            tick_div <= 0;
            tick <= 1;
        end
        else begin
            tick_div <= tick_div + 1;
            tick <= 0;
        end
    end

    /* Similar to transmitter, if we recieve a signal on rx and the signal is more
   than 8 ticks, START is registered, data is retrieved and subsequently STOP proceedure is called. */
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tick_cnt <= 0;
            bit_cnt <= 0;
            data_out <= 0;
            data_valid <= 0;
        end else begin
            data_valid <= 0;
            if (tick) case (state)
                IDLE: if (rx == 0) begin
                    state <= START;
                    tick_cnt <= 0;
                end
                START: if (tick_cnt == 7) begin
                    if (rx == 0) begin
                        state <= DATA;
                        tick_cnt <= 0;
                        bit_cnt <= 0;
                    end
                    else state <= IDLE; //This is to manage fluctuations and noise, and check if the start bit received is real.
                end else
                tick_cnt <= tick_cnt + 1;
                DATA: if (tick_cnt == 15) begin
                    tick_cnt <= 0;
                    shift_reg[bit_cnt] <= rx;
                    if (bit_cnt == 7)
                    state <= STOP;
                    else
                    bit_cnt <= bit_cnt + 1;
                end else tick_cnt <= tick_cnt + 1;
                STOP: if (tick_cnt == 15) begin
                    data_out <= shift_reg;
                    data_valid <= 1;
                    state <= IDLE;
                end else tick_cnt <= tick_cnt + 1;
            endcase
        end
    end
endmodule
