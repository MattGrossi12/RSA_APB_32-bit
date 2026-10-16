module rsa_apb_top #(
    parameter   DATA_WIDTH = 32,
                D_WID = DATA_WIDTH - 1,
                ADDR_WIDTH = 11,
                A_WID = ADDR_WIDTH - 1
)(
    // Inputs:
    input  logic             pclk_i,
    input  logic             presetn_i,
    input  logic [D_WID:0]   pwdata_i,
    input  logic [A_WID:0]   paddr_i,
    input  logic             psel_i,
    input  logic             penable_i,
    input  logic             pwrite_i,

    // Outputs:
    output logic [D_WID:0]   prdata_o,
    output logic             pready_o,
    output logic             pslverr_o,
    output logic             irq_o
);

    logic [3:0]             oaddr_w;

    logic [D_WID:0]         op_ctl_i_w,
                            op_sts_i_w,
                            op_ier_i_w,
                            op_msg_i_w,
                            op_exp_i_w,
                            op_mod_i_w,
                            op_res_i_w,
                            op_idr_i_w;

    logic [D_WID:0]         op_ctl_o_w,
                            op_sts_o_w,
                            op_ier_o_w,
                            op_msg_o_w,
                            op_exp_o_w,
                            op_mod_o_w,
                            op_res_o_w,
                            op_idr_o_w;
                            
    logic [D_WID:0]         prdata_o_w;

/*
    // APB response defaults
    assign pready_o  = 1'b1;
    assign pslverr_o = 1'b0;
    assign irq_o     = 1'b0;

    // Default values to the register-side inputs of the data path
    assign op_ctl_i_w = '0;
    assign op_sts_i_w = '0;
    assign op_ier_i_w = '0;
    assign op_msg_i_w = '0;
    assign op_exp_i_w = '0;
    assign op_mod_i_w = '0;
    assign op_res_i_w = '0;
    assign op_idr_i_w = '0;
*/

    // Read data output from the data I/O block
    assign prdata_o = prdata_o_w;

    amba_3_apb_data_io_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_data_io_top (
        .paddr_i(paddr_i),

        .pwdata_i(pwdata_i),

        .op_ctl_i(op_ctl_i_w),
        .op_sts_i(op_sts_i_w),
        .op_ier_i(op_ier_i_w),
        .op_msg_i(op_msg_i_w),
        .op_exp_i(op_exp_i_w),
        .op_mod_i(op_mod_i_w),
        .op_res_i(op_res_i_w),
        .op_idr_i(op_idr_i_w),

        .prdata_o(prdata_o_w),

        .op_ctl_o(op_ctl_o_w),
        .op_sts_o(op_sts_o_w),
        .op_ier_o(op_ier_o_w),
        .op_msg_o(op_msg_o_w),
        .op_exp_o(op_exp_o_w),
        .op_mod_o(op_mod_o_w),
        .op_res_o(op_res_o_w),
        .op_idr_o(op_idr_o_w),

        .oaddr_o(oaddr_w),

        .addr_valid_o(addr_valid_w)
    );

    

endmodule: rsa_apb_top
