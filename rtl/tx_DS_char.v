module tx_DS_char(
	input		TxReset,
	input		TxClk,
	input		valid_i,
	input	[7:0]	dat_i,
	input		lchar_i,

	output		Tx0,
	output		Tx1,
	output		ready_o
);
	reg		ready;
	reg	[3:0]	chrLen;
	reg	[1:0]	icpLen;
	reg	[7:0]	shreg;
	reg		lcharFlag;
	reg		parity;
	reg		Tx0, Tx1;

	wire isReady = (ready && (chrLen == 4'd0) && (icpLen == 2'd2));
	wire isSendingParity = (~ready && (icpLen == 2'd2));
	wire isSendingLChar = (~ready && (icpLen == 2'd1));
	wire isSendingBits = (~ready && (icpLen == 2'd0) && (chrLen > 0));

	assign ready_o = isReady & ~valid_i;

	always @(posedge TxClk) begin
		ready <= ready;
		chrLen <= chrLen;
		icpLen <= icpLen;
		parity <= parity;
		Tx1 <= Tx1;
		Tx0 <= Tx0;
		shreg <= shreg;

		if(TxReset) begin			// S1
			ready <= 1;
			chrLen <= 0;
			icpLen <= 2'd2;
			parity <= 0;
			Tx1 <= 0;
			Tx0 <= 0;
			shreg <= 8'd0;
		end
		else begin
			if(valid_i && isReady) begin	// S2, S3
				ready <= 0;
				shreg <= dat_i;
				lcharFlag <= lchar_i;

				if(lchar_i) begin	// S3
					chrLen <= 4'd2;
				end
				else begin		// S2
					chrLen <= 4'd8;
				end
			end
			if(isSendingParity) begin	// S4
				Tx1 <= ~lcharFlag ^ parity;
				Tx0 <= lcharFlag ^ parity;
				icpLen <= 2'd1;
			end
			if(isSendingLChar) begin	// S5
				Tx1 <= lcharFlag;
				Tx0 <= ~lcharFlag;
				icpLen <= 2'd0;
				parity <= 0;
			end
			if(isSendingBits) begin		// S6, S7
				Tx1 <= shreg[0];
				Tx0 <= ~shreg[0];
				parity <= parity ^ shreg[0];
				shreg <= (shreg >> 1);
				chrLen <= chrLen - 1;

				if(chrLen == 4'd1) begin	// S7
					ready <= 1;
					icpLen <= 2'd2;
				end
			end
		end
	end
endmodule

