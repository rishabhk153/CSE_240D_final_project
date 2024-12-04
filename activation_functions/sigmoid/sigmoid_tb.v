module test_sigmoid;
    reg signed [7:0] x;
    wire [7:0] y_piecewise, y_lut, y_poly;
    integer i;
    reg reset;
    reg clk;

    sigmoid_piecewise instance_piecewise (
        .x_in(x),
        .y_out(y_piecewise),
        .clk(clk),
        .reset(reset)
    );

    sigmoid_lut instance_lut (
        .x_in(x),
        .y_out(y_lut),
        .clk(clk),
        .reset(reset)
    );

    sigmoid_poly instance_poly (
        .x_in(x),
        .y_out(y_poly),
        .clk(clk),
        .reset(reset)
    );

   //clock generation
   initial begin
    clk = 0;
    forever begin #0.5 clk = ~clk; end
   end   
   

    initial begin
      $dumpfile("test_sigmoid.vcd");
      $dumpvars(0,test_sigmoid);

      $display("Begin Reset");
      reset = 0; 
      repeat(2)@(posedge clk);
      reset = 1;
      $display("End reset");

      $display("Testing Sigmoid Module:");
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
