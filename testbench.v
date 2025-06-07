`include "processor.v"

module testbench;
    reg clock = 0;
    reg [15:0] iin;
    reg resetn = 1;

    wire [15:0] bus;
    
    always #1 clock = !clock;
    initial $dumpfile("build/testeProcessador.vcd");
    initial $dumpvars(0, testbench);

    processor p(clock, iin, resetn, bus);
    
    initial begin
        resetn = 1'b1;
        #4 resetn = 1'b0;  // Dá tempo para o clear acontecer
        #8 iin = 16'b101_000_0000011100;
        #8 iin = 16'b101_001_0000001010;
        #8 iin = 16'b001_000_001_0000000;
        #8 iin = 16'b100_000_0000000000;
        #8 $finish;
    end

endmodule