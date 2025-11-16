///////////////////////////////////////////////////////////////
// Organisation:    University of Ain Shams, IEEE       ///////
// Department:      Digital IC Design                   ///////
// Author:          Mustafa Tamer EL-Sherif             ///////
// Email:           elsherifmustafa04@gmail.com         ///////
// Date:            November 2025                       ///////
// Module Name:     N-bits Sum Block                    ///////
///////////////////////////////////////////////////////////////

module Sum_blk #(
    parameter N = 4
) (
    input  logic [N - 1 : 0]    p_i   ,
    input  logic [N - 1 : 0]    cin   ,

    output logic [N - 1 : 0]    sum_o
);

    assign sum_o = p_i ^ cin ;
endmodule