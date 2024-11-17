#include "Vour.h"
#include "verilated.h"
#include <stdio.h>
int main(int argc, char** argv) {
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    Vour* top = new Vour{contextp};
    printf("start...\n");
    while (!contextp->gotFinish()) { 
        top->eval();
        printf("step...\n");
    }
    delete top;
    delete contextp;
    return 0;
}