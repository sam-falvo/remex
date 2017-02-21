`timescale 1ns / 1ps

module tx_top(
	input		txClk,
	input		txReset,
	input	[7:0]	dat_i,
	input		lchar_i,
	input		valid_i,

	output		d,
	output		s,
	output		ready_o
);
	wire		tx1, tx0;

	tx_DS_SE phy(
		.TxClk(txClk),
		.TxReset(txReset),
		.Tx1(tx1),
		.Tx0(tx0),
		.D(d),
		.S(s)
	);

	tx_DS_char serializer(
		.TxClk(txClk),
		.TxReset(txReset),
		.valid_i(valid_i),
		.dat_i(dat_i),
		.lchar_i(lchar_i),
		.Tx0(tx0),
		.Tx1(tx1),
		.ready_o(ready_o)
	);
endmodule

