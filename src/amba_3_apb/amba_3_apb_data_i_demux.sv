module amba_3_apb_data_i_demux #(
    parameter   DATA_WIDTH = 32,
                D_WID = WIDTH-1
)(
    input  logic [A_WID:0]  paddr_i,    //Full address    bus
    input  logic [D_WID:0]  pwdata_i,   //Data-to-write input
    output logic [D_WID:0]  out1,
                            out2,
                            out3,
                            out4,
                            out5,
                            out6,
                            out7,
                            out8
);

wire [3:0]  pwdata_w = paddr_i[5:2]

/*
localparam  CTRL    = 5'b00000, 
            STATUS  = 5'b00100,
            IER     = 5'b01000,
            MSG     = 5'b01100,
            EXP     = 5'b10000
            MOD     = 5'b10100,
            RESULT  = 5'b11000,
            ID      = 5'b11100;
            RES     = 

*/

// Op codes:
localparam  CTRL_R    = 4'b0000,
            STATUS_R  = 4'b0001,
            IER_R     = 4'b0010,
            MSG_R     = 4'b0011,
            EXP_R     = 4'b0100
            MOD_R     = 4'b0101,
            RESULT_R  = 4'b0110,
            ID_R      = 4'b0111;

always_comb 
    begin : Demux
        case(pwdata_w)
            CTRL_R:       
                begin
                    out1 = pwdata_w;
                    out2 = 'Z;
                    out3 = 'Z;
                    out4 = 'Z;
                    out5 = 'Z;
                    out6 = 'Z;
                    out7 = 'Z;
                    out8 = 'Z;
                end
            STATUS_R:     
                begin
                    out1 = 'Z;
                    out2 = pwdata_w;
                    out3 = 'Z;
                    out4 = 'Z;
                    out5 = 'Z;
                    out6 = 'Z;
                    out7 = 'Z;
                    out8 = 'Z;
                end
            IER_R:        
                begin
                    out1 = 'Z;
                    out2 = 'Z;
                    out3 = pwdata_w;
                    out4 = 'Z;
                    out5 = 'Z;
                    out6 = 'Z;
                    out7 = 'Z;
                    out8 = 'Z;
                end
            MSG_R:        
                begin
                    out1 = 'Z;
                    out2 = 'Z;
                    out3 = 'Z;
                    out4 = pwdata_w;
                    out5 = 'Z;
                    out6 = 'Z;
                    out7 = 'Z;
                    out8 = 'Z;
                end
            MOD_R:        
                begin
                    out1 = 'Z;
                    out2 = 'Z;
                    out3 = 'Z;
                    out4 = 'Z;            
                    out5 = pwdata_w;
                    out6 = 'Z;
                    out7 = 'Z;
                    out8 = 'Z;
                end
            RESULT_R:     
                begin
                    out1 = 'Z;
                    out2 = 'Z;
                    out3 = 'Z;
                    out4 = 'Z;    
                    out5 = 'Z;
                    out6 = pwdata_w;
                    out7 = 'Z;
                    out8 = 'Z;
                end
            ID_R:         
                begin
                    out1 = 'Z;
                    out2 = 'Z;
                    out3 = 'Z;
                    out4 = 'Z;    
                    out5 = 'Z;
                    out6 = 'Z;
                    out7 = pwdata_w;
                    out8 = 'Z;
                end
            default:      
                begin
                    out1 = 'Z;
                    out2 = 'Z;
                    out3 = 'Z;
                    out4 = 'Z;    
                    out5 = 'Z;
                    out6 = 'Z;
                    out7 = 'Z;
                    out8 = 'Z;
                end
        endcase
    end

endmodule: amba_3_apb_data_i_demux
