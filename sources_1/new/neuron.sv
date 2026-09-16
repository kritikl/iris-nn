module neuron #(
    parameter int INPUTS     = 4,
    parameter int TOTAL_BITS = 16,
    parameter int FRAC_BITS  = 8
)(
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic signed [TOTAL_BITS-1:0] x [0:INPUTS-1],
    input  logic signed [TOTAL_BITS-1:0] w [0:INPUTS-1],
    input  logic signed [TOTAL_BITS-1:0] bias,
    output logic signed [TOTAL_BITS-1:0] y,
    output logic done
);
    localparam int ACC_BITS = 2*TOTAL_BITS + 8;

    typedef enum logic [2:0] {IDLE, CLEAR, MAC, WAIT_ACC, FINALIZE, DONE_STATE} state_t;

    state_t state;
    logic [$clog2(INPUTS)-1:0] idx;

    logic vmac_en, vmac_clear;
    logic signed [TOTAL_BITS-1:0] vmac_a, vmac_b;

    // 1. Declare accumulator signal BEFORE VMAC instantiation
    logic signed [ACC_BITS-1:0] vmac_acc;

    vmac #(.WIDTH(TOTAL_BITS)) u_vmac (
        .clk(clk), .rst(rst),
        .clear(vmac_clear), .en(vmac_en),
        .a(vmac_a), .b(vmac_b),
        .acc(vmac_acc)
    );

   always_ff @(posedge clk) begin
    if (rst) begin
        state      <= IDLE;
        idx        <= '0;
        y          <= '0;
        done       <= 1'b0;
        vmac_en    <= 1'b0;
        vmac_clear <= 1'b0;
    end else begin
        vmac_en    <= 1'b0;
        vmac_clear <= 1'b0;
        done       <= 1'b0;

        case (state)
            IDLE: 
                if (start) begin
                    idx   <= '0;
                    state <= CLEAR;
                end

            CLEAR: begin
                vmac_clear <= 1'b1;
                state      <= MAC;
            end

            MAC: begin
                vmac_a  <= x[idx];
                vmac_b  <= w[idx];
                vmac_en <= 1'b1;
                if (idx == INPUTS-1)
                    state <= WAIT_ACC;
                else
                    idx <= idx + 1;
            end

            WAIT_ACC: 
                state <= FINALIZE;

            FINALIZE: begin
                logic signed [ACC_BITS-1:0] sum;
                sum = vmac_acc + (signed'(ACC_BITS'(bias)) <<< FRAC_BITS);
                y   <= (sum < 0) ? '0 : sum[FRAC_BITS + TOTAL_BITS - 1 : FRAC_BITS];
                state <= DONE_STATE;
            end

            DONE_STATE: begin
                done <= 1'b1;
                if (!start)
                    state <= IDLE;
            end
        endcase
    end
end
endmodule
