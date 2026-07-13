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
 
module register_file (
	input wire clk,
	input wire rst,
	input wire [1:0] rd_sel,
	output wire [3:0] rd_data,
	input wire [1:0] wr_sel,
	input wire [3:0] wr_data,
	input wire we,
	output wire [3:0] r0,
	output wire [3:0] r1,
	output wire [3:0] r2,
	output wire [3:0] r3
);

	reg [3:0] regs [0:3];

	assign rd_data = regs[rd_sel];
	assign r0 = regs[0];
	assign r1 = regs[1];
	assign r2 = regs[2];
	assign r3 = regs[3];

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			regs[0] <= 4'h1;
			regs[1] <= 4'h2;
			regs[2] <= 4'h3;
			regs[3] <= 4'h4;
		end else if (we) begin
			regs[wr_sel] <= wr_data;
		end
	end

endmodule
