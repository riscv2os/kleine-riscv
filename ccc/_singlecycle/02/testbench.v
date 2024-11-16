`timescale 1ns / 1ps

module testbench;
    reg clk;
    reg rst;
    wire [31:0] pc_out;

    // 實例化單晶片模組
    riscv_chip uut (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out)
    );

    // 時鐘生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 每5ns翻轉一次時鐘
    end

    // 測試序列
    initial begin
        // 初始化
        rst = 1; // 啟動時重置
        #10;     // 等待10ns
        rst = 0; // 解除重置

        // 等待一段時間以觀察程式計數器的變化
        #100;
        
        // 結束模擬
        $stop;
        $finish;
    end

    // 輸出觀察
    initial begin
        $monitor("Time: %5t PC: %h I: %h r0=%h rd=%h", $time, pc_out, uut.cpu.instruction, uut.cpu.regfile[0], uut.cpu.rd);
    end
endmodule
