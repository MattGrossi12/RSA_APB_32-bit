module testbench;

    localparam DATA_WIDTH = 32;
    localparam D_WID = DATA_WIDTH - 1;

    logic             rsa_rst_i;
    logic [6:0]       c_state_i;
    logic [D_WID:0]   op_msg_i;
    logic [D_WID:0]   op_exp_i;
    logic [D_WID:0]   op_mod_i;
    logic             core_load_o;
    logic [D_WID:0]   core_din_o;
    logic             rsa_wp_busy_o;

    amba_3_apb_rsa_wrapper_data #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .rsa_rst_i(rsa_rst_i),
        .c_state_i(c_state_i),
        .op_msg_i(op_msg_i),
        .op_exp_i(op_exp_i),
        .op_mod_i(op_mod_i),
        .core_load_o(core_load_o),
        .core_din_o(core_din_o),
        .rsa_wp_busy_o(rsa_wp_busy_o)
    );

endmodule
