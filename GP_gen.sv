///////////////////////////////////////////////////////////////////////
// Organisation:    University of Ain Shams, IEEE               ///////
// Department:      Digital IC Design                           ///////
// Author:          Mustafa Tamer EL-Sherif                     ///////
// Email:           elsherifmustafa04@gmail.com                 ///////
// Date:            November 2025                               ///////
// Module Name:     Generate and Propagate Signals Generator    ///////
///////////////////////////////////////////////////////////////////////

module gp_gen #(
    parameter DATA_WIDTH = 4  // Width of the operands (number of bits)
)(
    input  logic [DATA_WIDTH-1:0] x_i   ,  // First operand (A) input
    input  logic [DATA_WIDTH-1:0] y_i   ,  // Second operand (B) input

    output logic [DATA_WIDTH-1:0] g_o   ,  // Generate output: indicates if this bit position generates a carry
    output logic [DATA_WIDTH-1:0] p_o      // Propagate output: indicates if this bit position propagates a carry
);

    // Generate signals: G[i] = A[i] & B[i]
    // A bit position generates a carry when BOTH input bits are 1
    // This carry is generated regardless of any incoming carry
    // Example: 1 + 1 = 10 (always produces a carry out)
    assign g_o = x_i & y_i ;

    // Propagate signals: P[i] = A[i] ^ B[i]
    // A bit position propagates a carry when exactly ONE input bit is 1
    // If there's an incoming carry, it will propagate to the next position
    // Example: 1 + 0 + Cin = (1 + Cin), 0 + 1 + Cin = (1 + Cin)
    // If Cin=1, result is 10 (carry propagates); if Cin=0, result is 01 (no carry)
    assign p_o = x_i ^ y_i ;
endmodule