```sh
#!/bin/bash
  
./simv -gui=dve          \
       +number_of_pkts=4  \
       +bytes_per_line=16  \
       +vcd+vcdpluson       \
       +fsdb+fsdbpluson 2> error.log | tee simulation.log


```
