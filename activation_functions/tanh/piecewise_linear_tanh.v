module tanh_piecewise (
    input clk,
    input reset,
    input signed [7:0] x_in,  // Q3.5 input (-4 to 4)
    output reg signed [7:0] y_out // Q0.7 output (-128 to 127)
);

    // Constants for the piecewise linear approximation (using shifts and adds)
    
    // For the range -3 to -2
    localparam signed [7:0] SHIFT_1 = 4;   
    localparam signed [7:0] OFFSET_1 = -8'd128;

    // For the range -2 to -1
    localparam signed [7:0] SHIFT_2 = 0;    
    localparam signed [7:0] OFFSET_2 = -8'd123;  

    // For the range -1 to 1
    localparam signed [7:0] SHIFT_3 = 1;    
    localparam signed [7:0] OFFSET_3 = -8'd97;  
 

    // For the range 1 to 2
    localparam signed [7:0] SHIFT_4 = 0;    
    localparam signed [7:0] OFFSET_4 = 8'd97;
   
    // For the range 2 to 3
    localparam signed [7:0] SHIFT_5 = 4;    
    localparam signed [7:0] OFFSET_5 = 8'd123;  
 
    localparam signed [7:0] OFFSET_6 = 8'd127; 

    always @(posedge clk or posedge reset) begin
        if (~reset) begin
            y_out <= 8'd0;  // Reset to 0
        end else begin
            // Piecewise function for tanh approximation
            if (x_in <= -96) begin
                y_out <= OFFSET_1; 
            end else if (x_in < -64) begin
                y_out <= ((x_in + 128) >>> SHIFT_1) + OFFSET_1; // Use shift to approximate slope
            end else if (x_in < -32) begin
                y_out <= ((x_in + 64) >>> SHIFT_2) + OFFSET_2; // Use shift to approximate slope
            end else if (x_in < 0) begin
                y_out <= ((x_in + 32) <<< SHIFT_3) + ((x_in + 32) >>> SHIFT_3) + OFFSET_3; // Use shift to approximate slope
            end else if (x_in < 32) begin
                y_out <= ((x_in) <<< SHIFT_3) + ((x_in + 32) >>> SHIFT_3); // Use shift to approximate slope
            end else if (x_in < 64) begin
                y_out <= ((x_in - 32) >>> SHIFT_4) + OFFSET_4; // Use shift to approximate slope
            end else if (x_in < 96) begin
                y_out <= ((x_in - 64) >>> SHIFT_5) + OFFSET_5; // Use shift to approximate slope
            end else begin
                y_out <= OFFSET_6;  // Default to 1 if x > 3
            end
        end
    end
endmodule

