module testbench;

    logic       pclk_i;
    logic       presetn_i;
    logic       rsa_rst_i;
    logic       start_i;
    logic       core_done_i;
    logic       core_error_i;
    logic [6:0] c_state_o;

    amba_3_apb_rsa_wrapper_control dut (
        .pclk_i(pclk_i),
        .presetn_i(presetn_i),
        .rsa_rst_i(rsa_rst_i),
        .start_i(start_i),
        .core_done_i(core_done_i),
        .core_error_i(core_error_i),
        .c_state_o(c_state_o)
    );

endmodule
