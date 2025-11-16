///////////////////////////////////////////////////////////////////////
// Organisation:    University of Ain Shams, IEEE               ///////
// Department:      Digital IC Design                           ///////
// Author:          Mustafa Tamer EL-Sherif                     ///////
// Email:           elsherifmustafa04@gmail.com                 ///////
// Date:            November 2025                               ///////
// Module Name:     Generate and Propagate Signals Generator    ///////
///////////////////////////////////////////////////////////////////////

module gp_gen #(
    parameter DATA_WIDTH = 4
)(
    input  logic [DATA_WIDTH-1:0] x_i   ,
    input  logic [DATA_WIDTH-1:0] y_i   ,

    output logic [DATA_WIDTH-1:0] g_o   ,
    output logic [DATA_WIDTH-1:0] p_o
);

    // Generate signals
    assign g_o = x_i & y_i ;

    // Propagate signals
    assign p_o = x_i ^ y_i ;
endmodule