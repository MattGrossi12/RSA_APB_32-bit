module amba_3_apb_data_o_mux #(
    parameter   DATA_WIDTH = 32,
                D_WID = WIDTH-1
                ADDR_WIDTH = 11,
                A_WID = ADDR_WIDTH-1
)(
    input logic [A_WID:0]   paddr_i,    //Full address    bus
    input logic [D_WID:0]   in1,
                            in2,
                            in3,
                            in4,
                            in5,
                            in6,
                            in7,
                            in8,

    output logic [D_WID:0]  pwdata_o   //Data-to-write output
);

wire [3:0]  paddr_w = paddr_i[5:2]

// Op codes:
localparam  CTRL_R    = 4'b0000,
            STATUS_R  = 4'b0001,
            IER_R     = 4'b0010,
            MSG_R     = 4'b0011,
            EXP_R     = 4'b0100,
            MOD_R     = 4'b0101,
            RESULT_R  = 4'b0110,
            ID_R      = 4'b0111;

logic [2:0] BANK_s;

always_comb 
    begin : Mux
        case(paddr_w)
            CTRL_R:       pwdata_o = in1;
            STATUS_R:     pwdata_o = in2;
            IER_R:        pwdata_o = in3;
            MSG_R:        pwdata_o = in4;
            MOD_R:        pwdata_o = in5;
            RESULT_R:     pwdata_o = in6;
            ID_R:         pwdata_o = in7;
            default:      pwdata_o = in8;
        endcase
    end

endmodule: amba_3_apb_data_o_mux
