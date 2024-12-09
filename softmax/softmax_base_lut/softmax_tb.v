// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

`timescale 1ns/1ps
module softmax_tb;

parameter total_cycle = 64;   // how many streamed Q vectors will be processed
parameter bw = 8;            // Q & K vector bit precision
parameter bw_psum = 2*bw;  // partial sum bit precision
parameter pr = 16;           // how many products added in each dot product 
parameter col = 32;           // how many dot product units are equipped
parameter softmax_col = 8;           // how many dot product units are equipped

real period;
reg  mode = 0;
reg clk = 0;
reg reset = 1;
reg execute = 0;
reg execute_q ;
reg ofifo_rd = 0;
reg ofifo_rd_q ;
reg [1:0] lut_wr = 0;
reg [1:0] lut_wr_q ;
reg fetch = 0;
reg [bw*softmax_col-1:0] in;
reg [bw*softmax_col-1:0] in_q;

reg [pr*bw-1:0] mem_in; 
reg [16*col-1:0] weight_in; 
//reg ofifo_rd = 0;
wire [11+8*col:0] inst; 
reg qmem_rd = 0;
reg qmem_wr = 0; 
reg [5:0] qkmem_add = 0;
wire [10:0] add_inst;

wire [bw*softmax_col-1:0] out;
//add_inst
assign add_inst[1:0] = mode;
assign add_inst[3:2] = lut_wr;
assign add_inst[4] = execute;
assign add_inst[5] = fetch;

assign inst[3] = qmem_rd;
assign inst[2] = qmem_wr;
assign inst[11:6] = qkmem_add;
//LUT data
//reg [bw*col*4-1:0] lut_data = 256'hCE8ae5ac459dc987ad25d525c73def4a7f61db6c5a1c8c39ca76c90eb3ea80c2;
//reg [bw*col*4-1:0] lut_data = 256'h1010101010101010101010101010101010101010101010101010101010101010;
//reg [bw*col*4-1:0] lut_data = 256'h1010101010101010101010101010101010101010101010101010101010101000;
reg [bw*softmax_col*4-1:0] lut_data = 256'hCE8ae5ac459dc987ad25d525c73def4a7f61db6c5a1c8c39ca76c90eb3ea80c2;

//reg [bw*col*3-1:0] in_total = 384'h1E6b3cf64ba1d4337739903f8e183528bae1c16c21c02c1198ad34fdd5468b0158ec675b1b057f26eb81376956fa0642;
reg [bw*softmax_col*8-1:0] in_total = 511'h000000000000000000000000000000001E6b3cf64ba1d4337739903f8e183528bae1c16c21c02c1198ad34fdd5468b0158ec675b1b057f26eb81376956fa0642;

integer  i,k,p,q,u, lut_file, lut_file_hd, in_file, in_file_hd, bin2dec_sum, captured_data;


integer  lut_msb[15:0];
integer  lut_lsb[15:0];
integer  in_data[47:0];

reg [bw*48-1:0] expected_out = 0 ;

integer w_file ; // file handler
integer w_scan_file ; // file handler

  integer max;
  integer idx_msb_now;
  integer idx_lsb_now;

  integer idx[63:0];
  reg [2*bw*64-1:0] prod;
  reg [bw-1+6:0] sum ; 
  reg [bw*64-1:0] exp_msb;
  reg [bw*64-1:0] exp_lsb ;
  reg [bw-1:0] test_sig1;
  reg [bw-1:0] test_sig2;
  reg [bw*8*8-1:0] predict_out;

initial begin 

  sum=0;

  for (i=0; i<64; i=i+1) begin

    //idx_msb_now = in_total[bw*(i+1)-1:bw*i+bw/2];
    idx_msb_now = in_total[bw*(i+1)-1 -:4];
    //idx_lsb_now = in_total[bw*i+bw/2-1:bw*i];
    idx_lsb_now = in_total[bw*i +:4];
    case(idx_msb_now)
    0:  exp_msb[bw*i +: 8] = lut_data[bw*(16+1)-1:bw*16];
    1:  exp_msb[bw*i +: 8] = lut_data[bw*(17+1)-1:bw*17];
    2:  exp_msb[bw*i +: 8] = lut_data[bw*(18+1)-1:bw*18];
    3:  exp_msb[bw*i +: 8] = lut_data[bw*(19+1)-1:bw*19];
    4:  exp_msb[bw*i +: 8] = lut_data[bw*(20+1)-1:bw*20];
    5:  exp_msb[bw*i +: 8] = lut_data[bw*(21+1)-1:bw*21];
    6:  exp_msb[bw*i +: 8] = lut_data[bw*(22+1)-1:bw*22];
    7:  exp_msb[bw*i +: 8] = lut_data[bw*(23+1)-1:bw*23];
    8:  exp_msb[bw*i +: 8] = lut_data[bw*(24+1)-1:bw*24];
    9:  exp_msb[bw*i +: 8] = lut_data[bw*(25+1)-1:bw*25];
    10: exp_msb[bw*i +: 8] = lut_data[bw*(26+1)-1:bw*26];
    11: exp_msb[bw*i +: 8] = lut_data[bw*(27+1)-1:bw*27];
    12: exp_msb[bw*i +: 8] = lut_data[bw*(28+1)-1:bw*28];
    13: exp_msb[bw*i +: 8] = lut_data[bw*(29+1)-1:bw*29];
    14: exp_msb[bw*i +: 8] = lut_data[bw*(30+1)-1:bw*30];
    15: exp_msb[bw*i +: 8] = lut_data[bw*(31+1)-1:bw*31];
    endcase
    //$display("idx_lsb contents: %5d", idx_lsb_now);
    
    case(idx_lsb_now)
    0:  exp_lsb[bw*i +: 8] = lut_data[bw*(0+1) -1:bw*0];
    1:  exp_lsb[bw*i +: 8] = lut_data[bw*(1+1) -1:bw*1];
    2:  exp_lsb[bw*i +: 8] = lut_data[bw*(2+1) -1:bw*2];
    3:  exp_lsb[bw*i +: 8] = lut_data[bw*(3+1) -1:bw*3];
    4:  exp_lsb[bw*i +: 8] = lut_data[bw*(4+1) -1:bw*4];
    5:  exp_lsb[bw*i +: 8] = lut_data[bw*(5+1) -1:bw*5];
    6:  exp_lsb[bw*i +: 8] = lut_data[bw*(6+1) -1:bw*6];
    7:  exp_lsb[bw*i +: 8] = lut_data[bw*(7+1) -1:bw*7];
    8:  exp_lsb[bw*i +: 8] = lut_data[bw*(8+1) -1:bw*8];
    9:  exp_lsb[bw*i +: 8] = lut_data[bw*(9+1) -1:bw*9];
    10: exp_lsb[bw*i +: 8] = lut_data[bw*(10+1)-1:bw*10];
    11: exp_lsb[bw*i +: 8] = lut_data[bw*(11+1)-1:bw*11];
    12: exp_lsb[bw*i +: 8] = lut_data[bw*(12+1)-1:bw*12];
    13: exp_lsb[bw*i +: 8] = lut_data[bw*(13+1)-1:bw*13];
    14: exp_lsb[bw*i +: 8] = lut_data[bw*(14+1)-1:bw*14];
    15: exp_lsb[bw*i +: 8] = lut_data[bw*(15+1)-1:bw*15];
    endcase
  end

  for (i=0; i<64; i=i+1) begin
    prod[(2*bw)*i +: 16] = exp_msb[bw*i +: 8] * exp_lsb[bw*i +: 8];
  end
  if (mode==1) begin
	  for (i=0; i<64; i=i+1) begin
	    sum = sum + prod[(2*bw)*(i+1)-1 -: 8];
	  end

	  for (i=0; i<64; i=i+1) begin
	    predict_out[bw*i +: 8] = {prod[(2*bw)*(i+1)-1 -: 8], 8'b00000000}/sum;   
	  end 
  end
  else begin
	  //for (i=0; i<64; i=i+1) begin
	   // sum = sum + prod[(2*bw)*(i+1)-1 -: 8];
	  //end
		
	  for (i=0; i<8; i=i+1) begin
	    sum = sum + prod[(2*bw)*(i+1)-1 -: 8];
	  end

	  for (i=0; i<64; i=i+1) begin
	    predict_out[bw*i +: 8] = {prod[(2*bw)*(i+1)-1 -: 8], 8'b00000000}/sum;   
	  end 

  end

  end

 softmax #(.bw(bw), .col(softmax_col)) softmax_instance (
      .reset(reset),
      .clk(clk), 
      .mode(mode),
      .in(in),
      .execute(execute), 
      .lut_wr(lut_wr), 
      .fetch(fetch), 
      .out(out)
);

//initial $sdf_annotate("softmax.pnr_fast.sdf", softmax_instance, , ,"MAXIMUM","1:1:1","FROM_MTM");




initial begin 

  $dumpfile("softmax_tb.vcd");
  $dumpvars(0,softmax_tb);

  w_file = $fopen("period.txt", "r");  //weight data
  //w_scan_file = $fscanf(w_file, "%f\n", period);
  period = 0.5;


 for (i=0; i<16; i=i+1) begin
  #(period) clk = 1'b0;
  #(period) clk = 1'b1;
 end  

  #(period) clk = 1'b0;
  reset = 0;
  #(period) clk = 1'b1;
  if (mode==0) $display("-------------------- Current mode: LSA 8 input --------------------");
  else $display("-------------------- Current mode: GSA 8x8 input --------------------");
  $display("-------------------- Mem Writing --------------------");
 for (q=0; q<4; q=q+1) begin
    #0.5 clk = 1'b0;  
    qmem_wr = 1;  if (q>0) qkmem_add = qkmem_add + 1; 
    mem_in[63:0]   = lut_data[bw*softmax_col*q +: 64];
    mem_in[127:64]   = 'b0;
    #0.5 clk = 1'b1;  

  end
  #0.5 clk = 1'b0;  
  qmem_wr = 0; 
  qkmem_add = 0;
  #0.5 clk = 1'b1; 

  $display("-------------------- LUT Writing --------------------");
  #0.5 clk = 1'b0;  qmem_rd=1; qkmem_add = 1; in = lut_data[bw*softmax_col*2-1:bw*softmax_col*1];
  #0.5 clk = 1'b1; 
  #(period) clk = 1'b0; lut_wr = 1;   // LSB LUT writing
  $display("LSB LUT contents: %32h", lut_data[bw*softmax_col*2-1:bw*softmax_col*1]);
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; lut_wr = 0; 
  #(period) clk = 1'b1;  

 for (i=0; i<8; i=i+1) begin
  #(period) clk = 1'b0;
  #(period) clk = 1'b1;
 end  


  #(period) clk = 1'b0;
  #(period) clk = 1'b1;
  #(period) clk = 1'b0; qkmem_add = 0 ; in = lut_data[bw*softmax_col*1-1:bw*softmax_col*0];
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; lut_wr = 1;   // LSB LUT writing part2
  $display("LSB LUT contents: %32h", lut_data[bw*softmax_col*1-1:bw*softmax_col*0]);
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; lut_wr = 0; 
  #(period) clk = 1'b1;  

 for (i=0; i<8; i=i+1) begin
  #(period) clk = 1'b0;
  #(period) clk = 1'b1;
 end  


  #(period) clk = 1'b0;
  #(period) clk = 1'b1;
  #(period) clk = 1'b0; qkmem_add = 3 ; in = lut_data[bw*softmax_col*4-1:bw*softmax_col*3];
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; lut_wr = 2;   // MSB LUT writing
  $display("MSB LUT contents: %32h", lut_data[bw*softmax_col*4-1:bw*softmax_col*3]);
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; lut_wr = 0; 
  #(period) clk = 1'b1;  

 for (i=0; i<8; i=i+1) begin
  #(period) clk = 1'b0;
  #(period) clk = 1'b1;
 end  

  #(period) clk = 1'b0;
  #(period) clk = 1'b1;
  #(period) clk = 1'b0; qkmem_add = 2; in = lut_data[bw*softmax_col*3-1:bw*softmax_col*2];
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; lut_wr = 2;   // MSB LUT writing part2
  $display("MSB LUT contents: %32h", lut_data[bw*softmax_col*3-1:bw*softmax_col*2]);
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; lut_wr = 0; 
  #(period) clk = 1'b1;  

 for (i=0; i<8; i=i+1) begin
  #(period) clk = 1'b0;
  #(period) clk = 1'b1;
 end  

  #(period) clk = 1'b0;
  #(period) clk = 1'b1;
  #(period) clk = 1'b0; qkmem_add =0 ; qmem_rd =0;
  #(period) clk = 1'b1;

  $display("-------------------- Computation start --------------------");

    $display("-------------------- Mem Writing --------------------");
 for (q=0; q<8; q=q+1) begin
    #0.5 clk = 1'b0;  
    qmem_wr = 1;  if (q>0) qkmem_add = qkmem_add + 1; 
    mem_in[63:0]   = in_total[bw*softmax_col*q +: 64];
    mem_in[127:64]   = 'b0;
    #0.5 clk = 1'b1;  

  end
  #0.5 clk = 1'b0;  
  qmem_wr = 0; 
  qkmem_add = 0;
  #0.5 clk = 1'b1; 


 if (mode==1) begin
  #(period) clk = 1'b0; execute = 1; 
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; execute = 0; 
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; in = in_total[bw*softmax_col*1-1:bw*softmax_col*0];
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; in = in_total[bw*softmax_col*2-1:bw*softmax_col*1];
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; in = in_total[bw*softmax_col*3-1:bw*softmax_col*2];
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; in = in_total[bw*softmax_col*4-1:bw*softmax_col*3];
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; in = in_total[bw*softmax_col*5-1:bw*softmax_col*4];
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; in = in_total[bw*softmax_col*6-1:bw*softmax_col*5];
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; in = in_total[bw*softmax_col*7-1:bw*softmax_col*6];
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; in = in_total[bw*softmax_col*8-1:bw*softmax_col*7];
  #(period) clk = 1'b1;
 for (i=0; i<20; i=i+1) begin
  #(period) clk = 1'b0; 
  #(period) clk = 1'b1;
 end
  #(period) clk = 1'b0; fetch = 1; 
  #(period) clk = 1'b1;  
 k=0;
 for (i=0; i<40; i=i+1) begin
  #(period) clk = 1'b0;
  if (softmax_instance.cnt_q == 3'd4) begin
    if (out==predict_out[64*k +: 64]) $display("Successful! out match to prediction %16h",out);
    else $display("Error! Expect %32h but we have %16h",predict_out[64*k +: 64], out);
    k=k+1;
  end
  #(period) clk = 1'b1;
 end
end
else begin
  #(period) clk = 1'b0; in = in_total[bw*softmax_col*1-1:bw*softmax_col*0];
  #(period) clk = 1'b1;
  #(period) clk = 1'b0; execute = 1; 
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; 
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; 
  #(period) clk = 1'b1;

  #(period) clk = 1'b0;  qmem_rd =1;
  #(period) clk = 1'b1;

 for (i=0; i<20; i=i+1) begin
  #(period) clk = 1'b0; 
  if (softmax_instance.cycle == 4'd4)  $display("out %16h",softmax_instance.out);
  if (softmax_instance.cycle == 4'd4)  $display("predict_out %16h",predict_out[63:0] );

  #(period) clk = 1'b1;
 end
end
// for (i=0; i<2; i=i+1) begin
//  #(period) clk = 1'b0; fetch = 1; 
//  #(period) clk = 1'b1; 
//  #(period) clk = 1'b0; fetch = 0;
//  #(period) clk = 1'b1;
//  #(period) clk = 1'b0; 
//  #(period) clk = 1'b1;
//  #(period) clk = 1'b0; 
//  #(period) clk = 1'b1;
// end 

  #(period) $finish;


end


always @ (posedge clk) begin
   lut_wr_q <= #0.15 lut_wr;
   execute_q <= #0.15 execute;
   ofifo_rd_q <= #0.15 ofifo_rd;
   lut_wr_q <= #0.15 lut_wr;
   in_q <= #0.15 in;
end

endmodule




