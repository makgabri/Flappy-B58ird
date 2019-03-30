module clock(input clock, output clk);

	reg [19:0] frame_counter;
	reg frame;

	always@(posedge clock)
	begin
		if (frame_counter == 20'b00000000000000000000) begin
			frame_counter = 20'b1011111010111100001000000;
			frame = 1'b1;
		end
  	else begin
			frame_counter = frame_counter - 1'b1;
			frame = 1'b0;
		end
	end

	assign clk = frame;

endmodule