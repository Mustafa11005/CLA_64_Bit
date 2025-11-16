///////////////////////////////////////////////////////////////
// Organisation:    University of Ain Shams, IEEE       ///////
// Department:      Digital IC Design                   ///////
// Author:          Mustafa Tamer EL-Sherif             ///////
// Email:           elsherifmustafa04@gmail.com         ///////
// Date:            November 2025                       ///////
// Module Name:     N-bits Sum Block                    ///////
///////////////////////////////////////////////////////////////

module Sum_blk #(
    parameter N = 4  // Width of the sum block (number of bits to add)
) (
    input  logic [N - 1 : 0]    p_i   ,  // Propagate vector: p_i[i] = A[i] ^ B[i] for each bit position
    input  logic [N - 1 : 0]    cin   ,  // Carry vector: cin[i] is the carry INTO bit position i

    output logic [N - 1 : 0]    sum_o    // Sum output: final result for each bit position
);

    // Final sum calculation using XOR operation
    // Sum[i] = P[i] ^ Carry[i]
    // Where P[i] = A[i] ^ B[i] (from propagate signal)
    // Therefore: Sum[i] = (A[i] ^ B[i]) ^ Carry[i] = A[i] ^ B[i] ^ Carry[i]
    // This is the standard full adder sum equation applied to all N bits in parallel
    assign sum_o = p_i ^ cin ;
endmodule