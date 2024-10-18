module fetch #(
    parameter RESET_VECTOR = 32'h8000_0000
) (
    input clk,
    input reset,

    // from memory
    input branch,
    input [31:0] branch_vector,
    
    // from writeback
    input trap,
    input mret,

    // from csr
    input [31:0] trap_vector,
    input [31:0] mret_vector,

    // from hazard
    input stall,
    input invalidate,
    
    // to busio
    output [31:0] fetch_address,
    // from busio
    input [31:0] fetch_data,

    // to decode
    output reg [31:0] pc_out,
    output reg [31:0] next_pc_out,
    output reg [31:0] instruction_out,
    output reg valid_out
);

reg [31:0] pc = RESET_VECTOR;

assign fetch_address = pc;
wire [31:0] next_pc = pc + 4;

always @(posedge clk) begin
    if (reset) begin
        pc <= RESET_VECTOR;
    end else if (trap) begin
        pc <= trap_vector;
    end else if (mret) begin
        pc <= mret_vector;
    end else if (branch) begin
        pc <= branch_vector;
    end else begin
        pc <= (stall || invalidate) ? pc : next_pc;
    end
end

always @(posedge clk) begin
    valid_out <= (stall ? valid_out : 1) && !invalidate;
    if (!stall) begin
        pc_out <= pc;
        next_pc_out <= next_pc;
        instruction_out <= fetch_data;
    end
end

endmodule
