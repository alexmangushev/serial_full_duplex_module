module TOP
#(
	parameter DATA_WIDTH_BASE = 5
)
(
	output sck_rx,
	input data_rx,
	output [2 ** DATA_WIDTH_BASE - 1:0] receive_data,
	output sck_tx,
	output data_tx,
	input [2 ** DATA_WIDTH_BASE - 1:0] transmit_data,
	output latch_flag,
	input clk,
	input rst,
	input start,
	output finish,
	output busy,
	input mode
);

	reg [3:0] cnt;
	wire finish_fsm_tx;
	wire finish_fsm_rx;
	
	wire finish_tx;
	wire finish_rx;
	
	wire latch_flag_tx;
	wire latch_flag_rx;

	localparam [1:0] FSM_IDLE = 0;
	localparam [1:0] FSM_RX = 1;
	localparam [1:0] FSM_TX = 2;
	
	reg [1:0] state;
	reg [1:0] next_state;
	
	assign finish = finish_tx || finish_rx;
	assign latch_flag = latch_flag_tx || latch_flag_rx;
	assign busy = (state == FSM_RX || state == FSM_TX) ? 1 : 0;
	
	tx_fsm #(DATA_WIDTH_BASE) tx
	(
		.state_in(state),
		.clk(clk),
		.rst(rst),
		.transmit_data(transmit_data),
		.sck_tx(sck_tx),
		.data_tx(data_tx),
		.latch_flag(latch_flag_tx),
		.finish(finish_tx),
		.finish_fsm(finish_fsm_tx)
	);
	
	rx_fsm #(DATA_WIDTH_BASE) rx
	(
		.state_in(state),
		.clk(clk),
		.rst(rst),
		.data_rx(data_rx),
		.receive_data(receive_data),
		.sck_rx(sck_rx),
		.latch_flag(latch_flag_rx),
		.finish(finish_rx),
		.finish_fsm(finish_fsm_rx)
	);
		
	// next state logic
	always@*
	case (next_state)
	FSM_IDLE:
		if (start == 1'd1 && mode == 1'd0 && cnt == 4'd2)
			next_state = FSM_TX;
		else if (start == 1'd1 && mode == 1'd1 && cnt == 4'd2)
			next_state = FSM_RX;
		else
			next_state = FSM_IDLE;
	FSM_RX:
		if (finish_fsm_rx)
			next_state = FSM_IDLE;
		else
			next_state = FSM_RX;
	FSM_TX:
		if (finish_fsm_tx)
			next_state = FSM_IDLE;
		else
			next_state = FSM_TX;
	default:
		next_state = FSM_IDLE;
	endcase
	
	// counter
	always@ (posedge clk)
	case (state)
	FSM_IDLE:
	begin
		if (start) cnt <= cnt + 1'd1;
		else cnt <= 1'd0;
	end
	default
		cnt <= 1'd0;
	endcase
	
	// state register
	always@(posedge clk or negedge rst)
	if (!rst)
		state <= FSM_IDLE;
	else
		state <= next_state;
	
endmodule
