`ifndef SYNTHESIS
module SB_IO(
	inout		PACKAGE_PIN,
	input		OUTPUT_ENABLE,
	input		D_OUT_0,
	output		D_IN_0
);
	parameter PIN_TYPE = 6'b1010_10;
	parameter PULLUP = 0;

	assign PACKAGE_PIN = (OUTPUT_ENABLE ? D_OUT_0 : 1'bz);
	assign D_IN_0 = PACKAGE_PIN;
endmodule
`endif
