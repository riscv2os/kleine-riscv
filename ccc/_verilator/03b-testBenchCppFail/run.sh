# verilator --build --binary -j 0 -Wall --timing sim_main.cpp testbench.v and_gate.v
verilator --cc --exe --build -j 0 -Wall --timing sim_main.cpp testbench.v and_gate.v
./obj_dir/Vtestbench

# verilator --binary -j 0 -Wall our.v