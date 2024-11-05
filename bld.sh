#!/bin/bash

# Initialize the environment
source .init

# Clean up previous build files
rm -rf ./AN.DB ./csrc ./DVEfiles ./simv ./simv.daidir ./ucli.key ./vc_hdrs.h simulation.log

# Compile the SystemVerilog files
vcs                                                      \
-sverilog                                                \
-kdb -full64 -debug_access+all                           \
-top tb \
 ../src/ipv4header.sv ../src/ipv6header.sv ../src/packet.sv ../src/generator.sv ../src/driver.sv ../src/intf.sv ../src/testbench.sv
