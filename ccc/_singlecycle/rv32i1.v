module riscv_single_cycle (
    input clk,
    input rst,
    output [31:0] pc_out
);

    // 註冊
    reg [31:0] pc;                // 程式計數器
    reg [31:0] instruction;       // 指令寄存器
    reg [31:0] regfile [0:31];    // 寄存器檔
    reg [31:0] data_memory [0:255]; // 簡單的數據記憶體

    // 指令解碼信號
    wire [6:0] opcode;            // 操作碼
    wire [4:0] rs1, rs2, rd;      // 源和目標寄存器
    wire [31:0] op1, op2, result; // 操作數和結果
    wire [31:0] imm;              // 立即數
    wire [3:0] funct;             // 功能碼

    // 初始化
    initial begin
        pc = 32'b0;
        regfile[0] = 32'b0; // x0 = 0
        // 初始化數據記憶體
        data_memory[0] = 32'h0000000A; // 示例數據
        data_memory[1] = 32'h00000014; // 示例數據
    end

    // 指令獲取
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'b0; // 重置程式計數器
        end else begin
            instruction <= data_memory[pc[7:2]]; // 從數據記憶體獲取指令
            pc <= pc + 4; // 更新 pc
        end
    end

    // 指令解碼
    assign opcode = instruction[6:0];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd = instruction[11:7];
    assign imm = {{20{instruction[31]}}, instruction[31:20]}; // 立即數
    assign funct = instruction[14:12]; // 功能碼

    // 操作數獲取
    assign op1 = regfile[rs1];
    assign op2 = (opcode == 7'b0010011) ? imm : regfile[rs2]; // 如果是立即數操作，則使用立即數

    // 執行
    always @(posedge clk) begin
        case (opcode)
            7'b0110011: begin // R-type 指令
                case (funct)
                    3'b000: regfile[rd] <= op1 + op2; // ADD
                    3'b100: regfile[rd] <= op1 - op2; // SUB
                    // 可擴展其他 R-type 指令
                endcase
            end
            7'b0010011: begin // I-type 指令（立即數指令）
                case (funct)
                    3'b000: regfile[rd] <= op1 + imm; // ADDI
                    // 可擴展其他 I-type 指令
                endcase
            end
            7'b0000011: begin // L-type 指令（載入）
                case (funct)
                    3'b010: regfile[rd] <= data_memory[op1 + imm[9:0]]; // LW
                    // 可擴展其他 L-type 指令
                endcase
            end
            7'b0100011: begin // S-type 指令（儲存）
                case (funct)
                    3'b010: data_memory[op1 + imm[9:0]] <= op2; // SW
                    // 可擴展其他 S-type 指令
                endcase
            end
            // 可擴展其他類型的指令
        endcase
    end

    // 輸出程式計數器的值
    assign pc_out = pc;

endmodule
