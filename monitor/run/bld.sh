```systemverilog
#!/bin/bash

# Initialize the environment
source .init

# Clean up previous build files
rm -rf ./AN.DB ./csrc ./DVEfiles ./simv ./simv.daidir ./ucli.key ./vc_hdrs.h simulation.log *.fsdb eth_pkt_waveform.vpd

# Compile the SystemVerilog files
vcs                                                      \
-sverilog                                                \
-kdb -full64 -debug_access+all                           \
-top tb \
 ../src/tcp_header.sv ../src/udp_header.sv ../src/ipv4header.sv ../src/ipv6header.sv ../src/packet.sv ../src/generator.sv ../src/driver.sv ../src/monitor.sv ../src/intf.sv ../src/testbench.sv
```
