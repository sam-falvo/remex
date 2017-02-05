`timescale 1ns / 1ps

// Decodes the bit-pairs received by the rx_DS_SE module
// into N-chars and L-chars.
//
// At present, parity is ignored.  However, it will eventually
// be covered by this module as well.
// The only way to recover from a parity error is through
// resetting the module.

module rx_DS_char_tb();
	reg		rxClk, rxReset, dv;
	reg	[1:0]	d;
	wire	[7:0]	q;
	wire		nchar, lchar;
	wire		parityError;

	rx_DS_char charDecoder(
		.rxClk(rxClk),
		.rxReset(rxReset),
		.d(d),
		.dValid(dv),
		.q(q),
		.nchar(nchar),
		.lchar(lchar),
		.parityError(parityError)
	);

	always begin
		#10; rxClk = ~rxClk;
	end

	task bitPair;
	input [1:0] pair;
	begin
		{dv, d} <= {1'b1, pair};
		#20;
		{dv, d} <= {1'b0, pair};
		#20;
	end
	endtask

	task nch;
	input oddp;
	input [7:0] chr;
	begin
		bitPair({1'b0, oddp});
		bitPair(chr[1:0]);
		bitPair(chr[3:2]);
		bitPair(chr[5:4]);
		bitPair(chr[7:6]);
	end
	endtask

	task lch;
	input oddp;
	input [1:0] chr;
	begin
		bitPair({1'b1, oddp});
		bitPair(chr);
	end
	endtask

	task null;
	input oddp;
	begin
		lch(oddp, 2'b11);
		lch(0, 0);
	end
	endtask

	initial begin
		$dumpfile("wtf.vcd");
		$dumpvars;

		{rxClk, rxReset, dv, d} <= 0;
		#10;

		rxReset <= 1;
		#20;
		rxReset <= 0;
		#20;

		null(0);
		null(0);
		nch(1, 8'h41);
		lch(0, 2);
		null(1);
		null(0);
		nch(1, 8'h4F);
		lch(1, 2);

		lch(1, 3);	// NULL character with parity error.
		lch(1, 0);	// This result in parityError being asserted.

		null(1);
		null(0);
		nch(1, 8'h41);
		nch(1, 8'h62);
		nch(0, 8'h63);
		nch(1, 8'h64);
		lch(1, 2);
		null(1);
		null(0);

		$display("@I Done.");
		$stop;
	end
endmodule

