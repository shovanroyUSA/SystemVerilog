class packet;
  rand bit [47:0] DA;
  rand bit [47:0] SA;
  rand bit [15:0] EtherType;
  rand bit [15:0] TCI;
  rand bit [15:0] EType; // upto this 18 bytes
  ipv6header ipv6; // 40 Bytes
  ipv4header ipv4; // 20 Bytes
  rand bit [7:0] l4_header[];
  rand int pkt_size;
  // Constraint to keep pkt_size within the range 64 to 4096
  constraint pkt_size_range {
    //pkt_size >= 64; pkt_size <= 4096;
    pkt_size inside {[64 : 4096]};
  }
  rand bit [7:0]     payload[];
  constraint EtherType_c {
    EtherType inside {16'h0800, 16'h86DD, 16'h8100};
  }
  constraint EType_c {
    EType inside {16'h0800, 16'h86DD};
  }
  
  function new();
    //ipv4 = new();
    //ipv6 = new();
  endfunction
 
  function int header_size();
    int hdr_size = 6 + 6; //DA + SA = 12 Bytes
    if (EtherType == 16'h8100) hdr_size += 4; // only if vlan tag present, add 4 bytes(2 for EtherType + 2 for TCI); 
    hdr_size += 2; // add 2 bytes for Etype
    if (EType == 16'h0800) hdr_size += 20; // ipv4.header_size(); // if 
    if (EType == 16'h86DD) hdr_size += 40; // ipv6.header_size();
    if (ipv4 != null) begin 
      if(ipv4.protocol == 8'h06) hdr_size += 20; // l4_tcp_header
      else if (ipv4.protocol == 8'h11) hdr_size += 8; 
    end
    if (ipv6 !== null) begin
      if(ipv6.next_header == 8'h06) hdr_size += 20; //TCP 
      else if(ipv6.next_header == 8'h11) hdr_size += 8; //UDP
    end
    return hdr_size;
  endfunction // header_size
 
  function void post_randomize();
    //$display("post_randomize(): EType = %h", EType);
    if (EType == 16'h0800) begin
      ipv6 = null;
      ipv4 = new();
      ipv4.randomize();
      if ( ipv4.protocol == 8'h06) begin // TCP
        l4_header = new[20];
        for(int i = 0; i < 20; i++) l4_header[i] = $urandom ;
      end
      else if (ipv4.protocol == 8'h11) begin
        l4_header = new[8];
        for(int i = 0; i < 8; i++) l4_header[i] = $urandom ;
      end
    end
    else if (EType == 16'h86DD) begin
      ipv4 = null;
      ipv6 = new();
      ipv6.randomize();
      if (ipv6.next_header == 8'h11) begin //UDP
        l4_header = new[8];
        for(int i = 0; i < 8; i++) l4_header[i] = $urandom ;
      end
      else if ( ipv6.next_header == 8'h06) begin //TCP
        l4_header = new[20];
        for(int i = 0; i < 20; i++) l4_header[i] = $urandom ;
      end
    end
    if(pkt_size < header_size()) pkt_size = header_size();
    //generate payloads
    payload = new[pkt_size - header_size()];
    for(int i = 0; i < pkt_size - header_size(); i++) payload[i] = $urandom;
  endfunction // post_randomize
  
  function void pack(ref byte byte_array[]);
    int byte_count = 0;
    byte temp_array[];
    byte_array = new[pkt_size];
    $display("Ethernet Frame: header_size = %0d, packet size = %0d", this.header_size(), pkt_size);
    // Pack DA
    for (int i = 0; i < $bits(DA)/8;i++) byte_array[byte_count++] = DA[8*i +: 8];
    // Pack SA
    for (int i = 0; i < $bits(SA)/8;i++) byte_array[byte_count++] = SA[8*i +: 8];
    // Check EtherType
    if (EtherType == 16'h8100) begin //if VLAN tag present
      // Pack EtherType
      for (int i = 0; i < $bits(EtherType)/8;i++) byte_array[byte_count++] = EtherType[8*i +: 8];
      // Pack TCI
      for (int i = 0; i < $bits(TCI)/8;i++) byte_array[byte_count++] = TCI[8*i +: 8];
    end
    //Pack Etype
    for (int i = 0; i < $bits(EType)/8;i++) byte_array[byte_count++] = EType[8*i +: 8];
    // Check EType and pack IPV4 or IPV6 header
    if (EType == 16'h0800) begin
      if ( ipv4 != null) ipv4.pack(temp_array);
      for (int i = 0; i < temp_array.size(); i++) byte_array[byte_count++] = temp_array[i];
    end else if (EType == 16'h86DD) begin
      if ( ipv6 != null) ipv6.pack(temp_array);
      for (int i = 0; i < temp_array.size(); i++) byte_array[byte_count++] = temp_array[i];
    end
    //Check protocol of IPV4 and next_header 0f IPV6 header and pack l4-header
    if ( ipv4 != null && ipv4.protocol == 8'h06 || ipv6 != null && ipv6.next_header == 8'h06) begin
      for (int i = 0; i < 20; i++) byte_array[byte_count++] = l4_header[i];
    end
    else if (ipv4 != null && ipv4.protocol == 8'h11 || ipv6 != null && ipv6.next_header == 8'h11) begin
      for(int i = 0; i < 8; i++) byte_array[byte_count++] = l4_header[i]; // switch-case can be used
    end
    //pack payload bytes
    //$display("$size(payload)= %0d", pkt_size - header_size());
    for (int i = 0; i < pkt_size - header_size(); i++) byte_array[byte_count++] = payload[i];
  endfunction

  function  void copy_data(input packet copy_to);
    copy_to.DA  = this.DA;
    copy_to.SA = this.SA;
    copy_to.EtherType = this.EtherType;
    copy_to.TCI = this.TCI;
    copy_to.EType  = this.EType;
    if (this.EType == 16'h0800) this.ipv4.copy_data(copy_to.ipv4);
    else if (this.EType == 16'h86DD) this.ipv6.copy_data(copy_to.ipv6);
    copy_to.l4_header = this.l4_header;
    copy_to.payload = this.payload;
    copy_to.pkt_size = this.pkt_size;
  endfunction
  
  function void display_fields(int bytes_per_line = 16);
    $display("Displaying Ethernet Packet of frame size:%0d", pkt_size);
    $write("DA: 0x%h ", DA);
    $write("SA: 0x%h ", SA);
    if (EtherType == 16'h8100) begin // if VLAN tag present display vlan + TCI
      $write("VLAN_Tag: 0x%h ", EtherType);
      $write("TCI: 0x%h ", TCI);
    end
    $write("EType: 0x%h ", EType);
    if (EType == 16'h0800) begin //if IPV4 header
      if(ipv4 != null) begin
        $display("ipv4 header: ");
        ipv4.display_fields();
        if ( ipv4.protocol == 8'h06) $write("TCP ");
        else if (ipv4.protocol == 8'h11) $write("UDP ");
      end
    end
    else if (EType == 16'h86DD) begin //if ipv6 header
      if(ipv6 != null) begin
        $write("\nipv6 header:: ");
        ipv6.display_fields();
        if (ipv6.next_header == 8'h06) $write("TCP ");
        else if (ipv6.next_header == 8'h11) $write("UDP ");
      end
    end
    $write("header(as hex byte array): ");
    for(int i = 0; i < $size(l4_header); i++) begin
      $write("%h ", l4_header[i]);
    end
    $write("\npayload(as hex byte array):");
    for (int i = 0; i < $size(payload); i++) begin
      if(i % bytes_per_line == 0) $write("\n[B%02d]", i);
      $write("%h ", payload[i]);
    end
  endfunction //
  
/* -----\/----- EXCLUDED -----\/-----
  function  packet copy();
    copy = new();
    copy.DA  = this.DA;
    copy.SA = this.SA;
    copy.EtherType = this.EtherType;
    copy.TCI = this.TCI;
    copy.EType  = this.EType;
    if (this.EType == 16'h0800) copy.ipv4 = ipv4.copy;
    else if (this.EType == 16'h86DD) copy.ipv6 = ipv6.copy;
    copy.l4_header = this.l4_header;
    copy.payload = this.payload;
    copy.pkt_size = this.pkt_size;
    return copy;
  endfunction
 
  function void display_byte_array(int bytes_per_line = 16, input byte byte_array[]);
    int byte_count = 0;
    $write("[B%03d]:", byte_count);
    for (int i = 0; i < byte_array.size(); i++) begin
      $write("%02h ", byte_array[i]);
      if (++byte_count % bytes_per_line == 0) $write("\n[B%03d]:", byte_count);
    end
    if (byte_count % bytes_per_line != 0) $write("\n");
  endfunction // display

  function void display(int bytes_per_line = 16);
    int byte_count = 0; 
    $display("Ethernet frame size:%0d", pkt_size);
    $write("[B%02d]:",byte_count);
    for (int i = 0; i < 6;i++) begin
      $write("%02h ", DA[8*i +: 8]);
      if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
    end
    for (int i = 0; i < 6;i++) begin
      $write("%02h ", SA[8*i +: 8]);
      if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
    end
    for (int i = 0; i < 2;i++) begin
      $write("%02h ", EtherType[8*i +: 8]);
      if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
    end
    // Check if EtherType is VLAN? then print TCI
    if (EtherType == 16'h8100) begin
      for (int i = 0; i < 2;i++) begin
        $write("%02h ", TCI[8*i +: 8]);
        if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
      end
    end 
    for (int i = 0; i < 2;i++) begin
      $write("%02h ", EType[8*i +: 8]);
      if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
    end
    if (EType == 16'h0800) begin //if IPV4 header
      if(ipv4 != null) begin
        ipv4.display(byte_count, bytes_per_line);
        byte_count += 20;
      end
    end
    else if (EType == 16'h86DD) begin //if ipv6 header
      if(ipv6 != null) begin 
        ipv6.display(byte_count, bytes_per_line);
        byte_count += 40;
      end
    end
    for (int i = 0; i < $size(l4_header); i++) begin
      $write("%02h ", l4_header[i]); 
      if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
    end
    // add payload 
    for (int i = 0; i < $size(payload); i++) begin
      $write("%02h ", payload[i]); 
      if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
    end
    if (++byte_count % bytes_per_line != 0) $write("\n"); 
  endfunction // print
 -----/\----- EXCLUDED -----/\----- */

endclass
