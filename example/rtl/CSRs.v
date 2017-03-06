module CSRs(
	input	[11:0]	cadr_i,
	output		cvalid_o,
	output	[63:0]	cdat_o,
	input	[63:0]	cdat_i,
	input		coe_i,
	input		cwe_i,

	input		mie_0,
	input		mie_mpie,
	input		mpie_mie,
	input		mpie_1,
	output	[63:0]	mtvec_o,
	output	[63:0]	mepc_o,
	output	[3:0]	cause_o,
	input	[63:0]	ia_i,
	input	[63:0]	pc_i,
	output		mie_o,
	output		mpie_o,
	input		ft0_i,
	input		tick_i,
	input		mcause_2,
	input		mcause_3,
	input		mcause_11,
	input		mcause_irq_i,
	input		mepc_ia,
	input		mepc_pc,
	input		irq_i,
	output		take_irq_o,

	input		reset_i,
	input		clk_i
);
	reg		mpie, mie;
	reg	[63:0]	mtvec;
	reg	[63:0]	mscratch;
	reg	[63:0]	mepc;
	reg	[4:0]	mcause;		// Compacted; bit 4 here maps to bit 63 in software
	reg	[63:0]	mbadaddr;
	reg	[63:0]	mcycle;
	reg	[63:0]	mtime;
	reg	[63:0]	minstret;
	reg		irqEn;

	wire		mpie_mux, mie_mux;
	wire	[63:0]	mtvec_mux;
	wire	[63:0]	mscratch_mux;
	wire	[63:0]	mepc_mux;
	wire	[4:0]	mcause_mux;
	wire	[63:0]	mbadaddr_mux;
	wire	[63:0]	mcycle_mux;
	wire	[63:0]	mtime_mux;
