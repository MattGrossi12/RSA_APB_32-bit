////////////////////////////////////////////////
// Curso de Verificação de Circuitos Digitais
// Outubro 2026
// Description: Interface
// DUT: RSA_APB
////////////////////////////////////////////////

`timescale 1ns/1ps;

interface apb_rsa_if #(
    parameter   DATA_WIDTH,
                ADDR_WIDTH
)(
    input  logic             pclk,
);

    // Signals
    logic presetn;
    logic psel; 
    logic penable; 
    logic pwrite;
    logic [ADDR_WIDTH-1:0] paddr;
    logic [DATA_WIDTH-1:0] pwdata;
    logic [DATA_WIDTH-1:0] prdata;
    logic  pready;
    logic  pslverr;
    logic  irq;

endinterface: apb_rsa_if