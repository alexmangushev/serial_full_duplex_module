`timescale 1ns/ 1ns
module test_rx_fsm;

reg [1:0] state_in;
reg clk;
reg rst;
reg data_rx;
wire [31:0] receive_data;
wire sck_rx;
wire latch_flag; 
wire finish;
wire finish_fsm;

rx_fsm rx
	(
		.state_in(state_in),
		.clk(clk),
		.rst(rst),
		.data_rx(data_rx),
		.receive_data(receive_data),
		.sck_rx(sck_rx),
		.latch_flag(latch_flag),
		.finish(finish),
		.finish_fsm(finish_fsm)
	);

wire [2:0] state = rx.state;
wire [5:0] cnt = rx.cnt;
reg [31:0] transmit_data;
reg [4:0] int_cnt;

initial
begin
	transmit_data = 32'd1_456_478_547;
	state_in = 0;
	clk = 0;
	rst = 1;
	int_cnt = 0;
	
	repeat(2)
	begin
		#1;	clk = !clk;
		#1;	clk = !clk;
	end
	
	rst = 0;
	
	repeat(1)
	begin
		#1;	clk = !clk;
		#1;	clk = !clk;
	end
	
	rst = 1;
	state_in = 1;
	
	repeat(2)
	begin
		#1;	clk = !clk;
		#1;	clk = !clk;
	end
	
	state_in = 0;
	repeat(120)
	begin
		#1;	clk = !clk;
		#1;	clk = !clk;
	end
	
end

always@ (posedge sck_rx)
begin
	data_rx <= transmit_data[int_cnt];
	int_cnt <= int_cnt + 1;
end
	
	
endmodule
