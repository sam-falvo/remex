`timescale 1ns / 1ps

module rx_top(
	input		rxClk,
	input		rxReset,
	input		d,
	input		s,

	output	[7:0]	q,
	output		nchar,
	output		lchar,
	output		parityError,

	output		full_o,
	output		empty_o
);
	wire	[1:0]	d_to_charDetector;
	wire		dv_to_charDetector;

	rx_DS_SE phy(
		.rxClk(rxClk),
		.rxReset(rxReset),
		.d(d),
		.s(s),
		.dq(d_to_charDetector),
		.dqValid(dv_to_charDetector)
	);

	rx_DS_char charDetector(
		.rxClk(rxClk),
		.rxReset(rxReset),
		.d(d_to_charDetector),
		.dValid(dv_to_charDetector),
		.q(q),
		.nchar(nchar),
		.lchar(lchar),
		.parityError(parityError)
	);

	queue_8x9 queue(
		.clk(rxClk),
		.reset(rxReset),
		.nchar(nchar),
		.lchar(lchar),
		.char_i(q),
		.stb_i(1'b0),
		.ack_o(),
		.dat_o(),
		.full_o(full_o),
		.empty_o(empty_o),
		.occupied_tb(),
		.rp_tb(),
		.wp_tb(),
		.we_tb()
	);
endmodule

