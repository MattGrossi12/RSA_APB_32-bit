set_clock_latency -source -early -max -rise  -0.0587792 [get_ports {pclk_i}] -clock pclk_i 
set_clock_latency -source -early -max -fall  -0.0608316 [get_ports {pclk_i}] -clock pclk_i 
set_clock_latency -source -late -max -rise  -0.0587792 [get_ports {pclk_i}] -clock pclk_i 
set_clock_latency -source -late -max -fall  -0.0608316 [get_ports {pclk_i}] -clock pclk_i 
