# Arina-4
A 4-bit accumulator-based microprocessor inspired by the Intel 4004 architecture.

## Step 1: Freeze ISA and Cycle-Level Control

Before extending RTL, freeze the instruction set and cycle timing. This step is the
implementation contract for `rtl/decoder.v` and `rtl/control_unit.v`.

### 1) Instruction Table (ISA)

Define every opcode with operands, side effects, flags, and cycle count.

| Mnemonic | Opcode (hex) | Operands | Description | Flags Written | Cycles |
|---|---|---|---|---|---|
| NOP | 0x0 | - | No operation | - | 1 |
| LDI A, imm4 | 0x1 | imm4 | Load 4-bit immediate into accumulator | Z | 2 |
| ADD A, Rn | 0x2 | Rn | Add register to accumulator | C, Z | 2 |
| SUB A, Rn | 0x3 | Rn | Subtract register from accumulator | C, Z | 2 |
| MOV A, Rn | 0x4 | Rn | Copy register into accumulator | Z | 2 |
| MOV Rn, A | 0x5 | Rn | Copy accumulator into register | - | 2 |
| JMP addr12 | 0x6 | addr12 | Unconditional jump | - | 3 |
| JZ addr12 | 0x7 | addr12 | Jump if zero flag is set | - | 3 |
| JC addr12 | 0x8 | addr12 | Jump if carry flag is set | - | 3 |
| CALL addr12 | 0x9 | addr12 | Push return address and jump | - | 4 |
| RET | 0xA | - | Return from subroutine | - | 3 |
| AND A, Rn | 0xB | Rn | Bitwise AND | Z | 2 |
| OR A, Rn | 0xC | Rn | Bitwise OR | Z | 2 |
| XOR A, Rn | 0xD | Rn | Bitwise XOR | Z | 2 |
| INC A | 0xE | - | Increment accumulator | C, Z | 1 |
| DEC A | 0xF | - | Decrement accumulator | C, Z | 1 |

Notes:
- This is a practical baseline ISA for bring-up.
- If you later align more strictly to Intel 4004 semantics, keep this table as the
	single source of truth and version changes explicitly.

### 2) Instruction Encoding

Use explicit bit-level encoding so decoder logic is deterministic.

Base instruction word:
- 8-bit instruction fetch
- `instr[7:4]` = opcode
- `instr[3:0]` = low nibble (register index, imm4, or address nibble)

Address-form instructions (`JMP`, `JZ`, `JC`, `CALL`):
- Byte 0: opcode in `instr[7:4]`, address high nibble in `instr[3:0]`
- Byte 1: address low byte
- Effective address: `addr12 = {byte0[3:0], byte1[7:0]}`

Register index convention:
- `Rn = instr[1:0]` for a 4-register file (`R0..R3`)
- `instr[3:2]` reserved for future extension (must decode cleanly)

### 3) Cycle-by-Cycle Micro-Operations

Define fetch/decode/execute behavior per T-state. The table below is the minimum
control schedule to implement.

| Instruction | T0 (fetch) | T1 (decode/read) | T2 (execute) | T3 (finalize) |
|---|---|---|---|---|
| NOP | `IR <- ROM[PC]`, `PC++` | - | - | - |
| LDI A, imm4 | `IR <- ROM[PC]`, `PC++` | decode immediate | `A <- IR[3:0]`, `Z <- (A==0)` | - |
| ADD A, Rn | `IR <- ROM[PC]`, `PC++` | `TMP <- Rn` | `A <- A + TMP`, `C/Z <- ALU` | - |
| SUB A, Rn | `IR <- ROM[PC]`, `PC++` | `TMP <- Rn` | `A <- A - TMP`, `C/Z <- ALU` | - |
| MOV A, Rn | `IR <- ROM[PC]`, `PC++` | `TMP <- Rn` | `A <- TMP`, `Z <- (A==0)` | - |
| MOV Rn, A | `IR <- ROM[PC]`, `PC++` | decode `Rn` | `Rn <- A` | - |
| JMP addr12 | `IR <- ROM[PC]`, `PC++` | `ADDR_HI <- IR[3:0]`, `TMP <- ROM[PC]`, `PC++` | `PC <- {ADDR_HI, TMP}` | - |
| JZ addr12 | `IR <- ROM[PC]`, `PC++` | `ADDR_HI <- IR[3:0]`, `TMP <- ROM[PC]`, `PC++` | if `Z==1`: `PC <- {ADDR_HI, TMP}` | - |
| JC addr12 | `IR <- ROM[PC]`, `PC++` | `ADDR_HI <- IR[3:0]`, `TMP <- ROM[PC]`, `PC++` | if `C==1`: `PC <- {ADDR_HI, TMP}` | - |
| CALL addr12 | `IR <- ROM[PC]`, `PC++` | `ADDR_HI <- IR[3:0]`, `TMP <- ROM[PC]`, `PC++` | `STACK_PUSH(PC)` | `PC <- {ADDR_HI, TMP}` |
| RET | `IR <- ROM[PC]`, `PC++` | `RET_TMP <- STACK_POP()` | `PC <- RET_TMP` | - |

Guidance:
- Keep all instructions aligned to the same `T0` fetch behavior.
- Multi-byte control flow instructions consume Byte 1 during `T1`.

### 4) Control Signal List (to be frozen)

Map these signals directly to control-unit outputs:

- `pc_inc` (increment program counter)
- `pc_load` (load program counter from bus)
- `pc_src[1:0]` (`00=pc+1`, `01=addr12`, `10=stack_top`)
- `ir_load`
- `addr_hi_load` (latch high address nibble for 12-bit targets)
- `tmp_load` (temporary register load)
- `acc_load`
- `reg_rd_sel[1:0]`
- `reg_wr_sel[1:0]`
- `reg_we`
- `alu_op[2:0]` (`ADD`, `SUB`, `AND`, `OR`, `XOR`, `INC`, `DEC`)
- `flags_we`
- `flags_mask[1:0]` (`bit0=Z`, `bit1=C`)
- `stack_push`
- `stack_pop`
- `bus_sel[2:0]` (`ROM`, `ALU`, `REG`, `IMM`, `STACK`)

### 5) Decoder Contract (`rtl/decoder.v`)

Decoder must provide at least:

- `opcode[3:0]`
- `is_imm`
- `is_reg_read`
- `is_reg_write`
- `is_branch`
- `is_call`
- `is_ret`
- `writes_flags`
- `uses_second_byte`

This keeps `control_unit.v` focused on sequencing, not opcode bit parsing.

### 6) Definition of Done for Step 1

- Every opcode has fixed operands, flag effects, and cycle count.
- Byte-level encoding is unambiguous, including 12-bit address instructions.
- A complete T-state micro-operation table exists for the baseline ISA.
- Control signals are named and mapped to cycle behavior.
- Decoder output contract is defined and sufficient for FSM implementation.

