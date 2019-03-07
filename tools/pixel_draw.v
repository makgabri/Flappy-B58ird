// Part 2 skeleton

module part_2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		LEDR
	);

	input			CLOCK_50;				//	50 MHz
	input   [17:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	output [17:0] LEDR;
	
	wire resetn;
	assign resetn = SW[17];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(SW[9:7]),
			.x(x),
			.y(y),
			.plot(writeEn),
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
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
	
    wire ld_x, ld_y;
   
	// Instansiate datapath
	 datapath d0(
		.clk(CLOCK_50),
		.resetn(resetn),
		.writeEn(writeEn),
		.coordinate(SW[6:0]), 
		.ld_x(ld_x),
		.ld_y(ld_y),
		.x_out(x),
		.y_out(y)
    );
	 
	 
	 wire go = ~SW[16];
	 
    // Instansiate FSM control
    control c0 (
		.clk(CLOCK_50),
		.resetn(resetn),
		.go(go),
		.ld_x(ld_x),
		.ld_y(ld_y),
		.writeEn(writeEn)
	 );
    
endmodule


module datapath(
    input clk,
    input resetn, writeEn,
    input [6:0] coordinate, 
    input ld_x, ld_y,
    output [7:0] x_out,
	 output [6:0] y_out
    );
    
    // input registers
	 reg [3:0] count_xy;
    reg [7:0] x; 
	 reg [6:0] y;
 
    // Registers a, b, c, x with respective input logic
    always@(posedge clk) begin
        if(!resetn) begin
            x <= 8'd0; 
            y <= 7'd0; 
        end
        else begin 
            if(ld_x)
                x <= {1'b0, coordinate}; // load x with padding
            if(ld_y)
                y <= coordinate; // load y
        end
    end
	
	// counter
	always @(posedge clk) begin
		if (!resetn)
			count_xy <= 4'd0;
		else if (writeEn)
			count_xy <= count_xy + 4'd1;
	end
	
	// set x,y colour out
	assign x_out = x + count_xy[1:0];
	assign y_out = y + count_xy[3:2];

    
endmodule

module control(
    input clk,
    input resetn,
    input go,

    output reg  ld_x, ld_y, writeEn
	 );

    reg [3:0] current_state, next_state; 
    
    localparam  S_LOAD_X        = 3'd0,
                S_LOAD_X_WAIT   = 3'd1,
                S_LOAD_Y_COLOUR = 3'd2,
                S_LOAD_Y_WAIT   = 3'd3,
                S_DRAW_BOX      = 3'd4,
					 S_DRAW_BOX_WAIT = 3'd5;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X; // Loop in current state until value is input
                S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : S_LOAD_Y_COLOUR; // Loop in current state until go signal goes low
                S_LOAD_Y_COLOUR: next_state = go ? S_LOAD_Y_WAIT : S_LOAD_Y_COLOUR; // Loop in current state until value is input
                S_LOAD_Y_WAIT: next_state = go ? S_LOAD_Y_WAIT : S_DRAW_BOX; // Loop in current state until go signal goes low
                S_DRAW_BOX: next_state = go 	? S_DRAW_BOX_WAIT : S_DRAW_BOX; // Restart FSM
					 S_DRAW_BOX_WAIT: next_state = go ? S_DRAW_BOX_WAIT : S_LOAD_X; // Loop in current state until go signal goes low
					 //default: next_state = S_LOAD_X;`
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_x = 1'b0;
        ld_y = 1'b0;
		  writeEn = 1'b0;
		  
        case (current_state)
            S_LOAD_X: begin
                ld_x = 1'b1;
                end
            S_LOAD_Y_COLOUR: begin
                ld_y = 1'b1;
                end
            S_DRAW_BOX: begin
                writeEn = 1'b1;
                end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD_X;
        else
            current_state <= next_state;
    end // state_FFS
endmodule