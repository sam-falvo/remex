`timescale 1ns / 1ps

`include "asserts.vh"


module queue_8x9_tb();
	reg	[11:0]	story_tb;

	reg		clk, reset;
	reg		nchar, lchar;
	reg	[7:0]	char_i;
	reg		stb_i;

	wire		ack_o;
	wire	[8:0]	dat_o;
	wire		full_o, empty_o;

	wire	[7:0]	occupied_tb;
	wire	[2:0]	rp_tb;
	wire	[2:0]	wp_tb;
	wire		we_tb;

	queue_8x9 queue(
		.clk(clk),
		.reset(reset),
		.nchar(nchar),
		.lchar(lchar),
		.char_i(char_i),
		.stb_i(stb_i),
		.ack_o(ack_o),
		.dat_o(dat_o),
		.full_o(full_o),
		.empty_o(empty_o),

		.occupied_tb(occupied_tb),
		.rp_tb(rp_tb),
		.wp_tb(wp_tb),
		.we_tb(we_tb)
	);

	task story;
	input [11:0] expected;
	begin
		story_tb = expected;
	end
	endtask

	task clkL;
	begin
		clk <= 0; #10;
	end
	endtask

	task clkH;
	begin
		clk <= 1; #10;
	end
	endtask

	`DEFASSERT(occupied,7,tb)
	`DEFASSERT(rp,2,tb)
	`DEFASSERT(wp,2,tb)
	`DEFASSERT0(we,tb)
	`DEFASSERT0(empty,o)
	`DEFASSERT0(full,o)
	`DEFASSERT0(ack,o)
	`DEFASSERT(dat,8,o)

	initial begin
		$dumpfile("wtf.vcd");
		$dumpvars;

		{clk, reset, nchar, lchar, char_i, stb_i} <= 0;
		story(0);

		clkL(); clkH();

		// We must accept all nchars and EOP/EEP lchars
		// as valid characters.  FCT and ESC must be ignored.

		reset <= 1;
		clkL(); clkH();
		assert_occupied(8'b00000000);
		assert_rp(0);
		assert_wp(0);
		assert_we(0);

		story(1);

		nchar <= 1;
		clkL(); clkH();
		assert_we(1);

		story(2);

		nchar <= 0;
		lchar <= 1;
		char_i <= 8'hFF;
		clkL(); clkH();
		assert_we(0);

		story(3);

		char_i <= 8'h00;
		clkL(); clkH();
		assert_we(0);

		char_i <= 8'bxxxxxx10;
		clkL(); clkH();
		assert_we(1);

		char_i <= 8'bxxxxxx01;
		clkL(); clkH();
		assert_we(1);

		char_i <= 0;

		// When writing, the write-pointer wp must increment.
		// Additionally, the corresponding bit in occupied vector
		// should be asserted, indicating valid data.

		story(12'h010);

		reset <= 1;
		clkL(); clkH();
		{clk, reset, nchar, lchar, char_i, stb_i} <= 0;
		clkL();	clkH();

		assert_wp(0);
		assert_empty(1);
		assert_full(0);
		assert_occupied(8'b00000000);

		nchar <= 1;
		story(12'h011);
		clkL(); clkH();

		assert_wp(1);
		assert_empty(0);
		assert_full(0);
		assert_occupied(8'b00000001);

		story(12'h012);
		clkL(); clkH();

		assert_wp(2);
		assert_empty(0);
		assert_full(0);
		assert_occupied(8'b00000011);

		story(12'h013);
		clkL(); clkH();

		assert_wp(3);
		assert_empty(0);
		assert_full(0);
		assert_occupied(8'b00000111);

		story(12'h014);
		clkL(); clkH();

		assert_wp(4);
		assert_empty(0);
		assert_full(0);
		assert_occupied(8'b00001111);

		story(12'h015);
		clkL(); clkH();

		assert_wp(5);
		assert_empty(0);
		assert_full(0);
		assert_occupied(8'b00011111);

		story(12'h016);
		clkL(); clkH();

		assert_wp(6);
		assert_empty(0);
		assert_full(0);
		assert_occupied(8'b00111111);

		story(12'h017);
		clkL(); clkH();

		assert_wp(7);
		assert_empty(0);
		assert_full(0);
		assert_occupied(8'b01111111);

		story(12'h018);
		clkL(); clkH();

		assert_wp(0);
		assert_empty(0);
		assert_full(1);
		assert_occupied(8'b11111111);

		// If full, attempting to push a new datum into the queue
		// must take no effect at all.  It MAY assert an overrun
		// status flag, though.

		story(12'h020);
		clkL(); clkH();

		assert_wp(0);
		assert_empty(0);
		assert_full(1);
		assert_occupied(8'b11111111);

		// Popping the queue should advance the read pointer.
		// NOTE: Asserting stb_i will cause ack_o to assert the following
		// cycle (Wishbone B4 pipeline spec).  While acknowledging, data
		// is valid.  This means that the read pointer doesn't advance until
		// the cycle _after_.

		story(12'h030);
		{clk, reset, nchar, lchar, char_i, stb_i} <= 0;
		clkL();	clkH();

		stb_i <= 1;
		clkL();
		assert_ack(0);
		assert_rp(0);
		story(12'h031);
		clkH();				// Read slot 0
		assert_ack(1);
		assert_rp(0);
		assert_occupied(8'b11111111);
		assert_empty(0);
		assert_full(1);

		story(12'h032);
		clkL(); clkH();			// Read slot 1
		assert_ack(1);
		assert_rp(1);
		assert_occupied(8'b11111110);
		assert_empty(0);
		assert_full(0);

		story(12'h033);
		clkL(); clkH();			// Read slot 2
		assert_ack(1);
		assert_rp(2);
		assert_occupied(8'b11111100);
		assert_empty(0);
		assert_full(0);

		story(12'h034);
		stb_i <= 0;
		clkL(); clkH();			// wait state
		assert_ack(0);
		assert_rp(3);
		assert_occupied(8'b11111000);
		assert_empty(0);
		assert_full(0);

		story(12'h035);
		clkL(); clkH();			// wait state
		assert_ack(0);
		assert_rp(3);
		assert_occupied(8'b11111000);
		assert_empty(0);
		assert_full(0);

		stb_i <= 1;
		story(12'h036);
		clkL(); clkH();			// Read slot 3
		assert_ack(1);
		assert_rp(3);
		assert_occupied(8'b11111000);
		assert_empty(0);
		assert_full(0);

		story(12'h037);
		clkL(); clkH();			// Read slot 4
		assert_ack(1);
		assert_rp(4);
		assert_occupied(8'b11110000);
		assert_empty(0);
		assert_full(0);

		story(12'h038);
		clkL(); clkH();			// Read slot 5
		assert_ack(1);
		assert_rp(5);
		assert_occupied(8'b11100000);
		assert_empty(0);
		assert_full(0);

		story(12'h039);
		clkL(); clkH();			// Read slot 6
		assert_ack(1);
		assert_rp(6);
		assert_occupied(8'b11000000);
		assert_empty(0);
		assert_full(0);

		story(12'h03A);
		clkL(); clkH();			// Read slot 7
		assert_ack(1);
		assert_rp(7);
		assert_occupied(8'b10000000);
		assert_empty(0);
		assert_full(0);

		story(12'h03B);
		clkL(); clkH();			// Formally undefined; we're empty now.
		assert_ack(1);
		assert_rp(0);
		assert_occupied(8'b00000000);
		assert_empty(1);
		assert_full(0);

		story(12'h03C);
		clkL(); clkH();			// Formally undefined; we're empty now.
		assert_ack(1);
		assert_rp(0);
		assert_occupied(8'b00000000);
		assert_empty(1);
		assert_full(0);

		// The FIFO must support concurrent reads and writes.

		story(12'h040);
		reset <= 1;
		clkL(); clkH();
		{clk, reset, nchar, lchar, char_i, stb_i} <= 0;
		clkL(); clkH();

		// Step 1.  Fill the queue with nchars.
		lchar <= 1;
		char_i <= 8'h55;
		assert_full(0);
		clkL(); clkH();
		clkL(); clkH();
		clkL(); clkH();
		clkL(); clkH();
		clkL(); clkH();
		clkL(); clkH();
		clkL(); clkH();
		clkL(); clkH();
		assert_full(1);

		// Step 2.  Replace data in queue.

		story(12'h041);
		char_i <= 8'hAA;
		lchar <= 0;
		nchar <= 1;
		stb_i <= 1;
		clkL(); clkH();
		assert_we(1);
		assert_ack(1);
		assert_dat(9'h155);
		assert_rp(0);
		assert_wp(0);
		assert_occupied(8'b11111111);

		story(12'h042);
		clkL(); clkH();
		assert_ack(1);
		assert_dat(9'h155);
		assert_rp(1);
		assert_wp(1);
		assert_occupied(8'b11111111);

		story(12'h043);
		clkL(); clkH();
		assert_ack(1);
		assert_dat(9'h155);
		assert_rp(2);
		assert_wp(2);
		assert_occupied(8'b11111111);

		story(12'h044);
		clkL(); clkH();
		assert_ack(1);
		assert_dat(9'h155);
		assert_rp(3);
		assert_wp(3);
		assert_occupied(8'b11111111);

		story(12'h045);
		clkL(); clkH();
		assert_ack(1);
		assert_dat(9'h155);
		assert_rp(4);
		assert_wp(4);
		assert_occupied(8'b11111111);

		story(12'h046);
		clkL(); clkH();
		assert_ack(1);
		assert_dat(9'h155);
		assert_rp(5);
		assert_wp(5);
		assert_occupied(8'b11111111);

		story(12'h047);
		clkL(); clkH();
		assert_ack(1);
		assert_dat(9'h155);
		assert_rp(6);
		assert_wp(6);
		assert_occupied(8'b11111111);

		story(12'h048);
		clkL(); clkH();
		assert_ack(1);
		assert_dat(9'h155);
		assert_rp(7);
		assert_wp(7);
		assert_occupied(8'b11111111);

		// (after writing the 8th item to the queue,
		// we should wrap around, and see the first
		// of the overwrites.)

		story(12'h049);
		clkL(); clkH();
		assert_ack(1);
		assert_dat(9'h0AA);
		assert_rp(0);
		assert_wp(0);
		assert_occupied(8'b11111111);

		// (Remember, ack_o is asserted when data is valid
		// on dat_o; the read pointer isn't incremented
		// until *after* this cycle.  Since the previous cycle
		// had an asserted ack, THIS cycle should just pop
		// the queue, since we're not going to write anything.)

		story(12'h04A);
		{clk, reset, nchar, lchar, char_i, stb_i} <= 0;
		clkL(); clkH();
		assert_ack(0);
		assert_dat(9'h0AA);
		assert_rp(1);
		assert_wp(0);
		assert_occupied(8'b11111110);

		$display("@I Done.");
		$stop;
	end
endmodule

