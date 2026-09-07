`timescale 1ns / 1ps

module cpu_test();
    reg clk, rst; 
    wire halt;
    integer test_case;

    // Instantiate Unit Under Test (UUT)
    cpu uut (
        .clk(clk), 
        .rst(rst), 
        .halt(halt)
    );

    // Generate Clock (10ns period)
    always #5 clk = ~clk;
    
    // Helper task to clear RAM
    task clear_ram;
        integer i;
        begin
            for(i = 0; i < 32; i = i + 1) begin
                uut.mem.ram[i] = 0;
            end
        end
    endtask
    
    // Task to setup instructions and data
    task setup;
        input [8*30-1:0] filename;
        integer fd, i; 
        begin
            fd = $fopen(filename, "r");
            if (fd) begin
                for (i = 0; i < 32; i = i + 1) begin
                    $fscanf(fd, "%b ", uut.mem.ram[i]); 
                end
                $fclose(fd);
            end
            else $display("Cannot open");
        end
    endtask
    
    // =========================================================================
    // TESTCASES
    // =========================================================================
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
        // TEST CASE 1: Signal Verification
        // ---------------------------------------------------------------------
        test_case = 1;
        clear_ram();
        
        // Setup data
        setup("test1.txt");
        
        // Execute the program
        $display("\n--- TEST CASE 1: SIGNAL VERIFICATION ---");
        rst = 1; #10 rst = 0; 
        
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
        
        // Verification display
        $display("\n--- TEST CASE 2: ALU LOGIC OPERATIONS ---");
        rst = 1; #10 rst = 0;
        
        wait(halt === 1'b1);
        #10;
        $display("AC = %9b | Expected: 000000000", uut.ac_out);
        if (uut.ac_out === 9'b0000_00000)
            $display("TC2 RESULT: PASS");
        else
            $display("TC2 RESULT: FAIL");

//        // ---------------------------------------------------------------------
//        // TEST CASE 3: Special Logic 
//        // ---------------------------------------------------------------------
        test_case = 3;
        clear_ram();
        
        // Setup data
        setup("test3.txt");
        
        // Verification display
        $display("\n--- TEST CASE 3: SPECIAL LOGICAL OPERATIONS ---");
        rst = 1; #10 rst = 0;
        
        wait(halt === 1'b1);
        #10;
        $display("RAM[31] = %9b | Expected: 010101010", uut.mem.ram[31]);
        $display("AC = %9b | Expected: 100001110", uut.ac_out);
        if (uut.mem.ram[31] === 9'b0101_01010 && uut.ac_out === 9'b10000_1110)
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

        // Verification display
        $display("\n--- TEST CASE 4: BASIC COMBINATIONAL TEST ---");
        rst = 1; #10 rst = 0;
        
        wait(halt === 1'b1);
        #10;
        $display("RAM[22] = %9b | Expected: 001110111", uut.mem.ram[22]);
        if (uut.mem.ram[22] === 9'b00111_0111)
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
        
        $display("\n--- TEST CASE 5: COMPLEX COMBINATIONAL TEST ---");
        rst = 1; #10 rst = 0;
        
        wait(halt === 1'b1);
        #10;
        $display("Memory[31] = %9b | Expected: 010001000", uut.mem.ram[31]);
        $display("Memory[30] = %9b | Expected: 000000101", uut.mem.ram[30]);
        $display("AC = %9b | Expected: 000000000", uut.ac_out);
        
        if (uut.mem.ram[31] == 9'b0100_01000 && uut.mem.ram[30] == 9'b0000_00101 && uut.ac_out == 9'b0000_00000)
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
            $display("Time: %t | TC: %0d |  State: %3b | Opcode: %4b | AC: %9b | Halt: %b",
                 $time, test_case, uut.Controller.state, uut.opcode, uut.ac_out, halt);
        end
    end
    
endmodule