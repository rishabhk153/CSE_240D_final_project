// Bits-to-Real Conversion Module (8-bit Floating Point Format)
module bits_to_real (
  input [7:0] bit_rep,    // 8-bit representation of the floating-point number
  output reg [7:0] real_val // 8-bit floating-point result
);

  reg sign;             // Sign bit (1 bit)
  reg [2:0] exponent;   // Exponent bits (3 bits)
  reg [3:0] mantissa;   // Mantissa bits (4 bits)

  reg [7:0] temp_real_val;
  reg [2:0] exp_adjusted;
  reg [4:0] mantissa_with_hidden_bit; // Include extra bit for hidden 1
  reg [7:0] mantissa_scaled;
  
  always @* begin
    // Default values for exponent and mantissa
    exp_adjusted = 3'b000;
    mantissa_with_hidden_bit = 5'b0;
    sign = bit_rep[7];
    exponent = bit_rep[6:4];
    mantissa = bit_rep[3:0];    // If the exponent is not zero, we have a normalized value
    if (exponent != 3'b000) begin
      exp_adjusted = exponent - 3'd3; // Adjust exponent by subtracting bias (3)
      mantissa_with_hidden_bit = {1'b1, mantissa}; // Add the hidden bit for normalized values
    end else begin
      // Handle denormalized numbers (exponent = 0), where mantissa doesn't have the hidden 1
      exp_adjusted = 3'd1; // Denormalized numbers have an exponent of 1
      mantissa_with_hidden_bit = {1'b0, mantissa}; // No hidden bit for denormalized numbers
    end

    // Scale the mantissa and shift it by the adjusted exponent value
    mantissa_scaled = mantissa_with_hidden_bit << exp_adjusted;

    // Handle sign bit (negative numbers)
    if (sign) begin
      temp_real_val = ~mantissa_scaled + 1; // Take two's complement for negative values
    end else begin
      temp_real_val = mantissa_scaled;
    end
    
    // Final real value is the result after sign adjustment
    real_val = temp_real_val;
  end

endmodule
