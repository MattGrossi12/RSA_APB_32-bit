module amba_3_apb_data_io_top #(
    parameter   DATA_WIDTH = 32,
                ADDR_WIDTH = 11,
                D_WID = DATA_WIDTH - 1,
                A_WID = ADDR_WIDTH - 1
)(
    input  logic [A_WID:0]  paddr_i,

    input  logic [D_WID:0]  pwdata_i,
    input  logic [D_WID:0]  op_ctl_i,
                            op_sts_i,
                            op_ier_i,
                            op_msg_i,
                            op_exp_i,
                            op_mod_i,
                            op_res_i,
                            op_idr_i,

    output logic [D_WID:0]  prdata_o,
    output logic [D_WID:0]  op_ctl_o,
                            op_sts_o,
                            op_ier_o,
                            op_msg_o,
                            op_exp_o,
                            op_mod_o,
                            op_res_o,
                            op_idr_o,
                            
    output logic [3:0]      oaddr_o,

    output                  addr_valid_o
);

wire [3:0] oaddr_w;

assign oaddr_w = paddr_i[5:2];
assign oaddr_o = oaddr_w;
assign addr_valid_o = ~|paddr_i[11:5];

    amba_3_apb_data_i_demux #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) da_i_dm (
        .paddr_i(oaddr_w),
        .pwdata_i(pwdata_i),
        .op_ctl_o(op_ctl_o),
        .op_sts_o(op_sts_o),
        .op_ier_o(op_ier_o),
        .op_msg_o(op_msg_o),
        .op_exp_o(op_exp_o),
        .op_mod_o(op_mod_o),
        .op_res_o(op_res_o),
        .op_idr_o(op_idr_o)
    );

    amba_3_apb_data_o_mux #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) da_o_m (
        .paddr_i(oaddr_w),
        .op_ctl_i(op_ctl_i),
        .op_sts_i(op_sts_i),
        .op_ier_i(op_ier_i),
        .op_msg_i(op_msg_i),
        .op_exp_i(op_exp_i),
        .op_mod_i(op_mod_i),
        .op_res_i(op_res_i),
        .op_idr_i(op_idr_i),
        .prdata_o(prdata_o)
    );

endmodule: amba_3_apb_data_io_top
