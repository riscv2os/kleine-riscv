#include "Vtestbench.h"
#include "verilated.h"
#include <stdio.h>
int main(int argc, char** argv) {
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    Vtestbench* top = new Vtestbench{contextp};
    printf("start...\n");
    while (!contextp->gotFinish()) { 
        top->eval();
        // printf("step...\n");
        top->nextTimeSlot();
    }
    delete top;
    delete contextp;
    return 0;
}