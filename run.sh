#!/bin/bash

# Run the simulation with specified parameters
./simv +number_of_pkts=100   \
       +bytes_per_line=8   \
       +vcd+vcdpluson | tee simulation.log
