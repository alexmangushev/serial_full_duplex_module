module rx_fsm
#(
	parameter DATA_WIDTH_BASE = 5
)
(
	input [1:0] state_in,
	input clk,
	input rst,
	input data_rx,
	output [2 ** DATA_WIDTH_BASE - 1:0] receive_data,
	output reg sck_rx,
	output reg latch_flag,
	output reg finish,
	output reg finish_fsm
);

	localparam [2:0] FSM_IDLE = 0;
	localparam [2:0] FSM_LATCH_1 = 1;
	localparam [2:0] FSM_SCK_RX_1 = 2;
	localparam [2:0] FSM_SCK_RX_0 = 3;
	localparam [2:0] FSM_LATCH_0 = 4;
	localparam [2:0] FSM_READ_BIT = 5;
	localparam [2:0] FSM_FINISH = 6;
	localparam [2:0] FSM_END_PULSE = 7;
	
	reg [2:0] state;
	reg [2:0] next_state;
	
	reg first_time;
	reg [DATA_WIDTH_BASE:0] cnt;
	reg [DATA_WIDTH_BASE - 1:0] cnt_delay;
	reg [2 ** DATA_WIDTH_BASE - 1:0] receive_data_reg;
	
	assign receive_data = receive_data_reg;
	
	always@*
	case (state)
	FSM_IDLE:
		if (state_in == 1) next_state = FSM_LATCH_1;
		else next_state = FSM_IDLE;
	FSM_LATCH_1:
		next_state = FSM_SCK_RX_1;
	FSM_SCK_RX_1:
		next_state = FSM_SCK_RX_0;
	FSM_SCK_RX_0:
		if (!first_time) next_state = FSM_LATCH_0;
		else if (cnt != 2 ** (DATA_WIDTH_BASE + 1) - 1) next_state = FSM_READ_BIT;
		else next_state = FSM_FINISH;
	FSM_LATCH_0:
		next_state = FSM_READ_BIT;
	FSM_READ_BIT:
		next_state = FSM_SCK_RX_1;
	FSM_FINISH:
		if (cnt_delay != 4) next_state = FSM_FINISH;
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
		sck_rx <= 0;
		latch_flag <= 0;
		first_time <= 0;
		cnt <= 2 ** DATA_WIDTH_BASE - 1;
		finish <= 0;
		finish_fsm <= 0;
	end
	FSM_LATCH_1:
		latch_flag <= 1;
	FSM_SCK_RX_1:
		sck_rx <= 1;
	FSM_SCK_RX_0:
	begin
		sck_rx <= 0;
		cnt_delay <= 0;
	end
	FSM_LATCH_0:
	begin
		first_time <= 1;
		latch_flag <= 0;
	end
	FSM_READ_BIT:
	begin
		receive_data_reg <= {data_rx, receive_data_reg[2 ** DATA_WIDTH_BASE - 1:1]};
		cnt <= cnt - 1;
	end		
	FSM_FINISH:
	begin
		finish <= 1;
		cnt_delay <= cnt_delay + 1;
	end
	FSM_END_PULSE:
		finish_fsm <= 1;
	default:
	begin
		sck_rx <= 0;
		latch_flag <= 0;
		first_time <= 0;
		cnt <= 2 ** DATA_WIDTH_BASE - 1;
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
