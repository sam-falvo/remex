`timescale 1ns / 1ps


`include "asserts.vh"


module tx_DS_char_tb();
	reg	[11:0]	story_tb;
	reg		reset, clk, valid_i, lchar_i;
	reg	[7:0]	dat_i;
	wire		tx0_o, tx1_o, ready_o;

	tx_DS_char serializer(
		.TxReset(reset),
		.TxClk(clk),
		.valid_i(valid_i),
		.dat_i(dat_i),
		.lchar_i(lchar_i),
		.Tx0(tx0_o),
		.Tx1(tx1_o),
		.ready_o(ready_o)
	);

	`DEFIO(clk,H,L)
	`DEFASSERT0(tx0,o)
	`DEFASSERT0(tx1,o)
	`DEFASSERT0(ready,o)

	initial begin
		$dumpfile("wtf.vcd");
		$dumpvars;

		// R R

		story_tb <= 12'h000;
		{reset, clk, valid_i, lchar_i, dat_i} <= 0;

		clkL(); clkH();

		reset <= 1;

		clkL(); clkH();

		assert_tx0(0);	assert_tx1(0);
		assert_ready(1);

		clkL(); clkH();

		assert_tx0(0);	assert_tx1(0);
		assert_ready(1);

		// R nc R

		story_tb <= 12'h010;
		{clk, valid_i, lchar_i, dat_i} <= 0;
		reset <= 1;

		clkL(); clkH();

		reset <= 0;

		clkL(); clkH();

		assert_tx0(0);	assert_tx1(0);
		assert_ready(1);

		story_tb <= 12'h011;
		dat_i <= 8'hAA;
		lchar_i <= 0;
		valid_i <= 1;

		clkL(); clkH();

		assert_ready(0);

		valid_i <= 0;

		clkL(); clkH();

		assert_tx1(1); assert_tx0(0);	// parity
		assert_ready(0);

		story_tb <= 12'h012;

		clkL(); clkH();

		story_tb <= 12'h013;

		assert_tx1(0); assert_tx0(1);	// LChar flag

		clkL(); clkH();

		story_tb <= 12'h014;

		assert_tx1(0); assert_tx0(1);	// D0

		clkL(); clkH();

		story_tb <= 12'h015;

		assert_tx1(1); assert_tx0(0);	// D1

		clkL(); clkH();

		story_tb <= 12'h016;

		assert_tx1(0); assert_tx0(1);	// D2

		clkL(); clkH();

		story_tb <= 12'h017;

		assert_tx1(1); assert_tx0(0);	// D3

		reset <= 1;

		clkL(); clkH();

		story_tb <= 12'h018;

		assert_tx1(0); assert_tx0(0);
		assert_ready(1);

		// R nc nc

		story_tb <= 12'h020;
		{clk, valid_i, lchar_i, dat_i} <= 0;
		reset <= 1;

		clkL(); clkH();

		reset <= 0;

		clkL(); clkH();

		assert_tx0(0);	assert_tx1(0);
		assert_ready(1);

		story_tb <= 12'h021;
		dat_i <= 8'hAA;
		lchar_i <= 0;
		valid_i <= 1;

		clkL(); clkH();

		assert_ready(0);

		valid_i <= 0;

		clkL(); clkH();

		assert_tx1(1); assert_tx0(0);	// parity
		assert_ready(0);

		story_tb <= 12'h022;

		clkL(); clkH();

		story_tb <= 12'h023;
		dat_i <= 8'h55;
		valid_i <= 1;

		assert_tx1(0); assert_tx0(1);	// LChar flag

		clkL(); clkH();

		story_tb <= 12'h024;
		valid_i <= 0;

		assert_tx1(0); assert_tx0(1);	// D0

		clkL(); clkH();

		story_tb <= 12'h025;

		assert_tx1(1); assert_tx0(0);	// D1

		clkL(); clkH();

		story_tb <= 12'h026;

		assert_tx1(0); assert_tx0(1);	// D2

		clkL(); clkH();

		story_tb <= 12'h027;

		assert_tx1(1); assert_tx0(0);	// D3

		clkL(); clkH();

		story_tb <= 12'h028;

		assert_tx1(0); assert_tx0(1);	// D4
		assert_ready(0);

		clkL(); clkH();

		story_tb <= 12'h029;

		assert_tx1(1); assert_tx0(0);	// D5
		assert_ready(0);

		clkL(); clkH();

		story_tb <= 12'h02A;

		assert_tx1(0); assert_tx0(1);	// D6
		assert_ready(0);

		clkL(); clkH();

		story_tb <= 12'h02B;

		assert_tx1(1); assert_tx0(0);	// D7
		assert_ready(1);

		story_tb <= 12'h02C;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(0);	// Tx pins should quiesce.
		assert_ready(1);

		// R nc lc

		story_tb <= 12'h030;
		{clk, valid_i, lchar_i, dat_i} <= 0;
		reset <= 1;

		clkL(); clkH();

		reset <= 0;

		clkL(); clkH();

		assert_tx0(0);	assert_tx1(0);
		assert_ready(1);

		story_tb <= 12'h031;
		dat_i <= 8'hAA;
		lchar_i <= 0;
		valid_i <= 1;

		clkL(); clkH();

		assert_ready(0);

		valid_i <= 0;

		clkL(); clkH();

		assert_tx1(1); assert_tx0(0);	// parity
		assert_ready(0);

		story_tb <= 12'h032;

		clkL(); clkH();

		story_tb <= 12'h033;
		dat_i <= 8'h55;
		lchar_i <= 1;
		valid_i <= 1;

		assert_tx1(0); assert_tx0(1);	// LChar flag

		clkL(); clkH();

		story_tb <= 12'h034;
		lchar_i <= 0;
		valid_i <= 0;

		assert_tx1(0); assert_tx0(1);	// D0

		clkL(); clkH();

		story_tb <= 12'h035;

		assert_tx1(1); assert_tx0(0);	// D1

		clkL(); clkH();

		story_tb <= 12'h036;

		assert_tx1(0); assert_tx0(1);	// D2

		clkL(); clkH();

		story_tb <= 12'h037;

		assert_tx1(1); assert_tx0(0);	// D3

		clkL(); clkH();

		story_tb <= 12'h038;

		assert_tx1(0); assert_tx0(1);	// D4
		assert_ready(0);

		clkL(); clkH();

		story_tb <= 12'h039;

		assert_tx1(1); assert_tx0(0);	// D5
		assert_ready(0);

		clkL(); clkH();

		story_tb <= 12'h03A;

		assert_tx1(0); assert_tx0(1);	// D6
		assert_ready(0);

		clkL(); clkH();

		story_tb <= 12'h03B;

		assert_tx1(1); assert_tx0(0);	// D7
		assert_ready(1);

		story_tb <= 12'h03C;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(0);	// Tx pins should quiesce.
		assert_ready(1);

		// R lc R

		story_tb <= 12'h040;
		{clk, valid_i, lchar_i, dat_i} <= 0;
		reset <= 1;

		clkL(); clkH();

		reset <= 0;

		clkL(); clkH();

		assert_tx0(0);	assert_tx1(0);
		assert_ready(1);

		story_tb <= 12'h041;
		dat_i <= 8'hAA;
		lchar_i <= 1;
		valid_i <= 1;

		clkL(); clkH();

		assert_ready(0);

		lchar_i <= 0;
		valid_i <= 0;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(1);	// parity
		assert_ready(0);

		clkL(); clkH();

		story_tb <= 12'h042;

		assert_tx1(1); assert_tx0(0);	// LChar flag

		story_tb <= 12'h043;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(1);	// D0

		story_tb <= 12'h044;
		reset <= 1;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(0);
		assert_ready(1);

		story_tb <= 12'h045;
		reset <= 0;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(0);	// Data should remain stable.

		// R lc nc

		story_tb <= 12'h050;
		{clk, valid_i, lchar_i, dat_i} <= 0;
		reset <= 1;

		clkL(); clkH();

		reset <= 0;

		clkL(); clkH();

		assert_tx0(0);	assert_tx1(0);
		assert_ready(1);

		story_tb <= 12'h051;
		dat_i <= 8'hAA;
		lchar_i <= 1;
		valid_i <= 1;

		clkL(); clkH();

		assert_ready(0);

		lchar_i <= 0;
		valid_i <= 0;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(1);	// parity
		assert_ready(0);

		clkL(); clkH();

		story_tb <= 12'h052;

		assert_tx1(1); assert_tx0(0);	// LChar flag

		story_tb <= 12'h053;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(1);	// D0

		story_tb <= 12'h054;
		dat_i <= 8'h55;
		lchar_i <= 0;
		valid_i <= 1;

		clkL(); clkH();

		assert_tx1(1); assert_tx0(0);	// D1
		assert_ready(0);

		story_tb <= 12'h055;
		valid_i <= 0;
		
		clkL(); clkH();

		assert_tx1(0); assert_tx0(0);	// Data should quiesce.

		// R lc lc

		story_tb <= 12'h060;
		{clk, valid_i, lchar_i, dat_i} <= 0;
		reset <= 1;

		clkL(); clkH();

		reset <= 0;

		clkL(); clkH();

		assert_tx0(0);	assert_tx1(0);
		assert_ready(1);

		story_tb <= 12'h061;
		dat_i <= 8'hAA;
		lchar_i <= 1;
		valid_i <= 1;

		clkL(); clkH();

		assert_ready(0);

		lchar_i <= 0;
		valid_i <= 0;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(1);	// parity
		assert_ready(0);

		clkL(); clkH();

		story_tb <= 12'h062;

		assert_tx1(1); assert_tx0(0);	// LChar flag

		story_tb <= 12'h063;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(1);	// D0

		story_tb <= 12'h064;
		dat_i <= 8'h55;
		lchar_i <= 1;
		valid_i <= 1;

		clkL(); clkH();

		assert_tx1(1); assert_tx0(0);	// D1
		assert_ready(0);

		story_tb <= 12'h065;
		valid_i <= 0;
		lchar_i <= 0;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(0);	// Data should quiesce.


		// R nc ic R

		story_tb <= 12'h070;
		{clk, valid_i, lchar_i, dat_i} <= 0;
		reset <= 1;

		clkL(); clkH();

		reset <= 0;

		clkL(); clkH();

		assert_tx0(0);	assert_tx1(0);
		assert_ready(1);

		story_tb <= 12'h071;
		dat_i <= 8'hAA;
		lchar_i <= 0;
		valid_i <= 1;

		clkL(); clkH();

		assert_ready(0);

		valid_i <= 0;

		clkL(); clkH();

		assert_tx1(1); assert_tx0(0);	// parity
		assert_ready(0);

		story_tb <= 12'h072;

		clkL(); clkH();

		story_tb <= 12'h073;

		assert_tx1(0); assert_tx0(1);	// LChar flag

		clkL(); clkH();

		story_tb <= 12'h074;

		assert_tx1(0); assert_tx0(1);	// D0

		clkL(); clkH();

		story_tb <= 12'h075;

		assert_tx1(1); assert_tx0(0);	// D1

		clkL(); clkH();

		story_tb <= 12'h076;

		assert_tx1(0); assert_tx0(1);	// D2

		clkL(); clkH();

		story_tb <= 12'h077;

		assert_tx1(1); assert_tx0(0);	// D3

		reset <= 1;

		clkL(); clkH();

		story_tb <= 12'h078;

		assert_tx1(0); assert_tx0(0);	// Transmission terminated
		assert_ready(1);

		reset <= 0;

		clkL(); clkH();

		story_tb <= 12'h079;

		assert_tx1(0); assert_tx0(0);	// D/S stable.
		assert_ready(1);

		// R nc ic nc

		story_tb <= 12'h080;
		{clk, valid_i, lchar_i, dat_i} <= 0;
		reset <= 1;

		clkL(); clkH();

		reset <= 0;

		clkL(); clkH();

		assert_tx0(0);	assert_tx1(0);
		assert_ready(1);

		story_tb <= 12'h081;
		dat_i <= 8'hAA;
		lchar_i <= 0;
		valid_i <= 1;

		clkL(); clkH();

		assert_ready(0);

		valid_i <= 0;

		clkL(); clkH();

		assert_tx1(1); assert_tx0(0);	// parity
		assert_ready(0);

		story_tb <= 12'h082;

		clkL(); clkH();

		story_tb <= 12'h083;

		assert_tx1(0); assert_tx0(1);	// LChar flag

		clkL(); clkH();

		story_tb <= 12'h084;

		assert_tx1(0); assert_tx0(1);	// D0

		clkL(); clkH();

		story_tb <= 12'h085;

		assert_tx1(1); assert_tx0(0);	// D1

		clkL(); clkH();

		story_tb <= 12'h086;

		assert_tx1(0); assert_tx0(1);	// D2

		clkL(); clkH();

		story_tb <= 12'h087;

		assert_tx1(1); assert_tx0(0);	// D3

		dat_i <= 8'h55;
		lchar_i <= 0;
		valid_i <= 1;

		clkL(); clkH();

		story_tb <= 12'h088;

		assert_tx1(0); assert_tx0(1);	// D4
		assert_ready(0);

		valid_i <= 0;

		clkL(); clkH();

		story_tb <= 12'h089;

		assert_tx1(1); assert_tx0(0);	// D5
		assert_ready(0);

		clkL(); clkH();

		story_tb <= 12'h08A;

		assert_tx1(0); assert_tx0(1);	// D6
		assert_ready(0);

		clkL(); clkH();

		story_tb <= 12'h08B;

		assert_tx1(1); assert_tx0(0);	// D7
		assert_ready(1);

		story_tb <= 12'h08C;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(0);	// Tx pins should quiesce.
		assert_ready(1);

		// R nc ic lc

		story_tb <= 12'h090;
		{clk, valid_i, lchar_i, dat_i} <= 0;
		reset <= 1;

		clkL(); clkH();

		reset <= 0;

		clkL(); clkH();

		assert_tx0(0);	assert_tx1(0);
		assert_ready(1);

		story_tb <= 12'h091;
		dat_i <= 8'hAA;
		lchar_i <= 0;
		valid_i <= 1;

		clkL(); clkH();

		assert_ready(0);

		valid_i <= 0;

		clkL(); clkH();

		assert_tx1(1); assert_tx0(0);	// parity
		assert_ready(0);

		story_tb <= 12'h092;

		clkL(); clkH();

		story_tb <= 12'h093;

		assert_tx1(0); assert_tx0(1);	// LChar flag

		clkL(); clkH();

		story_tb <= 12'h094;

		assert_tx1(0); assert_tx0(1);	// D0

		clkL(); clkH();

		story_tb <= 12'h095;

		assert_tx1(1); assert_tx0(0);	// D1

		clkL(); clkH();

		story_tb <= 12'h096;

		assert_tx1(0); assert_tx0(1);	// D2

		clkL(); clkH();

		story_tb <= 12'h097;

		assert_tx1(1); assert_tx0(0);	// D3

		dat_i <= 8'h55;
		lchar_i <= 1;
		valid_i <= 1;

		clkL(); clkH();

		story_tb <= 12'h098;

		assert_tx1(0); assert_tx0(1);	// D4
		assert_ready(0);

		valid_i <= 0;
		lchar_i <= 0;

		clkL(); clkH();

		story_tb <= 12'h099;

		assert_tx1(1); assert_tx0(0);	// D5
		assert_ready(0);

		clkL(); clkH();

		story_tb <= 12'h09A;

		assert_tx1(0); assert_tx0(1);	// D6
		assert_ready(0);

		clkL(); clkH();

		story_tb <= 12'h09B;

		assert_tx1(1); assert_tx0(0);	// D7
		assert_ready(1);

		story_tb <= 12'h09C;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(0);	// Tx pins should quiesce.
		assert_ready(1);

		// R nc ic fch
		//	implied by R nc ic {nc|lc} tests above.

		// R lc ic R

		story_tb <= 12'h0A0;
		{clk, valid_i, lchar_i, dat_i} <= 0;
		reset <= 1;

		clkL(); clkH();

		reset <= 0;

		clkL(); clkH();

		assert_tx0(0);	assert_tx1(0);
		assert_ready(1);

		story_tb <= 12'h0A1;
		dat_i <= 8'hAA;
		lchar_i <= 1;
		valid_i <= 1;

		clkL(); clkH();

		assert_ready(0);

		valid_i <= 0;
		lchar_i <= 0;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(1);	// parity
		assert_ready(0);

		story_tb <= 12'h0A2;

		clkL(); clkH();

		assert_tx1(1); assert_tx0(0);	// LChar flag

		story_tb <= 12'h0A3;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(1);	// D0

		story_tb <= 12'h0A4;
		reset <= 1;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(0);	// Transmission interrupted.
		assert_ready(1);

		story_tb <= 12'h0A5;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(0);	// D/S stable.
		assert_ready(1);

		// R lc ic nc

		story_tb <= 12'h0B0;
		{clk, valid_i, lchar_i, dat_i} <= 0;
		reset <= 1;

		clkL(); clkH();

		reset <= 0;

		clkL(); clkH();

		assert_tx0(0);	assert_tx1(0);
		assert_ready(1);

		story_tb <= 12'h0B1;
		dat_i <= 8'hAA;
		lchar_i <= 1;
		valid_i <= 1;

		clkL(); clkH();

		assert_ready(0);

		valid_i <= 0;
		lchar_i <= 0;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(1);	// parity
		assert_ready(0);

		story_tb <= 12'h0B2;

		clkL(); clkH();

		assert_tx1(1); assert_tx0(0);	// LChar flag

		story_tb <= 12'h0B3;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(1);	// D0

		story_tb <= 12'h0B4;
		dat_i <= 8'h55;
		lchar_i <= 0;
		valid_i <= 1;

		clkL(); clkH();

		assert_tx1(1); assert_tx0(0);	// D1
		assert_ready(0);		// 0 b/c valid_i asserted.

		story_tb <= 12'h0B5;
		valid_i <= 0;
		lchar_i <= 0;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(0);	// Tx pins quiesced.
		assert_ready(1);

		// R lc ic lc

		story_tb <= 12'h0C0;
		{clk, valid_i, lchar_i, dat_i} <= 0;
		reset <= 1;

		clkL(); clkH();

		reset <= 0;

		clkL(); clkH();

		assert_tx0(0);	assert_tx1(0);
		assert_ready(1);

		story_tb <= 12'h0C1;
		dat_i <= 8'hAA;
		lchar_i <= 1;
		valid_i <= 1;

		clkL(); clkH();

		assert_ready(0);

		valid_i <= 0;
		lchar_i <= 0;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(1);	// parity
		assert_ready(0);

		story_tb <= 12'h0C2;

		clkL(); clkH();

		assert_tx1(1); assert_tx0(0);	// LChar flag

		story_tb <= 12'h0C3;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(1);	// D0

		story_tb <= 12'h0C4;
		dat_i <= 8'h55;
		lchar_i <= 1;
		valid_i <= 1;

		clkL(); clkH();

		assert_tx1(1); assert_tx0(0);	// D1
		assert_ready(0);		// 0 b/c valid_i asserted.

		story_tb <= 12'h0C5;
		valid_i <= 0;
		lchar_i <= 0;

		clkL(); clkH();

		assert_tx1(0); assert_tx0(0);	// Tx pins quiesced.
		assert_ready(1);

		// R lc ic fch
		//	implied by R lc ic {nc|lc} tests above.

		// Make sure that the S signal is stable between characters.

		story_tb <= 12'h0D0;
		{clk, valid_i, lchar_i, dat_i} <= 0;
		reset <= 1;

		clkL(); clkH();

		reset <= 0;

		clkL(); clkH();

		dat_i <= 8'h02;
		lchar_i <= 1;
		valid_i <= 1;

		clkL(); clkH();
		clkL(); clkH();

		assert_ready(0);
		assert_tx1(0);	assert_tx0(1);	// Parity

		valid_i <= 0;
		story_tb <= 12'h0D1;

		clkL(); clkH();

		assert_ready(0);
		assert_tx1(1);	assert_tx0(0);	// LChar flag

		story_tb <= 12'h0D2;

		clkL(); clkH();

		assert_ready(0);
		assert_tx1(0);	assert_tx0(1);	// D0a

		story_tb <= 12'h0D3;

		clkL(); clkH();

		assert_ready(1);
		assert_tx1(1);	assert_tx0(0);	// D1a

		story_tb <= 12'h0D4;
		dat_i <= 8'h00;
		valid_i <= 1;
		lchar_i <= 1;

		clkL(); clkH();

		assert_ready(0);
		assert_tx1(0);	assert_tx0(0);	// Do not insert spurious bits
		
		story_tb <= 12'h0D5;
		valid_i <= 0;
		lchar_i <= 0;

		clkL(); clkH();

		assert_ready(0);
		assert_tx1(1);	assert_tx0(0);	// Parity
	
		story_tb <= 12'h0D5;
		
		clkL(); clkH();

		assert_ready(0);
		assert_tx1(1);	assert_tx0(0);	// LChar flag
	
		story_tb <= 12'h0D6;
		
		clkL(); clkH();

		assert_ready(0);
		assert_tx1(0);	assert_tx0(1);	// D0b
	
		story_tb <= 12'h0D7;
		
		clkL(); clkH();

		assert_ready(1);
		assert_tx1(0);	assert_tx0(1);	// D1b
	
		$display("@I Done.");
		$stop;
	end
endmodule

