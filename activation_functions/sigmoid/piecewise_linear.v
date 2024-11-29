module sigmoid_piecewise (
    input clk,
    input reset,
    input signed [7:0] x_in,  // Q3.5 input (-4 to 4)
    output reg [7:0] y_out    // Q0.8 output (0 to 1)
);

    // Precomputed constants (Q0.8 format for slopes and offsets)
    // Now the slopes are scaled as powers of 2 to avoid multiplication
    // Each slope is represented as shift constants

    // Slope for -4 to -2 (a = 0.03125 -> shift by 5)
    localparam signed [7:0] SHIFT_1 = 2;    // 2^2 for slope = 0.25
    localparam signed [7:0] OFFSET_1 = 8'd5;  // Offset for -4 to -2 (b = 0.0 -> Q0.8 = 5)

    // Slope for -2 to -1 (a = 0.125 -> shift by 3)
    localparam signed [7:0] SHIFT_2 = 1;    // 2^1 for slope = 0.5
    localparam signed [7:0] OFFSET_2 = 8'd32;  // Offset for -2 to -1 (b = 0.125 -> Q0.8 = 32)

    // Slope for -1 to 1 (a = 0.25 -> shift by 2)
    localparam signed [7:0] SHIFT_3 = 1;    // 2^1 for slope = 2
    localparam signed [7:0] OFFSET_3 = 8'd69;  // Offset for -1 to 1 (b = 0.375 -> Q0.8 = 96)

    // Slope for 1 to 2 (a = 0.125 -> shift by 3)
    localparam signed [7:0] SHIFT_4 = 1;    // 2^1 for slope = 0.5
    localparam signed [7:0] OFFSET_4 = 8'd187; // Offset for 1 to 2 (b = 0.625 -> Q0.8 = 160)

    // Slope for 2 to 4 (a = 0.03125 -> shift by 5)
    localparam signed [7:0] SHIFT_5 = 2;    // 2^2 for slope = 0.125
    localparam signed [7:0] OFFSET_5 = 8'd225; // Offset for 2 to 4 (b = 0.75 -> Q0.8 = 192)
   
    reg [7:0] y_s;

    //registering output
    always @(posedge clk or negedge reset) begin
      if(~reset) begin
        y_out <= 0;
      end
      else begin
        y_out <= y_s;
      end
    end 

    always @(*) begin
        if (x_in <= -128) begin
            y_s = 8'd0;  // Output saturates to 0 for x <= -4
        end else if (x_in >= 127) begin
            y_s = 8'd255; // Output saturates to 1 for x >= 4
        end else if (x_in < -64) begin  // Segment 1: -4 to -2
            y_s = ((x_in + 128) >>> SHIFT_1) + OFFSET_1;
        end else if (x_in < -32) begin  // Segment 2: -2 to -1
            y_s = ((x_in + 64) >>> SHIFT_2) + OFFSET_2;
        end else if (x_in < 32) begin  // Segment 3: -1 to 1
            y_s = ((x_in + 32) <<< SHIFT_3) + OFFSET_3;
        end else if (x_in < 64) begin  // Segment 4: 1 to 2
            y_s = ((x_in - 32) >>> SHIFT_4) + OFFSET_4;
        end else begin  // Segment 5: 2 to 4
            y_s = ((x_in - 64) >>> SHIFT_5) + OFFSET_5;
        end
    end
endmodule

