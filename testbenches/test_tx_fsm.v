`timescale 1ns/ 1ns
module test_tx_fsm;

reg [1:0] state_in;
reg clk;
reg rst;
wire [31:0] transmit_data;
wire sck_tx;
wire data_tx;
wire latch_flag; 
wire finish;
wire finish_fsm;

tx_fsm tx
(
	.state_in(state_in),
	.clk(clk),
	.rst(rst),
	.transmit_data(transmit_data),
	.sck_tx(sck_tx),
	.data_tx(data_tx),
	.latch_flag(latch_flag),
	.finish(finish),
	.finish_fsm(finish_fsm)
);

wire [2:0] state = tx.state;
wire [4:0] cnt = tx.cnt;
assign transmit_data = 32'd1_456_478_547;

initial
begin
	state_in = 0;
	clk = 0;
	rst = 1;
	
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
	state_in = 2;
	
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
	
endmodule
