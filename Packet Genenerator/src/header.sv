```systemverilog
class header;
  
//Header-Properties
  rand bit [47 : 0] da;
  rand bit [47 : 0] sa;
  rand bit [31 : 0] vlan;
  rand bit [15 : 0] eth;
  rand bit [159 :0] ipv4;
  rand bit [63 :0] udp;
  
  function int size();
    return ($bits(da) + $bits(sa) + $bits(vlan) + $bits(eth) + $bits(ipv4) + $bits(udp))/8;  
  endfunction // header_size
  
  function void pack(ref byte byte_array[]);
    int byte_count = 0;
    
    for (int i = 0; i < $bits(da)/8;i++) byte_array[byte_count++] = da[8*i +: 8];
    for (int i = 0; i < $bits(sa)/8;i++) byte_array[byte_count++] = sa[8*i +: 8];
    for (int i = 0; i < $bits(vlan)/8;i++) byte_array[byte_count++] = vlan[8*i +: 8];
    for (int i = 0; i < $bits(eth)/8;i++) byte_array[byte_count++] = eth[8*i +: 8]; 
    for (int i = 0; i < $bits(ipv4)/8;i++) byte_array[byte_count++] = ipv4[8*i +: 8];
    for (int i = 0; i < $bits(udp)/8;i++) byte_array[byte_count++] = udp[8*i +: 8];
   
  endfunction // pack
endclass // header

```
