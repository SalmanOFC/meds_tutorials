module sequential_multiply_tb();

logic CLK;
logic signed [15:0] A;
logic signed [15:0] B;
logic start;
logic RESET;
logic signed [31:0] product;
logic READY;

// Change Count Value
int count = 1000000;
int fd;
int simulation_run;

sequential_multiply DUT (
    .CLK(CLK),
    .A(A),
    .B(B),
    .start(start),
    .RESET(RESET),
    .product(product),
    .READY(READY)
);

// Clock generation
initial 
begin
    CLK = 0;
    forever #10 CLK = ~CLK;
end

// Reset sequence
task reset_sequence();
begin
    RESET = 0;
    start = 0;
    @(posedge CLK);
    RESET = 1;
end
endtask

// Task to perform directed test
task directed_test(input logic signed [15:0] A_in, input logic signed [15:0] B_in);
    logic signed [31:0] expected_product;

    begin
        A <= #1 A_in;
        B <= #1 B_in;
        start <= #1 1;
        @(posedge CLK);
        start <= #1 0;

        // Wait for 16 clock cycles
        repeat (16) @(posedge CLK);
    end
endtask

// Driver
task driver(input int count);
    int i;
    begin
        for (i=0; i<count; i++)
        begin
            A <= #1 ($random % 65535);
            B <= #1 ($random % 65535);
            
            start <= #1 1;
            @(posedge CLK);
            start <= #1 0;
            // Wait 16 clock cycles
            repeat(16) @(posedge CLK);
        end
    end
endtask

// Monitor
task monitor(input int simulation_run);
    int j;
    logic signed [15:0] M_A;
    logic signed [15:0] M_B;
    logic signed [31:0] expected_product;
    begin
        j = 0;
        while (simulation_run)
        begin
            while (!start)
                @(posedge CLK);
            M_A = A;
            M_B = B;
            j = j+1;
            @(posedge CLK);

            // Wait for 16 clock cycles
            repeat (15) @(posedge CLK);

            // Compute expected product
            expected_product = M_A * M_B;

            // Compare the result
            if (product !== expected_product) 
                begin
                    $display("ERROR: A=%d, B=%d, Expected Product=%d, Got=%d", M_A, M_B, expected_product, product);
                    $finish;
                end 
            else 
                begin
                    $display("Test #%0d PASS: A=%d, B=%d, Product=%d",j, M_A, M_B, product);
                end
        end
    end
endtask

  initial begin
    simulation_run = 1;
    @(posedge CLK);
    monitor(simulation_run);
  end

  // Main test sequence
  initial begin
    reset_sequence();

    // Run directed tests
    directed_test(1, 1);        //1
    directed_test(10, 0);       //2
    directed_test(-10, 0);      //3
    directed_test(0, 10);       //4
    directed_test(0, -10);      //5
    directed_test(10, 10);      //6
    directed_test(-10, 10);     //7
    directed_test(10, -10);     //8
    directed_test(-10, -10);    //9

    // Run driver and monitor after directed tests
    driver(count);

    simulation_run = 0;

    $display("###################");
    $display("\nAll tests passed!\n");
    $display("###################\n");


    $stop;
    $finish;
  end

endmodule