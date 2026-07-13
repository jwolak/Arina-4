`timescale 1ns/1ps

module arina4_cpu_tb;
    reg clk;
    reg rst;

    wire [7:0] debug_pc;
    wire [7:0] debug_ir;
    wire [3:0] debug_acc;
    wire [3:0] debug_r0;
    wire [3:0] debug_r1;
    wire [3:0] debug_r2;
    wire [3:0] debug_r3;
    wire debug_carry;
    wire debug_zero;
    wire debug_fetch_phase;

    arina4_cpu dut (
        .clk(clk),
        .rst(rst),
        .debug_pc(debug_pc),
        .debug_ir(debug_ir),
        .debug_acc(debug_acc),
        .debug_r0(debug_r0),
        .debug_r1(debug_r1),
        .debug_r2(debug_r2),
        .debug_r3(debug_r3),
        .debug_carry(debug_carry),
        .debug_zero(debug_zero),
        .debug_fetch_phase(debug_fetch_phase)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b1;

        #20;
        rst = 1'b0;

        repeat (16) begin
            @(posedge clk);
            $display("t=%0t phase=%0d pc=%02h ir=%02h acc=%01h r0=%01h r1=%01h r2=%01h r3=%01h c=%0d z=%0d",
                $time,
                debug_fetch_phase,
                debug_pc,
                debug_ir,
                debug_acc,
                debug_r0,
                debug_r1,
                debug_r2,
                debug_r3,
                debug_carry,
                debug_zero
            );
        end

        $finish;
    end

endmodule
