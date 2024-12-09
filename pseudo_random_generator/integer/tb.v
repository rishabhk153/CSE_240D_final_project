`define MT8_PRNG
module tb_lcg_prng;

  // Testbench Parameters
  parameter N = 8;           // Width of the PRNG (set to 8 bits for this test)
  parameter OUTPUT_TYPE = 0; // Output type: 0 :: "integer" or 1 ::"floating"

  // Testbench Signals
  reg clk;
  reg reset;
  reg load_seed;
  reg [N-1:0] seed_data;
  wire [N-1:0] prng_data;
  wire [N-1:0] lfsr_data;
  wire [N-1:0] xyz_data;
  wire prng_done;
  wire xyz_done;

  // Period Detection
  reg [N-1:0] first_value;
  reg [31:0] cycle_count;
  reg period_detected;

`ifdef LCG_PRNG
  // LCG PRNG Instantiation
  lcg_prng #(
    .N(N),
    .OUTPUT_TYPE(OUTPUT_TYPE)
  ) uut (
    .clk(clk),
    .reset(reset),
    .load_seed(load_seed),
    .seed_data(seed_data),
    .prng_data(prng_data),
    .prng_done(prng_done)
  );
`elsif MT8_PRNG
  // Mersenne Twister PRNG Instantiation
  mt8_prng #(
    .N(N),
    .OUTPUT_TYPE(OUTPUT_TYPE)
  ) uut (
    .clk(clk),
    .reset(reset),
    .load_seed(load_seed),
    .seed_data(seed_data),
    .prng_data(prng_data),
    .prng_done(prng_done)
  );
`else
  // LFSR Instantiation
  lfsr #(
    .N(N)
  ) lfsr_uut (
    .clk(clk),
    .reset(reset),
    .load_seed(load_seed),
    .seed_data(seed_data),
    .lfsr_data(lfsr_data)
  );
`endif

  // Clock Generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10ns clock period
  end

  // Testbench Logic
  initial begin
    // Initialize inputs
    reset = 1'b1;
    load_seed = 1'b0;
    seed_data = 8'd0;

    // Create a VCD file for waveform dumping
    $dumpfile("lcg_prng_waveform.vcd");  // Specify the VCD file name
    $dumpvars(0, tb_lcg_prng);  // Dump all variables at the 0 level (top module)

    // Apply reset
    #10;
    reset = 1'b0;
    #10;
    reset = 1'b1;

    #50;
    // PRNG Test Logic
    seed_data = 8'd42;  // Example seed (non-zero and within 8-bit range)
    load_seed = 1'b1;   // Load the seed
    #10;
    load_seed = 1'b0;

    cycle_count = 0;
    period_detected = 0;

`ifdef LCG_PRNG
    // Capture the first PRNG output
    #10 first_value = prng_data;
    $display("First PRNG Output: %d", first_value);

    // Monitor PRNG output for repetition
    forever begin
      #10;
      cycle_count = cycle_count + 1;

      $display("Cycle %d: PRNG Output: %d", cycle_count, prng_data);

      if (prng_data == first_value && cycle_count > 1) begin
        $display("PRNG Output repeats after %d cycles at time %t", cycle_count, $time);
        period_detected = 1;
        $finish;  // End simulation after detecting the period
      end

      // Safety stop after 300 cycles
      if (cycle_count >= 300) begin
        $display("Simulation completed after 300 cycles.");
        $stop;
      end
    end
`elsif MT8_PRNG
    // Capture the first PRNG output
    #10 first_value = prng_data;
    $display("First PRNG Output: %d", first_value);

    // Monitor PRNG output for repetition
    forever begin
      #10;
      cycle_count = cycle_count + 1;

      $display("Cycle %d: PRNG Output: %d", cycle_count, prng_data);

      if (prng_data == first_value && cycle_count > 1) begin
        $display("PRNG Output repeats after %d cycles at time %t", cycle_count, $time);
        period_detected = 1;
        $finish;  // End simulation after detecting the period
      end

      // Safety stop after 300 cycles
      if (cycle_count >= 300) begin
        $display("Simulation completed after 300 cycles.");
        $stop;
      end
    end
`else
    // Capture the first LFSR output
    #10 first_value = lfsr_data;
    $display("First LFSR Output: %d", first_value);

    // Monitor LFSR output for repetition
    forever begin
      #10;
      cycle_count = cycle_count + 1;

      $display("Cycle %d: LFSR Output: %d", cycle_count, lfsr_data);

      if (lfsr_data == first_value && cycle_count > 1) begin
        $display("LFSR Output repeats after %d cycles at time %t", cycle_count, $time);
        period_detected = 1;
        $finish;  // End simulation after detecting the period
      end

      // Safety stop after 300 cycles
      if (cycle_count >= 300) begin
        $display("Simulation completed after 300 cycles.");
        $stop;
      end
    end
`endif
  end

endmodule
