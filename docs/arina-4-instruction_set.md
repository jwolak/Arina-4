# Arina-4 CPU Instruction Set (4-bit)

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


- All operations operate on 4-bit nibbles; results are truncated to 4 bits.
- Flags: Zero (`Z`) set when result == 0; Carry (`C`) set on arithmetic overflow/borrow as defined by the ALU design.
Implementation notes:

- Machine encoding (opcode/operand formats) should be specified in a separate section consistent with the `rom/` layout.

Machine encoding

Instruction word size: 8 bits (one byte). Format for most instructions: [7:4] = opcode, [3:0] = operand nibble.

Operand meanings:
- If the low nibble is used as a register specifier, it encodes a 4-bit register ID (0x0..0xE). A low nibble of 0xF is reserved to indicate an extended form where an 8-bit address (next byte) follows.
- For immediate 4-bit values (e.g., `LDM`), the immediate is stored in the low nibble of the single instruction byte.
- For instructions that operate on memory addresses larger than 4 bits, use the extended form: first byte contains opcode in high nibble and low nibble = 0xF, second byte is the 8-bit address.

Opcode map (high nibble = opcode):

| Opcode (hex) | Encoding examples | Meaning |
|:------------:|:-----------------:|:--------|
| 0x0n | `0x0n` | LDM imm4 — Load immediate 4-bit value into A (A = n).
| 0x1x | `0x10` | CLR — Clear accumulator (single byte, low nibble ignored).
| 0x2r / 0x2F addr8 | `0x2r` or `0x2F 0xAA` | LD — Load from register `r` into A, or `LD addr` when low nibble=F and next byte is address.
| 0x3r | `0x3r` | XCH r — Exchange A with register `r`.
| 0x4r / 0x4F addr8 | `0x4r` or `0x4F 0xAA` | ADD — Add register `r` or memory at `addr` to A.
| 0x5r / 0x5F addr8 | `0x5r` or `0x5F 0xAA` | SUB — Subtract register `r` or memory at `addr` from A.
| 0x60 | `0x60` | INC — Increment accumulator (A = (A+1)&0xF).
| 0x70 | `0x70` | DEC — Decrement accumulator (A = (A-1)&0xF).
| 0x8F addr8 | `0x8F 0xAA` | JMP addr — Unconditional jump to 8-bit address `AA` (extended form required).
| 0x9F addr8 | `0x9F 0xAA` | JZ addr — Jump if Z set to address `AA`.
| 0xAF addr8 | `0xAF 0xAA` | JC addr — Jump if C set to address `AA`.
| 0xBF addr8 | `0xBF 0xAA` | LOAD addr — Prepare memory pointer/buffer for subsequent access.
| 0xCF addr8 | `0xCF 0xAA` | STORE addr — Store A to memory address `AA`.
| 0xDr / 0xDF addr8 | `0xDr` or `0xDF 0xAA` | AND — Bitwise AND with register `r` or memory at `AA`.
| 0xEr / 0xEF addr8 | `0xEr` or `0xEF 0xAA` | OR — Bitwise OR with register `r` or memory at `AA`.
| 0xFr / 0xFF addr8 | `0xFr` or `0xFF 0xAA` | XOR — Bitwise XOR with register `r` or memory at `AA`.

Notes and examples:
- `LDM 0x7` is encoded as single byte `0x07`.
- `ADD R2` is encoded as `0x42` (0x4 opcode + reg id 2).
- `ADD [0x3A]` (add memory at address 0x3A) is encoded as two bytes: `0x4F 0x3A`.
- `JMP 0x80` is encoded as `0x8F 0x80`.
- Use register IDs 0x0..0xE for internal registers; avoid 0xF unless intentionally using extended memory addressing.

This encoding balances compact single-byte operations for register-based and small immediates, while allowing full 8-bit addresses via an explicit extended form.

