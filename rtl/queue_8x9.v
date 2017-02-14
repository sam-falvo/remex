`timescale 1ns / 1ps

module queue_8x9(
	input		clk,
	input		reset,
	input		nchar,
	input		lchar,
	input	[7:0]	char_i,
	input		stb_i,
	output		ack_o,
	output	[8:0]	dat_o,
	output		full_o,
	output		empty_o,

	output	[7:0]	occupied_tb,	// TEST BENCH ONLY
	output	[2:0]	rp_tb,
	output	[2:0]	wp_tb,
	output		we_tb
);
	reg [8:0] queue[0:7];
	reg [7:0] occupied;	// Which slots hold valid data?
	reg [2:0] rp, wp;	// Counters indicating next slot to read, write.
	reg oe_r;

	assign ack_o = oe_r;
	assign dat_o = queue[rp];
	assign full_o = occupied[wp];
	assign empty_o = ~occupied[rp];

	wire is_eop = (char_i[1:0] == 2'b01) | (char_i[1:0] == 2'b10);
	wire we = (nchar | (lchar & is_eop));
	wire ptrs_eq = (wp == rp);

	always @(posedge clk) begin
		oe_r <= oe_r;

		if(reset) begin
			oe_r <= 0;
		end
		else if(stb_i) begin
			oe_r <= 1;
		end
		else if(oe_r) begin
			oe_r <= 0;
		end
	end

	wire should_set_occupied_flag = (~ack_o & we & ~occupied[wp]);
	wire read_write_concurrently = (ack_o & we & ptrs_eq);
	wire should_store = should_set_occupied_flag | read_write_concurrently;
	wire should_pop_queue = ack_o & occupied[rp];

	always @(posedge clk) begin
		occupied <= occupied;
		rp <= rp;
		wp <= wp;

		if(reset) begin
			occupied <= 8'h00;
			rp <= 3'd0;
			wp <= 3'd0;
		end
		else begin
			if(should_store) begin
				queue[wp] <= {lchar, char_i};
				wp <= wp + 1;
			end
			if(should_set_occupied_flag) begin
				occupied[wp] <= 1;
			end
			if(should_pop_queue) begin
				if(~read_write_concurrently) begin
					occupied[rp] <= 0;
				end
				rp <= rp + 1;
			end
		end
	end

	assign occupied_tb = occupied;
	assign rp_tb = rp;
	assign wp_tb = wp;
	assign we_tb = we;
endmodule

