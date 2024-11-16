# kleine-riscv 如何編譯與測試

必須在 linux 底下，先安裝 lld libelf-dev g++ clang verilator

然後就能 make

```
root@localhost:~/kleine-riscv/ccc# make
make[1]: Entering directory '/root/kleine-riscv/ccc/tests'
Building build/misc/fibonacci
make[1]: Leaving directory '/root/kleine-riscv/ccc/tests'
Running test addi
Running test lhu
Running test jal
Running test sll
Running test sltu
Running test lw
Running test bgeu
Running test lbu
Running test auipc
Running test simple
Running test bne
Running test srai
Running test xor
Running test blt
Running test fence_i
Running test sw
Running test slt
Running test bge
Running test sltiu
Running test slti
Running test lb
Running test sb
Running test lh
Running test beq
Running test or
Running test add
Running test sh
Running test andi
Running test jalr
Running test ori
Running test srl
Running test slli
Running test srli
Running test sra
Running test bltu
Running test lui
Running test sub
Running test xori
Running test and
Running test fastfib
Running test ackermann
Running test alarm
Running test partitions
Running test sha256
Running test fibonacci
Running test factorial
Running test primes
Running test csr
Running test scall
Running test ma_addr
Running test mcsr
Running test ma_fetch
Running test shamt
Running test illegal
Running test sbreak
Running test mtimecmp
test
```

如果沒有錯誤，那就代表所有 test 都是成功的

如果有錯，那就會在錯誤的那個測試上停掉

舉例而言，我在 fibonacci.c 上的驗證 ASSERT 故意改成錯的，fib(10) 應該是 55，而非 59

```cpp
void test() {
    // ASSERT(2, recursive(10) == 55);
    ASSERT(2, recursive(10) == 59);
    ASSERT(3, recursive(15) == 610);
}
```

這樣跑 make 就會出現

```sh
root@localhost:~/kleine-riscv/ccc# make
make[1]: Entering directory '/root/kleine-riscv/ccc/tests'
Building build/misc/fibonacci
make[1]: Leaving directory '/root/kleine-riscv/ccc/tests'
Running test addi
Running test lhu
Running test jal
Running test sll
Running test sltu
Running test lw
Running test bgeu
Running test lbu
Running test auipc
Running test simple
Running test bne
Running test srai
Running test xor
Running test blt
Running test fence_i
Running test sw
Running test slt
Running test bge
Running test sltiu
Running test slti
Running test lb
Running test sb
Running test lh
Running test beq
Running test or
Running test add
Running test sh
Running test andi
Running test jalr
Running test ori
Running test srl
Running test slli
Running test srli
Running test sra
Running test bltu
Running test lui
Running test sub
Running test xori
Running test and
Running test fastfib
Running test ackermann
Running test alarm
Running test partitions
Running test sha256
Running test fibonacci
Failed test case #2
make: *** [makefile:57: RUNTEST.tests/build/misc/fibonacci] Error 1
```

所以只要沒有錯誤，就是驗證成功了！
