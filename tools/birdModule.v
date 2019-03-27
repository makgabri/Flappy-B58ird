module Birdy(clock, resetn, go, color, y_out);

	// Currently a top module to test with LEDS
	input clock;
    input resetn;
    input go;
    output [2:0] color;
	output [6:0] y_out;

	// If x is fixed, create the x coordinate to feed back to high module, or even no x coordinate(not used in calculating y of bird)
    //wire fixed_x;
    //assign fixed_x = 8'd20;

    // Resetn should be 1 to go to next state
	control c1(
	  .clk(clock),
    .resetn(resetn),
    .go(go),
    .color(color),
    .ld_y(y_out)
	);

endmodule

module control(clk, resetn, go, color, ld_y);
	input clk;
	input resetn;
	input go;

    output reg [2:0] color;
	output reg [6:0] ld_y;

	reg [2:0] current_state, next_state;
    reg fall = 1'b0;
    reg speed = 8'd1;
	localparam  	S_START       = 3'd0,
								S_FALL 				= 3'd1,
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
		  S_START: begin
						ld_y = 6'd3;
						speed = 8'd1;
			end
			S_FALL: begin
                // Decrease speed and increase gravity by *2 every clock cycle
                ld_y = ld_y - speed;
                speed = speed + speed;
                        counter = 0;
    
        if fall == 1'b0:
            colour = 2'b110;
            x = bird_x + pixel_counter[3:2];
            y = ld_y + pixel_counter[1:0];
            
            if (pixel_counter == 4'b1111) begin
                pixel_counter = 4'b0000;
                fall = true;
            end
            else pixel_counter = pixel_counter + 1'b1;
            
        // erase and move down 4
        else if fall == true: 
            // erase current
            colour = black;
            x = bird_x + pixel_counter[3:2];
            y = ld_y + pixel_counter[1:0];
            
            if (pixel_counter == 4'b1111) begin
                pixel_counter = 4'b0000;
                ld_y -=4 - speed;
                speed = speed + speed;
                fall = false;
            end
            else pixel_counter = pixel_counter + 1'b1;
            
      end
      S_FLAP: begin
				// Increase gravity every clock cycle by *2
				// erase current, set new y then draw bird and reset gravit
				ld_y = ld_y + 6'd2;
				speed = 6'd1;
      end
			S_FLAP_WAIT: begin
				// Similar to fall state but need this state to prevent holding fly
				ld_y = ld_y - speed;
				speed = speed + speed;
      end
      //default:
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

	/*
	Ahmed. Bird.
	drawfall draws, then fal
				//color = blackls etc
	drawrise draws, then rises. 3 times. then goes to drawfall/

	default is init, which draws the bird.
	bird_x and bird_y should be initial position of bird.
	bird_x does not change. y goes up and down.
	
	INIT_BIRD: begin
		if birdcounter < 2
			colour = green;
			x = bird_x + pixel_counter[3:2];
			y = bird_y + pixel_counter[1:0];
			

			if (pixel_counter == 4'b1111) begin
				pixel_counter = 4'b0000;
				bird_y += 4;
				birdcounter ++;
			end
			else pixel_counter = pixel_counter + 1'b1;
		else
			state = drawfall
	end

	drawrise:
		// erase and go up 4
		if rise == false and counter < 3:
			// erase current
			colour = black;
			x = bird_x + pixel_counter[3:2];
			y = bird_y + pixel_counter[1:0];
			

			if (pixel_counter == 4'b1111) begin
				pixel_counter = 4'b0000;
				bird_y += 4;
				rise = true;
			end
			else pixel_counter = pixel_counter + 1'b1;

		// draw
		else if rise == true and couter < 3: 
			colour = green;
			x = bird_x + pixel_counter[3:2];
			y = bird_y + pixel_counter[1:0];
				

			if (pixel_counter == 4'b1111) begin
				pixel_counter = 4'b0000;
				counter ++;
			end
			else pixel_counter = pixel_counter + 1'b1;
		else:
			counter = 0;
			rise = false;
			fall = true;
			state = drawfall;



	drawfall:
		counter = 0;
		rise = false;
		if fall == false:
			// draw
			colour = green;
			x = bird_x + pixel_counter[3:2];
			y = bird_y + pixel_counter[1:0];
			

			if (pixel_counter == 4'b1111) begin
				pixel_counter = 4'b0000;
				fall = true;
			end
			else pixel_counter = pixel_counter + 1'b1;

		// erase and move down 4
		else if fall == true: 
			// erase current
			colour = black;
			x = bird_x + pixel_counter[3:2];
			y = bird_y + pixel_counter[1:0];
			

			if (pixel_counter == 4'b1111) begin
				pixel_counter = 4'b0000;
				bird_y -=4;
				fall = false;
			end
			else pixel_counter = pixel_counter + 1'b1;


	default: initbird
	*/
S_FALL: begin
                // Decrease speed and increase gravity by *2 every clock cycle
                ld_y = ld_y - speed;
                speed = speed + speed;
                        counter = 0;
    
        if fall == false:
            // draw
            colour = green;
            x = bird_x + pixel_counter[3:2];
            y = ld_y + pixel_counter[1:0];
            
            if (pixel_counter == 4'b1111) begin
                pixel_counter = 4'b0000;
                fall = true;
            end
            else pixel_counter = pixel_counter + 1'b1;
            
        // erase and move down 4
        else if fall == true: 
            // erase current
            colour = black;
            x = bird_x + pixel_counter[3:2];
            y = ld_y + pixel_counter[1:0];
            
            if (pixel_counter == 4'b1111) begin
                pixel_counter = 4'b0000;
                ld_y -=4 - speed;
                speed = speed + speed;
                fall = false;
            end
            else pixel_counter = pixel_counter + 1'b1;
            
      end
