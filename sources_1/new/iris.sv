module iris_precision #(
    parameter int TOTAL_BITS = 16,
    parameter int FRAC_BITS  = 8
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic signed [31:0] x [0:3],         
    output logic [1:0] class_out,
    output logic done,
    output logic signed [TOTAL_BITS-1:0] l2_debug [0:2]
);
    `include "network_weights.svh"

    logic signed [TOTAL_BITS-1:0] x_int [0:3];
    logic signed [TOTAL_BITS-1:0] l0 [0:15];
    logic signed [TOTAL_BITS-1:0] l1 [0:15];
    logic signed [TOTAL_BITS-1:0] l2 [0:2];

    logic done0_vec [0:15];
    logic done1_vec [0:15];
    logic done2_vec [0:2];

    logic done_l0, done_l1, done_l2;
    logic start_l1, start_l2;

    always_ff @(posedge clk) begin
        if (rst) begin
            start_l1 <= 1'b0;
            start_l2 <= 1'b0;
        end else begin
            start_l1 <= done_l0;
            start_l2 <= done_l1;
        end
    end

    // Input Normalization
    always_comb begin
        for (int i = 0; i < 4; i++) begin
            if (TOTAL_BITS == 32) begin
                automatic logic signed [31:0] mean_q1616 = $signed(norm_mean[i]) <<< 8;
                x_int[i] = x[i] - mean_q1616;
            end else if (TOTAL_BITS == 16) begin
                automatic logic signed [15:0] x16 = x[i][15:0];
                x_int[i] = x16 - norm_mean[i];
            end else begin
                automatic logic signed [15:0] x16 = x[i][15:0];
                automatic logic signed [15:0] diff = x16 - norm_mean[i];
                x_int[i] = diff[11:4];
            end
        end
    end

    genvar g;
    generate
        // LAYER 0
        for (g = 0; g < 16; g++) begin : gen_l0
            if (TOTAL_BITS == 8) begin
                neuron #(.INPUTS(4), .TOTAL_BITS(8), .FRAC_BITS(4)) n (
                    .clk(clk), .rst(rst), .start(start),
                    .x(x_int),
                    .w('{W_q4_L0[g*4+0], W_q4_L0[g*4+1], W_q4_L0[g*4+2], W_q4_L0[g*4+3]}),
                    .bias(b_q4_L0[g][7:0]),
                    .y(l0[g]), .done(done0_vec[g])
                );
            end else if (TOTAL_BITS == 16) begin
                neuron #(.INPUTS(4), .TOTAL_BITS(16), .FRAC_BITS(8)) n (
                    .clk(clk), .rst(rst), .start(start),
                    .x(x_int),
                    .w('{W_q8_L0[g*4+0], W_q8_L0[g*4+1], W_q8_L0[g*4+2], W_q8_L0[g*4+3]}),
                    .bias(b_q8_L0[g][15:0]),
                    .y(l0[g]), .done(done0_vec[g])
                );
            end else begin
                neuron #(.INPUTS(4), .TOTAL_BITS(32), .FRAC_BITS(16)) n (
                    .clk(clk), .rst(rst), .start(start),
                    .x(x_int),
                    .w('{W_q16_L0[g*4+0][31:0], W_q16_L0[g*4+1][31:0], W_q16_L0[g*4+2][31:0], W_q16_L0[g*4+3][31:0]}),
                    .bias(b_q16_L0[g][31:0]),
                    .y(l0[g]), .done(done0_vec[g])
                );
            end
        end

        // LAYER 1
        for (g = 0; g < 16; g++) begin : gen_l1
            if (TOTAL_BITS == 8) begin
                neuron #(.INPUTS(16), .TOTAL_BITS(8), .FRAC_BITS(4)) n (
                    .clk(clk), .rst(rst), .start(start_l1), .x(l0),
                    .w('{W_q4_L1[g*16+0],W_q4_L1[g*16+1],W_q4_L1[g*16+2],W_q4_L1[g*16+3],
                         W_q4_L1[g*16+4],W_q4_L1[g*16+5],W_q4_L1[g*16+6],W_q4_L1[g*16+7],
                         W_q4_L1[g*16+8],W_q4_L1[g*16+9],W_q4_L1[g*16+10],W_q4_L1[g*16+11],
                         W_q4_L1[g*16+12],W_q4_L1[g*16+13],W_q4_L1[g*16+14],W_q4_L1[g*16+15]}),
                    .bias(b_q4_L1[g][7:0]),
                    .y(l1[g]), .done(done1_vec[g])
                );
            end else if (TOTAL_BITS == 16) begin
                neuron #(.INPUTS(16), .TOTAL_BITS(16), .FRAC_BITS(8)) n (
                    .clk(clk), .rst(rst), .start(start_l1), .x(l0),
                    .w('{W_q8_L1[g*16+0],W_q8_L1[g*16+1],W_q8_L1[g*16+2],W_q8_L1[g*16+3],
                         W_q8_L1[g*16+4],W_q8_L1[g*16+5],W_q8_L1[g*16+6],W_q8_L1[g*16+7],
                         W_q8_L1[g*16+8],W_q8_L1[g*16+9],W_q8_L1[g*16+10],W_q8_L1[g*16+11],
                         W_q8_L1[g*16+12],W_q8_L1[g*16+13],W_q8_L1[g*16+14],W_q8_L1[g*16+15]}),
                    .bias(b_q8_L1[g][15:0]),
                    .y(l1[g]), .done(done1_vec[g])
                );
            end else begin
                neuron #(.INPUTS(16), .TOTAL_BITS(32), .FRAC_BITS(16)) n (
                    .clk(clk), .rst(rst), .start(start_l1), .x(l0),
                    .w('{W_q16_L1[g*16+0][31:0],W_q16_L1[g*16+1][31:0],W_q16_L1[g*16+2][31:0],W_q16_L1[g*16+3][31:0],
                         W_q16_L1[g*16+4][31:0],W_q16_L1[g*16+5][31:0],W_q16_L1[g*16+6][31:0],W_q16_L1[g*16+7][31:0],
                         W_q16_L1[g*16+8][31:0],W_q16_L1[g*16+9][31:0],W_q16_L1[g*16+10][31:0],W_q16_L1[g*16+11][31:0],
                         W_q16_L1[g*16+12][31:0],W_q16_L1[g*16+13][31:0],W_q16_L1[g*16+14][31:0],W_q16_L1[g*16+15][31:0]}),
                    .bias(b_q16_L1[g][31:0]),
                    .y(l1[g]), .done(done1_vec[g])
                );
            end
        end

        // LAYER 2 
        for (g = 0; g < 3; g++) begin : gen_l2
            if (TOTAL_BITS == 8) begin
                neuron #(.INPUTS(16), .TOTAL_BITS(8), .FRAC_BITS(4)) n (
                    .clk(clk), .rst(rst), .start(start_l2), .x(l1),
                    .w('{W_q4_L2[g*16+0],W_q4_L2[g*16+1],W_q4_L2[g*16+2],W_q4_L2[g*16+3],
                         W_q4_L2[g*16+4],W_q4_L2[g*16+5],W_q4_L2[g*16+6],W_q4_L2[g*16+7],
                         W_q4_L2[g*16+8],W_q4_L2[g*16+9],W_q4_L2[g*16+10],W_q4_L2[g*16+11],
                         W_q4_L2[g*16+12],W_q4_L2[g*16+13],W_q4_L2[g*16+14],W_q4_L2[g*16+15]}),
                    .bias(b_q4_L2[g][7:0]),
                    .y(l2[g]), .done(done2_vec[g])
                );
            end else if (TOTAL_BITS == 16) begin
                neuron #(.INPUTS(16), .TOTAL_BITS(16), .FRAC_BITS(8)) n (
                    .clk(clk), .rst(rst), .start(start_l2), .x(l1),
                    .w('{W_q8_L2[g*16+0],W_q8_L2[g*16+1],W_q8_L2[g*16+2],W_q8_L2[g*16+3],
                         W_q8_L2[g*16+4],W_q8_L2[g*16+5],W_q8_L2[g*16+6],W_q8_L2[g*16+7],
                         W_q8_L2[g*16+8],W_q8_L2[g*16+9],W_q8_L2[g*16+10],W_q8_L2[g*16+11],
                         W_q8_L2[g*16+12],W_q8_L2[g*16+13],W_q8_L2[g*16+14],W_q8_L2[g*16+15]}),
                    .bias(b_q8_L2[g][15:0]),
                    .y(l2[g]), .done(done2_vec[g])
                );
            end else begin
                neuron #(.INPUTS(16), .TOTAL_BITS(32), .FRAC_BITS(16)) n (
                    .clk(clk), .rst(rst), .start(start_l2), .x(l1),
                    .w('{W_q16_L2[g*16+0][31:0],W_q16_L2[g*16+1][31:0],W_q16_L2[g*16+2][31:0],W_q16_L2[g*16+3][31:0],
                         W_q16_L2[g*16+4][31:0],W_q16_L2[g*16+5][31:0],W_q16_L2[g*16+6][31:0],W_q16_L2[g*16+7][31:0],
                         W_q16_L2[g*16+8][31:0],W_q16_L2[g*16+9][31:0],W_q16_L2[g*16+10][31:0],W_q16_L2[g*16+11][31:0],
                         W_q16_L2[g*16+12][31:0],W_q16_L2[g*16+13][31:0],W_q16_L2[g*16+14][31:0],W_q16_L2[g*16+15][31:0]}),
                    .bias(b_q16_L2[g][31:0]),
                    .y(l2[g]), .done(done2_vec[g])
                );
            end
        end
    endgenerate

    always_comb begin
        done_l0 = 1'b1;
        for (int k = 0; k < 16; k++) done_l0 &= done0_vec[k];
        done_l1 = 1'b1;
        for (int k = 0; k < 16; k++) done_l1 &= done1_vec[k];
        done_l2 = 1'b1;
        for (int k = 0; k < 3; k++) done_l2 &= done2_vec[k];
    end

    assign done = done_l2;
    assign l2_debug = l2;

    always_comb begin
        class_out = 0;
        if (l2[0] >= l2[1] && l2[0] >= l2[2]) class_out = 0;
        else if (l2[1] >= l2[2]) class_out = 1;
        else class_out = 2;
    end

endmodule
