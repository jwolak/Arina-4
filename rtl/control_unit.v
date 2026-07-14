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
 
module control_unit (
    input wire clk,
    input wire rst,
    input wire [3:0] opcode,
    output reg ir_load,
    output reg pc_inc,
    output reg pc_load,
    output reg acc_load,
    output reg reg_we,
    output reg flags_we,
    output reg use_imm,
    output reg exchange,
    output reg [1:0] wb_sel,
    output reg [3:0] alu_opcode,
    output reg phase_fetch
);

    localparam [0:0] S_FETCH = 1'b0;
    localparam [0:0] S_EXEC = 1'b1;

    localparam [3:0] OP_LDM = 4'b0000;
    localparam [3:0] OP_CLR = 4'b0001;
    localparam [3:0] OP_LD  = 4'b0010;
    localparam [3:0] OP_XCH = 4'b0011;
    localparam [3:0] OP_ADD = 4'b0100;
    localparam [3:0] OP_SUB = 4'b0101;
    localparam [3:0] OP_INC = 4'b0110;
    localparam [3:0] OP_DEC = 4'b0111;
    localparam [3:0] OP_AND = 4'b1000;
    localparam [3:0] OP_OR  = 4'b1001;
    localparam [3:0] OP_XOR = 4'b1010;

    reg state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_FETCH;
        end else begin
            case (state)
                S_FETCH: state <= S_EXEC;
                default: state <= S_FETCH;
            endcase
        end
    end

    always @(*) begin
        ir_load = 1'b0;
        pc_inc = 1'b0;
        pc_load = 1'b0;
        acc_load = 1'b0;
        reg_we = 1'b0;
        flags_we = 1'b0;
        use_imm = 1'b0;
        exchange = 1'b0;
        wb_sel = 2'b00;
        alu_opcode = opcode;
        phase_fetch = (state == S_FETCH);

        case (state)
            S_FETCH: begin
                ir_load = 1'b1;
                pc_inc = 1'b1;
            end

            S_EXEC: begin
                case (opcode)
                    OP_LDM: begin
                        acc_load = 1'b1;
                        flags_we = 1'b1;
                        use_imm = 1'b1;
                        wb_sel = 2'b00;
                        alu_opcode = OP_LDM;
                    end

                    OP_CLR,
                    OP_LD,
                    OP_ADD,
                    OP_SUB,
                    OP_INC,
                    OP_DEC,
                    OP_AND,
                    OP_OR,
                    OP_XOR: begin
                        acc_load = 1'b1;
                        flags_we = 1'b1;
                        wb_sel = 2'b00;
                    end

                    OP_XCH: begin
                        acc_load = 1'b1;
                        reg_we = 1'b1;
                        flags_we = 1'b1;
                        exchange = 1'b1;
                        wb_sel = 2'b00;
                    end

                    default: begin
                        // Treat unknown opcodes as NOP.
                    end
                endcase
            end
        endcase
    end

endmodule
