```systemverilog
class udp_header;
  rand bit [15:0] sport;
  rand bit [15:0] dport;
  rand bit [15:0] hlen;
  rand bit [15:0] checksum; // upto this  8 byte
  rand bit [15:0] range;
  
  constraint sport_c {
    sport dist {20 := 1, 80 := 1, 443 := 1, 1723 := 1, range :/ 1};
    ! (range inside {20,80,1723});
  } 
  constraint dport_c {
    dport dist {20 := 1, 80 := 1, 443 := 1, 1723 := 1, range :/ 1};
    ! (range inside {20,80,1723});
  }
  
  function void copy(input udp_header copy_from);
    this.sport = copy_from.sport ;
    this.dport = copy_from.dport;
    this.hlen = copy_from.hlen;
    this.checksum = copy_from.checksum ;
  endfunction // copy

  function void display_fields();
    $write("sport: %02d ", sport);
    $write("dport: %02d ", dport);
    $write("hlen: 0x%h ", hlen);
    $write("checksum: 0x%h ", checksum);
  endfunction //
 
  function void unpack(int byte_count, byte byte_array[]);
    // unPack sport
    for (int i = 0; i < 2; i++) this.sport[8*i +: 8] = byte_array[byte_count++];
    // unPack dport
    for (int i = 0; i < 2; i++) this.dport[8*i +: 8] = byte_array[byte_count++];
    // unPack hlen
    for (int i = 0; i < $bits(hlen)/8; i++) this.hlen[8*i +: 8] = byte_array[byte_count++];
    // unPack checksum
    for (int i = 0; i < $bits(checksum)/8; i++) this.checksum[8*i +: 8] = byte_array[byte_count++];
  endfunction // unpack

  function void pack(ref byte byte_array[]);
    int offset = 0;
    byte_array = new[8];
    // Pack source port
    for (int i = 0; i < $bits(sport)/8;i++) byte_array[offset++] = sport[8*i +: 8];
    // Pack destination port
    for (int i =0; i<$bits(dport)/8; i++) byte_array[offset++] = dport[8*i +: 8];
    // pack hlen
    for (int i = 0; i < $bits(hlen)/8;i++) byte_array[offset++] = hlen[8*i +: 8];
    // Pack header_checksum
    for (int i = 0; i < $bits(checksum)/8;i++) byte_array[offset++] = checksum[8*i +: 8];
  endfunction //pack
endclass // udp_header
```
