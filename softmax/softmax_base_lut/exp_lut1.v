// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module exp_lut (clk, wr, out, in, lut_in, reset);

parameter DATA_WIDTH = 8;
parameter DATA_DEPTH = 64; //
parameter DATA_IDX = 6; //

output [DATA_WIDTH-1:0] out ;
input  [DATA_WIDTH-1:0] lut_in;
input  [DATA_IDX-1:0] in;
input  clk;
input  wr;
input  reset;
wire [DATA_WIDTH-1:0] test_lut;
assign test_lut = lut_q[1];

reg	[DATA_WIDTH-1:0] lut_q [0:DATA_DEPTH-1];

assign out = lut_q[in];
         
integer i;
always @ (posedge clk) begin
 if (wr) begin
        lut_q[0] <= lut_in;
        for (i = 0; i < DATA_DEPTH - 1; i = i + 1) begin
            lut_q[i+1] <= lut_q[i];
        end

  end

end

endmodule
