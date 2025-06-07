`include "decodificador.v"
`include "decode_reg.v"

module unidControle (
    input [15:0] instrucao, 
    input resetn,
    input [1:0] step,
    output reg [2:0] OpSelect,
    output reg [7:0] reg_enable,
    output reg A_enable,
    output reg R_enable,
    output reg clear,
    output reg [3:0] selReg,
    output reg bus_enable
);

    // fios para o decodificador
    wire [2:0] opcode;
    wire [2:0] RX;
    wire [2:0] RY;

    // Instanciação do decodificador
    decodificador decode (
        .instrucao(instrucao),
        .opcode(opcode),
        .RX(RX),
        .RY(RY)
    );

    // Decodificar registrador
    wire [7:0] RX_decoded;

    decode_reg reg_decoder (
        .reg_num(RX),
        .output_reg(RX_decoded)
    );

    // Codigos para operações
    parameter ADD = 3'b000;
    parameter SUB = 3'b001;
    parameter NAN = 3'b010;
    parameter OUT = 3'b100;
    parameter LDI = 3'b101;
    parameter REP = 3'b111;

    // Bloco principal
    always @(*) begin
        // Reset das saidas
        OpSelect = 3'b000;
        reg_enable = 8'b00000000;
        A_enable = 1'b0;
        R_enable = 1'b0;
        clear = 1'b0;
        selReg = 4'b0000;
        bus_enable = 1'b0;

        if(!resetn) begin
            clear = 1'b1;   // Reset no contador
        end else begin
            case(step)
                2'b00: begin
                    // Ciclo 0
                end

                2'b01: begin
                    // Ciclo 1: buscar primeiro operando
                    case(opcode)
                        ADD, SUB, NAN: begin
                            selReg = {1'b0, RX}; // Seleciona RX no mux
                            A_enable = 1'b1;    // Habilita o registrador A
                        end
                        OUT: begin 
                            selReg = {1'b0, RX};    // Prepara RX para saída
                        end
                    endcase
                end

                2'b10: begin
                    // Ciclo 2: executar operação
                    case(opcode)
                        ADD, SUB, NAN, REP: begin
                            selReg = {1'b0, RY};
                            OpSelect = opcode;
                            R_enable = 1'b1;
                        end
                        LDI: begin
                            selReg = 4'b1000;
                            OpSelect = 3'b000;
                            R_enable = 1'b1;
                        end
                        OUT: begin
                            selReg = {1'b0, RX};
                            bus_enable = 1'b1;
                        end
                    endcase
                end

                2'b11: begin
                    // Ciclo 3: Reescrita
                    case(opcode)
                        ADD, SUB, NAN, REP, LDI: begin
                            reg_enable = RX_decoded;
                            selReg = 4'b1001;   // R (resultado)
                        end
                        OUT: begin
                            selReg = {1'b0, RX};
                            bus_enable = 1'b1;
                        end
                    endcase
                end
            endcase
        end
    end      

endmodule