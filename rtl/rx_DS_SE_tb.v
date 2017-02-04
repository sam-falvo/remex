`timescale 1ns / 1ps

module rx_DS_SE_tb();
	reg		d, s;
	reg		rxClk, rxReset;
	wire	[1:0]	dq;
	wire		dqValid;
	wire		dqParity;

	rx_DS_SE dut(
		.d(d),
		.s(s),
		.rxClk(rxClk),
		.rxReset(rxReset),
		.dq(dq),
		.dqValid(dqValid),
		.dqParity(dqParity)
	);

	task assert_dqvalid;
	input [7:0] story;
	input expected;
	begin
		if(dqValid !== expected) begin
			$display("@E %02X DQVALID Expected %d, got %d", story, expected, dqValid);
			$stop;
		end
	end
	endtask

	task assert_dq;
	input [7:0] story;
	input [1:0] expected;
	begin
		if(dq !== expected) begin
			$display("@E %02X DQ Expected %2b, got %2b", story, expected, dq);
			$stop;
		end
	end
	endtask

	always begin
		#10; rxClk <= ~rxClk;
	end

	initial begin
		$dumpfile("wtf.vcd");
		$dumpvars;

		{d, s, rxClk, rxReset} <= 0;
		#20;

		rxReset <= 1;
		#30;
		rxReset <= 0;
		assert_dqvalid(10, 0);
		assert_dq(10, 0);

		{d, s} <= 2'b01; #30;
		{d, s} <= 2'b11; #30;
		{d, s} <= 2'b10; #30;
		{d, s} <= 2'b11; #30;

		{d, s} <= 2'b01; #30;
		{d, s} <= 2'b11; #30;
		{d, s} <= 2'b01; #30;
		{d, s} <= 2'b00; #30;

		{d, s} <= 2'b01; #30;
		{d, s} <= 2'b11; #30;
		{d, s} <= 2'b10; #30;
		{d, s} <= 2'b11; #30;

		{d, s} <= 2'b01; #30;
		{d, s} <= 2'b11; #30;
		{d, s} <= 2'b01; #30;
		{d, s} <= 2'b00; #30;

		{d, s} <= 2'b01; #30;
		{d, s} <= 2'b11; #30;
		{d, s} <= 2'b10; #30;
		{d, s} <= 2'b11; #30;

		{d, s} <= 2'b01; #30;
		{d, s} <= 2'b11; #30;
		{d, s} <= 2'b01; #30;
		{d, s} <= 2'b00; #30;

		#100;

		$display("@I Done.");
		$stop;
	end
endmodule
