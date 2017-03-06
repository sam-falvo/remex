`timescale 1ns / 1ps

module TOP_tb();
	reg fpga_clk, cpu_reset;

	always begin
		#5; fpga_clk <= ~fpga_clk;
	end

	initial begin
		$dumpfile("wtf.vcd");
		$dumpvars;
		fpga_clk <= 0;
		cpu_reset <= 1;
		#1000 cpu_reset <= 0;
	end

	reg [15:0] fixed_sram_dat_io = 16'h0BAD;
	wire [15:0] sram_dat_io = fixed_sram_dat_io;

	TOP t(
		.fpga_clk(fpga_clk),
		.cpu_reset(cpu_reset),

		.sram_adr_o(),
		.sram_dat_io(sram_dat_io),
		.sram_ce_on(),
		.sram_we_on(),
		.sram_oe_on(),
		.sram_lbe_on(),
		.sram_ube_on(),

		.led0(led0),
		.led1(led1),
		.led2(led2),
		.switch0(1'b0)
	);
endmodule

