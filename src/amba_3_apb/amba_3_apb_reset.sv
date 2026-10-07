module amba_3_apb_reset #(
    parameter   DATA_WIDTH  = 32,
                D_WID       = WIDTH-1,
                ADDR_WIDTH  = 11,
                A_WID       = ADDR_WIDTH-1,
                LATENCY     = 2,
                L_WID       = LATENCY-1,
                MAX_COUNT   = 2**LATENCY-1
)(
    //Inputs:
    input  logic             pclk_i,     //Rising edge  APB clock. Also clocks rsa_core (core_clk). 
    input  logic             presetn_i,  //APB reset. Resets all registers, the sequencer and rsa_core.

    output logic             presetp_o,  //RSA Assyncronous reset. Resets all registers, the sequencer and rsa_core.
    output logic             presetnd_o  //APB Syncronous reset. Resets all registers, the sequencer and rsa_core.
);

logic [L_WID:0] lat_reset_counter;

//Counter to generate a synchronous reset with a latency of LATENCY cycles.
always_ff @(posedge pclk_i or negedge presetn_i) 
begin
    if (!presetn_i) lat_reset_counter   <= 1'b0;
    else            lat_reset_counter   <= lat_reset_counter + 1'b1;
end

//Synchronous reset generation with a latency of LATENCY cycles.
always_comb 
begin
    if (lat_reset_counter == {L_WID{1'b1}}) presetnd_o = 1'b0;
    else                                    presetnd_o = 1'b0;
end

//Resets attach:
assign presetp_o   = !presetn_i;

endmodule: amba_3_apb_reset
