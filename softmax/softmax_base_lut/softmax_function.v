function [511:0] get_softmax_predict ; 
  input [bw*softmax_col*4-1:0] lut_data;
  input [bw*softmax_col*128-1:0] in_total;
  input mode;
  integer max;
  integer idx_msb_now;
  integer idx_lsb_now;
  integer idx[63:0];
  reg [2*bw*64-1:0] prod;
  reg [bw-1+6:0] sum ; 
  reg [bw*64-1:0] exp_msb;
  reg [bw*64-1:0] exp_lsb ;

  begin
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
	     get_softmax_predict[bw*i +: 8] = {prod[(2*bw)*(i+1)-1 -: 8], 8'b00000000}/sum;   
	  end 
  end
  else begin
	  //for (i=0; i<64; i=i+1) begin
	   // sum = sum + prod[(2*bw)*(i+1)-1 -: 8];
	  //end
		
	  for (i=0; i<8; i=i+1) begin
	    sum = sum + prod[(2*bw)*(i+1)-1 -: 8];
	  end

	  for (i=0; i<8; i=i+1) begin
	     get_softmax_predict[bw*i +: 8] = {prod[(2*bw)*(i+1)-1 -: 8], 8'b00000000}/sum;   
	  end 

  end
  end
endfunction

/*

task softmax_output_check ;
input [bw*softmax_col*8-1:0] lut_data;
 input [bw*softmax_col*128-1:0] in_total;
input mode;
input integer offset;
reg [bw*8*8-1:0] softmax_predict_out;
reg [63:0] mem_data_monitor;
begin
	k=0;
	softmax_predict_out=get_softmax_predict(lut_data,in_total[bw*softmax_col*offset +: bw*softmax_col*8],mode);//for GSA
 	t=offset;
 	for (q=0; q<8; q=q+1) begin
		//$display("TESt! Expect %d",t);

    		delay_cycle(1);	
		mem_data_monitor=fullchip_instance.core_instance.core_pmem_out[127:0];
		if (mode==0) begin
  			softmax_predict_out=get_softmax_predict(lut_data,in_total[64*k +: 64],mode);
			k=k+1;
			t=t+1;
    			if (mem_data_monitor==softmax_predict_out[63:0]) $display("Successful! out match to prediction %16h", mem_data_monitor);
    			else $display("Error! Expect %32h but we have %16h",softmax_predict_out[63:0], mem_data_monitor);
		end 
		else begin
			//$display("TESt! Expect %128h",in_total);
    			if (mem_data_monitor==softmax_predict_out[64*k +: 64]) $display("Successful! out match to prediction %16h", mem_data_monitor);
    			else $display("Error! Expect %32h but we have %16h",softmax_predict_out[64*k +: 64], mem_data_monitor);
			k=k+1;
			t=t+1;
		end

 	end
end
endtask
*/

task delay_cycle (input integer d_cycle);
begin
 for (i=0; i<d_cycle; i=i+1) begin
  #(0.5) clk = 1'b0;
  #(0.5) clk = 1'b1;
 end  
end
endtask

task sys_reset;
begin
  #(0.5) clk = 1'b0;
  reset = 1;
  #(0.5) clk = 1'b1;  
  #(0.5) clk = 1'b0;
  reset = 0;
  #(0.5) clk = 1'b1;  
end
endtask
