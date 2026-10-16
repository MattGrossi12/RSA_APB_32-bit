module testbench;

    localparam DATA_WIDTH = 32;
    localparam D_WID = DATA_WIDTH - 1;
    localparam ADDR_WIDTH = 11;
    localparam A_WID = ADDR_WIDTH - 1;

    logic             pclk_i;
    logic             presetn_i;
    logic [D_WID:0]   pwdata_i;
    logic [A_WID:0]   paddr_i;
    logic             psel_i;
    logic             penable_i;
    logic             pwrite_i;
    logic [D_WID:0]   prdata_o;
    logic             pready_o;
    logic             pslverr_o;
    logic             irq_o;

    rsa_apb_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .pclk_i(pclk_i),
        .presetn_i(presetn_i),
        .pwdata_i(pwdata_i),
        .paddr_i(paddr_i),
        .psel_i(psel_i),
        .penable_i(penable_i),
        .pwrite_i(pwrite_i),
        .prdata_o(prdata_o),
        .pready_o(pready_o),
        .pslverr_o(pslverr_o),
        .irq_o(irq_o)
    );

endmodule
