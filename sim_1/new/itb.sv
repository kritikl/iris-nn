`timescale 1ns/1ps
module iris_tb;
    logic clk = 0;
    logic rst = 1;
    logic start = 0;
    logic signed [31:0] x [0:3];

    logic [1:0] class_q44, class_q88, class_q1616;
    logic done_q44, done_q88, done_q1616;

    logic signed [7:0]  l2_q44 [0:2];
    logic signed [15:0] l2_q88 [0:2];
    logic signed [31:0] l2_q1616 [0:2];

    always #5 clk = ~clk;

    iris_precision #(.TOTAL_BITS(8),  .FRAC_BITS(4))  dut_q44 (
        .clk(clk), .rst(rst), .start(start),
        .x(x), .class_out(class_q44), .done(done_q44), .l2_debug(l2_q44)
    );

    iris_precision #(.TOTAL_BITS(16), .FRAC_BITS(8))  dut_q88 (
        .clk(clk), .rst(rst), .start(start),
        .x(x), .class_out(class_q88), .done(done_q88), .l2_debug(l2_q88)
    );

    iris_precision #(.TOTAL_BITS(32), .FRAC_BITS(16)) dut_q1616 (
        .clk(clk), .rst(rst), .start(start),
        .x(x), .class_out(class_q1616), .done(done_q1616), .l2_debug(l2_q1616)
    );

    initial begin
        x[0] = 32'sd120;
        x[1] = 32'sd80;
        x[2] = 32'sd100;
        x[3] = 32'sd60;

        #30 rst = 0;
        #50 start = 1;
        #60 start = 0;

        wait(done_q88);

        $display("=== PRECISION COMPARISON ===");
        $display("Q4.4   -> L2 = %0d %0d %0d | Class = %0d", l2_q44[0], l2_q44[1], l2_q44[2], class_q44);
        $display("Q8.8   -> L2 = %0d %0d %0d | Class = %0d", l2_q88[0], l2_q88[1], l2_q88[2], class_q88);
        $display("Q16.16 -> L2 = %0d %0d %0d | Class = %0d", l2_q1616[0], l2_q1616[1], l2_q1616[2], class_q1616);

        #50 $finish;
    end
endmodule
