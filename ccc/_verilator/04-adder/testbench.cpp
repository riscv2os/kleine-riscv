#include "Vadder.h"
#include "verilated.h"

void toggle_clock(Vadder* adder, bool& clk) {
    clk = !clk;            // Toggle clock
    adder->clk = clk;      // Apply clock value
    adder->eval();         // Evaluate the model
}

void monitor(Vadder* adder, int cycle) {
    printf("[%3d] clk=%d reset=%d a=%d b=%d sum=%d\n",
           cycle, adder->clk, adder->reset, adder->a, adder->b, adder->sum);
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    Vadder* adder = new Vadder;
    bool clk = 0;         // Initialize clock
    int cycle = 0;        // Cycle counter

    // Initial conditions
    adder->reset = 1;     // Assert reset
    adder->a = 0;         // Initialize inputs
    adder->b = 0;

    // Simulation loop
    for (cycle = 0; cycle < 20; cycle++) {
        toggle_clock(adder, clk);

        if (cycle == 2) adder->reset = 0; // Deassert reset
        if (cycle == 4) { adder->a = 5; adder->b = 3; } // Apply inputs
        if (cycle == 10) { adder->a = 7; adder->b = 8; } // Change inputs

        monitor(adder, cycle); // Monitor signals
    }

    delete adder;
    return 0;
}
