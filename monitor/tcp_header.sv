```systemverilog
class tcp_header;
  rand bit [15:0] sport;
  rand bit [15:0] dport;
  rand bit [31:0] seqnum;
  rand bit [31:0] acknum;
  rand bit [3:0]  hlen;
  rand bit [3:0]  reserved;
  rand bit [7:0]  flags;
  rand bit [15:0] wsize;
  rand bit [15:0] checksum; 
  rand bit [15:0] uptr; // urgent_pointer upto this 20 byte
  rand bit [15:0] range;
  
  constraint sport_c {
    sport dist {20 := 1, 80 := 1, 443 := 1, 1723 := 1, range :/ 1};
    ! (range inside {20,80,1723});
  } 
  constraint dport_c {
    dport dist {20 := 1, 80 := 1, 443 := 1, 1723 := 1, range :/ 1};
    ! (range inside {20,80,1723});
  }

  function void unpack(int byte_count, byte byte_array[]);
    // unPack sport
    for (int i = 0; i < 2; i++) this.sport[8*i +: 8] = byte_array[byte_count++];
    // unPack dport
    for (int i = 0; i < 2; i++) this.dport[8*i +: 8] = byte_array[byte_count++];
    // unPack seqnum
    for (int i = 0; i < $bits(seqnum)/8; i++) this.seqnum[8*i +: 8] = byte_array[byte_count++];
    // unPack acknum
    for (int i = 0; i < $bits(acknum)/8; i++) this.acknum[8*i +: 8] = byte_array[byte_count++];
    //unpack hlen & reserved
    {this.hlen, this.reserved} = byte_array[byte_count++];
    $display("{this.hlen = 0x%h, this.reserved = 0x%h}", this.hlen, this.reserved);
    //unpack flags
    this.flags = byte_array[byte_count++];
    // unPack wsize
    for (int i = 0; i < $bits(wsize)/8; i++) this.wsize[8*i +: 8] = byte_array[byte_count++];
    // unPack checksum
    for (int i = 0; i < $bits(checksum)/8; i++) this.checksum[8*i +: 8] = byte_array[byte_count++];
    // unpack uptr
    for (int i = 0; i < $bits(uptr)/8; i++) this.uptr[8*i +: 8] = byte_array[byte_count++];
  endfunction // unpack
  
  function void copy(input tcp_header copy_from);
    this.sport = copy_from.sport ;
    this.dport = copy_from.dport;
    this.seqnum = copy_from.seqnum;
    this.acknum = copy_from.acknum ;
    this.hlen = copy_from.hlen;
    this.reserved = copy_from.reserved;
    this.flags = copy_from.flags ;
    this.wsize = copy_from.wsize ;
    this.checksum = copy_from.checksum ;
    this.uptr = copy_from.uptr ;
  endfunction // copy

  function void display_fields();
    $write("sport: %02d ", sport);
    $write("dport: %02d ", dport);
    $write("seqnumber: 0x%h ", seqnum);
    $write("acknum: 0x%h ", acknum);
    $write("hlen: 0x%h ", hlen);
    $write("reserved: 0x%h ", reserved);
    $write("flags: 0x%h ", flags);
    $write("wsize: 0x%h ", wsize);
    $write("checksum: 0x%h ", checksum);
    $write("urgent pointer: 0x%h ", uptr);
  endfunction // 
  
  function void pack(ref byte byte_array[]);
    int offset = 0;
    byte_array = new[20];
    // Pack source port
    for (int i = 0; i < $bits(sport) / 8; i++) byte_array[offset++] = sport[8*i +: 8];
    // Pack destination port
    for (int i =0; i<$bits(dport) / 8; i++) byte_array[offset++] = dport[8*i +: 8];
    // Pack sequence number
    for (int i = 0; i < $bits(seqnum) / 8; i++) byte_array[offset++] = seqnum[8*i +: 8];
    // Pack ack number
    for (int i = 0; i < $bits(acknum) / 8; i++) byte_array[offset++] = acknum[8*i +: 8];
    // Pack hlen and reserved
    byte_array[offset++] = {hlen, reserved}; 
    // Pack flags
    for (int i = 0; i < $bits(flags) / 8; i++) byte_array[offset++] = flags[8*i +: 8];
    // Pack window size
    for (int i = 0; i < $bits(wsize) / 8; i++) byte_array[offset++] = wsize[8*i +: 8];
    // Pack header_checksum
    for (int i = 0; i < $bits(checksum) / 8; i++) byte_array[offset++] = checksum[8*i +: 8];
    // Pack urgent_pointer
    for (int i = 0; i < $bits(uptr) / 8; i++) byte_array[offset++] = uptr[8*i +: 8];
  endfunction //pack
 
endclass // tcp_header
```
