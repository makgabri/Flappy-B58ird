module RateDivider (clk, enable, clear, out);
	input clk;
	input enable;
	input [1:0] clear;
	output [3:0] out;

	wire [27:0] rate_div_out;
	wire count_enable;

	twoeightbit_decrement_switch_load my_28(
		.clk(clk),
		.enable(enable),
		.clear_b(clear[1]),
		.q(rate_div_out)
	);

	assign count_enable = (rate_div_out == 0) ? 1 : 0;

	fourbit_increment my_4(
		.clk(clk),
		.enable(count_enable),
		.clear_b(clear[0]),
		.q(out)
	);
endmodule

module twoeightbit_decrement_switch_load (clk, enable, clear_b, q);
	input clk;
	input enable;
	input clear_b;
	reg [27:0] load_val;
	output reg [27:0] q;


	load_val = 28'b0101111101011110000100000000;

	always @(posedge clk)
	begin
		if (clear_b == 1'b0)
			q <= 1'b1;
		else if (q == 0)
			q <= load_val;
		else if (enable == 1'b1)
			q <= q - 1'b1;
	endload_val
endmodule

module fivebit_increment (clk, enable, clear_b, q);
	input clk;
	input enable;
	input clear_b;
	output reg [4:0] q;

	always @(posedge clk)
	begin
		if (clear_b == 1'b0)
			q <= 0;
		else if (q == 5'b11111)
			q <= 0;
		else if (enable == 1'b1)
			q <= q + 1'b1;
	end
endmodule