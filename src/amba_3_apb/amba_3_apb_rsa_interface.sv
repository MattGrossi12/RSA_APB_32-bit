module amba_3_apb_rsa_interface #(
    //AMBAR Params:
    parameter   DATA_WIDTH = 32,
                D_WID = WIDTH-1,
                ADDR_WIDTH = 11,
                A_WID = ADDR_WIDTH-1,

    //RSA Params:
    parameter RESET = 1'b1,
    parameter LOAD = 1'b1
)(
    //Inputs:
    input logic             pclk_i,     //Rising edge  APB clock. Also clocks rsa_core (core_clk). 
    input logic             presetn_i,  //APB reset. Resets all registers, the sequencer and rsa_core.
    input logic [D_WID:0]   pwdata_i,   //Write data.
    input logic [A_WID:0]   paddr_i,    //Byte address. Bits [1:0] are ignored; accesses are word aligned. 
    input logic             psel_i,     //Slave select from the APB decoder. 
    input logic             penable_i,  //Marks the second (access) phase of a transfer.
    input logic             pwrite_i,   //1 = write transfer, 0 = read transfer.

    //Outputs:
    output logic [D_WID:0]  prdata_o,   //Read data. Reserved bits read as 0. 
    output logic            pready_o,   //Tied HIGH: every transfer completes with zero wait states.
    output logic            pslverr_o,  //Transfer error, valid in the access phase (see section 6.7). 
    output logic            irq_o       //Interrupt request, level sensitive (see IER register). 
);


    parameter DATA_WIDTH = 32,
    parameter RESET = 1'b1,
    parameter LOAD = 1'b1
)(
    input   wire core_clk,
    input   wire core_rst,
    input   wire core_load,
    input   wire [DATA_WIDTH-1:0] core_din,
    output  wire core_done,
    output  wire core_err,
    output  wire [DATA_WIDTH-1:0] core_dout,
    output  wire core_clk_o
);

endmodule: rsa_apb_top
