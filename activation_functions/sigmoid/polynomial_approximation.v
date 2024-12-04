module sigmoid_poly (
    input clk,
    input reset,
    input signed [7:0] x_in,  // Q3.5 input (-4 to 4)
    output reg [7:0] y_out    // Q0.8 output (0 to 1)
);

    // Internal registers for intermediate calculations
    reg signed [15:0] x_scaled;      // Q3.13 (scaled input)
    reg signed [15:0] x_squared;     // Q6.10 (x^2 intermediate)
    reg signed [15:0] x_cubed;       // Q9.7 (x^3 intermediate)
    reg signed [15:0] poly_result;   // Q0.16 (polynomial result)

    //combinational output
    reg[7:0] y_s;

    always @(*) begin
       // Scale input to Q3.13 (shift left by 8)
       x_scaled = {x_in, 8'b0};

       // Compute x^2 in Q6.10
       x_squared = (x_scaled * x_scaled) >>> 16;

       // Compute x^3 in Q9.7
       x_cubed = (x_squared * x_scaled) >>> 16;

       // Evaluate polynomial in Q0.16
       poly_result = 16'h2000 + (x_scaled >>> 2) - (x_cubed >>> 5);

       // Convert to Q0.8 for output (truncate)
       y_s = poly_result[15:8];
    end

    always @(posedge clk or negedge reset) begin
      if(~reset) begin
        y_out <= 0;
      end
      else begin
        y_out <= y_s;
      end
    end 

endmodule

