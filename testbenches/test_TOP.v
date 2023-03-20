`timescale 1ns/ 1ns
module test_TOP;

parameter DATA_WIDTH_BASE = 5;

wire sck_rx;
reg data_rx;
wire [2 ** DATA_WIDTH_BASE - 1:0] receive_data;
wire sck_tx;
wire data_tx;
reg [2 ** DATA_WIDTH_BASE - 1:0] transmit_data;
wire latch_flag;
reg clk;
reg rst;
reg start;
wire finish;
wire busy;
reg mode;

wire [3:0] top_cnt;
wire [1:0] top_state;

integer int_cnt;
integer latch_cnt;
integer finish_cnt;
reg [2 ** DATA_WIDTH_BASE - 1:0] tx_data;

TOP #(DATA_WIDTH_BASE) T
(
	.sck_rx(sck_rx),
	.data_rx(data_rx),
	.receive_data(receive_data),
	.sck_tx(sck_tx),
	.data_tx(data_tx),
	.transmit_data(transmit_data),
	.latch_flag(latch_flag),
	.clk(clk),
	.rst(rst),
	.start(start),
	.finish(finish),
	.busy(busy),
	.mode(mode)
);

assign top_cnt = T.cnt;
assign top_state = T.next_state;

initial
begin
	repeat (2) begin
	clk = 0;
	rst = 0;
	start = 0;
	mode = 0;
	transmit_data = 32'd1_456_478_547;
	int_cnt = 0;
	latch_cnt = 0;
	finish_cnt = 0;
	
	#1; rst = 1; #1;
	
	// test RX
	mode = 1; start = 1;
	#4;
	mode = 0; start = 0;
	
	#2;
	while (busy)
	begin
		#2;
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
		
	// test TX
	mode = 0; start = 1; latch_cnt = 0; finish_cnt = 0;
	#4;
	mode = 0; start = 0;
	
	#2;
	while (busy)
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
	$stop;
		
end

always begin
	#1; clk = !clk;
end

// rx_counter
always@ (posedge sck_rx)
begin
	data_rx <= transmit_data[int_cnt];
	int_cnt <= int_cnt + 1;
end

// tx
always@ (posedge sck_tx)
begin
	tx_data <= {tx_data[2 ** DATA_WIDTH_BASE - 2:0], data_tx};

end
endmodule
