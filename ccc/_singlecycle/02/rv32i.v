// 數據記憶體模組
module data_memory (
    input clk,
    input [31:0] address,
    input [31:0] write_data,
    input mem_write,
    input mem_read,
    output reg [31:0] read_data
);
    reg [31:0] memory [0:255]; // 256個32位元數據

    always @(posedge clk) begin
        if (mem_write)
            memory[address[7:0]] <= write_data; // 寫入數據
    end

    always @(*) begin
        if (mem_read)
            read_data = memory[address[7:0]]; // 讀取數據
        else
            read_data = 32'b0; // 沒有讀取時輸出0
    end
endmodule

// 指令記憶體模組
module instruction_memory (
    input [31:0] address,
    output wire [31:0] instruction // output reg [31:0] instruction
);
    reg [31:0] memory [0:255]; // 256個32位元指令

    initial begin
        // 載入一些範例指令
        memory[0] = 32'b00000000000000000000000000110011; // ADD x1, x0, x0
        memory[1] = 32'b00000000000000000000000000110111; // ADDI x2, x0, 7
        memory[2] = 32'b00000000000000000000000000110001; // LW x3, 0(x1)
        memory[3] = 32'b00000000000000000000000000100010; // SW x3, 0(x2)
        // 更多指令可以在這裡添加
    end

    assign instruction = memory[address[7:0]]; 
    // always @(*) begin
    //     instruction = memory[address[7:0]]; // 根據地址讀取指令
    // end
endmodule

// 單周期 RISC-V 處理器模組
module riscv_single_cycle (
    input clk,
    input rst,
    output [31:0] pc_out
);
    // 註冊
    reg [31:0] pc;                // 程式計數器
    wire [31:0] instruction; // reg [31:0] instruction;       // 指令寄存器
    reg [31:0] regfile [0:31];    // 寄存器檔
    wire [31:0] data_memory_out;  // 數據記憶體輸出
    wire [31:0] imm;              // 立即數
    wire [4:0] rs1, rs2, rd;      // 源和目標寄存器
    wire [6:0] opcode;            // 操作碼
    wire [3:0] funct;             // 功能碼

    // 初始化
    initial begin
        pc = 32'b0;
        regfile[0] = 32'b0; // x0 = 0
    end

    // 指令記憶體實例
    instruction_memory instr_mem (
        .address(pc),
        .instruction(instruction)
    );

    // 數據記憶體實例
    data_memory data_mem (
        .clk(clk),
        .address(op1 + imm[9:0]), // 使用 op1 和立即數進行地址計算
        .write_data(op2),          // 寫入數據
        .mem_write(mem_write),     // 寫入使能信號
        .mem_read(mem_read),       // 讀取使能信號
        .read_data(data_memory_out) // 讀取數據
    );

    // 指令解碼
    assign opcode = instruction[6:0];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd = instruction[11:7];
    assign imm = {{20{instruction[31]}}, instruction[31:20]}; // 立即數
    assign funct = instruction[14:12]; // 功能碼

    // 操作數獲取
    wire [31:0] op1 = regfile[rs1];
    wire [31:0] op2 = (opcode == 7'b0010011) ? imm : regfile[rs2]; // 如果是立即數操作，則使用立即數

    // 寫入信號
    reg mem_write;
    reg mem_read;

    // 執行階段
    always @(posedge clk) begin
        if (rst) begin
            pc <= 32'b0; // 重置程式計數器
        end else begin
            case (opcode)
                7'b0110011: begin // R-type 指令
                    case (funct)
                        3'b000: regfile[rd] <= op1 + op2; // ADD
                        3'b100: regfile[rd] <= op1 - op2; // SUB
                        // 可擴展其他 R-type 指令
                    endcase
                    mem_write <= 1'b0; // 不寫入數據
                    mem_read <= 1'b0;  // 不讀取數據
                end
                7'b0010011: begin // I-type 指令（立即數指令）
                    case (funct)
                        3'b000: regfile[rd] <= op1 + imm; // ADDI
                        // 可擴展其他 I-type 指令
                    endcase
                    mem_write <= 1'b0; // 不寫入數據
                    mem_read <= 1'b0;  // 不讀取數據
                end
                7'b0000011: begin // L-type 指令（載入）
                    case (funct)
                        3'b010: begin // LW
                            regfile[rd] <= data_memory_out; // 將讀取的數據儲存到目標寄存器
                        end
                    endcase
                    mem_write <= 1'b0; // 不寫入數據
                    mem_read <= 1'b1;  // 讀取數據
                end
                7'b0100011: begin // S-type 指令（儲存）
                    case (funct)
                        3'b010: begin // SW
                            mem_write <= 1'b1; // 寫入數據
                        end
                    endcase
                    mem_read <= 1'b0;  // 不讀取數據
                end
                // 可擴展其他類型的指令
            endcase
            pc <= pc + 4; // 更新 pc
        end
    end

    // 輸出程式計數器的值
    assign pc_out = pc;

endmodule

// 整體單晶片模組
module riscv_chip (
    input clk,
    input rst,
    output [31:0] pc_out
);
    riscv_single_cycle cpu (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out)
    );
endmodule
