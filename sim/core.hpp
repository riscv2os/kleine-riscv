
#include "Vcore.h"
#include "memory.hpp"

struct Core {
    Vcore core_logic;
    MagicMemory memory;
    int memory_latency;

    void initialize();
    void reset();
    void cycle();
};

