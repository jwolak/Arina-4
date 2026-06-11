# CPU Instruction Set (4-bit, based on Intel 4004)

Note: The architecture is based on a 4-bit model similar to the Intel 4004. The accumulator is 4 bits wide. Arithmetic and logical operations keep only the lowest 4 bits of results. Flags: Zero (Z) and Carry (C).

| Instruction | Syntax | Description | Flags / Effects |
|-------------:|:------:|:-----------|:----------------|
| LDM | `LDM imm4` | Load immediate 4-bit value into accumulator (A = imm4). | Updates Z |
| CLR | `CLR` | Clear accumulator (A = 0). | Sets Z if result is zero |
| LD | `LD addr` / `LD r` | Load nibble from memory or register into accumulator (A = M[addr] / R[r]). | Updates Z |
| XCH | `XCH r` | Exchange accumulator with internal register `r` (swap A and R[r]). | — |
| ADD | `ADD r` / `ADD addr` | Add value from register/memory to accumulator (A = A + operand). | Sets C on 4-bit overflow; updates Z |
| SUB | `SUB r` / `SUB addr` | Subtract value (A = A - operand). | Sets C for borrow as implemented; updates Z |
| INC | `INC` | Increment accumulator modulo 16 (A = (A + 1) & 0xF). | Updates Z; may set C depending on wrap policy |
| DEC | `DEC` | Decrement accumulator modulo 16 (A = (A - 1) & 0xF). | Updates Z; may set C depending on borrow policy |
| JMP | `JMP addr` | Unconditional jump to address (PC = addr). | — |
| JZ | `JZ addr` | Jump if Zero flag set (if Z == 1 then PC = addr). | Conditional on Z |
| JC | `JC addr` | Jump if Carry flag set (if C == 1 then PC = addr). | Conditional on C |
| LOAD | `LOAD addr` | Prepare memory pointer/buffer for a subsequent access (implementation-defined). | Implementation-defined |
| STORE | `STORE addr` | Store accumulator (or specified register) to memory (M[addr] = A). | — |
| AND | `AND r` / `AND addr` | Bitwise AND between accumulator and operand (A = A & operand). | Updates Z |
| OR | `OR r` / `OR addr` | Bitwise OR (A = A | operand). | Updates Z |
| XOR | `XOR r` / `XOR addr` | Bitwise XOR (A = A ^ operand). | Updates Z |

Implementation notes:

- All operations operate on 4-bit nibbles; results are truncated to 4 bits.
- Flags: Zero (`Z`) set when result == 0; Carry (`C`) set on arithmetic overflow/borrow as defined by the ALU design.
- Machine encoding (opcode/operand formats) should be specified in a separate section consistent with the `rom/` layout.

