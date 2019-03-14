// Part 2 skeleton

module part2(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
		  LEDR,
			SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);
	input [17:0] SW;
	input			CLOCK_50;				//	50 MHz
	input   [3:0]   KEY;
	output [17:0] LEDR;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
output	[9:0] VGA_B; 

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(1'b1),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(1'b1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
defparam VGA.BACKGROUND_IMAGE = "black.mif";
	 
	 wire [39:0] obstacle_data;
	 wire test_bit_out;
	 shift_register_40_bit s1 (
  .clk(frame),
  .resetn(SW[16]),
  .data_in(SW[0]),
  .bit_out(test_bit_out),
  .forty_bit_out(obstacle_data)
  );


	 
	 reg [5:0] state;
	 reg [7:0] x, y, feed_increment;
	 reg [7:0] border_x, border_y;
	 reg [2:0] colour;
	 reg [17:0] drawing, drawing_x;
	 reg [3:0] pixel_counter;
	 reg [5:0] bit_counter;
	 wire frame;
	 
	 assign LEDR[7:0] = obstacle_data[7:0];
	 
	 localparam  CLEAR_SCREEN       = 6'b000000,
                INIT_FLOOR       = 6'b000001,
						INIT_CIELING       = 6'b000010,
						DRAW_SEED = 6'b000011,
					 DRAW_PIXEL    		    = 6'b011001;

	clock(.clock(CLOCK_50), .clk(frame));
	 always@(posedge CLOCK_50)
    begin

			colour = 3'b000;
			feed_increment = 8'b00000000;
			x = 8'b00000000;
			y = 8'b00000000;
			if (~KEY[0]) state = CLEAR_SCREEN;
        case (state)
		  CLEAR_SCREEN: begin
			if (drawing < 17'b10000000000000000) begin
						x = drawing[7:0];
						y = drawing[16:8];
						drawing = drawing + 1'b1;
						end
					else begin
						drawing= 8'b00000000;
						state = INIT_FLOOR;
					end
		  end
    			 INIT_FLOOR: begin
					 if (drawing < 8'b10100000) begin
					 border_x = 8'd0;
					 border_y = 8'd110;
						x = border_x + drawing;
						y = border_y + 1'b0;
						drawing = drawing + 1'b1;
						colour = 3'b010;
						end
					else begin
						drawing= 8'b00000000;
						state = INIT_CIELING;
					end
				 end
				 INIT_CIELING: begin
					 if (drawing < 8'b10100000) begin
					 border_x = 8'd0;
					 border_y = 8'd10;
						x = border_x + drawing;
						y = border_y + 1'b0;
						drawing = drawing + 1'b1;
						colour = 3'b010;
						end
					else begin
						drawing= 8'b00000000;
						drawing_x = 8'b00000000;
						bit_counter = 6'b000000;
						border_x = 8'd156;
					   border_y = 8'd40;
						state = DRAW_SEED;
						
						
					
					end
				 end

						
				 
				 
				 DRAW_SEED: begin
						x = border_x + pixel_counter[3:2] - (3'b100 * bit_counter);
						y = border_y + pixel_counter[1:0];
						
						if (obstacle_data[bit_counter] == 1'b1) colour = 3'b011;
						else colour = 3'b000;
						
						if (pixel_counter == 4'b1111) begin
							pixel_counter = 4'b0000;
							bit_counter = bit_counter + 6'b000001;
						end
						else pixel_counter = pixel_counter + 1'b1;
						
						if (bit_counter == 6'b101000) bit_counter = 6'b000000;
				end
				
				


         endcase
end
endmodule

module shift_register_40_bit (
  input clk,
  input resetn,
  input data_in,
  output reg bit_out,
  output reg [39:0] forty_bit_out
  );

  // Reset Shift Register on low resetn signal, otherwise every positive clock
  // edge takes the input value and puts it at the least significant bit of the
  // 40-bit shift register, with the pushed out bit also being returned.

  always @(posedge clk)
  begin
    if (!resetn) begin
      bit_out = forty_bit_out[0];
      forty_bit_out <= {forty_bit_out[38:0], data_in};
    end
    else begin
      bit_out = 1'b0;
      forty_bit_out <= 40'b0;
    end
  end
endmodule



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