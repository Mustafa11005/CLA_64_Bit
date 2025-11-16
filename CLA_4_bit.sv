///////////////////////////////////////////////////////////////
// Organisation:    University of Ain Shams, IEEE       ///////
// Department:      Digital IC Design                   ///////
// Author:          Mustafa Tamer EL-Sherif             ///////
// Email:           elsherifmustafa04@gmail.com         ///////
// Date:            November 2025                       ///////
// Module Name:     4-bit Carry Lookahead Adder (CLA)   ///////
///////////////////////////////////////////////////////////////

module cla_4bit (
    input  logic cin    ,  // Carry input to the 4-bit block
    input  logic g0_i   ,  // Generate signal for bit position 0 (G0 = A0 & B0)
    input  logic p0_i   ,  // Propagate signal for bit position 0 (P0 = A0 ^ B0)
    input  logic g1_i   ,  // Generate signal for bit position 1 (G1 = A1 & B1)
    input  logic p1_i   ,  // Propagate signal for bit position 1 (P1 = A1 ^ B1)
    input  logic g2_i   ,  // Generate signal for bit position 2 (G2 = A2 & B2)
    input  logic p2_i   ,  // Propagate signal for bit position 2 (P2 = A2 ^ B2)
    input  logic g3_i   ,  // Generate signal for bit position 3 (G3 = A3 & B3)
    input  logic p3_i   ,  // Propagate signal for bit position 3 (P3 = A3 ^ B3)
    output logic c1_o   ,  // Carry out from bit position 0 (carry into bit 1)
    output logic c2_o   ,  // Carry out from bit position 1 (carry into bit 2)
    output logic c3_o   ,  // Carry out from bit position 2 (carry into bit 3)
    output logic c4_o   ,  // Carry out from bit position 3 (carry out of the 4-bit block)
    output logic p_o    ,  // Group propagate: entire 4-bit block can propagate a carry
    output logic g_o       // Group generate: entire 4-bit block generates a carry
);

    // Carry-out calculations using CLA equations
    // These are computed in parallel (no ripple delay) for fast carry computation
    
    // C1 = G0 + P0·Cin
    // Bit 0 generates a carry OR bit 0 propagates the input carry
    assign c1_o = g0_i | (p0_i & cin)                                                                                           ;
    
    // C2 = G1 + P1·G0 + P1·P0·Cin
    // Bit 1 generates OR bit 1 propagates bit 0's generate OR both bits propagate input carry
    assign c2_o = g1_i | (p1_i & g0_i) | (p1_i & p0_i & cin)                                                                    ;
    
    // C3 = G2 + P2·G1 + P2·P1·G0 + P2·P1·P0·Cin
    // Similar expansion: bit 2 generates, or propagates from lower bits
    assign c3_o = g2_i | (p2_i & g1_i) | (p2_i & p1_i & g0_i) | (p2_i & p1_i & p0_i & cin)                                      ;
    
    // C4 = G3 + P3·G2 + P3·P2·G1 + P3·P2·P1·G0 + P3·P2·P1·P0·Cin
    // Complete expansion: all possible carry generation and propagation paths
    assign c4_o = g3_i | (p3_i & g2_i) | (p3_i & p2_i & g1_i) | (p3_i & p2_i & p1_i & g0_i) | (p3_i & p2_i & p1_i & p0_i & cin) ;

    // Group Propagate and Generate for hierarchical CLA
    
    // Group Propagate: P_group = P3·P2·P1·P0
    // All 4 bits must propagate for the entire group to propagate a carry
    // If ANY bit doesn't propagate, the group doesn't propagate
    assign p_o = p3_i & p2_i & p1_i & p0_i                                                  ;

    // Group Generate: G_group = G3 + P3·G2 + P3·P2·G1 + P3·P2·P1·G0
    // Similar to C4 but WITHOUT the Cin term (independent of input carry)
    // This tells if the 4-bit group generates a carry on its own
    assign g_o = g3_i | (p3_i & g2_i) | (p3_i & p2_i & g1_i) | (p3_i & p2_i & p1_i & g0_i)  ;

endmodule