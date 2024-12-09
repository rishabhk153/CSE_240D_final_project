module lcg_fp_prng #(
  parameter N = 8,             // Width of the PRNG (specific to the 8-bit LCG)
  parameter OUTPUT_TYPE = 0    // Output type: 0 :: "integer" or 1 ::"floating"
)(
  input clk,
  input reset,
  input load_seed,
  input [N-1:0] seed_data,
  output reg [7:0] prng_data,  // 8-bit floating-point output
  output reg prng_done
);

  // Internal state register for PRNG
  reg [N-1:0] state;

  // Constants for the LCG (Linear Congruential Generator)
  reg [N-1:0] a = 5;  // Multiplier (must be odd, chosen to satisfy Hull-Dobell)
  reg [N-1:0] c = 1;  // Increment (relatively prime to modulus)
  reg [N:0] m = 256; // Modulus (2^8 for 8-bit LCG)

  // PRNG state update
  always @(posedge clk or negedge reset) begin
    if (!reset) begin
      // Reset state with seed value
      state <= seed_data;
      prng_done <= 0;
    end else if (load_seed) begin
      // Load a new seed
      state <= seed_data;
      prng_done <= 0;
    end else begin
      // Update PRNG state using LCG formula
      state <= (a * state + c) % m;  // LCG formula
      prng_done <= 1;                // Indicate PRNG cycle complete
    end
  end

  // Instantiate the bits_to_real module to convert integer output to floating point
  wire [7:0] real_val;
  bits_to_real real_converter (
    .bit_rep(state),    // Convert PRNG integer state to floating point
    .real_val(real_val) // Output the floating-point value
  );

  // Output logic
  always @(*) begin
    if (OUTPUT_TYPE == 0) begin
      prng_data = state;  // Output raw integer value
    end else begin
      prng_data = real_val; // Output floating-point value
    end
  end

endmodule
