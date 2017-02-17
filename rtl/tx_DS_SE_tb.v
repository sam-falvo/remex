`timescale 1ns / 1ps

`include "asserts.vh"


module tx_DS_SE_tb();
	reg	[11:0]	story_tb;
	reg		TxClk, TxReset, Tx1, Tx0;
	wire 		D_o, S_o;

	`DEFIO(TxClk,1,0)
	`DEFASSERT0(D,o)
	`DEFASSERT0(S,o)

	tx_DS_SE transmitter(
		.TxClk(TxClk),
		.TxReset(TxReset),
		.Tx1(Tx1),
		.Tx0(Tx0),
		.D(D_o),
		.S(S_o)
	);

	initial begin
		$dumpfile("wtf.vcd");
		$dumpvars;

		// R -> O -> O -> R

		story_tb <= 12'h000;
		{TxClk,TxReset, Tx1, Tx0} = 0;
		TxClk0(); TxClk1();
		TxReset <= 1;
		TxClk0(); TxClk1();
		TxReset <= 0;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(0);

		story_tb <= 12'h001;
		Tx1 <= 1;
		TxClk0(); TxClk1();
		assert_D(1); assert_S(0);

		story_tb <= 12'h002;
		TxClk0(); TxClk1();
		assert_D(1); assert_S(1);

		story_tb <= 12'h003;
		TxReset <= 1;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(0);


		// R -> O -> O -> O


		story_tb <= 12'h010;
		{TxClk,TxReset, Tx1, Tx0} = 0;
		TxClk0(); TxClk1();
		TxReset <= 1;
		TxClk0(); TxClk1();
		TxReset <= 0;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(0);

		story_tb <= 12'h011;
		Tx1 <= 1;
		TxClk0(); TxClk1();
		assert_D(1); assert_S(0);

		story_tb <= 12'h012;
		TxClk0(); TxClk1();
		assert_D(1); assert_S(1);

		story_tb <= 12'h013;
		TxClk0(); TxClk1();
		assert_D(1); assert_S(0);


		// R -> O -> O -> Z


		story_tb <= 12'h020;
		{TxClk,TxReset, Tx1, Tx0} = 0;
		TxClk0(); TxClk1();
		TxReset <= 1;
		TxClk0(); TxClk1();
		TxReset <= 0;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(0);

		story_tb <= 12'h021;
		Tx1 <= 1;
		TxClk0(); TxClk1();
		assert_D(1); assert_S(0);

		story_tb <= 12'h022;
		TxClk0(); TxClk1();
		assert_D(1); assert_S(1);

		story_tb <= 12'h023;
		{Tx1, Tx0} = 2'b01;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(1);


		// R -> Z -> O -> R

		story_tb <= 12'h030;
		{TxClk,TxReset, Tx1, Tx0} = 0;
		TxClk0(); TxClk1();
		TxReset <= 1;
		TxClk0(); TxClk1();
		TxReset <= 0;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(0);

		story_tb <= 12'h031;
		Tx0 <= 1;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(1);

		story_tb <= 12'h032;
		{Tx0, Tx1} <= 2'b01;
		TxClk0(); TxClk1();
		assert_D(1); assert_S(1);

		story_tb <= 12'h033;
		TxReset <= 1;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(0);


		// R -> Z -> O -> O


		story_tb <= 12'h040;
		{TxClk,TxReset, Tx1, Tx0} = 0;
		TxClk0(); TxClk1();
		TxReset <= 1;
		TxClk0(); TxClk1();
		TxReset <= 0;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(0);

		story_tb <= 12'h041;
		Tx0 <= 1;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(1);

		story_tb <= 12'h042;
		{Tx0, Tx1} <= 2'b01;
		TxClk0(); TxClk1();
		assert_D(1); assert_S(1);

		story_tb <= 12'h043;
		TxClk0(); TxClk1();
		assert_D(1); assert_S(0);


		// R -> Z -> O -> Z


		story_tb <= 12'h050;
		{TxClk,TxReset, Tx1, Tx0} = 0;
		TxClk0(); TxClk1();
		TxReset <= 1;
		TxClk0(); TxClk1();
		TxReset <= 0;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(0);

		story_tb <= 12'h051;
		Tx0 <= 1;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(1);

		story_tb <= 12'h052;
		{Tx0, Tx1} = 2'b01;
		TxClk0(); TxClk1();
		assert_D(1); assert_S(1);

		story_tb <= 12'h053;
		{Tx1, Tx0} = 2'b01;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(1);


		// R -> Z -> R


		story_tb <= 12'h060;
		{TxClk,TxReset, Tx1, Tx0} = 0;
		TxClk0(); TxClk1();
		TxReset <= 1;
		TxClk0(); TxClk1();
		TxReset <= 0;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(0);

		story_tb <= 12'h061;
		Tx0 <= 1;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(1);

		story_tb <= 12'h062;
		TxReset <= 1;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(0);


		// R -> Z -> Z


		story_tb <= 12'h070;
		{TxClk,TxReset, Tx1, Tx0} = 0;
		TxClk0(); TxClk1();
		TxReset <= 1;
		TxClk0(); TxClk1();
		TxReset <= 0;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(0);

		story_tb <= 12'h071;
		Tx0 <= 1;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(1);

		story_tb <= 12'h072;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(0);


		// R -> O -> R


		story_tb <= 12'h080;
		{TxClk,TxReset, Tx1, Tx0} = 0;
		TxClk0(); TxClk1();
		TxReset <= 1;
		TxClk0(); TxClk1();
		TxReset <= 0;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(0);

		story_tb <= 12'h081;
		Tx1 <= 1;
		TxClk0(); TxClk1();
		assert_D(1); assert_S(0);

		story_tb <= 12'h082;
		TxReset <= 1;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(0);


		// R -> O -> Z


		story_tb <= 12'h090;
		{TxClk,TxReset, Tx1, Tx0} = 0;
		TxClk0(); TxClk1();
		TxReset <= 1;
		TxClk0(); TxClk1();
		TxReset <= 0;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(0);

		story_tb <= 12'h091;
		Tx1 <= 1;
		TxClk0(); TxClk1();
		assert_D(1); assert_S(0);

		story_tb <= 12'h092;
		{Tx1, Tx0} <= 2'b01;
		TxClk0(); TxClk1();
		assert_D(0); assert_S(0);


		$display("@I Done.");
		$stop;
	end
endmodule

