#!/bin/bash
  
./simv -gui=dve +number_of_pkts=4 +bytes_per_line=8 \
       +vcd+vcdpluson 2> error.log | tee simulation.log
