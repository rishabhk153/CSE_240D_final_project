`timescale 1ns / 1ps
module prng_testbench;
  parameter N = 4; // Seed and output width
  logic clk;
  logic reset_n;
  logic load_seed;
  logic start;
  logic [N-1:0] seed_data;
  logic [N-1:0] prng_output;
  logic done;

  // Clock generator
  initial clk = 0;
  always #5 clk = ~clk; // 100 MHz clock

`ifdef SHA_PRNG
  // Instantiate SHA-based PRNG
  sha_prng #(.N(N)) prng_inst (
    .clk(clk),
    .reset(reset_n),
    .start(start),
    .seed(seed_data),
    .prng_out(prng_output),
    .done(done)
  );
`else
  // Instantiate LFSR PRNG
  lfsr #(.N(N)) prng_inst (
    .clk(clk),
    .reset(reset_n),
    .load_seed(load_seed),
    .seed_data(seed_data),
    .lfsr_data(prng_output),
    .lfsr_done(done)
  );
`endif

  // Testbench logic
  initial begin
    // Initialize Inputs
    reset_n = 0;
    load_seed = 0;
    start = 0;
    seed_data = {N{1'b0}};

    // Apply reset
    #10 reset_n = 1;

`ifdef SHA_PRNG
    // SHA-based PRNG Test
    #10 start = 1;
    seed_data = 16'hDEAD; // Input seed
    #10 start = 0;

    // Wait for SHA computation
    #300;

    // Test with another seed
    #10 start = 1;
    seed_data = 16'hBEEF;
    #10 start = 0;
    #300;

`else
    // LFSR PRNG Test
    #10 load_seed = 1;
    seed_data = 16'b1010_1010_1010_1010;
    #10 load_seed = 0;

    // Wait for LFSR to finish
    #300;

    // Test with another seed
    #10 load_seed = 1;
    seed_data = 16'b0101_0101_0101_0101;
    #10 load_seed = 0;
    #200;

`endif

    // End simulation
    $stop();
  end

  // Monitor signals
  initial begin
    $monitor("time=%0t, reset_n=%b, clk=%b, load_seed=%b, start=%b, seed_data=%b, prng_output=%b, done=%b", 
             $time, reset_n, clk, load_seed, start, seed_data, prng_output, done);
  end
endmodule
