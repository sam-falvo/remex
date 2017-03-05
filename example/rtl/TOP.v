`timescale 1ns / 1ps


module TOP(
	input		fpga_clk,
	input		cpu_reset,

	output	[18:0]	sram_adr_o,
	inout	[15:0]	sram_dat_io,
	output		sram_ce_on,
	output		sram_we_on,
	output		sram_oe_on,
	output		sram_lbe_on,
	output		sram_ube_on,

	output		led0,
	output		led1,
	output		led2,
	input		switch0
);
	wire iack, istb;
	wire [31:0] idat;
	wire [63:0] idat_wide, iadr;
	wire [63:0] ddati, ddato, dadr;
	wire dwe, dcyc, dstb, dsigned, dack;
	wire [1:0] dsiz;
	wire [63:0] xdato, xdati, xadr;
	wire xwe, xcyc, xstb, xsigned, xack;
	wire [1:0] xsiz;
	wire [15:0] sdato, sdati;
	wire [63:0] sadr;
	wire swe, scyc, sstb, ssigned, sack;
	wire ssiz;
	wire [63:0] wbdato;
	wire [7:0] wbsel;
	wire [15:0] wbdati;
	wire ram_ack, remex_ack, gpia_ack, rom_ack;
	wire [15:0] ram_dat_o, remex_dat_o, gpia_dat_o, rom_dat_o;
	wire [15:0] gpia_outputs;

	// Main clock is 100MHz on icoBoard.
	// Reduce it to no more than 25MHz for CPU.

	reg [7:0] divider = 0;
	reg cpu_clk = 0;

	always @(posedge fpga_clk) begin
		divider <= divider + 1;
		if(divider == 7'd 50) begin
			cpu_clk <= ~cpu_clk;
			divider <= 0;
		end
	end

	PolarisCPU cpu(
		.clk_i(cpu_clk),
		.reset_i(cpu_reset),

		.fence_o(),
		.trap_o(),
		.cause_o(),
		.mepc_o(),
		.mpie_o(),
		.mie_o(),

		.irq_i(0),

		.iack_i(iack),
		.idat_i(idat),
		.iadr_o(iadr),
		.istb_o(istb),

		.dack_i(dack),
		.ddat_i(ddati),
		.ddat_o(ddato),
		.dadr_o(dadr),
		.dwe_o(dwe),
		.dcyc_o(dcyc),
		.dstb_o(dstb),
		.dsiz_o(dsiz),
		.dsigned_o(dsigned),

		.cadr_o(),
		.coe_o(),
		.cwe_o(),
		.cvalid_i(0),
		.cdat_o(),
		.cdat_i(0)
	);

	// Converge Harvard buses to Von Neumann

	assign idat = idat_wide[31:0];

	arbiter arb(
		.clk_i(cpu_clk),
		.reset_i(cpu_reset),

		.idat_i(0),
		.iadr_i(iadr),
		.iwe_i(0),
		.icyc_i(istb),
		.istb_i(istb),
		.isiz_i(2),	// Always 32-bit
		.isigned_i(0),
		.iack_o(iack),
		.idat_o(idat_wide),

		.ddat_i(ddato),
		.dadr_i(dadr),
		.dwe_i(dwe),
		.dcyc_i(dcyc),
		.dstb_i(dstb),
		.dsiz_i(dsiz),
		.dsigned_i(dsigned),
		.dack_o(dack),
		.ddat_o(ddati),

		.xdat_o(xdato),
		.xadr_o(xadr),
		.xwe_o(xwe),
		.xcyc_o(xcyc),
		.xstb_o(xstb),
		.xsiz_o(xsiz),
		.xsigned_o(xsigned),
		.xack_i(xack),
		.xdat_i(xdati)
	);

	// Reduce bus to 16-bits wide.

	bottleneck bot(
		.clk_i(cpu_clk),
		.reset_i(cpu_reset),

		.m_adr_i(xadr),
		.m_cyc_i(xcyc),
		.m_dat_i(xdato),
		.m_signed_i(xsigned),
		.m_siz_i(xsiz),
		.m_stb_i(xstb),
		.m_we_i(xwe),
		.m_ack_o(xack),
		.m_dat_o(xdati),
		.m_err_align_o(),

		.s_adr_o(sadr),
		.s_cyc_o(scyc),
		.s_signed_o(ssigned),
		.s_siz_o(ssiz),
		.s_stb_o(sstb),
		.s_we_o(swe),
		.s_dat_o(sdato),
		.s_ack_i(sack),
		.s_dat_i({48'd0, sdati})
	);

	// Expose a Wishbone B3 interface.

	bridge wb_bridge(
		.f_signed_i(ssigned),
		.f_siz_i({1'b0, ssiz}),
		.f_adr_i({2'b00, sadr[0]}),
		.f_dat_i({48'd0, sdato}),
		.f_dat_o(sdati),

		.wb_sel_o(wbsel),
		.wb_dat_o(wbdato),
		.wb_dat_i({48'd0, wbdati})
	);

	wire ram_addr   = sadr[23:20] == 4'b0000;
	wire gpia_addr  = sadr[23:20] == 4'b0001;
	wire remex_addr = sadr[23:20] == 4'b0010;
	wire rom_addr   = sadr[23:20] == 4'b1111;

	wire ram_stb   = scyc & sstb & ram_addr;
	wire gpia_stb  = scyc & sstb & gpia_addr;
	wire remex_stb = scyc & sstb & remex_addr;
	wire rom_stb   = scyc & sstb & rom_addr;

	// We want sack asserted if we address a non-existent
	// region of memory.  The data read back will just be 0.
	// Remember, this logic only works because of how B3
	// defines the relationship between STB and ACK signals.
	// If upgrading to Wishbone B4, we'll need to change this.

	assign sack	= (ram_stb ? ram_ack : 1)
//			& (remex_stb ? remex_ack : 1)
			& (gpia_stb ? gpia_ack : 1)
			& (rom_stb ? rom_ack : 1)
			;

	assign wbdati	= (ram_ack ? ram_dat_o : 0)
//			| (remex_ack ? remex_dat_o : 0)
			| (gpia_ack ? gpia_dat_o : 0)
			| (rom_ack ? rom_dat_o : 0)
			;

	// Static RAM interface.

	sram ram(
		.sram_clk(cpu_clk),
		.sram_adr_o(sram_adr_o),
		.sram_dat_io(sram_dat_io),
		.sram_ce_on(sram_ce_on),
		.sram_we_on(sram_we_on),
		.sram_oe_on(sram_oe_on),
		.sram_lbe_on(sram_lbe_on),
		.sram_ube_on(sram_ube_on),
		.sram_sel_i(wbsel[1:0]),
		.sram_we_i(swe),
		.sram_adr_i(sadr[19:1]),
		.sram_dat_o(ram_dat_o),
		.sram_dat_i(wbdato[15:0]),
		.sram_stb_i(ram_stb),
		.sram_ack_o(ram_ack)
	);

	// General Purpose I/O Adapter.

	GPIA gpia(
		.RST_I(cpu_reset),
		.CLK_I(cpu_clk),
		.PORT_O(gpia_outputs),
		.PORT_I({15'd0, switch0}),
		.ADR_I(sadr[1]),
		.CYC_I(scyc),
		.STB_I(gpia_stb),
		.WE_I(swe),
		.DAT_I(wbdato[15:0]),
		.DAT_O(gpia_dat_o),
		.ACK_O(gpia_ack)
	);

	assign led0 = gpia_outputs[0];
	assign led1 = gpia_outputs[1];
	assign led2 = gpia_outputs[2];

	// Bootstrap ROM.

	BROM rom(
		.adr_i(sadr[7:1]),
		.dat_o(rom_dat_o),
		.stb_i(rom_stb),
		.ack_o(rom_ack)
	);
endmodule

