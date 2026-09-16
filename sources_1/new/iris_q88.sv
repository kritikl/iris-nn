module iris_q88_top (
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic signed [31:0] x [0:3],     
    output logic [1:0] class_out,
    output logic done
);
    iris_precision #(.TOTAL_BITS(16), .FRAC_BITS(8)) dut (
        .clk(clk), .rst(rst), .start(start),
        .x(x),
        .class_out(class_out),
        .done(done),
        .l2_debug()
    );
endmodule