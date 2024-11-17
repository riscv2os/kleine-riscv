

```
(base) cccimac@cccimacdeiMac 04-adder % ./run.sh
verilator --cc --exe --build testbench.cpp adder.v -o testbench
make[1]: Nothing to be done for `default'.
- V e r i l a t i o n   R e p o r t: Verilator 5.028 2024-08-21 rev UNKNOWN.REV
- Verilator: Built from 0.000 MB sources in 0 modules, into 0.000 MB in 0 C++ files needing 0.000 MB
- Verilator: Walltime 0.014 s (elab=0.000, cvt=0.000, bld=0.011); cpu 0.001 s on 1 threads
[  0] clk=1 reset=1 a=0 b=0 sum=0
[  1] clk=0 reset=1 a=0 b=0 sum=0
[  2] clk=1 reset=0 a=0 b=0 sum=0
[  3] clk=0 reset=0 a=0 b=0 sum=0
[  4] clk=1 reset=0 a=5 b=3 sum=0
[  5] clk=0 reset=0 a=5 b=3 sum=0
[  6] clk=1 reset=0 a=5 b=3 sum=8
[  7] clk=0 reset=0 a=5 b=3 sum=8
[  8] clk=1 reset=0 a=5 b=3 sum=8
[  9] clk=0 reset=0 a=5 b=3 sum=8
[ 10] clk=1 reset=0 a=7 b=8 sum=8
[ 11] clk=0 reset=0 a=7 b=8 sum=8
[ 12] clk=1 reset=0 a=7 b=8 sum=15
[ 13] clk=0 reset=0 a=7 b=8 sum=15
[ 14] clk=1 reset=0 a=7 b=8 sum=15
[ 15] clk=0 reset=0 a=7 b=8 sum=15
[ 16] clk=1 reset=0 a=7 b=8 sum=15
[ 17] clk=0 reset=0 a=7 b=8 sum=15
[ 18] clk=1 reset=0 a=7 b=8 sum=15
[ 19] clk=0 reset=0 a=7 b=8 sum=15
```
