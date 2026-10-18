module testbench;

    localparam DATA_WIDTH = 32;
    localparam D_WID = DATA_WIDTH - 1;

    logic             pclk_i;
    logic             presetn_i;
    logic             presetnsync_i;
    logic             start_i;
    logic             rsa_rst_i;
    logic [D_WID:0]   op_msg_i;
    logic [D_WID:0]   op_exp_i;
    logic [D_WID:0]   op_mod_i;
    logic             rsa_wp_busy_o;
    logic             rsa_wp_done_o;
    logic             rsa_wp_error_o;
    logic [D_WID:0]   rsa_wp_dout_o;

    amba_3_apb_rsa_wrapper_top #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .pclk_i(pclk_i),
        .presetn_i(presetn_i),
        .presetnsync_i(presetnsync_i),
        .start_i(start_i),
        .rsa_rst_i(rsa_rst_i),
        .op_msg_i(op_msg_i),
        .op_exp_i(op_exp_i),
        .op_mod_i(op_mod_i),
        .rsa_wp_busy_o(rsa_wp_busy_o),
        .rsa_wp_done_o(rsa_wp_done_o),
        .rsa_wp_error_o(rsa_wp_error_o),
        .rsa_wp_dout_o(rsa_wp_dout_o)
    );

endmodule
