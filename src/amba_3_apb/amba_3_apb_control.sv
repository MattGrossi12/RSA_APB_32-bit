
module amba_3_apb_control #(
    parameter   DATA_WIDTH = 32,
                D_WID = DATA_WIDTH - 1
)(
    // APB Interface:
    input  logic            pclk_i,
    input  logic            presetn_i,

    // APB Control Inputs:
    input  logic            psel_i,
    input  logic            penable_i,
    input  logic            pwrite_i,
    input  logic [3:0]      paddr_i,
    input  logic [D_WID:0]  pwdata_i,
    input  logic            addr_valid_i,

    // Register Bank Status:
    input  logic            status_done_i,
    input  logic            status_error_i,

    // Interrupt Enable Register:
    input  logic            done_ie_i,
    input  logic            err_ie_i,

    // Wrapper Control Inputs:
    input  logic            busy_i,

    // APB Control Outputs:
    output logic            pready_o,
    output logic            pslverr_o,
    output logic            irq_o,

    // Register Bank Write Enables:
    output logic            ctl_we,
    output logic            status_we,
    output logic            ier_we,
    output logic            msg_we,
    output logic            exp_we,
    output logic            mod_we
);

// APB Phase Encoding:
localparam logic [3:0] IDLE   = 4'b1000,
                       SETUP  = 4'b1001,
                       ACCESS = 4'b1011;

// Reduced Register Bank Address:
localparam logic [3:0] CTRL_R   = 4'b0000,
                       STATUS_R = 4'b0001,
                       IER_R    = 4'b0010,
                       MSG_R    = 4'b0011,
                       EXP_R    = 4'b0100,
                       MOD_R    = 4'b0101,
                       RESULT_R = 4'b0110,
                       ID_R     = 4'b0111;

// APB3: Zero Wait States
assign pready_o = 1'b1;

assign irq_o = (status_done_i  && done_ie_i) || (status_error_i && err_ie_i);

logic [3:0] apb_phase;

always_comb
    begin : control_branch

        if (psel_i && !penable_i)
            begin
                apb_phase = SETUP;
            end

        else if (psel_i && penable_i)
            begin
                apb_phase = ACCESS;
            end

        else
            begin
                apb_phase = IDLE;
            end
    end

// APB Operation Decoder:
always_comb
    begin : APB_actions

        // Default values:
        ctl_we    = 1'b0;
        status_we = 1'b0;
        ier_we    = 1'b0;
        msg_we    = 1'b0;
        exp_we    = 1'b0;
        mod_we    = 1'b0;
        pslverr_o = 1'b0;

        case (apb_phase)

            // IDLE phase:
            IDLE:
                begin
                    // No active APB transaction.
                end

            // SETUP phase:
            SETUP:
                begin
                    // Address, control and write data are prepared.
                    // No register write is performed.
                end

            // ACCESS phase:
            ACCESS:
                begin
                    // Address validation:
                    if (!addr_valid_i)
                        begin
                            pslverr_o = 1'b1;
                        end

                    // APB Write operation:
                    else if (pwrite_i)
                        begin
                            case (paddr_i)
                                // CTRL register:
                                CTRL_R:
                                    begin
                                        if (pwdata_i[1]) // SRST priority
                                            begin
                                                ctl_we = 1'b1;
                                            end
                                        else if (pwdata_i[0] && busy_i)
                                            begin
                                                pslverr_o = 1'b1;
                                            end
                                        else
                                            begin
                                                ctl_we = 1'b1;
                                            end
                                    end

                                // STATUS register (W1C):
                                STATUS_R:
                                    begin
                                        status_we = 1'b1;
                                    end

                                // IER register:
                                IER_R:
                                    begin
                                        ier_we = 1'b1;
                                    end

                                // MSG register:
                                MSG_R:
                                    begin
                                        if (!busy_i)
                                            begin
                                                msg_we = 1'b1;
                                            end
                                        else
                                            begin
                                                pslverr_o = 1'b1;
                                            end
                                    end

                                // EXP register:
                                EXP_R:
                                    begin
                                        if (!busy_i)
                                            begin
                                                exp_we = 1'b1;
                                            end
                                        else
                                            begin
                                                pslverr_o = 1'b1;
                                            end
                                    end

                                // MOD register:
                                MOD_R:
                                    begin
                                        if (!busy_i)
                                            begin
                                                mod_we = 1'b1;
                                            end
                                        else
                                            begin
                                                pslverr_o = 1'b1;
                                            end
                                    end

                                // Read-only registers:
                                RESULT_R, ID_R:
                                    begin
                                        pslverr_o = 1'b1;
                                    end

                                default:
                                    begin
                                        pslverr_o = 1'b1;
                                    end
                            endcase
                        end
                end

            default:
                begin
                    // Undefined APB phase.
                end

        endcase
    end

endmodule: amba_3_apb_control
