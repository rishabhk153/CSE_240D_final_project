module ParametricReLU #(parameter WIDTH = 8, ALPHA_WIDTH = 8) (
    input signed [WIDTH-1:0] x_in,              // Input value Q3.5
    input [ALPHA_WIDTH-1:0] alpha,             // Alpha parameter Q0.8 (unsigned)
    input clk,                                 // Clock signal
    input reset,                               // Reset signal
    output reg signed [WIDTH-1:0] y_out        // Output value Q3.5
);


    always @(posedge clk or posedge reset) begin
        if (~reset) begin
            y_out <= 0;  // Reset output
        end else begin
            if (x_in >= 0) begin
                y_out <= x_in;  // Pass through positive input
            end else begin
                y_out <= x_in>>>alpha;//multiplu based on alpha value
            end
        end
    end
endmodule

