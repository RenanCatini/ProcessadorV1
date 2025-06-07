`include "processor.v"

module testbench;
    reg clock = 0;
    reg [15:0] iin;
    reg resetn = 1;

    wire [15:0] bus;
    
    always #1 clock = !clock;
    initial $dumpfile("testeProcessador.vcd");
    initial $dumpvars(0, testbench);

    processor p(clock, iin, resetn, bus);
    
    initial begin
        # 0 resetn = 0;
        # 2 resetn = 1;
        # 8 iin = 16'b1010000000011100;
        # 8 iin = 16'b1010010000001010;
        # 8 iin = 16'b0010000010000000;
        # 8 iin = 16'b1000000000000000;
        # 8 $finish;
    end

endmodule