module mt8_prng #(
  parameter N = 8,             // Width of the PRNG (8 bits)
  parameter OUTPUT_TYPE = 0    // Output type: 0 :: "integer" or 1 :: "floating"
)(
  input clk,
  input reset,
  input load_seed,
  input [N-1:0] seed_data,     // Seed input
  output reg [N-1:0] prng_data,  // 8-bit PRNG output
  output reg prng_done         // Indicates PRNG cycle complete
);

  // Internal state array for the simplified MT PRNG
  reg [N-1:0] state[0:3];      // Four 8-bit state registers
  reg [N-1:0] temp;            // Temporary register
  integer i;

  // PRNG initialization and seed loading
  always @(posedge clk or negedge reset) begin
    if (!reset) begin
      // Reset the PRNG state to default values
      state[0] <= 8'h01;
      state[1] <= 8'hB7;
      state[2] <= 8'h93;
      state[3] <= 8'h7E;
      prng_done <= 0;
    end else if (load_seed) begin
      // Load the seed into the initial state
      state[0] <= seed_data;
      state[1] <= seed_data ^ 8'hA5;  // Mix seed with a constant
      state[2] <= seed_data ^ 8'h5A;
      state[3] <= ~seed_data;         // Invert seed for diversity
      prng_done <= 0;
    end else begin
      // Simplified Mersenne Twister-like state transition
      temp = state[3] ^ (state[3] >> 1);  // XOR and shift
      state[3] <= state[2];
      state[2] <= state[1];
      state[1] <= state[0];
      state[0] <= temp ^ (temp << 1) ^ (state[1] >> 3);
      prng_done <= 1;  // PRNG cycle complete
    end
  end

  always @(*) begin
    prng_data = state[0];
  end

endmodule
