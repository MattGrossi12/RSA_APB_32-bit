module rsa_apb_top #(
    parameter   DATA_WIDTH = 32,
                D_WID = WIDTH-1,
                ADDR_WIDTH = 11,
                A_WID = ADDR_WIDTH-1
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
//----------------------------------------------------------------------\\
//                                  Regbank:                            \\
//----------------------------------------------------------------------\\
//CTRL -> 0x00:
//31:2 Reserved
//1: SRST
logic SRST;  //Write 1: one-cycle core_rst, sequencer to IDLE, STATUS cleared. Self-clearing. 
//0: START
logic START; //Write 1: clear DONE and ERROR, then load MSG, EXP, MOD into rsa_core. Self-clearing. Ignored with PSLVERR if BUSY = 1. 
//----------------------------------------------------------------------\\
//STATUS -> 0x04:
//31:3 Reserved
//2: ERROR
logic ERROR; //Set when core_error pulses (n = 0). Write 1 to clear.
//1: DONE
logic DONE;  //Set when core_done pulses and RESULT is updated. Write 1 to clear.
//0: BUSY
logic BUSY;  //1 from the START write until DONE or ERROR is set.
//----------------------------------------------------------------------\\
//IER -> 0x08:
//31:2 Reserved
//1: ERROR_IE
logic ERROR_IE; //1 = STATUS.ERROR drives irq
//0: DONE_IE
logic DONE_IE;  //1 = STATUS.DONE drives irq
//----------------------------------------------------------------------\\
//MSG (0x0C), EXP (0x10), MOD (0x14):

endmodule: rsa_apb_top
