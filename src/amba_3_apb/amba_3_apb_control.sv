module amba_3_apb_control (
    //Op Inputs:
    input logic             pclk_i,     //Rising edge  APB clock. Also clocks rsa_core (core_clk). 
    input logic             presetn_i,  //APB reset. Resets all registers, the sequencer and rsa_core.
    
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

always_comb 
    begin : control_path
        case (c_state)
            IDLE: 
                begin
                    if (!psel_i && !penable_i) n_state = SETUP;
                    else                       n_state = IDLE;
                end

            SETUP: 
                begin
                    if (psel_i && !penable_i && ) n_state = ACCESS;
                    else                     n_state = ERROR;
                end

            ACCESS: 
                begin
                    if (psel_i && penable_i) n_state = ACCESS;
                    else                     n_state = IDLE;
                end

            ERROR: 
                begin
                    if (psel_i && !penable_i) n_state = SETUP;
                    else                      n_state = ERROR;
                end

            default: n_state = IDLE;
        endcase
    end

endmodule: amba_3_apb_control
