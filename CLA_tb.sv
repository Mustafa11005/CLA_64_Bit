//////////////////////////////////////////////////////////
// Organisation:    University of Ain Shams, IEEE  ///////
// Department:      Digital IC Design              ///////
// Author:          Mustafa Tamer EL-Sherif        ///////
// Email:           elsherifmustafa04@gmail.com    ///////
// Date:            November 2025                  ///////
// Module Name:     Testbench                      ///////
//////////////////////////////////////////////////////////

module top_tb ();

    // Testbench parameter - can be overridden for different bit widths
    parameter DATA_WIDTH = 64;

    // DUT input signals
    logic [DATA_WIDTH-1:0] A;    // First operand for addition
    logic [DATA_WIDTH-1:0] B;    // Second operand for addition
    logic                  cin;  // Carry input

    // DUT output signals
    logic [DATA_WIDTH-1:0] sum;  // Sum result from CLA
    logic                  cout; // Carry output from CLA

    // Counters for test statistics
    int passed_tests = 0;  // Count of successful test cases
    int failed_tests = 0;  // Count of failed test cases

    // Expected result for comparison
    logic [DATA_WIDTH:0] expected_result;  // Full width to hold sum + carry

    // Instantiate the Device Under Test (DUT)
    CLA_top #(
        .DATA_WIDTH(DATA_WIDTH)  // Pass parameterized width to CLA
    ) DUT (
        .A   (A),    // Connect operand A
        .B   (B),    // Connect operand B
        .cin (cin),  // Connect carry input
        .sum (sum),  // Connect sum output
        .cout(cout)  // Connect carry output
    );

    // Main test sequence
    initial begin
        $display("========================================");
        $display("Starting CLA Testbench");
        $display("Data Width: %0d bits", DATA_WIDTH);
        $display("========================================\n");

        // ========== Test 1: Corner Cases ==========
        $display("Test 1: Corner Cases");
        
        // Test case 1a: All zeros (minimum values)
        A = 0; B = 0; cin = 0;
        #5;  // Wait for combinational logic to settle
        check_result("All zeros");
        #5;

        // Test case 1b: All ones (maximum values, will overflow)
        A = '1; B = '1; cin = 1;  // '1 creates all-ones pattern
        #5;
        check_result("All ones with carry");
        #5;

        // Test case 1c: Maximum value + 0
        A = '1; B = 0; cin = 0;
        #5;
        check_result("Max + 0");
        #5;

        // Test case 1d: Carry propagation test (alternating pattern)
        A = {DATA_WIDTH{1'b1}};  // All ones
        B = 1;                   // Add 1 to trigger full carry chain
        cin = 0;
        #5;
        check_result("Carry propagation chain");
        #5;

        // ========== Test 2: Power-of-2 Values ==========
        $display("\nTest 2: Power-of-2 Values");
        
        // Test addition of powers of 2 (single bit set)
        for (int i = 0; i < DATA_WIDTH; i++) begin
            A = (1 << i);  // 2^i
            B = 0;
            cin = 0;
            #5;
            check_result($sformatf("2^%0d", i));
            #5;
        end

        // ========== Test 3: Alternating Bit Patterns ==========
        $display("\nTest 3: Alternating Bit Patterns");
        
        // Pattern: 0x5555... (01010101...)
        A = {DATA_WIDTH{2'b01}};
        B = {DATA_WIDTH{2'b10}};  // 0xAAAA... (10101010...)
        cin = 0;
        #5;
        check_result("0x5555... + 0xAAAA...");
        #5;

        // Pattern: Same with carry
        A = {DATA_WIDTH{2'b01}};
        B = {DATA_WIDTH{2'b10}};
        cin = 1;
        #5;
        check_result("0x5555... + 0xAAAA... + 1");
        #5;

        // ========== Test 4: Sequential Values ==========
        $display("\nTest 4: Sequential Additions");
        
        // Test sequential numbers
        for (int i = 0; i < 20; i++) begin
            A = i;
            B = i + 1;
            cin = i % 2;  // Alternate carry input
            #5;
            check_result($sformatf("Sequential %0d", i));
            #5;
        end

        // ========== Test 5: Random Vectors ==========
        $display("\nTest 5: Random Test Vectors");
        
        // Comprehensive random testing
        repeat (1000) begin
            A = $random;    // Generate random value for A
            B = $random;    // Generate random value for B
            cin = $random;  // Random carry input (0 or 1)
            #5;

            // Verify result matches expected sum
            check_result("Random");

            #5;
        end

        // ========== Test 6: Stress Test - Near Overflow ==========
        $display("\nTest 6: Near-Overflow Cases");
        
        // Test values near maximum
        for (int i = 0; i < 10; i++) begin
            A = ({DATA_WIDTH{1'b1}} - i);  // Max - i
            B = i;
            cin = $random % 2;
            #5;
            check_result($sformatf("Near-max %0d", i));
            #5;
        end

        // ========== Final Report ==========
        $display("\n========================================");
        $display("Test Summary:");
        $display("  Passed: %0d", passed_tests);
        $display("  Failed: %0d", failed_tests);
        $display("  Total:  %0d", passed_tests + failed_tests);
        
        if (failed_tests == 0) begin
            $display("  Status: ALL TESTS PASSED ✓");
        end else begin
            $display("  Status: SOME TESTS FAILED ✗");
        end
        $display("========================================\n");

        $stop;  // Stop simulation
    end

    // Task to check and report results
    // Compares DUT output against expected value and updates statistics
    task check_result(string test_name);
        // Calculate expected result: full width addition
        expected_result = A + B + cin;
        
        // Compare DUT output {cout, sum} with expected result
        if ({cout, sum} !== expected_result) begin
            // Mismatch detected - report error
            $error("[%s] FAIL: A=%0h, B=%0h, cin=%0b => {cout,sum}=%0h, expected=%0h", 
                   test_name, A, B, cin, {cout, sum}, expected_result);
            failed_tests++;
        end else begin
            // Test passed
            $display("[%s] PASS: A=%0h + B=%0h + %0b = %0h", 
                     test_name, A, B, cin, {cout, sum});
            passed_tests++;
        end
    endtask

endmodule