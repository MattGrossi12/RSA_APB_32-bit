set_clock_latency -source -early -max -rise  -0.0692472 [get_ports {pclk_i}] -clock pclk_i 
set_clock_latency -source -early -max -fall  -0.0708441 [get_ports {pclk_i}] -clock pclk_i 
set_clock_latency -source -late -max -rise  -0.0692472 [get_ports {pclk_i}] -clock pclk_i 
set_clock_latency -source -late -max -fall  -0.0708441 [get_ports {pclk_i}] -clock pclk_i 
