/*-
 * BSD 3-Clause License
 *
 * Copyrights 2026, Janusz Wolak
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */
 
module arina4_cpu (
    input wire clk,
    input wire rst,
    output wire [7:0] debug_pc,
    output wire [7:0] debug_ir,
    output wire [3:0] debug_acc,
    output wire [3:0] debug_r0,
    output wire [3:0] debug_r1,
    output wire [3:0] debug_r2,
    output wire [3:0] debug_r3,
    output wire debug_carry,
    output wire debug_zero,
    output wire debug_fetch_phase
);

    wire [7:0] pc_value;
    wire [7:0] rom_data;
    wire [7:0] ir_instr;

    wire [3:0] dec_opcode;
    wire [1:0] dec_reg_sel;
    wire [3:0] dec_imm4;

    wire cu_ir_load;
    wire cu_pc_inc;
    wire cu_pc_load;
    wire cu_acc_load;
    wire cu_reg_we;
    wire cu_flags_we;
    wire cu_use_imm;
    wire cu_exchange;
    wire [1:0] cu_wb_sel;
    wire [3:0] cu_alu_opcode;
    wire cu_phase_fetch;

    wire [3:0] acc_value;
    wire [3:0] reg_rd_data;
    wire [3:0] alu_operand_b;
    wire [3:0] alu_result;
    wire alu_carry;
    wire alu_zero;
    wire [3:0] wb_bus;
    wire [3:0] reg_wr_data;
    wire flags_carry;
    wire flags_zero;

    assign alu_operand_b = cu_use_imm ? dec_imm4 : reg_rd_data;
    assign reg_wr_data = cu_exchange ? acc_value : wb_bus;

    pc u_pc (
        .clk(clk),
        .rst(rst),
        .inc(cu_pc_inc),
        .load(cu_pc_load),
        .load_value(8'h00),
        .value(pc_value)
    );

    rom u_rom (
        .addr(pc_value),
        .data(rom_data)
    );

    ir u_ir (
        .clk(clk),
        .rst(rst),
        .load(cu_ir_load),
        .data_in(rom_data),
        .instr(ir_instr)
    );

    decoder u_decoder (
        .instr(ir_instr),
        .opcode(dec_opcode),
        .reg_sel(dec_reg_sel),
        .imm4(dec_imm4)
    );

    control_unit u_control (
        .clk(clk),
        .rst(rst),
        .opcode(dec_opcode),
        .ir_load(cu_ir_load),
        .pc_inc(cu_pc_inc),
        .pc_load(cu_pc_load),
        .acc_load(cu_acc_load),
        .reg_we(cu_reg_we),
        .flags_we(cu_flags_we),
        .use_imm(cu_use_imm),
        .exchange(cu_exchange),
        .wb_sel(cu_wb_sel),
        .alu_opcode(cu_alu_opcode),
        .phase_fetch(cu_phase_fetch)
    );

    register_file u_regfile (
        .clk(clk),
        .rst(rst),
        .rd_sel(dec_reg_sel),
        .rd_data(reg_rd_data),
        .wr_sel(dec_reg_sel),
        .wr_data(reg_wr_data),
        .we(cu_reg_we),
        .r0(debug_r0),
        .r1(debug_r1),
        .r2(debug_r2),
        .r3(debug_r3)
    );

    alu4 u_alu (
        .acc(acc_value),
        .operand_b(alu_operand_b),
        .opcode(cu_alu_opcode),
        .result(alu_result),
        .carry_flag_out(alu_carry),
        .zero_flag_out(alu_zero)
    );

    bus_mux u_bus_mux (
        .sel(cu_wb_sel),
        .in_alu(alu_result),
        .in_imm(dec_imm4),
        .in_reg(reg_rd_data),
        .in_zero(4'h0),
        .out(wb_bus)
    );

    accumulator u_acc (
        .clk(clk),
        .rst(rst),
        .load(cu_acc_load),
        .data_in(wb_bus),
        .value(acc_value)
    );

    flags u_flags (
        .clk(clk),
        .rst(rst),
        .we(cu_flags_we),
        .carry_in(alu_carry),
        .zero_in(alu_zero),
        .carry(flags_carry),
        .zero(flags_zero)
    );

    assign debug_pc = pc_value;
    assign debug_ir = ir_instr;
    assign debug_acc = acc_value;
    assign debug_carry = flags_carry;
    assign debug_zero = flags_zero;
    assign debug_fetch_phase = cu_phase_fetch;

endmodule
