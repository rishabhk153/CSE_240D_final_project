// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fifo_depth8 (rd_clk, wr_clk, in, out, rd, wr, o_full, o_empty, reset);

  parameter bw = 16;
  parameter simd = 1;

  input  rd_clk;
  input  wr_clk;
  input  rd;
  input  wr;
  input  reset;
  output o_full;
  output o_empty;
  input  [simd*bw-1:0] in;
  output [simd*bw-1:0] out;

  wire [simd*bw-1:0] out_sub1;
  wire [simd*bw-1:0] out_sub2;
 
  wire full, empty;

  reg [3:0] rd_ptr;
  reg [3:0] wr_ptr;

  reg [simd*bw-1:0] q0;
  reg [simd*bw-1:0] q1;
  reg [simd*bw-1:0] q2;
  reg [simd*bw-1:0] q3;
  reg [simd*bw-1:0] q4;
  reg [simd*bw-1:0] q5;
  reg [simd*bw-1:0] q6;
  reg [simd*bw-1:0] q7;

 assign empty = (wr_ptr == rd_ptr) ? 1'b1 : 1'b0 ;
 assign full  = ((wr_ptr[2:0] == rd_ptr[2:0]) && (wr_ptr[3] != rd_ptr[3])) ? 1'b1 : 1'b0;

 assign o_full  = full;
 assign o_empty = empty;


  fifo_mux_8_1 #(.bw(bw), .simd(simd)) fifo_mux_8_1a (.in0(q0), .in1(q1), .in2(q2), .in3(q3), .in4(q4), .in5(q5), .in6(q6), .in7(q7),
	         .sel(rd_ptr[2:0]), .out(out));


 always @ (posedge rd_clk) begin
   if (reset) begin
      rd_ptr <= 4'b0000;
   end
   else if ((rd == 1) && (empty == 0)) begin
      rd_ptr <= rd_ptr + 1;
   end
 end


 always @ (posedge wr_clk) begin
   if (reset) begin
      wr_ptr <= 4'b0000;
   end
   else begin 
      if ((wr == 1) && (full == 0)) begin
        wr_ptr <= wr_ptr + 1;
      end

      if (wr == 1) begin
        case (wr_ptr[2:0])
         3'b000   :    q0  <= in ;
         3'b001   :    q1  <= in ;
         3'b010   :    q2  <= in ;
         3'b011   :    q3  <= in ;
         3'b100   :    q4  <= in ;
         3'b101   :    q5  <= in ;
         3'b110   :    q6  <= in ;
         3'b111   :    q7  <= in ;
        endcase
      end
   end

 end


endmodule
