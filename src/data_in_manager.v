module data_in_manager(
		input clk,
		input resetn,
		output reg [29:0] dim
	);

	reg [2:0] count;
	reg [1:0] jump;
	reg [1:0] pattern;

	always @(posedge clk)
  begin

		if (resetn) begin
			count = 3'b0;
			jump = 2'b0;
			pattern = 2'b00;
		end

		else begin
			if (jump == 1'b0) begin
				dim = 30'b0;

				if (count == 1'b0) begin
					count = 3'b111;
					jump = 2'b01;

					if (pattern == 2'b00)
						dim = 30'b111110000000000111111111111111;
					else if (pattern == 2'b01)
						dim = 30'b111111111111111000000000011111;
					else if (pattern == 2'b10)
						dim = 30'b111111111100000000001111111111;
					else if (pattern == 2'b11)
						dim = 30'b111111111111000000111111111111;

					if (pattern == 2'b11) pattern = 2'b00;
					else pattern = pattern + 1'b1;

				end
				else count = count - 1'b1;

			end
			else jump = jump - 1'b1;
		end

  end
endmodule
