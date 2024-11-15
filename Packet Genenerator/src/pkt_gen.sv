```systemverilog
class pkt_gen;
  header hdr;
 ///Payload-Property
  rand byte         payload[];
  const int         header_size; 
  const int         pkt_min_size, pkt_max_size;
  constraint size_c {
    //header_size = size();
    payload.size() inside {[pkt_min_size - header_size : pkt_max_size - header_size]};//For keeping packet size 64B - 1KB
  }
  
  function new();
    hdr = new();
    header_size = hdr.size(); 
    pkt_min_size = 64;
    pkt_max_size = 1024;
  endfunction // new
  
  function void display(byte byte_array[], int bytes_per_line);
    //Display byte array
    int byte_count = 0;
    $write("[B%03d]:",byte_count);
    for (int i = 0; i < byte_array.size();i++) begin
      $write("%02h ", byte_array[i]);
      if (++byte_count % bytes_per_line == 0) $write("\n[B%03d]:",byte_count);
    end
    if (byte_count % bytes_per_line != 0) $write("\n");
  endfunction // display
  
 //pack function assembles header + payload to form a packet
  function void pack(ref byte arr[]);
    int offset = hdr.size();
    arr = new[hdr.size() + payload.size()];
    $display("hdr_size: %02d payload size: %02d",hdr.size(),payload.size());
    
    // Pack header into byte array
    hdr.pack(arr);
    
    // Pack payload into byte array
    for (int i = 0; i < payload.size(); i++) begin 
      arr[offset + i] = payload[i]; 
    end
  endfunction // pack
 
endclass // pkt_gen

```
