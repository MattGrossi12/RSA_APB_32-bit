module testbench;

    localparam DATA_WIDTH = 32;
    localparam D_WID = DATA_WIDTH - 1;

    logic            pclk_i;
    logic            presetn_i;
    logic [D_WID:0]  pwdata_i;
    logic            we_ctrl_i;
    logic            we_status_i;
    logic            we_ier_i;
    logic            we_msg_i;
    logic            we_exp_i;
    logic            we_mod_i;
    logic            rsa_wp_busy_i;
    logic            rsa_wp_done_i;
    logic            rsa_wp_error_i;
    logic [D_WID:0]  rsa_wp_dout_i;
    logic            start_o;
    logic            srst_o;
    logic            status_done_o;
    logic            status_error_o;
    logic            done_ie_o;
    logic            err_ie_o;
    logic [D_WID:0]  op_sts_o;
    logic [D_WID:0]  op_ier_o;
    logic [D_WID:0]  op_msg_o;
    logic [D_WID:0]  op_exp_o;
    logic [D_WID:0]  op_mod_o;
    logic [D_WID:0]  op_res_o;
    logic [D_WID:0]  op_idr_o;

    amba_3_apb_regbank #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .pclk_i(pclk_i),
        .presetn_i(presetn_i),
        .pwdata_i(pwdata_i),
        .we_ctrl_i(we_ctrl_i),
        .we_status_i(we_status_i),
        .we_ier_i(we_ier_i),
        .we_msg_i(we_msg_i),
        .we_exp_i(we_exp_i),
        .we_mod_i(we_mod_i),
        .rsa_wp_busy_i(rsa_wp_busy_i),
        .rsa_wp_done_i(rsa_wp_done_i),
        .rsa_wp_error_i(rsa_wp_error_i),
        .rsa_wp_dout_i(rsa_wp_dout_i),
        .start_o(start_o),
        .srst_o(srst_o),
        .status_done_o(status_done_o),
        .status_error_o(status_error_o),
        .done_ie_o(done_ie_o),
        .err_ie_o(err_ie_o),
        .op_sts_o(op_sts_o),
        .op_ier_o(op_ier_o),
        .op_msg_o(op_msg_o),
        .op_exp_o(op_exp_o),
        .op_mod_o(op_mod_o),
        .op_res_o(op_res_o),
        .op_idr_o(op_idr_o)
    );

endmodule
