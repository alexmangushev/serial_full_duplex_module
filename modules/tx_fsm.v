module tx_fsm
#(
	parameter DATA_WIDTH_BASE = 5
)
(
	input [1:0] state_in,
	input clk,
	input rst,
	input [2 ** DATA_WIDTH_BASE - 1:0] transmit_data,
	output reg sck_tx,
	output reg data_tx,
	output reg latch_flag,
	output reg finish,
	output reg finish_fsm
);

	localparam [2:0] FSM_IDLE = 0;
	localparam [2:0] FSM_SET_BIT = 1;
	localparam [2:0] FSM_SCK_TX_1 = 2;
	localparam [2:0] FSM_SCK_TX_0 = 3;
	localparam [2:0] FSM_LATCH_1 = 4;
	localparam [2:0] FSM_LATCH_0 = 5;
	localparam [2:0] FSM_FINISH = 6;
	localparam [2:0] FSM_END_PULSE = 7;
	
	reg [2:0] state;
	reg [2:0] next_state;
	
	reg send_end;
	reg [DATA_WIDTH_BASE - 1:0] cnt;
	
	
	// next state logic
	always@*
	case (state)
	FSM_IDLE:
		if (state_in == 2) next_state = FSM_SET_BIT;
		else next_state = FSM_IDLE;
	FSM_SET_BIT:
		next_state = FSM_SCK_TX_1;
	FSM_SCK_TX_1:
		next_state = FSM_SCK_TX_0;
	FSM_SCK_TX_0:
		if (cnt != 0) next_state = FSM_SET_BIT;
		else if (send_end) next_state = FSM_LATCH_0;
		else next_state = FSM_LATCH_1;
	FSM_LATCH_1:
		next_state = FSM_SCK_TX_1;
	FSM_LATCH_0:
		next_state = FSM_FINISH;
	FSM_FINISH:
		if (cnt != 4) next_state = FSM_FINISH;
		else next_state = FSM_END_PULSE;
	FSM_END_PULSE:
		next_state = FSM_IDLE;
	default:
		next_state = FSM_IDLE;
	endcase
	
	
	// output logic
	always@ (posedge clk) 
	case (next_state)
	FSM_IDLE:
	begin
		sck_tx <= 0;
		data_tx <= 0;
		latch_flag <= 0;
		send_end <= 0;
		cnt <= -1;
		finish <= 0;
		finish_fsm <= 0;
	end
	FSM_SET_BIT:
	begin
		data_tx <= transmit_data[cnt];
		cnt <= cnt - 1;
	end
	FSM_SCK_TX_1:
		sck_tx <= 1;
	FSM_SCK_TX_0:
		sck_tx <= 0;
	FSM_LATCH_1:
	begin
		latch_flag <= 1;
		send_end <= 1;
	end
	FSM_LATCH_0:
	begin
		latch_flag <= 0;
		cnt <= 0;
	end
	FSM_FINISH:
	begin
		finish <= 1;
		cnt <= cnt + 1;
	end
	FSM_END_PULSE:
		finish_fsm <= 1;
	default:
	begin
		sck_tx <= 0;
		data_tx <= 0;
		latch_flag <= 0;
		send_end <= 0;
		cnt <= -1;
		finish <= 0;
		finish_fsm <= 0;
	end
	endcase
	
	// state register
	always@(posedge clk or negedge rst)
	if (!rst)
		state <= FSM_IDLE;
	else
		state <= next_state;

endmodule
