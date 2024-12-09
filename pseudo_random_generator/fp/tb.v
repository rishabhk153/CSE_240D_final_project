`define MT8_PRNG
module tb_lcg_prng;

  // Testbench Parameters
  parameter N = 8;           // Width of the PRNG (set to 8 bits for this test)
  parameter OUTPUT_TYPE = 1; // Output type: 0 :: "integer" or 1 ::"floating"

  // Testbench Signals
  reg clk;
  reg reset;
  reg load_seed;
  reg [N-1:0] seed_data;
  wire [N-1:0] prng_data;  // Correctly drive prng_data for LCG PRNG
  wire [N-1:0] lfsr_data;  // Wire for LFSR output
  wire prng_done;

  // Period Detection
  reg [N-1:0] first_value;
  reg [31:0] cycle_count;
  reg period_detected;

  // Split the floating-point value into sign, exponent, and mantissa
  reg sign ;         // Sign bit (1 bit)
  reg [2:0] exponent ; // Exponent bits (3 bits)
  reg [3:0] mantissa ; // Mantissa bits (4 bits)

`ifdef LCG_PRNG
  // DUT Instantiation for LCG_PRNG (Floating-point Output)
  lcg_fp_prng #(
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
  // DUT Instantiation for LFSR (No Change)
  lfsr #(
    .N(N)
  ) lfsr_uut (
    .clk(clk),
    .reset(reset),
    .load_seed(load_seed),
    .seed_data(seed_data),
    .lfsr_done(lfsr_done),
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
    // Capture the first PRNG output (Floating-point format)
    #10 first_value = prng_data;  // Correct assignment for LCG PRNG
    $display("First PRNG Output: %d", first_value);

    // Monitor PRNG output for repetition
    forever begin
      #10;
      cycle_count = cycle_count + 1;
      sign = prng_data[7];         // Sign bit (1 bit)
      exponent = prng_data[6:4]; // Exponent bits (3 bits)
      mantissa = prng_data[3:0]; // Mantissa bits (4 bits)

      if (OUTPUT_TYPE == 0) begin
        $display("Cycle %d: PRNG_LCG Output (Integer): %d", cycle_count, prng_data);
      end else begin
        $display("Cycle %d: PRNG_LCG Output (Floating-point): sign_%b_exponent_%b_mantissa_%b", cycle_count, sign, exponent, mantissa);
      end

      if (prng_data == first_value && cycle_count > 1) begin
        $display("PRNG_LCG Output repeats after %d cycles at time %t", cycle_count, $time);
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
    // Capture the first PRNG output (Floating-point format)
    #10 first_value = prng_data;  // Correct assignment for LCG PRNG
    $display("First PRNG_MT8 Output: %d", first_value);

    // Monitor PRNG output for repetition
    forever begin
      #10;
      cycle_count = cycle_count + 1;
      sign = prng_data[7];         // Sign bit (1 bit)
      exponent = prng_data[6:4]; // Exponent bits (3 bits)
      mantissa = prng_data[3:0]; // Mantissa bits (4 bits)

      if (OUTPUT_TYPE == 0) begin
        $display("Cycle %d: PRNG_MT8 Output (Integer): %d", cycle_count, prng_data);
      end else begin
        $display("Cycle %d: PRNG_MT8 Output (Floating-point): sign_%b_exponent_%b_mantissa_%b", cycle_count, sign, exponent, mantissa);
      end

      if (prng_data == first_value && cycle_count > 1) begin
        $display("PRNG_MT8 Output repeats after %d cycles at time %t", cycle_count, $time);
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
    // Capture the first LFSR output (No floating-point format)
    #10 first_value = lfsr_data;  // Correct assignment for LFSR
    $display("First LFSR Output: %d", first_value);

    // Monitor LFSR output for repetition
    forever begin
      #10;
      cycle_count = cycle_count + 1;
      sign = lfsr_data[7];         // Sign bit (1 bit)
      exponent = lfsr_data[6:4]; // Exponent bits (3 bits)
      mantissa = lfsr_data[3:0]; // Mantissa bits (4 bits)

      if (OUTPUT_TYPE == 0) begin
        $display("Cycle %d: LFSR Output (Integer): %d", cycle_count, lfsr_data);
      end else begin
        $display("Cycle %d: LFSR Output (Floating-point): sign_%b_exponent_%b_mantissa_%b", cycle_count, sign, exponent, mantissa);
      end

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
