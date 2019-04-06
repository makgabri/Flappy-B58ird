module project(
		CLOCK_50,						//	On Board 50 MHz
		// Inputs and outputs here
    SW, KEY, HEX0, HEX1,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   					//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,				//	VGA BLANK
		VGA_SYNC_N,					//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	// Declare inputs and outputs here
	input		CLOCK_50;			//	50 MHz
	input 	[17:0] SW;
	input 	[3:0] KEY;
	output  [6:0] HEX0;
  output 	[6:0] HEX1;

	// Do not change the following outputs
	output				VGA_CLK;   				//	VGA Clock
	output				VGA_HS;						//	VGA H_SYNC
	output				VGA_VS;						//	VGA V_SYNC
	output				VGA_BLANK_N;			//	VGA BLANK
	output				VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   					//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 					//	VGA Green[9:0]
	output	[9:0] VGA_B;						//  VGA Blue[9:0]

	// Instance of a VGA controller
	// 1-bit RGB colours
	// black.mif for initial black background
	vga_adapter VGA(
		.resetn(1'b1),
		.clock(CLOCK_50),
		.colour(colour),
		.x(x),
		.y(y),
		.plot(1'b1),	// Plot always on
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

	// HEX Displays for time spent flying
  hex_display h0(
  	.IN(score[3:0]),
  	.OUT(HEX0));
  hex_display h1(
  	.IN(score[7:4]),
    .OUT(HEX1));

	// Pipe pattern manager
	data_in_manager dim(
		.clk(frame),
		.resetn(hardreset),
		.dim(data_in));

	// 30 Instances of 40-bit registers for pipes
	wire [29:0] data_in;
	wire [29:0] bits_out;
	wire [1199:0] obstacle_data;
	shift_register_40_bit all_regs[29:0] (
		.clk(frame),
		.resetn(hardreset),
		.data_in(data_in),
		.bit_out(bits_out),
		.forty_bit_out(obstacle_data));

	// Registers to assist with state, drawing, and bird movement/positioning
	reg [5:0] state;
	reg [7:0] x, y, feed_increment, birdx, birdy;
	reg [1199:0] b;
	reg [7:0] border_x, border_y, score;
	reg [2:0] colour;
	reg [17:0] drawing, drawing_x, x_off;
	reg [3:0] pixel_counter;
	reg [5:0] bit_counter;
	reg [4:0] reg_counter;
	reg [7:0] bird_counter;
	reg hardreset;
	wire jump, start;
	wire frame;

	assign jump = SW[1];
	assign start = ~KEY[3];

	localparam  CLEAR_SCREEN = 6'b000000,
              INIT_FLOOR   = 6'b000001,
							INIT_CIELING = 6'b000010,
							START_SCREEN = 6'b011000,
							DRAW_SEED 	 = 6'b000011,
					 		DRAW_BIRD    = 6'b011001;

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

			// Green bar across the bottom of the start screen
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

			// Green bar across the top of the start screen
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
					border_x = 8'd156;
					if (birdy > 7'b1101110) birdy = 8'b01101110;
					else birdy = birdy + 8'b00000001;
					border_y = 8'd0;
					state = START_SCREEN;
				end
			end

			// Reset Score and Bird coordinates
			START_SCREEN: begin
				colour = 3'b110;
				birdx = 8'b00010100;
				score = 8'b00000000;
				birdy = 8'b00110000;
				bird_counter = 8'b00000000;
				x = birdx;
				y = birdy;
        if (start == 1'b1) begin
					drawing= 8'b00000000;
					drawing_x = 8'b00000000;
					border_x = 8'd156;
					border_y = 8'd0;
          state = DRAW_SEED;
				end
			end

			// Draw pipes, detect if bird has collided with a pipe
			DRAW_SEED: begin
				hardreset = 1'b0;
				x = border_x + pixel_counter[3:2] - (3'b100 * bit_counter);
				y = border_y + pixel_counter[1:0] + (3'b100 * reg_counter);

				b = bit_counter + (reg_counter * 6'b101000);

				if (obstacle_data[b] == 1'b1) begin
					colour = 3'b011;
					if (x == birdx) begin
						if (y == birdy) begin
							hardreset = 1'b1;
							state = CLEAR_SCREEN;
						end
					end
				end
				else colour = 3'b000;

				if (pixel_counter == 4'b1111) begin
					pixel_counter = 4'b0;
					bit_counter = bit_counter + 1'b1;
				end
				else pixel_counter = pixel_counter + 1'b1;

				if (bit_counter == 6'b101000) begin
					bit_counter = 6'b0;
					reg_counter = reg_counter + 1'b1;
				end

				if (reg_counter == 5'b11110) begin
					reg_counter = 5'b0;
					state = DRAW_BIRD;
				end
			end

			// Bird movement and drawing, increment score
			DRAW_BIRD: begin
				if (bird_counter == 6'b111111) begin
					score = score + 1'b1;
          if (jump == 1'b0) begin
						if (birdy > 7'b1101110) birdy = 7'b1101110;
						else birdy = birdy + 7'b0000001;
					end
					else begin
						if (birdy < 3'b111) birdy = 3'b111;
						else birdy = birdy - 7'b0000001;
					end
					bird_counter = 6'b000000;
				end
				else bird_counter = bird_counter + 1'b1;

				colour = 3'b110;
				x = birdx;
				y = birdy;
				state = DRAW_SEED;
			end
    endcase
	end

endmodule
