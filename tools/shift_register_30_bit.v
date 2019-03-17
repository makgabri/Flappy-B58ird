module shift_register_30_bit(
  input clk,
  input resetn,
  input data_in,

  output bit_out,
  output reg [29:0] thirty_bit_out
  );

  // Reset Shift Register on low resetn signal, otherwise every positive clock
  // edge takes the input value and puts it at the least significant bit of the
  // 30-bit shift register, with the pushed out bit also being returned.

  always @(posedge clk)
  begin
    if (!resetn) begin
      bit_out = forty_bit_out[29];
      forty_bit_out <= {forty_bit_out[28:0], data_in};
    end
    else begin
      bit_out = 1'b0;
      forty_bit_out <= 20'b0;
    end
  end

endmodule
