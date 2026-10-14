
module amba_3_apb_rsa_wrapper #(
    parameter   DATA_WIDTH = 32,
                D_WID = DATA_WIDTH - 1,
                LOAD_GAP = 0
)(
    // Clock and Reset:
    input  logic             pclk_i,
    input  logic             presetn_i,
    input  logic             presetnsync_i,

    // Register Bank Control:
    input  logic             start_i,
    input  logic             rsa_rst_i,

    // RSA Operands:
    input  logic [D_WID:0]   op_msg_i,
    input  logic [D_WID:0]   op_exp_i,
    input  logic [D_WID:0]   op_mod_i,

    // RSA Wrapper Status:
    output logic             rsa_wp_busy_o,
    output logic             rsa_wp_done_o,
    output logic             rsa_wp_error_o,
    output logic [D_WID:0]   rsa_wp_dout_o
);


// RSA Core Interface:
logic               core_clk;
logic               core_rst;
logic               core_load;
logic [D_WID:0]     core_din;
logic               core_done;
logic               core_error;
logic [D_WID:0]     core_dout;
logic               core_clk_o;


// RSA Core Clock and Reset:
assign core_clk = pclk_i;
assign core_rst = rsa_rst_i;

// RSA Wrapper Outputs:
assign rsa_wp_done_o  = core_done;
assign rsa_wp_error_o = core_error;
assign rsa_wp_dout_o  = core_dout;

// RSA Core Instance:
rsa_core #(
    .DATA_WIDTH (DATA_WIDTH),
    .RESET      (1'b1),
    .LOAD       (1'b1)
) rsa_core_inst (
    .core_clk   (core_clk),
    .core_rst   (core_rst),
    .core_load  (core_load),
    .core_din   (core_din),
    .core_done  (core_done),
    .core_err   (core_error),
    .core_dout  (core_dout),
    .core_clk_o (core_clk_o)
);


endmodule: amba_3_apb_rsa_wrapper
