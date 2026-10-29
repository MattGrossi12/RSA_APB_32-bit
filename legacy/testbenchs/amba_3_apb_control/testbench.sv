module testbench;

    localparam DATA_WIDTH = 32;
    localparam D_WID = DATA_WIDTH - 1;

    logic            psel_i;
    logic            penable_i;
    logic            pwrite_i;
    logic [3:0]      paddr_i;
    logic [D_WID:0]  pwdata_i;
    logic            addr_valid_i;
    logic            status_done_i;
    logic            status_error_i;
    logic            done_ie_i;
    logic            err_ie_i;
    logic            busy_i;
    logic            pready_o;
    logic            pslverr_o;
    logic            irq_o;
    logic            we_ctrl_o;
    logic            we_status_o;
    logic            we_ier_o;
    logic            we_msg_o;
    logic            we_exp_o;
    logic            we_mod_o;

    amba_3_apb_control #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .psel_i(psel_i),
        .penable_i(penable_i),
        .pwrite_i(pwrite_i),
        .paddr_i(paddr_i),
        .pwdata_i(pwdata_i),
        .addr_valid_i(addr_valid_i),
        .status_done_i(status_done_i),
        .status_error_i(status_error_i),
        .done_ie_i(done_ie_i),
        .err_ie_i(err_ie_i),
        .busy_i(busy_i),
        .pready_o(pready_o),
        .pslverr_o(pslverr_o),
        .irq_o(irq_o),
        .we_ctrl_o(we_ctrl_o),
        .we_status_o(we_status_o),
        .we_ier_o(we_ier_o),
        .we_msg_o(we_msg_o),
        .we_exp_o(we_exp_o),
        .we_mod_o(we_mod_o)
    );

endmodule
