# ============================================================
# APB RSA peripheral - TSMC28
# Liberty time unit: 1 ns
# Target clock: 100 MHz -> 10 ns
# ============================================================

# ------------------------------------------------------------
# Primary clock
# ------------------------------------------------------------

create_clock \
    -name pclk_i \
    -period 10.0 \
    [get_ports pclk_i]


# ------------------------------------------------------------
# Input interface delays
# ------------------------------------------------------------
# External logic is assumed to consume 2 ns before inputs
# reach this block.
#
# Do NOT apply input delay to pclk_i.

set_input_delay 2.0 \
    -clock pclk_i \
    [get_ports {presetn_i psel_i penable_i pwrite_i paddr_i[*] pwdata_i[*]}]


# ------------------------------------------------------------
# Output interface delays
# ------------------------------------------------------------
# External receiving logic is assumed to require 2 ns
# of the clock period for APB outputs.
#
# Outputs are prdata_o, pready_o, pslverr_o and irq_o.

set_output_delay 2.0 \
    -clock pclk_i \
    [get_ports {prdata_o[*] pready_o pslverr_o irq_o}]