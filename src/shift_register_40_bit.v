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
