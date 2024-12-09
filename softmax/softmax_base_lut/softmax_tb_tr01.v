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
reg [1:0] mode = 1;
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
reg   [col-1:0] pmem_rd=0;
reg   [col-1:0] pmem_wr=0;
reg   [col*6-1:0] pmem_add=0;
//reg ofifo_rd = 0;
wire [11+8*col:0] inst; 
reg qmem_rd = 0;
reg qmem_wr = 0; 
reg [5:0] qkmem_add = 0;
wire [10:0] add_inst;

wire [bw_psum*col-1:0] out;
reg [5:0] tmp_addr_ctrl;
//add_inst
assign add_inst[1:0] = mode;
assign add_inst[3:2] = lut_wr;
assign add_inst[4] = execute;
assign add_inst[5] = fetch;

assign inst[3] = qmem_rd;
assign inst[2] = qmem_wr;
assign inst[11:6] = qkmem_add;

assign inst[11+col : 12] = pmem_rd;
assign inst[11+2*col: 12+col] = pmem_wr;
assign inst[11+8*col:12+2*col] = pmem_add;
//LUT data
//reg [bw*col*4-1:0] lut_data = 256'hCE8ae5ac459dc987ad25d525c73def4a7f61db6c5a1c8c39ca76c90eb3ea80c2;
reg [bw*softmax_col*4-1:0] lut_data = 256'hCE8ae5ac459dc987ad25d525c73def4a7f61db6c5a1c8c39ca76c90eb3ea80c2;

reg [bw*softmax_col*8-1:0] in_total = 511'h000000000000000000000000000000001E6b3cf64ba1d4337739903f8e183528bae1c16c21c02c1198ad34fdd5468b0158ec675b1b057f26eb81376956fa0642;

integer  i,k,p,q,u, lut_file, lut_file_hd, in_file, in_file_hd, bin2dec_sum, captured_data;


integer  lut_msb[15:0];
integer  lut_lsb[15:0];
integer  in_data[47:0];

reg [bw*48-1:0] expected_out = 0 ;

reg [bw*8*8-1:0] predict_out;
reg [63:0] mem_data_monitor;

integer w_file ; // file handler
integer w_scan_file ; // file handler
`include "softmax_function.v"

 fullchip #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) fullchip_instance (
      .reset(reset),
      .clk(clk), 
      .mem_in(mem_in),
      .weight_in(weight_in),
      .out(out), 
      .add_inst(add_inst), 
      .inst(inst)
);

//initial $sdf_annotate("softmax.pnr_fast.sdf", softmax_instance, , ,"MAXIMUM","1:1:1","FROM_MTM");



task softmax_input_mem_wr (input [bw*softmax_col*8-1:0] lut_data, input integer wr_cycle);
begin
 for (q=0; q<wr_cycle; q=q+1) begin
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
end
endtask

task softmax_output_check (input [bw*softmax_col*8-1:0] lut_data, input [bw*softmax_col*8-1:0] in_total,input mode);
begin
  	k=0;

 	for (q=0; q<8; q=q+1) begin
		mem_data_monitor=get_softmax_psum_rslt(q);
		if (mode==0) begin
  			predict_out=get_softmax_predict(lut_data,in_total[64*k +: 64]);
			k=k+1;
    			if (mem_data_monitor==predict_out[63:0]) $display("Successful! out match to prediction %16h", mem_data_monitor);
    			else $display("Error! Expect %32h but we have %16h",predict_out[63:0], mem_data_monitor);
		end 
		else begin
  			predict_out=get_softmax_predict(lut_data,in_total);
    			if (mem_data_monitor==predict_out[64*k +: 64]) $display("Successful! out match to prediction %16h", mem_data_monitor);
    			else $display("Error! Expect %32h but we have %16h",predict_out[64*k +: 64], mem_data_monitor);
			k=k+1;
		end

 	end
end
endtask
  task lut_write;
  begin
  #0.5 clk = 1'b0;  qmem_rd=1; qkmem_add = 1;
  #0.5 clk = 1'b1; 
  #(period) clk = 1'b0; lut_wr = 1;   // LSB LUT writing
  $display("LSB LUT contents: %32h", lut_data[bw*softmax_col*2-1:bw*softmax_col*1]);
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; lut_wr = 0; 
  #(period) clk = 1'b1;  
  delay_cycle(8);

  #(period) clk = 1'b0; qkmem_add = 0 ;
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; lut_wr = 1;   // LSB LUT writing part2
  $display("LSB LUT contents: %32h", lut_data[bw*softmax_col*1-1:bw*softmax_col*0]);
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; lut_wr = 0; 
  #(period) clk = 1'b1;  
  delay_cycle(8);

  #(period) clk = 1'b0; qkmem_add = 3 ;
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; lut_wr = 2;   // MSB LUT writing
  $display("MSB LUT contents: %32h", lut_data[bw*softmax_col*4-1:bw*softmax_col*3]);
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; lut_wr = 0; 
  #(period) clk = 1'b1;  

 delay_cycle(8);

  #(period) clk = 1'b0; qkmem_add = 2;
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; lut_wr = 2;   // MSB LUT writing part2
  $display("MSB LUT contents: %32h", lut_data[bw*softmax_col*3-1:bw*softmax_col*2]);
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; lut_wr = 0; 
  #(period) clk = 1'b1;  

  delay_cycle(8);


  #(period) clk = 1'b0; qkmem_add =0 ; qmem_rd =0;
  #(period) clk = 1'b1;
end
endtask

initial begin 

  $dumpfile("softmax_tb.vcd");
  $dumpvars(0,softmax_tb);

  //w_file = $fopen("period.txt", "r");  //weight data
  //w_scan_file = $fscanf(w_file, "%f\n", period);
  period = 0.5;
  //get softmax predicted output
  //predict_out=get_softmax_predict(lut_data,in_total);

 delay_cycle(16);
 sys_reset;
  if (mode==0) $display("-------------------- Current mode: LSA 8 input --------------------");
  else $display("-------------------- Current mode: GSA 8x8 input --------------------");

  $display("-------------------- LUT Mem Writing --------------------");
  softmax_input_mem_wr(lut_data,4);

  $display("-------------------- LUT Writing --------------------");
  lut_write;

  $display("-------------------- Input Mem Writing --------------------");
  softmax_input_mem_wr(in_total,8);

  $display("-------------------- Computation start --------------------");

 if (mode==1) begin
  #(period) clk = 1'b0; execute = 1; 
  #(period) clk = 1'b1;

  #(period) clk = 1'b0; execute = 0;
  #(period) clk = 1'b1;

  delay_cycle(30);

  #(period) clk = 1'b0; fetch = 1; 
  #(period) clk = 1'b1;  

  delay_cycle(40);

  #(period) clk = 1'b0; fetch  = 0;
  #(period) clk = 1'b1;

   //Check if softmax result in psum mem match to predicted   
   softmax_output_check(lut_data,in_total,mode);
end
///// mode = 0
else begin
  #(period) clk = 1'b0; execute = 1;
  #(period) clk = 1'b1;

 for (q=0; q<40; q=q+1) begin
  #(period) clk = 1'b0; 
  #(period) clk = 1'b1;
 end

  #(period) clk = 1'b0;  execute = 0;
  #(period) clk = 1'b1;

   //Check if softmax result in psum mem match to predicted   
   softmax_output_check(lut_data,in_total,mode);

end

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




