`timescale 1ns / 1ps

module cpu_test();

    parameter OPCODE_WIDTH = 4;
    parameter OPERAND_WIDTH = 12;

    reg clk, rst; 
    wire halt;
    integer test_case;

    // Instantiate unit under test
    cpu uut (
        .clk(clk), 
        .rst(rst), 
        .halt(halt)
    );

    // Generate 10ns clock
    always #5 clk = ~clk;
    
    // Clear memory task
    task clear_ram;
        integer i;
        begin
            for(i = 0; i < (1 << OPERAND_WIDTH); i = i + 1) begin
                uut.mem.ram[i] = 0;
            end
        end
    endtask
    
    // Setup instructions and data
    task setup;
        input [127:0] filename;
        integer fd, i; 
        begin
            fd = $fopen(filename, "r");
            if (fd) begin
                for (i = 0; i < (1 << OPERAND_WIDTH); i = i + 1) begin
                    $fscanf(fd, "%b ", uut.mem.ram[i]); 
                end
                $fclose(fd);
            end
            else $display("Cannot open");
        end
    endtask
    
    // =====================================================================
    // TESTCASES
    // =====================================================================
    initial begin
        // Initialize clock and reset
        clk = 0;
        rst = 1;
        test_case = 0;
        #10 rst = 0;
        
        $display("=================================================");
        $display("---          STARTING CPU SIMULATION          ---");
        $display("=================================================");

        // ---------------------------------------------------------------------
        // TEST 1: Signal Verification
        // ---------------------------------------------------------------------
        test_case = 1;
        clear_ram();
        
        // Setup data
        setup("test1.txt");
        
        // Execute
        $display("\n--- TEST CASE 1: SIGNAL VERIFICATION ---");
        rst = 1; #10 rst = 0; 
        
        // Verification
        wait(halt === 1'b1);
        #10; 
        $display("TC1 RESULT: PASS");

        // ---------------------------------------------------------------------
        // TEST CASE 2: ALU Logic
        // ---------------------------------------------------------------------
        test_case = 2;
        clear_ram();
        
        // Setup data
        setup("test2.txt");
        
        // Execute
        $display("\n--- TEST CASE 2: ALU LOGIC OPERATIONS ---");
        rst = 1; #10 rst = 0;
        
        wait(halt === 1'b1);
        #10;
        $display("AC = %16b | Expected: 0110000000000000", uut.ac_out);
        if (uut.ac_out === 16'b0110000000000000)
            $display("TC2 RESULT: PASS");
        else
            $display("TC2 RESULT: FAIL");

        // ---------------------------------------------------------------------
        // TEST CASE 3: Special Logic 
        // ---------------------------------------------------------------------
        test_case = 3;
        clear_ram();
        
        // Setup data
        setup("test3.txt");
        
        // Execute
        $display("\n--- TEST CASE 3: SPECIAL LOGICAL OPERATIONS ---");
        rst = 1; #10 rst = 0;
        
        // Verification
        wait(halt === 1'b1);
        #10;
        $display("RAM[31] = %16b | Expected: 0101000000001010", uut.mem.ram[31]);
        $display("AC = %16b | Expected: 0000000000001110", uut.ac_out);
        if (uut.mem.ram[31] === 16'b0101000000001010 && uut.ac_out === 16'b1000000000001110)
            $display("TC3 RESULT: PASS");
        else
            $display("TC3 RESULT: FAIL");

        // ---------------------------------------------------------------------
        // TEST CASE 4: Basic Combinational Test
        // ---------------------------------------------------------------------
        test_case = 4;
        clear_ram();

        // Setup data
        setup("test4.txt");

        // Execute
        $display("\n--- TEST CASE 4: BASIC COMBINATIONAL TEST ---");
        rst = 1; #10 rst = 0;
        
        // Verification
        wait(halt === 1'b1);
        #10;
        $display("RAM[22] = %16b | Expected: 0011000000010111", uut.mem.ram[22]);
        if (uut.mem.ram[22] === 16'b0011000000010111)
            $display("TC4 RESULT: PASS");
        else
            $display("TC4 RESULT: FAIL");

        // ---------------------------------------------------------------------
        // TEST CASE 5: Complex Combinational Test
        // ---------------------------------------------------------------------
        test_case = 5;
        clear_ram();
        
        // Setup data
        setup("test5.txt");
        
        // Execute
        $display("\n--- TEST CASE 5: COMPLEX COMBINATIONAL TEST ---");
        rst = 1; #10 rst = 0;
        
        // Verification
        wait(halt === 1'b1);
        #10;
        $display("Memory[31] = %16b | Expected: 0000000010001000", uut.mem.ram[31]);
        $display("Memory[30] = %16b | Expected: 0000000000000101", uut.mem.ram[30]);
        $display("AC = %16b | Expected: 0000000000000000", uut.ac_out);
        
        if (uut.mem.ram[31] == 16'b0000000010001000 && uut.mem.ram[30] == 9'b0000000000000101 && uut.ac_out == 16'b0000000000000000)
            $display("TC5 RESULT: PASS");
        else
            $display("TC5 RESULT: FAIL");
        
        #20;
        $display("=================================================");
        $display("---           ENDING CPU SIMULATION           ---");
        $display("=================================================");

        $finish;
    end
    
    // =========================================================================
    // MONITORING
    // =========================================================================
    
    // TC1 display
    always @(posedge clk) begin
        if (test_case == 1) begin
            $display("[TC1 Phase Trace] Time: %t | State: %3b",
                     $time, uut.Controller.state);
        end
    end

    // Other TCs display
     always @(posedge clk) begin
        if (test_case != 1) begin
            $display("Time: %t | TC: %0d |  State: %3b | Opcode: %4b | AC: %12b | Halt: %b",
                 $time, test_case, uut.Controller.state, uut.opcode, uut.ac_out, halt);
        end
    end
    
endmodule