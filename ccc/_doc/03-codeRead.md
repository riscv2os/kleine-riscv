

參考 -- https://verilator.org/guide/latest/example_cc.html

## simulator.cpp

```cpp
// ...
#include "core.hpp"
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

## core.hpp

```cpp
#include "Vcore.h"
#include "memory.hpp"

struct Core {
    Vcore core_logic;
    MagicMemory memory;
    int memory_latency;
    int memory_wait;

    void reset();
    void cycle();
};
```

其中 Vcore 對應到 core.v 元件，也就是 core_logic;

Vcore.h 是 veriloator 編譯 core.v 時建構出來的，位於 build/Vcore.h

只要呼叫 Vcore.eval() 就可以前進一步

```cpp
// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Primary model header
//
// This header should be included by all source files instantiating the design.
// The class here is then constructed to instantiate the design.
// See the Verilator manual for examples.

#ifndef VERILATED_VCORE_H_
#define VERILATED_VCORE_H_  // guard

#include "verilated.h"

class Vcore__Syms;
class Vcore___024root;

// This class is the main interface to the Verilated model
class alignas(VL_CACHE_LINE_BYTES) Vcore VL_NOT_FINAL : public VerilatedModel {
  private:
    // Symbol table holding complete model state (owned by this class)
    Vcore__Syms* const vlSymsp;

  public:

    // PORTS
    // The application code writes and reads these signals to
    // propagate new values into/out from the Verilated model.
    VL_IN8(&clk,0,0);
    VL_IN8(&reset,0,0);
    VL_IN8(&meip,0,0);
    VL_OUT8(&ext_valid,0,0);
    VL_OUT8(&ext_instruction,0,0);
    VL_IN8(&ext_ready,0,0);
    VL_OUT8(&ext_write_strobe,3,0);
    VL_OUT(&ext_address,31,0);
    VL_OUT(&ext_write_data,31,0);
    VL_IN(&ext_read_data,31,0);

    // CELLS
    // Public to allow access to /* verilator public */ items.
    // Otherwise the application code can consider these internals.

    // Root instance pointer to allow access to model internals,
    // including inlined /* verilator public_flat_* */ items.
    Vcore___024root* const rootp;

    // CONSTRUCTORS
    /// Construct the model; called by application code
    /// If contextp is null, then the model will use the default global context
    /// If name is "", then makes a wrapper with a
    /// single model invisible with respect to DPI scope names.
    explicit Vcore(VerilatedContext* contextp, const char* name = "TOP");
    explicit Vcore(const char* name = "TOP");
    /// Destroy the model; called (often implicitly) by application code
    virtual ~Vcore();
  private:
    VL_UNCOPYABLE(Vcore);  ///< Copying not allowed

  public:
    // API METHODS
    /// Evaluate the model.  Application must call when inputs change.
    void eval() { eval_step(); }
    /// Evaluate when calling multiple units/models per time step.
    void eval_step();
    /// Evaluate at end of a timestep for tracing, when using eval_step().
    /// Application must call after all eval() and before time changes.
    void eval_end_step() {}
    /// Simulation complete, run final blocks.  Application must call on completion.
    void final();
    /// Are there scheduled events to handle?
    bool eventsPending();
    /// Returns time at next time slot. Aborts if !eventsPending()
    uint64_t nextTimeSlot();
    /// Trace signals in the model; called by application code
    void trace(VerilatedVcdC* tfp, int levels, int options = 0);
    /// Retrieve name of this model instance (as passed to constructor).
    const char* name() const;

    // Abstract methods from VerilatedModel
    const char* hierName() const override final;
    const char* modelName() const override final;
    unsigned threads() const override final;
    /// Prepare for cloning the model at the process level (e.g. fork in Linux)
    /// Release necessary resources. Called before cloning.
    void prepareClone() const;
    /// Re-init after cloning the model at the process level (e.g. fork in Linux)
    /// Re-allocate necessary resources. Called after cloning.
    void atClone() const;
};

#endif  // guard

```

## core.cpp

所以在 Core::reset 和 Core::cycle 中都已有呼叫 core_logic.eval()

而且把 memory 物件也包進來了

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


## Vcore.cpp

```cpp
// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vcore__pch.h"

//============================================================
// Constructors

Vcore::Vcore(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vcore__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , reset{vlSymsp->TOP.reset}
    , meip{vlSymsp->TOP.meip}
    , ext_valid{vlSymsp->TOP.ext_valid}
    , ext_instruction{vlSymsp->TOP.ext_instruction}
    , ext_ready{vlSymsp->TOP.ext_ready}
    , ext_write_strobe{vlSymsp->TOP.ext_write_strobe}
    , ext_address{vlSymsp->TOP.ext_address}
    , ext_write_data{vlSymsp->TOP.ext_write_data}
    , ext_read_data{vlSymsp->TOP.ext_read_data}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vcore::Vcore(const char* _vcname__)
    : Vcore(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vcore::~Vcore() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vcore___024root___eval_debug_assertions(Vcore___024root* vlSelf);
#endif  // VL_DEBUG
void Vcore___024root___eval_static(Vcore___024root* vlSelf);
void Vcore___024root___eval_initial(Vcore___024root* vlSelf);
void Vcore___024root___eval_settle(Vcore___024root* vlSelf);
void Vcore___024root___eval(Vcore___024root* vlSelf);

void Vcore::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vcore::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vcore___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vcore___024root___eval_static(&(vlSymsp->TOP));
        Vcore___024root___eval_initial(&(vlSymsp->TOP));
        Vcore___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vcore___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vcore::eventsPending() { return false; }

uint64_t Vcore::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vcore::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vcore___024root___eval_final(Vcore___024root* vlSelf);

VL_ATTR_COLD void Vcore::final() {
    Vcore___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vcore::hierName() const { return vlSymsp->name(); }
const char* Vcore::modelName() const { return "Vcore"; }
unsigned Vcore::threads() const { return 1; }
void Vcore::prepareClone() const { contextp()->prepareClone(); }
void Vcore::atClone() const {
    contextp()->threadPoolpOnClone();
}

//============================================================
// Trace configuration

VL_ATTR_COLD void Vcore::trace(VerilatedVcdC* tfp, int levels, int options) {
    vl_fatal(__FILE__, __LINE__, __FILE__,"'Vcore::trace()' called on model that was Verilated without --trace option");
}

```