`timescale 1ns / 1ps

// This module implements a quasi-self-clocked receiver for
// IEEE-1355-compatible DS-SE-* PHYs.  It is only "quasi"-
// self-clocked because I was unable to get a true self-clocked
// implementation to properly simulate and report back any
// estimated timing parameters.
//
// Instead, I use a master clock, rxClk, which must run at least
// 3x the desired maximum supported data rate.  To meet DS-SE-02
// maximum specifications, rxClk must be run at 600MHz.
//
// The result is scoped by the dqValid output.  This is a *pulse*,
// which lasts for one rxClk period.  When asserted, the bits on
// dq[1:0] are valid.
//
// NOTE: Due to the extensive use of flipflops in the design,
// the circuit described below naturally forms a pipeline.
// dqValid doesn't assert for a given bit-pair P until the
// module is already receiving bit-pair P+1.  I recognize this
// is inconvenient.  However, it's the best I could do.  :(

module rx_DS_SE(
	input		d,
	input		s,
	input		rxClk,
	input		rxReset,

	output	[1:0]	dq,
	output		dqValid
);
	wire rxPhase = d ^ s;

	reg d_r, rxPhase_r;
	always @(posedge rxClk) begin
		if(rxReset) begin
			d_r <= 0;
			rxPhase_r <= 0;
		end
		else begin
			d_r <= d;
			rxPhase_r <= rxPhase;
		end
	end

	reg rxPhase_rr;
	always @(posedge rxClk) begin
		if(rxReset) begin
			rxPhase_rr <= 0;
		end
		else begin
			rxPhase_rr <= rxPhase_r;
		end
	end

	wire edgeDetect = rxPhase_r ^ rxPhase_rr;
	wire bit0Enable = edgeDetect & rxPhase_r;
	wire bit1Enable = edgeDetect & ~rxPhase_r;

	reg bit0_r, bit1_r;

	always @(posedge rxClk) begin
		if(rxReset) begin
			bit0_r <= 0;
			bit1_r <= 0;
		end
		else begin
			if(bit0Enable) begin
				bit0_r <= d_r;
			end

			if(bit1Enable) begin
				bit1_r <= d_r;
			end
		end
	end

	// q0, q1, qen synchronize the output state of the 
	// module.  qnfe is used internally to gate dqValid.
	// qnfe tracks whether or not the qen pulse has been
	// seen at least once.  Due to how the above logic
	// works, qen signals high when receiving the very
	// first bit, making it a spurious pulse.  qnfe
	// prevents this pulse from making it out to dqValid.

	reg q0, q1, qen, qnfe;

	always @(posedge rxClk) begin
		if(rxReset) begin
			q0 <= 0;
			q1 <= 0;
			qen <= 0;
			qnfe <= 0;
		end
		else begin
			q0 <= bit0_r;
			q1 <= bit1_r;
			qen <= bit0Enable;
			qnfe <= qen | qnfe;
		end
	end

	assign dq = {q1, q0};
	assign dqValid = qen & qnfe;
endmodule

