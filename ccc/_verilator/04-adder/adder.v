module adder(
    input wire clk,
    input wire reset,
    input wire [3:0] a,
    input wire [3:0] b,
    output reg [4:0] sum
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            sum <= 0;
        else
            sum <= a + b;
    end
endmodule
