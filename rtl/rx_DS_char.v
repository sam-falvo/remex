`timescale 1ns / 1ps

`define WAITING_FOR_ICT		6'b000001
`define WAITING_FOR_P0		6'b000010
`define WAITING_FOR_P1		6'b000100
`define WAITING_FOR_P2		6'b001000
`define WAITING_FOR_P3		6'b010000
`define WAITING_FOR_CMD		6'b100000

module rx_DS_char(
	input		rxClk,
	input		rxReset,
	input	[1:0]	d,
	input		dValid,

	output	[7:0]	q,
	output		nchar,
	output		lchar,
	output		parityError
);
	reg		nchar, nnchar;
	reg		lchar, nlchar;
	reg		parityError;

	always @(posedge rxClk) begin
		if(rxReset) begin
			nchar <= 0;
			lchar <= 0;
		end
		else begin
			nchar <= nnchar;
			lchar <= nlchar;
		end
	end

	reg	[5:0]	state;
	reg	[5:0]	nstate;

	always @(posedge rxClk) begin
		if (rxReset) begin
			state <= `WAITING_FOR_ICT;
		end
		else begin
			state <= nstate;
		end
	end

	reg	[1:0]	qp0, qp1, qp2, qp3;
	reg		bits01, bits23, bits45, bits67;

	assign q = {qp3, qp2, qp1, qp0};

	always @(posedge rxClk) begin
		if(rxReset) begin
			qp0 <= 0;
			qp1 <= 0;
			qp2 <= 0;
			qp3 <= 0;
		end
		else begin
			if(bits01) begin
				qp0 <= d;
			end
			if(bits23) begin
				qp1 <= d;
			end
			if(bits45) begin
				qp2 <= d;
			end
			if(bits67) begin
				qp3 <= d;
			end
		end
	end

	reg [1:0] parityPair;
	reg zeroParity, accumulateParity;

	always @(posedge rxClk) begin
		if(rxReset | zeroParity) begin
			parityPair = 0;
		end
		else begin
			if(accumulateParity) begin
				parityPair = parityPair ^ d;
			end
		end
	end

	wire paritySoFar = ^(d ^ parityPair);
	reg parityErrorDetect;

	always @(posedge rxClk) begin
		if(rxReset) begin
			parityError <= 0;
		end
		else begin
			parityError <= parityError | parityErrorDetect;
		end
	end

	always @(*) begin
		nstate = state;
		bits01 = 0;
		bits23 = 0;
		bits45 = 0;
		bits67 = 0;
		nlchar = 0;
		nnchar = 0;
		zeroParity = 0;
		accumulateParity = 0;
		parityErrorDetect = 0;

		if(dValid && (state == `WAITING_FOR_ICT)) begin
			if(d[1] == 1'b0) begin
				nstate = `WAITING_FOR_P0;
			end
			else begin
				nstate = `WAITING_FOR_CMD;
			end

			parityErrorDetect = ~paritySoFar;
			zeroParity = 1;
		end

		if(dValid && (state == `WAITING_FOR_CMD)) begin
			bits01 = 1;
			nstate = `WAITING_FOR_ICT;
			nlchar = 1;
			accumulateParity = 1;
		end

		if(dValid && (state == `WAITING_FOR_P0)) begin
			bits01 = 1;
			nstate = `WAITING_FOR_P1;
			accumulateParity = 1;
		end
		if(dValid && (state == `WAITING_FOR_P1)) begin
			bits23 = 1;
			nstate = `WAITING_FOR_P2;
			accumulateParity = 1;
		end
		if(dValid && (state == `WAITING_FOR_P2)) begin
			bits45 = 1;
			nstate = `WAITING_FOR_P3;
			accumulateParity = 1;
		end
		if(dValid && (state == `WAITING_FOR_P3)) begin
			bits67 = 1;
			nstate = `WAITING_FOR_ICT;
			nnchar = 1;
			accumulateParity = 1;
		end
	end
endmodule

