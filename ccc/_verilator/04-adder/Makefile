# Verilator flags
VERILATOR = verilator
VERILATOR_FLAGS = --cc --exe --build

# Source files
VERILOG_SRC = adder.v
CPP_SRC = testbench.cpp

# Target binary
TARGET = testbench

all: $(TARGET)

$(TARGET): $(VERILOG_SRC) $(CPP_SRC)
	$(VERILATOR) $(VERILATOR_FLAGS) $(CPP_SRC) $(VERILOG_SRC) -o $(TARGET)

clean:
	rm -rf obj_dir $(TARGET)

.PHONY: all clean
