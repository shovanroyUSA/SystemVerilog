```sh
#!/bin/bash

# Run the simulation with specified parameters
./simv +number_of_pkts=1   \
       +bytes_per_line=8   \
       +fsdb+fsdbpluson    \
       +vcd+vcdpluson | tee simulation.log
```
