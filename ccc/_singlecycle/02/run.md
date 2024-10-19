
```
root@localhost:~/kleine-riscv/ccc/_singlecycle/02# iverilog testbench.v rv32i.v
root@localhost:~/kleine-riscv/ccc/_singlecycle/02# vvp a.out
Time:                    0 | PC: 00000000
Time:                15000 | PC: 00000004
Time:                25000 | PC: 00000008
Time:                35000 | PC: 0000000c
Time:                45000 | PC: 00000010
Time:                55000 | PC: 00000014
Time:                65000 | PC: 00000018
Time:                75000 | PC: 0000001c
Time:                85000 | PC: 00000020
Time:                95000 | PC: 00000024
Time:               105000 | PC: 00000028
testbench.v:32: $stop called at 110000 (1ps)
** VVP Stop(0) **
** Flushing output streams.
** Current simulation time is 110000 ticks.
```

