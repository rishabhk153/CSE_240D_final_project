module tanh_using_sigmoid (
    input clk,
    input reset,
    input signed [7:0] x_in,      // Q3.5 input
    output reg signed [7:0] y_out    // Q0.7 output
);
    wire signed [7:0] scaled_input;  // Q3.5 scaled input
    wire signed [7:0] sigmoid_out;  // Q0.8 output of sigmoid
    wire signed [8:0] scaled_sigmoid; // Q1.8 intermediate scaling
    wire signed [7:0] tanh_temp;     // Q0.8 temporary result

    wire signed [7:0] y_s;

    // Scale input (x_in * 2)
    assign scaled_input = x_in <<< 1; // Multiply by 2, maintain Q3.5

    // Pass scaled_input to sigmoid
    sigmoid_piecewise u1 (
        .x_in(scaled_input),
        .clk(clk),
        .reset(reset), 
        .y_out(sigmoid_out)
    );

    // Scale sigmoid output (sigmoid_out * 2) -> Q1.8
    assign scaled_sigmoid = {sigmoid_out, 1'b0}; // Multiply by 2 (Q0.8 to Q1.8)

    // Subtract 1 to shift the range [-1, 1]
    assign tanh_temp = scaled_sigmoid[8:1] - 8'd128; // Convert to Q0.7 and subtract 1

    // Assign final result
    assign y_s = tanh_temp;
    
    

    //register the output
    always @(*) begin
      if(x_in <= -64) begin
        y_out = -8'd128;
      end else if(x_in >= 64) begin
        y_out = 8'd127;
      end
      else begin
        y_out = y_s;
      end
    end 

endmodule
