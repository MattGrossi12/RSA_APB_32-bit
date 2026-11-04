module testbench;

    localparam LATENCY = 2;

    logic pclk_i;
    logic presetn_i;
    logic srst_i;
    logic rsa_rst_o;

    amba_3_apb_reset #(
        .LATENCY(LATENCY)
    ) dut (
        .pclk_i(pclk_i),
        .presetn_i(presetn_i),
        .srst_i(srst_i),
        .rsa_rst_o(rsa_rst_o)
    );

endmodule
