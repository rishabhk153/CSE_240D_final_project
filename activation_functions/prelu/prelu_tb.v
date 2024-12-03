module tb_ParametricReLU;

    // Parameters
    parameter WIDTH = 8;
    parameter ALPHA_WIDTH = 8;
    
    // Testbench signals
    reg signed [WIDTH-1:0] x_in;        // Input to PReLU
    reg [ALPHA_WIDTH-1:0] alpha; // Alpha parameter
    reg clk;                            // Clock signal
    reg reset;                          // Reset signal
    wire signed [WIDTH-1:0] y_out;      // Output of PReLU
    integer i;
    
    // Instantiate the Parametric ReLU module
    ParametricReLU #(
        .WIDTH(WIDTH),
        .ALPHA_WIDTH(ALPHA_WIDTH)
    ) prelu_inst (
        .x_in(x_in),
        .alpha(alpha),
        .clk(clk),
        .reset(reset),
        .y_out(y_out)
    );
    
    // Clock generation
   initial begin
    clk = 0;
    forever begin #0.5 clk = ~clk; end
   end  
    
    // Test sequence
    initial begin
      $dumpfile("test_prelu.vcd");
      $dumpvars(0,tb_ParametricReLU);
      $display("Begin Reset");
      reset = 0; 
      repeat(2)@(posedge clk);
      reset = 1;
      $display("End reset"); 
      $display("Testing Prelu Module:");
      $display("  input\t\toutput");
      @(negedge clk)
      alpha = 1; //0.5
      for (i = 0; i < 256; i = i + 1) begin
          x_in = (i - 128); // Test inputs: -128, -96, ..., 127
          @(negedge clk)
          $display("%d\t\t%d\t\t", x_in, y_out);
      end 
        // End simulation
      $finish;
    end
    
endmodule

