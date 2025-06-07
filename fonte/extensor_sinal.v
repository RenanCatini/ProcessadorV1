module extensor_sinal (
    input [15:0] instrucao,
    output reg [15:0] imediato
);

    always @(*) begin
        imediato = {6'b000000, instrucao[9:0]};
    end

endmodule