//	wire	[63:0]	minstret_mux;

	assign mtvec_o = mtvec;
	assign mepc_o = mepc;

	wire		csrv_misa = (cadr_i == 12'hF10);
	wire		csrv_mvendorid = (cadr_i == 12'hF11);
	wire		csrv_marchid = (cadr_i == 12'hF12);
	wire		csrv_mimpid = (cadr_i == 12'hF13);
	wire		csrv_mhartid = (cadr_i == 12'hF14);
	wire		csrv_mstatus = (cadr_i == 12'h300);
	wire		csrv_medeleg = (cadr_i == 12'h302);
	wire		csrv_mideleg = (cadr_i == 12'h303);
	wire		csrv_mie = (cadr_i == 12'h304);
	wire		csrv_mtvec = (cadr_i == 12'h305);
	wire		csrv_mscratch = (cadr_i == 12'h340);
	wire		csrv_mepc = (cadr_i == 12'h341);
	wire		csrv_mcause = (cadr_i == 12'h342);
	wire		csrv_mbadaddr = (cadr_i == 12'h343);
	wire		csrv_mip = (cadr_i == 12'h344);
	wire		csrv_mcycle = (cadr_i == 12'hF00);
	wire		csrv_mtime = (cadr_i == 12'hF01);
	wire		csrv_minstret = (cadr_i == 12'hF02);

	assign cvalid_o = |{
		csrv_misa, csrv_mvendorid, csrv_marchid,
		csrv_mimpid, csrv_mhartid, csrv_mstatus,
		csrv_medeleg, csrv_mideleg, csrv_mie,
		csrv_mtvec, csrv_mscratch, csrv_mepc,
		csrv_mcause, csrv_mbadaddr, csrv_mip,
		csrv_mcycle, csrv_mtime, csrv_minstret
	};

	wire	[63:0]	csrd_misa = {2'b10, 36'd0, 26'b00000001000000000100000000};
	wire	[63:0]	csrd_mvendorid = 64'd0;
	wire	[63:0]	csrd_marchid = 64'd0;
	wire	[63:0]	csrd_mimpid = 64'h1161008010000000;
	wire	[63:0]	csrd_mhartid = 64'd0;
	wire	[63:0]	csrd_mstatus = {
		1'b0,		// SD
		34'd0,		// reserved		
		5'b00000,	// VM
		4'b0000,	// reserved
		3'b000,		// MXR, PUM, MPRV
		2'b00,		// XS
		2'b00,		// FS
		2'b11,		// MPP
		2'b10,		// HPP
		1'b1,		// SPP
		mpie, 3'b000,
		mie, 3'b000
	};
	wire	[63:0]	csrd_medeleg = 64'd0;
	wire	[63:0]	csrd_mideleg = 64'd0;
	wire	[63:0]	csrd_mie = {
		52'd0,
		irqEn,
		11'd0
	};
	wire	[63:0]	csrd_mtvec = mtvec;
	wire	[63:0]	csrd_mscratch = mscratch;
	wire	[63:0]	csrd_mepc = mepc;
	wire	[63:0]	csrd_mcause = {
		mcause[4],
		59'd0,		// reserved
		mcause[3:0]
	};
	wire	[63:0]	csrd_mbadaddr = mbadaddr;
	wire	[63:0]	csrd_mip = {
		52'd0,
		irq_i,
		11'd0
	};
	wire	[63:0]	csrd_mcycle = mcycle;
	wire	[63:0]	csrd_mtime = mtime;
	wire	[63:0]	csrd_minstret = minstret;

	assign take_irq_o = mie & irqEn & irq_i;
	assign cdat_o =
		(csrv_misa ? csrd_misa : 0) |
		(csrv_mvendorid ? csrd_mvendorid : 0) |
		(csrv_marchid ? csrd_marchid : 0) |
		(csrv_mimpid ? csrd_mimpid : 0) |
		(csrv_mhartid ? csrd_mhartid : 0) |
		(csrv_mstatus ? csrd_mstatus : 0) |
		(csrv_medeleg ? csrd_medeleg : 0) |
		(csrv_mideleg ? csrd_mideleg : 0) |
		(csrv_mie ? csrd_mie : 0) |
		(csrv_mtvec ? csrd_mtvec : 0) |
		(csrv_mscratch ? csrd_mscratch : 0) |
		(csrv_mepc ? csrd_mepc : 0) |
		(csrv_mcause ? csrd_mcause : 0) |
		(csrv_mbadaddr ? csrd_mbadaddr : 0) |
		(csrv_mip ? csrd_mip : 0) |
		(csrv_mcycle ? csrd_mcycle : 0) |
		(csrv_mtime ? csrd_mtime : 0) |
		(csrv_minstret ? csrd_minstret : 0);

	wire irqEn_cdat = csrv_mie & cwe_i;
	wire irqEn_irqEn = ~|{irqEn_cdat, reset_i};
	wire irqEn_mux =
			(irqEn_cdat ? cdat_i[11] : 0) |
			(irqEn_irqEn ? irqEn : 0);

	wire mstatus_we = csrv_mstatus & cwe_i;
	wire mie_mie = ~|{mie_0, mie_mpie, mstatus_we};
	assign mie_mux =
			(mie_0 ? 0 : 0) |
			(mie_mpie ? mpie : 0) |
			(mstatus_we ? cdat_i[3] : 0) |
			(mie_mie ? mie : 0);

	wire mpie_mpie = ~|{mpie_mie, mpie_1, mstatus_we};
	assign mpie_mux =
			(mpie_mie ? mie : 0) |
			(mpie_1 ? 1 : 0) |
			(mstatus_we ? cdat_i[7] : 0) |
			(mpie_mpie ? mpie : 0);
	assign mie_o = mie;
	assign mpie_o = mpie;

	wire mtvec_we = csrv_mtvec & cwe_i;
	wire mtvec_mtvec = ~|{mtvec_we, reset_i};
	assign mtvec_mux =
			(mtvec_we ? cdat_i : 0) |
			(reset_i ? 64'hFFFF_FFFF_FFFF_FE00 : 0) |
			(mtvec_mtvec ? mtvec : 0);

	wire mscratch_we = csrv_mscratch & cwe_i;
	assign mscratch_mux = (mscratch_we ? cdat_i : mscratch);

	wire mepc_we = csrv_mepc & cwe_i;
	wire mepc_mepc = ~|{mepc_we, mepc_ia, mepc_pc};
	assign mepc_mux =
			(mepc_we ? cdat_i : 0) |
			(mepc_ia ? ia_i : 0) |
			(mepc_pc ? pc_i : 0) |
			(mepc_mepc ? mepc : 0);

	wire mcause_we = csrv_mcause & cwe_i;
	wire mcause_mcause = ~|{mcause_2, mcause_3, mcause_11, mcause_we};
	assign cause_o = mcause_mux[3:0];
	assign mcause_mux =
			(mcause_we ? {cdat_i[63], cdat_i[3:0]} : 0) |
			(mcause_2 ? {mcause_irq_i, 4'd2} : 0) |
			(mcause_3 ? {mcause_irq_i, 4'd3} : 0) |
			(mcause_11 ? {mcause_irq_i, 4'd11} : 0) |
			(mcause_mcause ? mcause : 0);

	wire mbadaddr_we = csrv_mbadaddr & cwe_i;
	assign mbadaddr_mux = (mbadaddr_we ? cdat_i : mbadaddr);

	assign mcycle_mux = (~reset_i ? mcycle + 1 : 0);
//	assign minstret_mux =
//			(~reset_i & ft0_i ? minstret + 64'd1 : 0) |
//			(~reset_i & ~ft0_i ? minstret : 0);
	assign mtime_mux =
			(~reset_i & tick_i ? mtime + 64'd1 : 0) |
			(~reset_i & ~tick_i ? mtime : 0);

	always @(posedge clk_i) begin
		minstret <= minstret;

		if (reset_i) begin
			minstret <= 64'd0;
		end

		else begin
			if (ft0_i) begin
				minstret <= minstret + 1;
			end
		end
	end

	always @(posedge clk_i) begin
		mie <= mie_mux;
		mpie <= mpie_mux;
		mtvec <= mtvec_mux;
		mscratch <= mscratch_mux;
		mepc <= mepc_mux;
		mcause <= mcause_mux;
		mbadaddr <= mbadaddr_mux;
		mcycle <= mcycle_mux;
//		minstret <= minstret_mux;
		mtime <= mtime_mux;

		irqEn <= irqEn_mux;
	end
endmodule

