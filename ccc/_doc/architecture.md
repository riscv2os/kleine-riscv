# kleine-riscv Architecture

![](../_img/kleine-riscv.png)

1. 全部的 hazard 處理都集中給 hazard.v 模組
2. hazard 和 5 階段都有互通，主要是決定 stall (停頓), valid/invalidate （是否有效或撤回）, mret, branch, 以及對 csr, rs1, rs2, rd 的讀寫 
3. 五階段管線，前面的會傳給後面，後面不會傳給前面
    * Fetch => Decode => Execute => Memory => Writeback
4. 透過 busio 處理對指令快取，資料快取，與外部記憶體的存取事宜。
    * 記憶體的存取，由 Verilator 的 cpp 模組進行互動，所以不在 Verilog 的管轄，沒有對應的 *.v 檔案。
    * busio 和 Fetch 與 Memory 階段有線路溝通。

## pipeline 的運作

1. Fetch: 根據 reset/trap/mret/branch 或者 正常遞增 pc+=4 來決定下一個 pc 的值
    * 送出 instruction 給 Decode
2. Decode: 根據 instruction 的 op 決定要設定 ALU 與 CMP 為何種運算，存取哪些暫存器 (rs1, rs2, rd, csr)，是否跳轉 (jump) 等等。
3. Execute: 裡面包含 ALU/CMP 兩個運算元件，真正執行運算並取得結果
4. Memory: 決定是否更新 PC/CSR/Regfile/Memory/mret/wfi，以及是否 branch (=> hazard)
5. Writeback: 執行 PC/CSR/Regfile/Memory/mret/wfi 的寫入動作，還有處理中斷 interrupt 並設定中斷原因 ecause

