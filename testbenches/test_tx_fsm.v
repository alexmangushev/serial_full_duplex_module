`timescale 1us/ 1us
module test_tx_fsm;

parameter DATA_WIDTH_BASE = 5;

reg [1:0] state_in;
reg clk;
reg rst;
wire [31:0] transmit_data;
wire sck_tx;
wire data_tx;
wire latch_flag; 
wire finish;
wire finish_fsm;

integer latch_cnt;
integer finish_cnt;
reg [2 ** DATA_WIDTH_BASE - 1:0] tx_data;

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

assign transmit_data = 32'd1_456_478_547;

initial
begin
	latch_cnt = 0;
	finish_cnt = 0;
	state_in = 0;
	clk = 0;
	rst = 1;
	
	#4; rst = 0; #2;
	
	rst = 1;
	state_in = 2;
	
	#2; state_in = 0;
	
	while (!finish_fsm)
	begin
		#2;
		if (latch_flag)
			latch_cnt = latch_cnt + 1;
		if (finish)
			finish_cnt = finish_cnt + 1;
	end
	
	
	if (transmit_data == tx_data && latch_cnt == 3  && finish_cnt == 5)
		$display("TX OK");
	if (transmit_data != tx_data)
		$display("TX BAD value");
	if (latch_cnt != 3)
		$display("TX BAD latch");
	if (finish_cnt != 5)
		$display("TX BAD finish");
	
end

always begin
	#1; clk = !clk;
end

always@ (posedge sck_tx)
begin
	tx_data <= {tx_data[2 ** DATA_WIDTH_BASE - 2:0], data_tx};

end
	
endmodule
