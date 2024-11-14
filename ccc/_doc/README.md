# kleine-riscv 處理器

## C 語言檔案

```
./sim:
core.cpp
core.hpp
memory.cpp # 沒有用 verilog 宣告記憶體模組，而是用 memory.cpp, memory.hpp 宣告記憶體
memory.hpp
simulator.cpp # 整個系統模擬的最上層元件
```

simplator.cpp

```cpp
// ...
int main(int argc, const char** argv) {
    uint32_t memory_size = 1 << 20;
    int cycle_limit = 0;
    int latency = 0;
    bool add_exit = false;
    const char* elf = NULL;
    parseArguments(argc, argv, &memory_size, &cycle_limit, &latency, &add_exit, &elf);
    if (elf == NULL) {
        return 1;
    } else {
        Core core;
        core.memory_latency = latency;
        uint32_t* ram = core.memory.addRamHandler(0x80000000, memory_size);
        if (!loadFromElfFile(elf, ram, 0x80000000, memory_size)) {
            return 1;
        }
        addHandlers(core.memory, add_exit);
        core.reset();
        for (int i = 0; i < cycle_limit || cycle_limit == 0; i++) {
            core.cycle();
        }
        std::cerr << "terminated after " << cycle_limit << " cycles" << std::endl;
        delete[] ram;
        return 1;
    }
}

```


然後記憶體和 CPU core 的互動方式在 core.cpp 中如下，

core.cpp

```cpp
#include "core.hpp"

void Core::reset() {
    core_logic.reset = 1;
    core_logic.clk = 0;
    core_logic.eval();
    core_logic.clk = 1;
    core_logic.eval();
    core_logic.reset = 0;
    core_logic.clk = 0;
    memory_wait = 0;
}

void Core::cycle() {
    if (memory_wait == 0) {
        memory.handleRequest(core_logic);
        memory_wait = memory_latency;
    } else {
        memory.delayRequest(core_logic);
        memory_wait--;
    }
    core_logic.eval();
    core_logic.clk = 1;
    core_logic.eval();
    core_logic.clk = 0;
}
```

## Verilog 檔案


```
./src:
core.v  ## 核心處理器
params.vh
pipeline
units

./src/pipeline: ## 管線相關模組
decode.v
execute.v
fetch.v
memory.v
pipeline.v ## 管線主模組
writeback.v

./src/units: ## 基本模組
alu.v
busio.v
cmp.v
csr.v
hazard.v
regfile.v
```
