module Birdy(clock, resetn, go, colour, out_x, out_y);

	input clock;
    input resetn;
    input go;
    output [2:0] colour;
	output [7:0] out_x;
	output [7:0] out_y;

    // Resetn should be 1 to go to next state
	control c1(
	.clk(clock),
    .resetn(resetn),
    .go(go),
    .colour(colour),
	.out_x(out_x),
    .out_y(out_y)
	);

endmodule

module control(clk, resetn, go, colour, out_x, out_y);
	input clk;
	input resetn;
	input go;

    output reg [2:0] colour;
	output reg [7:0] out_x;
	output reg [7:0] out_y;

	reg [7:0] cur_x = 8'd24;
	reg [7:0] cur_y = 8'd48;
	reg [7:0] next_y;
	reg [2:0] current_state, next_state;
    reg speed = 8'd1;
	reg erased = 1'b0;
	reg [4:0] pixel_counter = 5'b00000;
	localparam  	S_START       = 3'd0,
					S_FALL 		  = 3'd1,
                	S_FLAP        = 3'd2,
                	S_FLAP_WAIT   = 3'd3;

  // Next state logic aka our state table
  always@(*)
  begin: state_table
		case (current_state)
		    S_START: next_state = go ? S_FALL : S_START;
			S_FALL: next_state = go ? S_FLAP : S_FALL; // Natural State is bird falling
			S_FLAP: next_state = go ? S_FLAP_WAIT : S_FALL; // On GO make bird fly 2 pixels
			S_FLAP_WAIT: next_state = go ? S_FLAP_WAIT : S_FALL; // Makes sure player doesn't hold button to fly up non-stop
			default: next_state = S_FALL;
    endcase
  end // state_table

  // Output logic aka all of our datapath control signals
  always @(*)
  begin: enable_signals
		case (current_state)
		    S_START: begin // Start with Bird Still
				colour = 3'b110;
				if (pixel_counter < 5'b10000) begin
					out_x = cur_x + pixel_counter[3:2];
					out_y = cur_y + pixel_counter[1:0];
					pixel_counter = pixel_counter + 1'b1;
				end
			end
			S_FALL: begin // Begin fall
				if (erased == 1'b0) begin // Erase current bird
					if (pixel_counter > 5'b00000) begin
						colour = 3'b000;
						out_x = cur_x - pixel_counter[3:2];
						out_y = cur_y - pixel_counter[1:0];
						pixel_counter = pixel_counter - 1'b1;
					end
					else if (pixel_counter == 5'b00000) begin
						out_x = cur_x;
						out_y = cur_y;
						erased = 1'b1;
						next_y = cur_y + speed;
						if (next_y > 8'd111) begin
							cur_y = next_y;
						end
						else begin
							cur_y = 8'd111;
						end
						speed = speed + speed;
					end
				end
				else begin // Draw next bird
					colour = 3'b110;
					if (pixel_counter < 5'b10000) begin
						out_x = cur_x + pixel_counter[3:2];
						out_y = cur_y + pixel_counter[1:0];
						pixel_counter = pixel_counter + 1'b1;
					end
					else begin
						erased = 1'b0;
					end
				end
			end
      		S_FLAP: begin // Begin flap
			  	speed = 8'd1;
				if (erased == 1'b0) begin // Erase current bird
					if (pixel_counter > 5'b00000) begin
						colour = 3'b000;
						out_x = cur_x - pixel_counter[3:2];
						out_y = cur_y - pixel_counter[1:0];
						pixel_counter = pixel_counter - 1'b1;
					end
					else if (pixel_counter == 5'b00000) begin
						out_x = cur_x;
						out_y = cur_y;
						erased = 1'b1;
						next_y = cur_y - 8'd6;
						if (next_y < 8'd12) begin
							cur_y = next_y;
						end
						else begin
							cur_y = 8'd12;
						end
					end
				end
				else begin // Draw next bird
					colour = 3'b110;
					if (pixel_counter < 5'b10000) begin
						out_x = cur_x + pixel_counter[3:2];
						out_y = cur_y + pixel_counter[1:0];
						pixel_counter = pixel_counter + 1'b1;
					end
					else begin
						erased = 1'b0;
					end
				end
			end
			S_FLAP_WAIT: begin // Begin fall - similar to fall
				if (erased == 1'b0) begin // Erase current bird
					if (pixel_counter > 5'b00000) begin
						colour = 3'b000;
						out_x = cur_x - pixel_counter[3:2];
						out_y = cur_y - pixel_counter[1:0];
						pixel_counter = pixel_counter - 1'b1;
					end
					else if (pixel_counter == 5'b00000) begin
						out_x = cur_x;
						out_y = cur_y;
						erased = 1'b1;
						next_y = cur_y + speed;
						if (next_y > 8'd111) begin
							cur_y = next_y;
						end
						else begin
							cur_y = 8'd111;
						end
						speed = speed + speed;
					end
				end
				else begin // Draw next bird
					colour = 3'b110;
					if (pixel_counter < 5'b10000) begin
						out_x = cur_x + pixel_counter[3:2];
						out_y = cur_y + pixel_counter[1:0];
						pixel_counter = pixel_counter + 1'b1;
					end
					else begin
						erased = 1'b0;
					end
				end
			end
        endcase
  end // enable_signals

  // current_state registers
  always@(posedge clk)
  begin: state_FFs
		if(!resetn)
			current_state <= S_START;
    else
			current_state <= next_state;
  end // state_FFS

endmodule
