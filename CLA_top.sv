///////////////////////////////////////////////////////////////
// Organisation:    University of Ain Shams, IEEE       ///////
// Department:      Digital IC Design                   ///////
// Author:          Mustafa Tamer EL-Sherif             ///////
// Email:           elsherifmustafa04@gmail.com         ///////
// Date:            November 2025                       ///////
// Module Name:     Carry Lookahead Adder TOP (CLA)     ///////
///////////////////////////////////////////////////////////////

module CLA_top #(
    parameter int DATA_WIDTH = 64
)(
    input  logic [DATA_WIDTH-1:0] A,
    input  logic [DATA_WIDTH-1:0] B,
    input  logic                  cin,
    output logic [DATA_WIDTH-1:0] sum,
    output logic                  cout
);

    localparam int NUM_GROUPS = DATA_WIDTH / 4;
    localparam int NUM_LEVELS = ($clog2(DATA_WIDTH)/2); // levels: 0..NUM_LEVELS

    logic [DATA_WIDTH - 1 : 0] g_vector;
    logic [DATA_WIDTH - 1 : 0] p_vector;

    logic [NUM_LEVELS : 0] g_group [NUM_GROUPS - 1 : 0];
    logic [NUM_LEVELS : 0] p_group [NUM_GROUPS - 1 : 0];

    logic [DATA_WIDTH:0] carry_vector;

    gp_gen #(
        .DATA_WIDTH(DATA_WIDTH)
    ) GP_GENERATOR (
        .x_i (A)        ,
        .y_i (B)        ,
        .g_o  (g_vector)   ,
        .p_o  (p_vector)
    );

    assign carry_vector[0] = cin;

    generate
        for (genvar i = 0 ; i < NUM_GROUPS ; i++) begin
            localparam int OFFSET = i * 4;
            logic c1, c2, c3, c4;
            cla_4bit gp4 (
                .cin(carry_vector[OFFSET]),
                .g0_i(g_vector[OFFSET]), 
                .p0_i(p_vector[OFFSET]),
                .g1_i(g_vector[OFFSET + 1]), 
                .p1_i(p_vector[OFFSET + 1]),
                .g2_i(g_vector[OFFSET + 2]), 
                .p2_i(p_vector[OFFSET + 2]),
                .g3_i(g_vector[OFFSET + 3]), 
                .p3_i(p_vector[OFFSET + 3]),
                .c1_o(c1), 
                .c2_o(c2), 
                .c3_o(c3), 
                .c4_o(c4),
                .p_o(p_group[0][i]),
                .g_o(g_group[0][i])
            );

            assign carry_vector[OFFSET + 1] = c1;
            assign carry_vector[OFFSET + 2] = c2;
            assign carry_vector[OFFSET + 3] = c3;
            assign carry_vector[OFFSET + 4] = c4;
        end
    endgenerate

    generate
        for (genvar j = 1 ; j <= NUM_LEVELS ; j++) begin : levels
            localparam int NUM_CHILD = (NUM_GROUPS / 4**(j - 1));
            localparam int NUM_PARENT = (NUM_GROUPS / 4**(j));
            for (genvar k = 0; k < NUM_PARENT; k++) begin : parents
                localparam int CHILD = k * 4;
                logic g0;
                logic p0;
                logic g1;
                logic p1;
                logic g2;
                logic p2;
                logic g3;
                logic p3;
                assign g0 = (CHILD < NUM_CHILD)      ? g_group[j - 1][CHILD] : 1'b0;
                assign p0 = (CHILD < NUM_CHILD)      ? p_group[j - 1][CHILD] : 1'b1;
                assign g1 = (CHILD + 1 < NUM_CHILD)  ? g_group[j - 1][CHILD + 1] : 1'b0;
                assign p1 = (CHILD + 1 < NUM_CHILD)  ? p_group[j - 1][CHILD + 1] : 1'b1;
                assign g2 = (CHILD + 2 < NUM_CHILD)  ? g_group[j - 1][CHILD + 2] : 1'b0;
                assign p2 = (CHILD + 2 < NUM_CHILD)  ? p_group[j - 1][CHILD + 2] : 1'b1;
                assign g3 = (CHILD + 3 < NUM_CHILD)  ? g_group[j - 1][CHILD + 3] : 1'b0;
                assign p3 = (CHILD + 3 < NUM_CHILD)  ? p_group[j - 1][CHILD + 3] : 1'b1;

                cla_4bit COMB (
                    .cin(1'b0),
                    .g0_i(g0), 
                    .p0_i(p0),
                    .g1_i(g1), 
                    .p1_i(p1),
                    .g2_i(g2), 
                    .p2_i(p2),
                    .g3_i(g3), 
                    .p3_i(p3),
                    .c1_o(),
                    .c2_o(),
                    .c3_o(),
                    .c4_o(),
                    .p_o(p_group[j][k]),
                    .g_o(g_group[j][k])
                );
            end
        end
    endgenerate

    assign cout = carry_vector[DATA_WIDTH];

    Sum_blk #(
        .N(DATA_WIDTH)
    ) SUM (
        .p_i   (p_vector),
        .cin   (carry_vector[DATA_WIDTH-1:0]),
        .sum_o (sum)
    );

endmodule
