module testbench;

    localparam DATA_WIDTH = 32;
    localparam D_WID = DATA_WIDTH - 1;

    logic [3:0]      paddr_i;
    logic [D_WID:0]  op_sts_i;
    logic [D_WID:0]  op_ier_i;
    logic [D_WID:0]  op_msg_i;
    logic [D_WID:0]  op_exp_i;
    logic [D_WID:0]  op_mod_i;
    logic [D_WID:0]  op_res_i;
    logic [D_WID:0]  op_idr_i;
    logic [D_WID:0]  prdata_o;

    amba_3_apb_data_o_mux #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .paddr_i(paddr_i),
        .op_sts_i(op_sts_i),
        .op_ier_i(op_ier_i),
        .op_msg_i(op_msg_i),
        .op_exp_i(op_exp_i),
        .op_mod_i(op_mod_i),
        .op_res_i(op_res_i),
        .op_idr_i(op_idr_i),
        .prdata_o(prdata_o)
    );

endmodule
