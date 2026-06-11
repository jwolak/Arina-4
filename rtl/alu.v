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

 module alu4(
    input wire [3:0] acc,
    input wire [3:0] operand_b,
    input wire [3:0] opcode,
    output reg [3:0] result,
    output reg carry_flag_out, // set to 1 when result exceeds 4 bits
    output reg zero_flag_out   // set to 1 when result is zero
 );

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

    reg [4:0] temp_carry_result;

    always @(*) begin
        result = 4'b0000;
        carry_flag_out = 1'b0;
        zero_flag_out = 1'b0;
        temp_carry_result = 5'b00000;

        case (opcode)
            OP_LDM: begin
                result = operand_b;
                carry_flag_out = 1'b0;
            end

            OP_CLR: begin
                result = 4'b0000;
                carry_flag_out = 1'b0;
            end

            OP_LD: begin
                result = operand_b;
                carry_flag_out = 1'b0;
            end

            OP_XCH: begin
                result = operand_b;
                carry_flag_out = 1'b0;
            end

            OP_ADD: begin
                temp_carry_result = {1'b0, acc} + {1'b0, operand_b};
                result = temp_carry_result[3:0];
                carry_flag_out = temp_carry_result[4];
            end

            OP_SUB: begin
                temp_carry_result = {1'b0, acc} - {1'b0, operand_b};
                result = temp_carry_result[3:0];
                carry_flag_out = (acc < operand_b) ? 1'b1 : 1'b0;
            end

            OP_INC: begin
                temp_carry_result = {1'b0, acc} + 5'b00001;
                result = temp_carry_result[3:0];
                carry_flag_out = temp_carry_result[4];
            end

            OP_DEC: begin
                temp_carry_result = {1'b0, acc} - 5'b00001;
                result = temp_carry_result[3:0];
                carry_flag_out = (acc == 4'b00000) ? 1'b1 : 1'b0;
            end

            OP_AND: begin
                result = acc & operand_b;
                carry_flag_out = 1'b0;
            end

            OP_OR: begin
                result = acc | operand_b;
                carry_flag_out = 1'b0;
            end

            OP_XOR: begin
                result = acc ^ operand_b;
                carry_flag_out = 1'b0;
            end

            default: begin
                result = 4'b0000;
                carry_flag_out = 1'b0;
            end
        endcase
        
        zero_flag_out = (result == 4'b0000) ? 1'b1 : 1'b0;
    end
 endmodule