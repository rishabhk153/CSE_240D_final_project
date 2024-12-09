`timescale 1ns/1ps

module softmax (clk, out, in, lut_wr, execute, fetch, reset, mode);

parameter bw  = 8;
parameter col = 8;

input mode;
input  [col*bw-1:0] in;
input  clk;
input  execute;
input  [1:0] lut_wr;
input  reset, fetch;
output [col*bw-1:0] out;
reg [col*bw-1:0] out_q;
reg execute_q;

reg [4:0] cycle;
reg [4:0] lut_wr_cnt;
wire [bw-1+3:0] sum0;
wire [bw-1+3:0] sum1;
reg [bw-1+3:0] sum0_q;
reg [bw-1+3:0] sum1_q;
reg [bw-1+6:0] sum_q;
reg [col*bw-1:0] in_q;
reg [1:0] lut_wr_q;
reg [1:0] lut_wr_en_q;

reg [bw-1:0] lut_in_q;
wire [col*bw-1:0] out_temp;
wire [col*bw-1:0] out_msb;
wire [col*bw-1:0] out_lsb;
reg  [col*bw-1:0] out_msb_q;
reg  [col*bw-1:0] out_lsb_q;
wire [col*(bw+1)-1:0] in_neg;
reg  [col*(bw+1)-1:0] in_neg_q;
wire [col*bw-1:0] prod_fifo_out;
wire [col*(2*bw)-1:0] prod;
reg  [col*(2*bw)-1:0] prod_q;
reg  [2:0] cnt_q;
reg   prod_fifo_wr, fifo_next;
reg div_start;

genvar i;
for (i=0; i < col ; i=i+1) begin : col_num 

   fifo_depth8 #(.bw(bw)) prod_fifo_instance (
         .rd_clk(clk), 
         .wr_clk(clk), 
         .in(prod_q[2*bw*(i+1)-1 : 2*bw*(i+1)-bw]), 
         .out(prod_fifo_out[bw*(i+1)-1 : bw*i]), 
         .rd(fifo_next), 
         .wr(prod_fifo_wr),  
         .reset(reset)
   );

   exp_lut #(.DATA_IDX(bw/2),.DATA_WIDTH(bw),.DATA_DEPTH(16)) exp_lut_msb (
        .clk(clk),
        .wr(lut_wr_q[1]),
        .out(out_msb[(i+1)*bw - 1 : i*bw]),
        .in(in_q[(i+1)*bw-1 : i*bw + bw/2]),
        .lut_in(lut_in_q[bw-1:0]), 
        .reset(reset)
   ); 

   exp_lut #(.DATA_IDX(bw/2),.DATA_WIDTH(bw),.DATA_DEPTH(16)) exp_lut_lsb (
        .clk(clk),
        .wr(lut_wr_q[0]),
        .out(out_lsb[(i+1)*bw - 1 :  i*bw]),
        .in(in_q[i*bw + bw/2 - 1: i*bw]),
        .lut_in(lut_in_q[bw-1:0]), 
        .reset(reset)
   ); 

   assign  prod[(i+1)*2*bw-1 : i*2*bw] = out_msb[(i+1)*bw-1 : i*bw] * out_lsb[(i+1)*bw-1 : i*bw];
   assign  #4 out_temp[bw*(i+1)-1 : bw*i] = mode ? {prod_fifo_out[bw*(i+1)-1 : bw*i], 8'b0}/sum_q[bw+4:0] : {prod_q[2*bw*(i+1)-1 : 2*bw*(i+1)-bw], 8'b0}/sum_q[bw+4:0] ;       
   assign out = out_q;
end

assign  sum0  = prod_q[2*bw*1-1  : 2*bw*1-bw]  + prod_q[2*bw*2-1  : 2*bw*2-bw]  + prod_q[2*bw*3-1 : 2*bw*3-bw]   + prod_q[2*bw*4-1  : 2*bw*4-bw] 
 		+ prod_q[2*bw*5-1  : 2*bw*5-bw]  + prod_q[2*bw*6-1  : 2*bw*6-bw]  + prod_q[2*bw*7-1 : 2*bw*7-bw]   + prod_q[2*bw*8-1  : 2*bw*8-bw] ;



always @ (posedge clk) begin
      if (reset) begin
        sum_q <= 0;
        cycle <= 0;
	lut_wr_cnt <= 0;
        prod_fifo_wr <= 0;
        execute_q <= 0;
        lut_wr_q <= 0;
        lut_wr_en_q <= 0;
        cnt_q <= 0;
        fifo_next <= 0;
	div_start <= 0;
      end
      else begin


// LUT write
        if (lut_wr_cnt == 0  && (lut_wr[0] || lut_wr[1]))  begin
           in_q <= in ;
           if (lut_wr[0])
              lut_wr_en_q[0] <= 1;
           if (lut_wr[1])
              lut_wr_en_q[1] <= 1;
        end
        else if (lut_wr_en_q[0] || lut_wr_en_q[1]) begin
          lut_wr_cnt <= lut_wr_cnt + 1;
          case (lut_wr_cnt)
            0:  begin lut_in_q <= in_q[bw* 8-1:bw* 7];  lut_wr_q <= lut_wr_en_q; end
            1:  lut_in_q <= in_q[bw* 7-1:bw* 6];
            2:  lut_in_q <= in_q[bw* 6-1:bw* 5];
            3:  lut_in_q <= in_q[bw* 5-1:bw* 4];
            4:  lut_in_q <= in_q[bw* 4-1:bw* 3];
            5:  lut_in_q <= in_q[bw* 3-1:bw* 2];
            6:  lut_in_q <= in_q[bw* 2-1:bw* 1];
            7:  lut_in_q <= in_q[bw* 1-1:bw* 0];
//            8:  lut_in_q <= in_q[bw* 8-1:bw* 7];
//            9:  lut_in_q <= in_q[bw* 7-1:bw* 6];
//            10: lut_in_q <= in_q[bw* 6-1:bw* 5];
//            11: lut_in_q <= in_q[bw* 5-1:bw* 4];
//            12: lut_in_q <= in_q[bw* 4-1:bw* 3];
//            13: lut_in_q <= in_q[bw* 3-1:bw* 2];
//            14: lut_in_q <= in_q[bw* 2-1:bw* 1];
//            15: lut_in_q <= in_q[bw* 1-1:bw* 0];
            8: begin lut_wr_cnt <= 0; lut_wr_q <= 0; lut_wr_en_q <= 0; end
          endcase
        end


 	// 8 input softmax mode
	if (mode == 0) begin
        	if (execute) begin
			if (cycle == 1) begin
				in_q <= in;
			end
			if (cycle == 2) begin
				prod_q <= prod;
			end

			if (cycle == 3) begin
				sum_q <= sum0;
             			div_start <= 1;
			end
			if (cycle == 4) begin
				cycle <= 0;
			end
			else begin
           			cycle <= cycle + 1;
			end
		end
		else begin
			div_start <= 0;
		end


	       if (div_start)  begin
			if (cnt_q == 4) begin
				cnt_q <= 0;
				out_q <= out_temp;
			end
			else begin
				cnt_q <= cnt_q+1;
			end
		end 
		else begin
			cnt_q <=0;
		end

	end
	// 8x8 input softmax mode
	else begin

        	if ((cycle == 0) && execute)
          		execute_q <= 1;

        	else if (execute_q) begin
          		if ((cycle >= 1) && (cycle < 9)) begin
             			in_q <= in;
           		end
          		if ((cycle >= 2) && (cycle < 10)) begin
             			prod_q <= prod;
           		end
			if (cycle == 2) begin
                		prod_fifo_wr <= 1;
				sum_q <= 0;
			end
				
          		if ((cycle >= 3) && (cycle < 11)) begin
             			sum0_q <= sum0;
           		end
          		if ((cycle >= 4) && (cycle < 12)) begin
             			sum_q <= sum_q + sum0_q;
           		end
          	 	if (cycle == 10) prod_fifo_wr <= 0;

          	 	if (cycle == 12) begin
             			execute_q <= 0;
             			cycle <= 0;
			end 
			else begin
           			cycle <= cycle + 1;
			end
		end

		if (fetch)  begin
			if (cnt_q == 4) begin
				cnt_q <= 0;
				fifo_next <= 0;
			end
			else begin
				cnt_q <= cnt_q+1;
				if (cnt_q == 3) begin
					out_q <= out_temp;
					fifo_next <= 1;
				end
			end
		end 
		else begin
			cnt_q <= 0;
		end
	end




   end
end
endmodule
