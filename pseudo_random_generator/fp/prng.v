module lfsr
  #(parameter N = 8) // Number of bits for LFSR
(
  input  clk, reset, load_seed,
  input  [N-1:0] seed_data,
  output lfsr_done,
  output [N-1:0] lfsr_data
);
  reg [N-1:0] lfsr_reg;
  reg [$clog2((1 << N) - 1):0] cnt; // Log2-based counter width

  assign lfsr_data = lfsr_reg;
  assign lfsr_done = (cnt == (1 << N) - 2) ? 1'b1 : 1'b0 ;

  // LFSR logic with taps for maximal sequence
  wire feedback = lfsr_reg[7] ^ lfsr_reg[5] ^ lfsr_reg[4] ^ lfsr_reg[3]; // Taps for N = 8

  always @(posedge clk or negedge reset) begin
    if (!reset) begin
      lfsr_reg <= {N{1'b0}}; 
    end else if (load_seed) begin
      lfsr_reg <= seed_data;
    end else begin
      lfsr_reg <= {lfsr_reg[N-2:0], feedback};
    end
  end

always @(posedge clk or negedge reset) begin
    if (!reset) begin
      cnt <= 0;
    end else if (load_seed) begin
      cnt <= 0;
    end else if (lfsr_reg) begin
      cnt <= cnt + 1;
      if (cnt == (1 << N) - 2) begin
        cnt <= 0;
      end
    end
  end
endmodule
