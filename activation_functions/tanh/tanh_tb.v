module test_tanh;
    reg signed [7:0] x;
    wire signed [7:0] y_piecewise, y_lut, y_sigmoid;
    integer i;
    reg reset;
    reg clk;

    tanh_piecewise instance_piecewise (
        .x_in(x),
        .y_out(y_piecewise),
        .clk(clk),
        .reset(reset)
    );

    tanh_lut instance_lut (
        .x_in(x),
        .y_out(y_lut),
        .clk(clk),
        .reset(reset)
    );

    tanh_using_sigmoid instance_using_sigmoid (
        .x_in(x),
        .y_out(y_sigmoid),
        .clk(clk),
        .reset(reset)
    );


   //clock generation
   initial begin
    clk = 0;
    forever begin #0.5 clk = ~clk; end
   end   
   

    initial begin
      $dumpfile("test_tanh.vcd");
      $dumpvars(0,test_tanh);

      $display("Begin Reset");
      reset = 0; 
      repeat(2)@(posedge clk);
      reset = 1;
      $display("End reset");

      $display("Testing Tanh Module:");
      $display("  x\t\tLUT\t\tPieceWise Linear\tusing sigmoid");
      @(negedge clk)
      for (i = 0; i < 256; i = i + 1) begin
          x = (i - 128); // Test inputs: -128, -96, ..., 127
          @(negedge clk)
          $display("%d\t\t%d\t\t%d\t\t%d\t\t", x, y_lut, y_piecewise,y_sigmoid);
      end 
        $finish;
    end
endmodule
