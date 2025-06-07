`include "counter.v"
`include "unidControle.v"
`include "registrador.v"
`include "extensor_sinal.v"
`include "multiplexador.v"
`include "ULA.v"

module processor (
    input clock,
    input [15:0] iin,
    input resetn,
    output wire [15:0] bus
);

    // Fios 
    wire [2:0] OpSelect;
    wire [7:0] reg_enable;
    wire A_enable, R_enable, clear, bus_enable;
    wire [3:0] selReg;
    wire [1:0] step;

    wire [15:0] r0_out, r1_out, r2_out, r3_out, r4_out, r5_out, r6_out, r7_out;
    wire [15:0] A_out, R_out, imm;

    wire [15:0] mux_out;
    wire [15:0] ula_out;

    // Instanciar contador
    counter contador (.clear(clear), .clock(clock), .out(step));

    // Instanciar unidade de controle
    unidControle UDC (
        .instrucao(iin), 
        .resetn(resetn),
        .step(step),
        .OpSelect(OpSelect),
        .reg_enable(reg_enable),
        .A_enable(A_enable),
        .R_enable(R_enable),
        .clear(clear),
        .selReg(selReg),
        .bus_enable(bus_enable)
    );

    // Instanciar registradores
    registrador r0 (.clock(clock), .enable(reg_enable[7]), .entrada(mux_out), .saida(r0_out));
    registrador r1 (.clock(clock), .enable(reg_enable[6]), .entrada(mux_out), .saida(r1_out));
    registrador r2 (.clock(clock), .enable(reg_enable[5]), .entrada(mux_out), .saida(r2_out));
    registrador r3 (.clock(clock), .enable(reg_enable[4]), .entrada(mux_out), .saida(r3_out));
    registrador r4 (.clock(clock), .enable(reg_enable[3]), .entrada(mux_out), .saida(r4_out));
    registrador r5 (.clock(clock), .enable(reg_enable[2]), .entrada(mux_out), .saida(r5_out));
    registrador r6 (.clock(clock), .enable(reg_enable[1]), .entrada(mux_out), .saida(r6_out));
    registrador r7 (.clock(clock), .enable(reg_enable[0]), .entrada(mux_out), .saida(r7_out));

    registrador A (.clock(clock), .enable(A_enable), .entrada(mux_out), .saida(A_out));
    registrador R (.clock(clock), .enable(R_enable), .entrada(ula_out), .saida(R_out));

    // Instanciar Extensor de sinal
    extensor_sinal extensor (.instrucao(iin), .imediato(imm));

    // Instanciar Multiplexador
    multiplexador mux(
        .r0(r0_out), .r1(r1_out), .r2(r2_out), .r3(r3_out),
        .r4(r4_out), .r5(r5_out), .r6(r6_out), .r7(r7_out),
        .R(R_out), .imm(imm), .sel(selReg), .saida(mux_out)
    );

    // Instanciar a ULA
    ULA ula (.A(A_out), .B(mux_out), .OpSelect(OpSelect), .Resul(ula_out));

    // Saida do barramento
    assign bus = (bus_enable) ? mux_out : 16'b0;
endmodule