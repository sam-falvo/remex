`timescale 1ns / 1ps

module sram(
	input		sram_clk,
	
	output	[18:0]	sram_adr_o,
	inout	[15:0]	sram_dat_io,
	output		sram_ce_on,
	output		sram_we_on,
	output		sram_oe_on,
	output		sram_lbe_on,
	output		sram_ube_on,

	input	[1:0]	sram_sel_i,
	input		sram_we_i,
	input	[18:0]	sram_adr_i,
	output	[15:0]	sram_dat_o,
	input	[15:0]	sram_dat_i,
	input		sram_stb_i,
	output		sram_ack_o
);
	SB_IO #(
		.PIN_TYPE(6'b1010_01),
		.PULLUP(1'b0)
	) sram_io [15:0] (
		.PACKAGE_PIN(sram_dat_io),
		.OUTPUT_ENABLE(sram_we_i & (~sram_clk)),
		.D_OUT_0(sram_dat_i),
		.D_IN_0(sram_dat_o)
	);

	assign sram_adr_o = sram_adr_i;
	assign sram_ce_on = 0;
	assign sram_we_on = ~(sram_we_i & ~sram_clk & sram_stb_i);
	assign sram_oe_on = ~(~sram_we_i & ~sram_clk & sram_stb_i);
	assign sram_lbe_on = ~(sram_sel_i[0] & sram_we_i & sram_stb_i);
	assign sram_ube_on = ~(sram_sel_i[1] & sram_we_i & sram_stb_i);
	assign sram_ack_o = sram_stb_i;
endmodule

