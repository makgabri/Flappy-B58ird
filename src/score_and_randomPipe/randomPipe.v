module project(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
		LEDR,
		SW,
        HEX0,
        HEX1,
        PS2_KBCLK, PS2_KBDAT,
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
	input 	[17:0] SW;
	input	CLOCK_50;			//	50 MHz
	input 	[3:0] KEY;
    input   PS2_KBCLK, PS2_KBDAT;
	output 	[17:0] LEDR;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output				VGA_CLK;   				//	VGA Clock
	output				VGA_HS;						//	VGA H_SYNC
	output				VGA_VS;						//	VGA V_SYNC
	output				VGA_BLANK_N;			//	VGA BLANK
	output				VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   					//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 					//	VGA Green[9:0]
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

	wire [29:0] data_in;
	wire [29:0] test_bit_out;
	wire [1199:0] obstacle_data;
    wire KEY_PRESSED;
    output [6:0] HEX_0;
    output [6:0] HEX_1;
    hex_display h0(
              .IN(score[3:0]),
              .OUT(HEX_ZERO)
              );
    hex_display h1(
              .IN(score[7:4]),
              .OUT(HEX_ONE)
              );

        hex_display h0(
        .hex_digit(binary_time[3:0]),
        .segments(hex_0)
        );

	data_in_manager dim(
		.clk(frame),
		.dim(data_in),
        .birdy_in(birdy),
		.resetn(SW[16]),
		.led(LEDR[17])
	);

	shift_register_40_bit all_regs[29:0] (
		.clk(frame),
		.resetn(SW[16]),
		.data_in(data_in),
		.bit_out(test_bit_out),
		.forty_bit_out(obstacle_data)
	);

    keyboard keyboard1(
        .CLOCK_50(CLOCK_50),
        .PS2_KBCLK(PS2_KBCLK),
        .PS2_KBDAT(PS2_KBDAT),
        .KEY_PRESSED(KEY_PRESSED)
    );

	reg [5:0] state;
	reg [7:0] x, y, feed_increment, score;
	reg [1199:0] b;
	reg [7:0] border_x, border_y;
	reg [2:0] colour;
	reg [17:0] drawing, drawing_x, x_off;
	reg [3:0] pixel_counter;
	reg [5:0] bit_counter;
	reg [4:0] reg_counter;
	reg [7:0] birdx, birdy;
	reg [2:0] bird_status;
    reg drawn;
	wire jump;
	wire frame;

	assign jump = KEY_PRESSED;

	assign LEDR[0] = obstacle_data[0];
	assign LEDR[1] = obstacle_data[40];
	assign LEDR[2] = obstacle_data[80];
	assign LEDR[3] = obstacle_data[120];
	assign LEDR[4] = obstacle_data[160];
	assign LEDR[5] = obstacle_data[200];
	assign LEDR[6] = obstacle_data[240];
	assign LEDR[7] = obstacle_data[280];

	localparam  CLEAR_SCREEN = 6'b000000,
              INIT_FLOOR   = 6'b000001,
							INIT_CIELING = 6'b000010,
							START_SCREEN = 6'b001000,
							DRAW_SEED 	 = 6'b000011,
					 		DRAW_BIRD   = 6'b011001;

	clock(.clock(CLOCK_50), .clk(frame));

	always@(posedge CLOCK_50)
	begin
		colour = 3'b000;
		feed_increment = 8'b00000000;
		birdx = 8'b00010100;
		birdy = 8'b00110000;
        drawn = 1'b0;
		x = 8'b00000000;
		y = 8'b00000000;
        score = 8'b00000000;
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
						border_x = 8'd156;
					   border_y = 8'd0;
						state = DRAW_SEED;
						// state = START_SCREEN;
					end
				end

				START_SCREEN: begin
					colour = 3'b110;
					x = birdx;
					y = birdy;
                    if (jump == 1'b1) begin
                        state = DRAW_SEED;
                    end
                    drawn = 1'b1;
				end

				DRAW_SEED: begin
					x = border_x + pixel_counter[3:2] - (3'b100 * bit_counter);
					y = border_y + pixel_counter[1:0] + (3'b100 * reg_counter);
                    if (y == birdy) begin
                        state = CLEAR_SCREEN;
                    end

					b = bit_counter + (reg_counter * 6'b101000);

					if (obstacle_data[b] == 1'b1) colour = 3'b011;
					else colour = 3'b000;

					if (pixel_counter == 4'b1111) begin
						pixel_counter = 4'b0;
						bit_counter = bit_counter + 1'b1;
					end
					else pixel_counter = pixel_counter + 1'b1;

					if (bit_counter == 6'b101000) begin
                        score = score + 1'b1;
						bit_counter = 6'b0;
						reg_counter = reg_counter + 1'b1;
					end

					if (reg_counter == 5'b11110) begin
						reg_counter = 5'b0;
					// After every pipe is finished drawing, draw bird's next state
					// Add this where appropriate
					// state = DRAW_BIRD
					end
				end

				DRAW_BIRD: begin
                    if (drawn == 1'b1) begin
					    colour = 3'b000; // erase bird
					    x = birdx;
					    y = birdy;
                        if (jump == 1'b0) begin
						    if (y == 8'b01101101) begin
								birdy = 8'b01101101;
							end
						    else birdy = y + 8'b00000001;
					    end
					    else if (jump == 1'b1) begin
						    if (nexty == 8'b00001011) begin
								birdy = 8'b00001011;
						    end
						    else birdy = y - 8'b00000001;;
					    end
                        drawn = 1'b0;
                    end
                    else if (drawn == 1'b0) begin
					    colour = 3'b110;
					    x = birdx;
					    y = birdy;
                        drawn = 1'b1;
					    state = DRAW_SEED;
                    end
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
      bit_out = forty_bit_out[39];
      forty_bit_out <= {forty_bit_out[38:0], data_in};
    end
    else begin
      bit_out = 1'b0;
      forty_bit_out <= 40'b0;
    end
  end

endmodule

module data_in_manager(
	input clk,
	output reg [29:0] dim,
	input resetn,
    input [7:0] birdy_in,
	output led
);

reg [2:0] count;
reg [1:0] jump;
reg [1:0] pattern;

assign led = (count == 1'b0);

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

            if (birdy > 7'b1100100) // 100
                dim = 30'b111111111111111000000000000011;
			else if (birdy > 7'b1010000) // 80
				dim = 30'b111111111111100000000001111111;
			else if (birdy > 6'b111100) //60 
				dim = 30'b111111111111111111000000000011;
			else if (birdy > 6'b101000) //40
				dim = 30'b111000000000000001111111111111;
			else
				dim = 30'b110000000111111111111111111111;

		end
		else count = count - 1'b1;

	end
	else jump = jump - 1'b1;

	end

end

endmodule

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


module hex_display(IN, OUT);
  input [3:0] IN;
  output reg [7:0] OUT;

  always @(*)
  begin
    case(IN[3:0])
      4'b0000: OUT = 7'b1000000;
      4'b0001: OUT = 7'b1111001;
      4'b0010: OUT = 7'b0100100;
      4'b0011: OUT = 7'b0110000;
      4'b0100: OUT = 7'b0011001;
      4'b0101: OUT = 7'b0010010;
      4'b0110: OUT = 7'b0000010;
      4'b0111: OUT = 7'b1111000;
      4'b1000: OUT = 7'b0000000;
      4'b1001: OUT = 7'b0011000;
      4'b1010: OUT = 7'b0001000;
      4'b1011: OUT = 7'b0000011;
      4'b1100: OUT = 7'b1000110;
      4'b1101: OUT = 7'b0100001;
      4'b1110: OUT = 7'b0000110;
      4'b1111: OUT = 7'b0001110;

      default: OUT = 7'b0111111;
    endcase
  end
endmodule