`timescale 1ns / 1ps

module rx_top_tb();
	reg rxClk, rxReset;
	reg d, s;
	wire [7:0] q;
	wire nchar, lchar, parityError;
	wire full_o, empty_o;

	always begin
		#10; rxClk <= ~rxClk;
	end

	rx_top dut(
		.rxClk(rxClk),
		.rxReset(rxReset),
		.d(d),
		.s(s),
		.q(q),
		.nchar(nchar),
		.lchar(lchar),
		.parityError(parityError),
		.full_o(full_o),
		.empty_o(empty_o)
	);

	initial begin
		$dumpfile("wtf.vcd");
		$dumpvars;

		{d, s, rxClk, rxReset} <= 0;

		#20;
		rxReset <= 1;
		#20;
		rxReset <= 0;
		#20;

		{d,s} <= 2'b01;	#30;  // 0  ESC
		{d,s} <= 2'b11;	#30;  // 1
		{d,s} <= 2'b10;	#30;  // 1
		{d,s} <= 2'b11;	#30;  // 1
		{d,s} <= 2'b01;	#30;  // 0  FCT (NULL)
		{d,s} <= 2'b11;	#30;  // 1
		{d,s} <= 2'b01;	#30;  // 0
		{d,s} <= 2'b00;	#30;  // 0

		{d,s} <= 2'b01;	#30;  // 0  ESC
		{d,s} <= 2'b11;	#30;  // 1
		{d,s} <= 2'b10;	#30;  // 1
		{d,s} <= 2'b11;	#30;  // 1
		{d,s} <= 2'b01;	#30;  // 0  FCT (NULL)
		{d,s} <= 2'b11;	#30;  // 1
		{d,s} <= 2'b01;	#30;  // 0
		{d,s} <= 2'b00;	#30;  // 0

		{d,s} <= 2'b10; #30;  // 1 NChar("H")
		{d,s} <= 2'b00; #30;  // 0
		{d,s} <= 2'b01; #30;  // 0
		{d,s} <= 2'b00; #30;  // 0
		{d,s} <= 2'b01; #30;  // 0
		{d,s} <= 2'b11; #30;  // 1
		{d,s} <= 2'b01; #30;  // 0
		{d,s} <= 2'b00; #30;  // 0
		{d,s} <= 2'b10; #30;  // 1
		{d,s} <= 2'b00; #30;  // 0

		{d,s} <= 2'b10; #30;  // 1 NChar("e")
		{d,s} <= 2'b00; #30;  // 0
		{d,s} <= 2'b10; #30;  // 1
		{d,s} <= 2'b00; #30;  // 0
		{d,s} <= 2'b10; #30;  // 1
		{d,s} <= 2'b00; #30;  // 0
		{d,s} <= 2'b01; #30;  // 0
		{d,s} <= 2'b11; #30;  // 1
		{d,s} <= 2'b10; #30;  // 1
		{d,s} <= 2'b00; #30;  // 0

		{d,s} <= 2'b10; #30;  // 1 NChar("l")
		{d,s} <= 2'b00; #30;  // 0
		{d,s} <= 2'b01; #30;  // 0
		{d,s} <= 2'b00; #30;  // 0
		{d,s} <= 2'b10; #30;  // 1
		{d,s} <= 2'b11; #30;  // 1
		{d,s} <= 2'b01; #30;  // 0
		{d,s} <= 2'b11; #30;  // 1
		{d,s} <= 2'b10; #30;  // 1
		{d,s} <= 2'b00; #30;  // 0

		{d,s} <= 2'b10; #30;  // 1 NChar("l")
		{d,s} <= 2'b00; #30;  // 0
		{d,s} <= 2'b01; #30;  // 0
		{d,s} <= 2'b00; #30;  // 0
		{d,s} <= 2'b10; #30;  // 1
		{d,s} <= 2'b11; #30;  // 1
		{d,s} <= 2'b01; #30;  // 0
		{d,s} <= 2'b11; #30;  // 1
		{d,s} <= 2'b10; #30;  // 1
		{d,s} <= 2'b00; #30;  // 0

		{d,s} <= 2'b10; #30;  // 1 NChar("o")
		{d,s} <= 2'b00; #30;  // 0
		{d,s} <= 2'b10; #30;  // 1
		{d,s} <= 2'b11; #30;  // 1
		{d,s} <= 2'b10; #30;  // 1
		{d,s} <= 2'b11; #30;  // 1
		{d,s} <= 2'b01; #30;  // 0
		{d,s} <= 2'b11; #30;  // 1
		{d,s} <= 2'b10; #30;  // 1
		{d,s} <= 2'b00; #30;  // 0

		{d,s} <= 2'b10; #30;  // 1 NChar("\r")
		{d,s} <= 2'b00; #30;  // 0
		{d,s} <= 2'b10; #30;  // 1
		{d,s} <= 2'b00; #30;  // 0
		{d,s} <= 2'b10; #30;  // 1
		{d,s} <= 2'b11; #30;  // 1
		{d,s} <= 2'b01; #30;  // 0
		{d,s} <= 2'b00; #30;  // 0
		{d,s} <= 2'b01; #30;  // 0
		{d,s} <= 2'b00; #30;  // 0

		{d,s} <= 2'b01; #30;  // 0 NChar("\n")
		{d,s} <= 2'b00; #30;  // 0
		{d,s} <= 2'b01; #30;  // 0
		{d,s} <= 2'b11; #30;  // 1
		{d,s} <= 2'b01; #30;  // 0
		{d,s} <= 2'b11; #30;  // 1
		{d,s} <= 2'b01; #30;  // 0
		{d,s} <= 2'b00; #30;  // 0
		{d,s} <= 2'b01; #30;  // 0
		{d,s} <= 2'b00; #30;  // 0

		{d,s} <= 2'b01;	#30;  // 0  FCT (NULL)
		{d,s} <= 2'b11;	#30;  // 1
		{d,s} <= 2'b01;	#30;  // 0
		{d,s} <= 2'b11;	#30;  // 1

		{d,s} <= 2'b10;	#30;  // 1  ESC
		{d,s} <= 2'b11;	#30;  // 1
		{d,s} <= 2'b10;	#30;  // 1
		{d,s} <= 2'b11;	#30;  // 1
		{d,s} <= 2'b01;	#30;  // 0  FCT (NULL)
		{d,s} <= 2'b11;	#30;  // 1
		{d,s} <= 2'b01;	#30;  // 0
		{d,s} <= 2'b00;	#30;  // 0

		$display("@I Done.");
		$stop;
	end
endmodule
