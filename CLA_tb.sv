module top_tb ();

    parameter DATA_WIDTH = 16;

    logic [DATA_WIDTH-1:0] A;
    logic [DATA_WIDTH-1:0] B;
    logic                  cin;
    logic [DATA_WIDTH-1:0] sum;
    logic                  cout;   

    CLA_top #(
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        .A   (A),
        .B   (B),
        .cin (cin),
        .sum (sum),
        .cout(cout)
    );

    initial begin
       repeat (1000) begin
            A = $random;
            B = $random;
            cin = $random;
            #5;

            if ({cout, sum} !== (A + B + cin)) begin
                $error("Mismatch: A=%0d, B=%0d, cin=%0d => sum=%0d (expected %0d)", A, B, cin, sum, (A + B + cin));
            end

            #5;
        end

        $stop;
    end

endmodule