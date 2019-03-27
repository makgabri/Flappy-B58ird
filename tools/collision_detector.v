module collision_detector(clock, bird_y, pipe, signal);

    input clock;
    input bird_y;
    input pipe;
    output signal;
    
	always@(posedge clock)
	begin
		if (pipe[bird_y] == 1'b1) begin
			signal <= 1'b1;
		end
  	else begin
			signal <= 1'b0;
		end
	end

endmodule