set_clock_latency -source -early -max -rise  -0.147869 [get_ports {pclk_i}] -clock pclk_i 
set_clock_latency -source -early -max -fall  -0.138669 [get_ports {pclk_i}] -clock pclk_i 
set_clock_latency -source -late -max -rise  -0.147869 [get_ports {pclk_i}] -clock pclk_i 
set_clock_latency -source -late -max -fall  -0.138669 [get_ports {pclk_i}] -clock pclk_i 
