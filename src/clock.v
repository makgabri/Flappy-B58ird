module clock(input clock, output clk);

	reg [22:0] frame_counter;
	reg frame;

	always@(posedge clock)
	begin
		if (frame_counter == 23'b0) begin
			frame_counter = 23'b01111111000000000000000;
			frame = 1'b1;
		end
  	else begin
			frame_counter = frame_counter - 1'b1;
			frame = 1'b0;
		end
	end

	assign clk = frame;

endmodule
