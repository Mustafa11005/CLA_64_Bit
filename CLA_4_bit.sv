///////////////////////////////////////////////////////////////
// Organisation:    University of Ain Shams, IEEE       ///////
// Department:      Digital IC Design                   ///////
// Author:          Mustafa Tamer EL-Sherif             ///////
// Email:           elsherifmustafa04@gmail.com         ///////
// Date:            November 2025                       ///////
// Module Name:     4-bit Carry Lookahead Adder (CLA)   ///////
///////////////////////////////////////////////////////////////

module cla_4bit (
    input  logic cin    ,
    input  logic g0_i   ,
    input  logic p0_i   ,
    input  logic g1_i   ,
    input  logic p1_i   ,
    input  logic g2_i   ,
    input  logic p2_i   ,
    input  logic g3_i   ,
    input  logic p3_i   ,

    output logic c1_o   ,
    output logic c2_o   ,
    output logic c3_o   ,
    output logic c4_o   ,
    output logic p_o    ,
    output logic g_o
);

    // Carry-out calculations
    assign c1_o = g0_i | (p0_i & cin)                                                                                           ;
    
    assign c2_o = g1_i | (p1_i & g0_i) | (p1_i & p0_i & cin)                                                                    ;
    
    assign c3_o = g2_i | (p2_i & g1_i) | (p2_i & p1_i & g0_i) | (p2_i & p1_i & p0_i & cin)                                      ;
    
    assign c4_o = g3_i | (p3_i & g2_i) | (p3_i & p2_i & g1_i) | (p3_i & p2_i & p1_i & g0_i) | (p3_i & p2_i & p1_i & p0_i & cin) ;

    // Group Propagate and Generate
    assign p_o = p3_i & p2_i & p1_i & p0_i                                                  ;

    assign g_o = g3_i | (p3_i & g2_i) | (p3_i & p2_i & g1_i) | (p3_i & p2_i & p1_i & g0_i)  ;

endmodule