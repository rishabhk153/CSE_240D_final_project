// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module exp_lut (clk, wr, out, in, lut_in, reset);

parameter bw = 8;

output [bw-1:0] out ;
input  [bw-1:0] lut_in;
input  [bw/2-1:0] in;
input  clk;
input  wr;
input  reset;


reg	[bw-1:0] lut_q0;
reg	[bw-1:0] lut_q1;
reg	[bw-1:0] lut_q2;
reg	[bw-1:0] lut_q3;
reg	[bw-1:0] lut_q4;
reg	[bw-1:0] lut_q5;
reg	[bw-1:0] lut_q6;
reg	[bw-1:0] lut_q7;
reg	[bw-1:0] lut_q8;
reg	[bw-1:0] lut_q9;
reg	[bw-1:0] lut_q10;
reg	[bw-1:0] lut_q11;
reg	[bw-1:0] lut_q12;
reg	[bw-1:0] lut_q13;
reg	[bw-1:0] lut_q14;
reg	[bw-1:0] lut_q15;



assign out = (in == 0) ? lut_q0 : 
   (in == 1) ?	lut_q1	:
   (in == 2) ?	lut_q2	:
   (in == 3) ?	lut_q3	:
   (in == 4) ?	lut_q4	:
   (in == 5) ?	lut_q5	:
   (in == 6) ?	lut_q6	:
   (in == 7) ?	lut_q7	:
   (in == 8) ?	lut_q8	:
   (in == 9) ?	lut_q9	:
   (in == 10) ?	lut_q10	:
   (in == 11) ?	lut_q11	:
   (in == 12) ?	lut_q12	:
   (in == 13) ?	lut_q13	:
   (in == 14) ?	lut_q14	:
   	        lut_q15 ; 	

          
always @ (posedge clk) begin

 if (wr) begin
   lut_q0   <= lut_in;
   lut_q1   <= lut_q0	;
   lut_q2   <= lut_q1	;
   lut_q3   <= lut_q2	;
   lut_q4   <= lut_q3	;
   lut_q5   <= lut_q4	;
   lut_q6   <= lut_q5	;
   lut_q7   <= lut_q6	;
   lut_q8   <= lut_q7	;
   lut_q9   <= lut_q8	;
   lut_q10  <= lut_q9	;
   lut_q11  <= lut_q10	;
   lut_q12  <= lut_q11	;
   lut_q13  <= lut_q12	;
   lut_q14  <= lut_q13	;
   lut_q15  <= lut_q14	;

  end

end

endmodule
