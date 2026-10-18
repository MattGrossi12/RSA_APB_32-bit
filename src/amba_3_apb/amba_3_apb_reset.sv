
module amba_3_apb_reset #(
    parameter LATENCY = 2
)(
    // Clock and Reset:
    input  logic pclk_i,
    input  logic presetn_i,

    // Software Reset:
    input  logic srst_i,

    // Reset Outputs:
    output logic presetp_o,
    output logic presetnsync_o,
    output logic rsa_rst_o
);

// Reset Synchronizer Registers:
logic [LATENCY-1:0] reset_sync_reg;

// Reset Synchronizer:
always_ff @(posedge pclk_i or negedge presetn_i)
    begin
        if (!presetn_i)
            begin
                reset_sync_reg <= '0;
            end
        else
            begin
                reset_sync_reg <= (reset_sync_reg << 1) | 1'b1;
            end
    end

// Reset Outputs:
assign presetp_o     = !presetn_i;
assign presetnsync_o = reset_sync_reg[LATENCY-1];

// RSA Core Reset:
assign rsa_rst_o = !presetnsync_o || srst_i;

endmodule: amba_3_apb_reset
