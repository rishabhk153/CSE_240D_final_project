module gelu_piecewise (
    input clk,
    input reset,
    input signed [7:0] x_in,  // Q3.5 input (-4 to 4)
    output reg signed [7:0] y_out // Q0.7 output (-128 to 127)
);

    // Constants for the piecewise linear approximation (using shifts and adds)
    //for range -2.5 to -0.5 
    localparam signed [7:0] SHIFT_1 = 4;   
    localparam signed [7:0] OFFSET_1 = -8'd1;

    localparam signed [7:0] SHIFT_2 = 2;    
    localparam signed [7:0] OFFSET_2 = -8'd5;  

    always @(posedge clk or posedge reset) begin
        if (~reset) begin
            y_out <= 8'd0;  // Reset to 0
        end else begin
            // Piecewise function for tanh approximation
            if (x_in <= -80) begin //x<-2.5
                y_out <= 0; 
            end else if (x_in < -16) begin //x< -0.5
                y_out <= OFFSET_1 - ((x_in + 80) >>> SHIFT_1); // Use shift to approximate slope
            end else if (x_in < 0) begin
                y_out <= ((x_in + 16) >>> SHIFT_2) + OFFSET_2; // Use shift to approximate slope
            end else begin
                y_out <= x_in;  // x>0
            end
        end
    end
endmodule

