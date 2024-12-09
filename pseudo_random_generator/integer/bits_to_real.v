// Bits-to-Real Conversion Module (IEEE 754 Single Precision)
module bits_to_real (
  input [31:0] bit_rep,    // 32-bit representation of the floating-point number
  output reg [31:0] real_val // 32-bit floating-point result
);

  wire sign;          // Sign bit
  wire [7:0] exponent; // Exponent bits (8 bits)
  wire [22:0] mantissa; // Mantissa bits (23 bits)

  reg [31:0] temp_real_val;
  reg [7:0] exp_adjusted;
  reg [22:0] mantissa_with_hidden_bit;
  reg [31:0] mantissa_scaled;
  
  // Split bit_rep into sign, exponent, and mantissa
  assign sign = bit_rep[31];
  assign exponent = bit_rep[30:23];
  assign mantissa = bit_rep[22:0];

  always @* begin
    // If the exponent is not zero, we have a normalized value
    if (exponent != 8'h00) begin
      exp_adjusted = exponent - 8'd127; // Adjust exponent by subtracting bias (127)
      mantissa_with_hidden_bit = {1'b1, mantissa}; // Add the hidden bit for normalized values
    end else begin
      // Handle denormalized numbers (exponent = 0), where mantissa doesn't have the hidden 1
      exp_adjusted = 8'd1; // Denormalized numbers have an exponent of 1
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
