`timescale 1ns / 1ps


`include "asserts.vh"


module tx_top_v();
	reg	[11:0]	story_tb;
	reg		clk, reset;
	reg	[7:0]	dat_i;
	reg		lchar_i, valid_i;

	wire		d_o, s_o, ready_o;

	tx_top top(
		.txClk(clk),
		.txReset(reset),
		.dat_i(dat_i),
		.lchar_i(lchar_i),
		.valid_i(valid_i),

		.d(d_o),
		.s(s_o),
		.ready_o(ready_o)
	);

	`DEFIO(clk,H,L)
	`DEFASSERT0(d,o)
	`DEFASSERT0(s,o)

	initial begin
		$dumpfile("wtf.vcd");
		$dumpvars;

		// Make sure that the S signal is stable between characters.

		story_tb <= 12'h000;
		{clk, valid_i, lchar_i, dat_i} <= 0;
		reset <= 1;

		clkL(); clkH();

		reset <= 0;

		clkL(); clkH();

		dat_i <= 8'h02;
		lchar_i <= 1;
		valid_i <= 1;

		clkL(); clkH();

		assert_d(0);	assert_s(0);

		story_tb <= 12'h001;
		valid_i <= 0;

		clkL(); clkH();			// Drives Tx pins during this cycle...

		story_tb <= 12'hFFF;

		clkL(); clkH();			// ... which should appear at D/S now.

		assert_d(0);	assert_s(1);	// Parity

		story_tb <= 12'hFFE;

		clkL(); clkH();

		assert_d(1);	assert_s(1);	// LChar flag

		story_tb <= 12'h002;

		clkL(); clkH();

		assert_d(0);	assert_s(1);	// D0a

		story_tb <= 12'h003;

		clkL(); clkH();

		assert_d(1);	assert_s(1);	// D1a

		story_tb <= 12'h004;
		dat_i <= 8'h00;
		valid_i <= 1;
		lchar_i <= 1;

		clkL(); clkH();

		assert_d(1);	assert_s(1);	// D/S stable
		
		story_tb <= 12'h005;
		valid_i <= 0;
		lchar_i <= 0;

		clkL(); clkH();
		clkL(); clkH();

		assert_d(1);	assert_s(0);	// Parity
	
		story_tb <= 12'h006;
		
		clkL(); clkH();

		assert_d(1);	assert_s(1);	// LChar flag
	
		story_tb <= 12'h007;
		
		clkL(); clkH();

		assert_d(0);	assert_s(1);	// D0b
	
		story_tb <= 12'h008;
		
		clkL(); clkH();

		assert_d(0);	assert_s(0);	// D1b
	
		$display("@I Done.");
		$stop;
	end
endmodule

