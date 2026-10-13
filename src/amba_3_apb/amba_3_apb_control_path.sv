module amba_3_apb_control_path (

    //Interface:
    input  logic             pclk_i,     //Rising edge  APB clock. Also clocks rsa_core (core_clk). 
    input  logic             presetn_i,  //APB reset. Resets all registers, the sequencer and rsa_core.
    input  logic [3:0]       paddr_i,   

    //FSM signals-inputs:

    input logic             psel_i,     //Slave select from the APB decoder. 
    input logic             penable_i,  //Marks the second (access) phase of a transfer.
    input logic             pwrite_i,   //1 = write transfer, 0 = read transfer.
    input logic             pready
        
    endpackage

    //FSM signal-outputs:
    output logic            pready_o,   //Tied HIGH: every transfer completes with zero wait states.
    output logic            pslverr_o,  //Transfer error, valid in the access phase (see section 6.7). 
    output logic            irq_o       //Interrupt request, level sensitive (see IER register). 
);

//Apb-phase enconding
localparam [1:0]    IDLE    = 2'b00,
                    SETUP   = 2'b01,
                    ACCESS  = 2'b11;

logic [1:0] apb_phase, apb_action;




always_comb 
    begin : control_path
        if(psel_i && !penable_i)
            apb_phase = SETUP;

        else if(psel_i && penable_i)
            apb_phase = ACCESS;

        else //!psel_i and penable dont care
            apb_phase = IDLE;
    end

always_ff @(posedge pclk_i) 
    begin : ACCESS_actions //1 = write transfer, 0 = read transfer.
        if(apb_phase == ACCESS && pwrite_i)
            
        else
    end

endmodule: amba_3_apb_control_path
