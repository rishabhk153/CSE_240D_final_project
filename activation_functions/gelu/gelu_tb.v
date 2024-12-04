module test_gelu;
    reg signed [7:0] x;
    wire signed [7:0] y_piecewise, y_lut, y_using_tanh;
    integer i;
    reg reset;
    reg clk;

    gelu_piecewise instance_piecewise (
        .x_in(x),
        .y_out(y_piecewise),
        .clk(clk),
        .reset(reset)
    );

    gelu_lut instance_lut (
        .x_in(x),
        .y_out(y_lut),
        .clk(clk),
        .reset(reset)
    );

    gelu_using_tanh instance_using_tanh (
        .x_in(x),
        .y_out(y_using_tanh),
        .clk(clk),
        .reset(reset)
    );


   //clock generation
   initial begin
    clk = 0;
    forever begin #0.5 clk = ~clk; end
   end   
   

    initial begin
      $dumpfile("test_gelu.vcd");
      $dumpvars(0,test_gelu);

      $display("Begin Reset");
      reset = 0; 
      repeat(2)@(posedge clk);
      reset = 1;
      $display("End reset");

      $display("Testing Tanh Module:");
      $display("  x\t\tLUT\t\tPieceWise Linear\t\t");
      @(negedge clk)
      for (i = 0; i < 256; i = i + 1) begin
          x = (i - 128); // Test inputs: -128, -96, ..., 127
          @(negedge clk)
          $display("%d\t\t%d\t\t%d\t\t", x, y_lut, y_piecewise);
      end 
        $finish;
    end

endmodule
