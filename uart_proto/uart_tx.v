module uart_tx #(
    parameter CLKS_PER_BIT = 67 //Initialize this to a value according to the FPGA board itself
) (
    input wire clk,
    input wire tx_start,
    input wire [7:0] tx_data,
    output reg tx_line,
    output reg tx_done
);

/*The states transmitter unit can be in
when idle the transmit line is in a high state,
a start signal sends the signal to low, after which data arrives.
parity check is done and the packet is delivered and CLEANUP
is called.*/

localparam IDLE=3'd0;
localparam START=3'd1;
localparam DATA=3'd2;
localparam STOP=3'd3;
localparam CLEANUP=3'd4;

reg [2:0] state = IDLE;
reg [$clog2(CLKS_PER_BIT):0] clk_count = 0;
reg [2:0] bit_index = 0;
reg [7:0] tx_buf=0;

always @(posedge clk) begin
    case(state)
        IDLE: begin
            tx_line = 1;
            tx_done = 0;
            clk_count = 0;
            bit_index = 0;
            if (tx_start) begin
               tx_buf=tx_data;
               state=START;
            end
        end
        START: begin
            tx_line = 1'b0;
            if (clk_count< CLKS_PER_BIT - 1) begin
                clk_count = clk_count + 1;
            end else begin
                clk_count = 0;
                state = DATA;
            end
        end
        DATA: begin
            tx_line = tx_buf[bit_index];
            if (clk_count < CLKS_PER_BIT - 1)
                clk_count = clk_count + 1;
            else begin
                clk_count = 0;
                if (bit_index<7)
                    bit_index = bit_index + 1;
                else begin
                    bit_index = 0;
                    state = STOP;
                end
            end
        end
        STOP: begin
            tx_line = 1'b1;
            if (clk_count < CLKS_PER_BIT - 1)
                clk_count = clk_count + 1;
            else begin
                clk_count = 0;
                tx_done = 1;
                state = CLEANUP;
            end
        end
        CLEANUP: begin
            tx_done = 1'b0;
            state = IDLE;
        end
    endcase
end

endmodule
