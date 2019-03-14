module birdy
	(
		CLOCK_50,						//	On Board 50 MHz
        KEY,
        SW,
		LEDR,
        //in_y,
        //out_y
	);

    input CLOCK_50;
    input [3:0] KEY;
	 input [17:0] SW;
	 output [17:0] LEDR;
    //input in_y,
    //output in_y,

		assign LEDR[1] = 1'b1;
		
    wire fixed_x;
    assign fixed_x = 8'd20;
	 
	 RateDivider rd(
		.clk(CLOCK_50),
		.enable(1'b1),
		.out(newClock)
	);
	 
	 control c1(
    .clk(newClock),
    .resetn(SW[16]),
    .go(KEY[1]),
    .ld_y(LEDR)
	 );

endmodule

module control(
    input clk,
    input resetn,
    input go,

    output reg ld_y
	 );

    reg [2:0] current_state, next_state; 
    wire fixed_x;
    assign fixed_x = 8'd20;
    reg speed = 8'd1;
    
    localparam  S_FALL        = 3'd0,
                S_FLAP        = 3'd1,
                S_FLAP_WAIT   = 3'd2;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_FALL: next_state = go ? S_FLAP : S_FALL; // Natural State is bird falling
                S_FLAP: next_state = go ? S_FLAP_WAIT : S_FALL; // On GO make bird fly 2 pixels
                S_FLAP_WAIT: next_state = go ? S_FLAP_WAIT : S_FALL; // On GO make bird fly 2 pixels
				default: next_state = S_FALL;
        endcase
    end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
		  
        case (current_state)
            S_FALL: begin
							ld_y = 6'd8;
                    //ld_y = ld_y - speed;
                    //speed = speed + speed;
                end
            S_FLAP: begin
                    ld_y = ld_y + 6'd2;
                    speed = 6'd1;
                end
            S_FLAP_WAIT: begin
                    ld_y = ld_y - speed;
                    speed = speed + speed;
                end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_FALL;
        else
            current_state <= next_state;
    end // state_FFS
endmodule
	 