module RateDivider (clk, enable, out);
	input clk;
	input enable;
	output [3:0] out;

	wire [27:0] rate_div_out;
	wire count_enable;

	twoeightbit_decrement_switch_load my_28(
		.clk(clk),
		.enable(enable),
		.q(rate_div_out)
	);

	assign count_enable = (rate_div_out == 0) ? 1 : 0;

	fivebit_increment my_4(
		.clk(clk),
		.enable(count_enable),
		.q(out)
	);
endmodule

module twoeightbit_decrement_switch_load (clk, enable, q);
	input clk;
	input enable;
	reg [27:0] load_val;
	output reg [27:0] q;

	always @(posedge clk)
	begin
		if (q == 0)
			q <= 28'b0101111101011110000100000000;
		else if (enable == 1'b1)
			q <= q - 1'b1;
	end
endmodule

module fivebit_increment (clk, enable, q);
	input clk;
	input enable;
	output reg [4:0] q;

	always @(posedge clk)
	begin
		if (q == 5'b11111)
			q <= 0;
		else if (enable == 1'b1)
			q <= q + 1'b1;
	end
endmodule