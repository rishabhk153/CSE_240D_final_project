module test_sigmoid;
    reg signed [7:0] x;
    wire [7:0] y;
    integer i;
    reg reset;
    reg clk;

    sigmoid_piecewise instance_piecewise (
        .x_in(x),
        .y_out(y),
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
      $display("  x\tPieceWise Linear");
      @(negedge clk)
      for (i = 0; i < 256; i = i + 1) begin
          x = (i - 128); // Test inputs: -128, -96, ..., 127
          @(negedge clk)
          $display("%d\t\t%d\t\t", x, y);
      end 
        $finish;
    end
endmodule
