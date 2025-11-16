///////////////////////////////////////////////////////////////
// Organisation:    University of Ain Shams, IEEE       ///////
// Department:      Digital IC Design                   ///////
// Author:          Mustafa Tamer EL-Sherif             ///////
// Email:           elsherifmustafa04@gmail.com         ///////
// Date:            November 2025                       ///////
// Module Name:     Carry Lookahead Adder TOP (CLA)     ///////
///////////////////////////////////////////////////////////////

module CLA_top #(
    parameter int DATA_WIDTH = 64  // Width of the adder in bits (default 64-bit)
)(
    input  logic [DATA_WIDTH-1:0] A,    // First operand input
    input  logic [DATA_WIDTH-1:0] B,    // Second operand input
    input  logic                  cin,  // Carry input
    output logic [DATA_WIDTH-1:0] sum,  // Sum output
    output logic                  cout  // Carry output
);

    // Calculate number of 4-bit groups needed (e.g., 64 bits / 4 = 16 groups)
    localparam int NUM_GROUPS = DATA_WIDTH / 4;        
    // Calculate tree depth: log4(NUM_GROUPS) = log2(NUM_GROUPS)/2
    // Each level combines 4 groups from previous level into 1 group
    localparam int NUM_LEVELS = ($clog2(DATA_WIDTH)/2); 

    // Bit-level signals from initial GP generation
    logic [DATA_WIDTH - 1 : 0] g_vector;  // Generate: G[i] = A[i] & B[i] (both bits are 1)
    logic [DATA_WIDTH - 1 : 0] p_vector;  // Propagate: P[i] = A[i] ^ B[i] (carry will propagate through)

    // Hierarchical group-level GP signals
    // [NUM_LEVELS:0] represents levels 0 through NUM_LEVELS
    // Level 0: 4-bit groups, Level 1: 16-bit groups, Level 2: 64-bit groups, etc.
    logic [NUM_LEVELS : 0] g_group [NUM_GROUPS - 1 : 0];  // Group generate signals
    logic [NUM_LEVELS : 0] p_group [NUM_GROUPS - 1 : 0];  // Group propagate signals

    // Carry chain: carry_vector[i] is the carry into bit position i
    logic [DATA_WIDTH:0] carry_vector;  

    // Generate bit-level G and P for all bit positions
    // G[i] = A[i] & B[i]: this position generates a carry
    // P[i] = A[i] ^ B[i]: this position will propagate an incoming carry
    gp_gen #(
        .DATA_WIDTH(DATA_WIDTH)  
    ) GP_GENERATOR (
        .x_i (A)        ,  
        .y_i (B)        ,  
        .g_o  (g_vector)   ,  
        .p_o  (p_vector)      
    );

    // Initialize carry chain with input carry
    assign carry_vector[0] = cin;  

    // ========== LEVEL 0: Process individual bits into 4-bit groups =========
    // For 64-bit: creates 16 groups, each handling 4 consecutive bits
    generate
        for (genvar i = 0 ; i < NUM_GROUPS ; i++) begin  
            localparam int OFFSET = i * 4;  // Starting bit index: 0, 4, 8, 12, ...
            logic c1, c2, c3, c4;  // Intermediate carries within this 4-bit group
            
            // Each cla_4bit computes:
            // - Individual carries c1, c2, c3, c4 for bits within the group
            // - Group-level G and P that represent the entire 4-bit block
            // Group G = G3 | (P3&G2) | (P3&P2&G1) | (P3&P2&P1&G0)
            // Group P = P3 & P2 & P1 & P0
            cla_4bit gp4 (
                .cin(carry_vector[OFFSET]),  // Carry into this 4-bit group
                .g0_i(g_vector[OFFSET]),      // Bit 0 generate
                .p0_i(p_vector[OFFSET]),      // Bit 0 propagate
                .g1_i(g_vector[OFFSET + 1]),  // Bit 1 generate
                .p1_i(p_vector[OFFSET + 1]),  // Bit 1 propagate
                .g2_i(g_vector[OFFSET + 2]),  // Bit 2 generate
                .p2_i(p_vector[OFFSET + 2]),  // Bit 2 propagate
                .g3_i(g_vector[OFFSET + 3]),  // Bit 3 generate
                .p3_i(p_vector[OFFSET + 3]),  // Bit 3 propagate
                .c1_o(c1),  // Carry out of bit 0: C1 = G0 | (P0&Cin)
                .c2_o(c2),  // Carry out of bit 1: C2 = G1 | (P1&G0) | (P1&P0&Cin)
                .c3_o(c3),  // Carry out of bit 2
                .c4_o(c4),  // Carry out of bit 3 (= carry out of entire 4-bit group)
                .p_o(p_group[0][i]),  // Level 0 group propagate for group i
                .g_o(g_group[0][i])   // Level 0 group generate for group i
            );

            // Store computed carries back into the carry vector for sum calculation
            assign carry_vector[OFFSET + 1] = c1;  
            assign carry_vector[OFFSET + 2] = c2;  
            assign carry_vector[OFFSET + 3] = c3;  
            assign carry_vector[OFFSET + 4] = c4;  // This becomes carry input for next group
        end
    endgenerate

    // ========== LEVELS 1 to NUM_LEVELS: Build hierarchical CLA tree =========
    // Each level combines 4 groups from the previous level into 1 parent group
    // Level 1: combines 4-bit groups into 16-bit groups
    // Level 2: combines 16-bit groups into 64-bit groups, etc.
    generate
        for (genvar j = 1 ; j <= NUM_LEVELS ; j++) begin : levels  
            // Number of child groups from previous level
            // Level 1: NUM_GROUPS/4^0 = 16 (for 64-bit)
            // Level 2: NUM_GROUPS/4^1 = 4
            // Level 3: NUM_GROUPS/4^2 = 1
            localparam int NUM_CHILD = (NUM_GROUPS / 4**(j - 1));  
            
            // Number of parent groups at this level
            // Level 1: NUM_GROUPS/4^1 = 4 (16-bit groups)
            // Level 2: NUM_GROUPS/4^2 = 1 (64-bit group)
            localparam int NUM_PARENT = (NUM_GROUPS / 4**(j));     
            
            for (genvar k = 0; k < NUM_PARENT; k++) begin : parents  
                // Index of first child group that feeds into this parent
                // Parent 0 uses children 0-3, Parent 1 uses children 4-7, etc.
                localparam int CHILD = k * 4;  
                
                // Local GP signals for the 4 child groups
                logic g0, p0;  // Child group 0
                logic g1, p1;  // Child group 1
                logic g2, p2;  // Child group 2
                logic g3, p3;  // Child group 3
                
                // Fetch GP from child groups with bounds checking
                // If child doesn't exist (e.g., only 3 children), use default values
                // Default G=0 (no generate), P=1 (transparent propagate)
                assign g0 = (CHILD < NUM_CHILD)      ? g_group[j - 1][CHILD] : 1'b0;      
                assign p0 = (CHILD < NUM_CHILD)      ? p_group[j - 1][CHILD] : 1'b1;      
                assign g1 = (CHILD + 1 < NUM_CHILD)  ? g_group[j - 1][CHILD + 1] : 1'b0;  
                assign p1 = (CHILD + 1 < NUM_CHILD)  ? p_group[j - 1][CHILD + 1] : 1'b1;  
                assign g2 = (CHILD + 2 < NUM_CHILD)  ? g_group[j - 1][CHILD + 2] : 1'b0;  
                assign p2 = (CHILD + 2 < NUM_CHILD)  ? p_group[j - 1][CHILD + 2] : 1'b1;  
                assign g3 = (CHILD + 3 < NUM_CHILD)  ? g_group[j - 1][CHILD + 3] : 1'b0;  
                assign p3 = (CHILD + 3 < NUM_CHILD)  ? p_group[j - 1][CHILD + 3] : 1'b1;  

                // Combine 4 child groups into 1 parent group using CLA logic
                // Parent G = G3 | (P3&G2) | (P3&P2&G1) | (P3&P2&P1&G0)
                // Parent P = P3 & P2 & P1 & P0
                // No cin needed here - we're just combining GP signals, not computing carries
                cla_4bit COMB (
                    .cin(1'b0),  // Cin=0 for GP combination (not computing actual carries)
                    .g0_i(g0),   
                    .p0_i(p0),   
                    .g1_i(g1),   
                    .p1_i(p1),   
                    .g2_i(g2),   
                    .p2_i(p2),   
                    .g3_i(g3),   
                    .p3_i(p3),   
                    .c1_o(),     // Intermediate carries not needed - only final GP matters
                    .c2_o(),     
                    .c3_o(),     
                    .c4_o(),     
                    .p_o(p_group[j][k]),  // Parent group propagate
                    .g_o(g_group[j][k])   // Parent group generate
                );
            end
        end
    endgenerate

    // Final carry out is the carry that would propagate beyond the last bit
    assign cout = carry_vector[DATA_WIDTH];  

    // Compute final sum bits using: Sum[i] = P[i] ^ Carry[i]
    // P[i] = A[i] ^ B[i], so Sum[i] = (A[i] ^ B[i]) ^ Carry[i] = A[i] ^ B[i] ^ Carry[i]
    Sum_blk #(
        .N(DATA_WIDTH)  
    ) SUM (
        .p_i   (p_vector),                    // Bit-level propagate (A ^ B)
        .cin   (carry_vector[DATA_WIDTH-1:0]),  // All carry signals (carry into each bit)
        .sum_o (sum)                          // Final sum = (A ^ B) ^ Carry
    );

endmodule
