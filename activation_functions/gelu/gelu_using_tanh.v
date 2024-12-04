module gelu_using_tanh (
    input clk,
    input reset,
    input signed [7:0] x_in,  // Q3.5 input (-4 to 4)
    output reg signed [7:0] y_out // Q3.5 output (-4 to 4)
);

    // Parameters for fixed-point scaling in Q3.5
    localparam signed [7:0] SQRT_2_PI = 8'd25;   // ? sqrt(2/pi) scaled to Q3.5
    localparam signed [7:0] COEFF = 8'd1;        // ? 0.044715 scaled to Q3.5

    wire signed [7:0] x_cube;       // x^3 in Q3.5
    wire signed [7:0] tanh_input;   // Input to the tanh block in Q3.5
    wire signed [7:0] tanh_output;  // Output from the tanh block in Q0.7
    reg signed [7:0] scaled_tanh;   // tanh_output scaled to Q3.5
    reg signed [7:0] result;        // GELU result (intermediate calculation)

    // Instantiate tanh block
    tanh_using_sigmoid tanh_inst (
        .clk(clk),
        .reset(reset),
        .x_in(tanh_input),
        .y_out(tanh_output)
    );

    // Compute x^3
    assign x_cube = (x_in * x_in * x_in) >>> 5; // Q3.5 * Q3.5 * Q3.5 -> Q3.5

    // Compute input to tanh: SQRT_2_PI * (x + COEFF * x^3)
    assign tanh_input = (SQRT_2_PI * (x_in + ((COEFF * x_cube) >>> 5))) >>> 5; // Q3.5 -> Q3.5

    // Scale tanh_output (Q0.7) to Q3.5
    always @(*) begin
        scaled_tanh = tanh_output >>> 2; // Convert Q0.7 to Q3.5 (shift left by 2 bits)
    end

    // Compute GELU: 0.5 * x * (1 + scaled_tanh)
    always @(*) begin
            result <= (x_in * (32 + scaled_tanh)) >>> 5; // Q3.5 * Q3.5 -> Q3.5
            y_out <= result >>> 1; // Divide by 2
    end

endmodule

