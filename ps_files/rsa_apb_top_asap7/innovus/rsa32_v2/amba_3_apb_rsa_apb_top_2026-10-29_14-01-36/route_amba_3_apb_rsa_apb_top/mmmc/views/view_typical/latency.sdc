set_clock_latency -source -early -max -rise  -67.4474 [get_ports {pclk_i}] -clock pclk_i 
set_clock_latency -source -early -max -fall  -65.526 [get_ports {pclk_i}] -clock pclk_i 
set_clock_latency -source -late -max -rise  -67.4474 [get_ports {pclk_i}] -clock pclk_i 
set_clock_latency -source -late -max -fall  -65.526 [get_ports {pclk_i}] -clock pclk_i 
