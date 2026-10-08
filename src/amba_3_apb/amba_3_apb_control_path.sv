module amba_3_apb_control_path.sv (
    //FSM signals-inputs:
    input logic             psel_i,     //Slave select from the APB decoder. 
    input logic             penable_i,  //Marks the second (access) phase of a transfer.
    input logic             pwrite_i,   //1 = write transfer, 0 = read transfer.

    //FSM signal-outputs:
    output logic            pready_o,   //Tied HIGH: every transfer completes with zero wait states.
    output logic            pslverr_o,  //Transfer error, valid in the access phase (see section 6.7). 
    output logic            irq_o       //Interrupt request, level sensitive (see IER register). 
);

//FSM-states [Grey-coded]:
localparam  IDLE    = 2'b00,
            SETUP   = 2'b01,
            ACCESS  = 2'b11,
            ERROR   = 2'b10;

logic [1:0] c_state, n_state;





endmodule: amba_3_apb_control_path
