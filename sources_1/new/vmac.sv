module vmac #(
    parameter int WIDTH = 16
)(
    input  logic clk,
    input  logic rst,
    input  logic clear,
    input  logic en,
    input  logic signed [WIDTH-1:0] a,
    input  logic signed [WIDTH-1:0] b,
    output logic signed [2*WIDTH + 8 -1:0] acc
);
    logic signed [2*WIDTH-1:0] mult;

    always_comb begin
        mult = a * b;        
    end

    always_ff @(posedge clk) begin
        if (rst)
            acc <= '0;
        else if (clear)
            acc <= '0;
        else if (en)
            acc <= acc + mult;
    end
endmodule