`timescale 1us/ 1us
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

integer latch_cnt;
integer finish_cnt;
reg [31:0] transmit_data;
reg [4:0] int_cnt;

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


initial
begin
	latch_cnt = 0;
	finish_cnt = 0;
	transmit_data = 32'd1_456_478_547;
	state_in = 0;
	clk = 0;
	rst = 1;
	int_cnt = 0;
	
	#4; rst = 0; #2;
	
	rst = 1;
	state_in = 1;
	
	while (!finish_fsm)
	begin
		#2;
		state_in = 0;
		if (latch_flag)
			latch_cnt = latch_cnt + 1;
		if (finish)
			finish_cnt = finish_cnt + 1;
	end
	
	if (transmit_data == receive_data && latch_cnt == 3 && finish_cnt == 5)
		$display("RX OK");
	if (transmit_data != receive_data)
		$display("RX BAD value");
	if (latch_cnt != 3)
		$display("RX BAD latch");
	if (finish_cnt != 5)
		$display("RX BAD finish");
	
end

always begin
	#1; clk = !clk;
end

always@ (posedge sck_rx)
begin
	data_rx <= transmit_data[int_cnt];
	int_cnt <= int_cnt + 1;
end
	
	
endmodule
