class ipv6header;
  bit [3:0] version = 6;
  rand bit [7:0] traffic_class;
  rand bit [19:0] flow_label;
  rand bit [15:0] payload_length;
  rand bit [7:0]  next_header;
  rand bit [7:0]  hop_limit;
  rand bit [127:0] source_ip;
  rand bit [127:0] destination_ip;
  /* IPV6 header = 40 Bytes */
  constraint next_header_c {
    next_header inside {8'h06, 8'h11};
  }
  
  function void copy_data(input ipv6header copy_to);
    copy_to.version = this.version;
    copy_to.traffic_class = this.traffic_class;
    copy_to.flow_label = this.flow_label;
    copy_to.payload_length  = this.payload_length;
    copy_to.next_header = this.next_header;
    copy_to.hop_limit = this.hop_limit;
    copy_to.source_ip = this.source_ip;
    copy_to.destination_ip = this.destination_ip;
  endfunction // copy

  function int header_size();
    // return 40 + (next_header == 8'h06 ? 20 : (next_header == 8'h11 ? 8 : 0));
    return 40;
  endfunction // header_size
  
  function void pack(ref byte byte_array[]);
    int byte_count = 0;
    byte_array = new[this.header_size()];
    byte_array[byte_count++] = {version, traffic_class[7:4]};
    byte_array[byte_count++] = {traffic_class[3:0], flow_label[19:16]};
    for (int i = 0; i < $bits(flow_label[15:0])/8; i++) byte_array[byte_count++] = flow_label[8*i +: 8];
    // Pack payload_length
    for (int i = 0; i < $bits(payload_length)/8; i++) byte_array[byte_count++] = payload_length[8*i +: 8];
    // Pack next_header
    for (int i = 0; i < $bits(next_header)/8; i++) byte_array[byte_count++] = next_header[8*i +: 8];
    // Pack hop_limit
    for (int i = 0; i < $bits(hop_limit)/8; i++) byte_array[byte_count++] = hop_limit[8*i +: 8];
    // Pack source_ip
    for (int i = 0; i < $bits(source_ip)/8; i++) byte_array[byte_count++] = source_ip[8*i +: 8];
    // Pack destination_ip
    for (int i = 0; i <$bits(destination_ip)/8; i++) byte_array[byte_count++] = destination_ip[8*i +: 8];
  endfunction // pack

  function void display_fields();
    $write("version: 0x%h ", version);
    $write("traffic_class: 0x%h ", traffic_class);
    $write("flow_label: 0x%h ", flow_label);
    $write("payload_length: 0x%h ", payload_length);
    $write("next_header: 0x%h ", next_header);
    $write("hop_limit: 0x%h ", hop_limit);
    $write("\nsource_ip: 0x%h", source_ip);
    $write("\ndestination_ip: 0x%h\n", destination_ip);
  endfunction // display_fields
  
/* -----\/----- EXCLUDED -----\/-----
 function ipv6header copy();
    copy = new();
    copy.version = this.version;
    copy.traffic_class = this.traffic_class;
    copy.flow_label = this.flow_label;
    copy.payload_length  = this.payload_length;
    copy.next_header = this.next_header;
    copy.hop_limit = this.hop_limit;
    copy.source_ip = this.source_ip;
    copy.destination_ip = this.destination_ip;
    return copy;
  endfunction // copy
  

  function void display(int offset, int bytes_per_line);
    int byte_count = offset; 
    $write("%02h ", version[3:0]);
    $write("%02h ", traffic_class[7:4]);
    if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
    $write("%02h ", traffic_class[3:0]);
    $write("%02h ", flow_label[19:16]);
    if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
    for (int i = 0; i < 2;i++) begin
      $write("%02h ", flow_label[8*i +: 8]);
      if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
    end
    for (int i = 0; i < 2;i++) begin
      $write("%02h ", payload_length[8*i +: 8]);
      if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
    end
    for (int i = 0; i < 1;i++) begin
      $write("%02h ", next_header[8*i +: 8]);
      if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
    end
    for (int i = 0; i < 1;i++) begin
      $write("%02h ", hop_limit[8*i +: 8]);
      if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
    end
    for (int i = 0; i < 16;i++) begin
      $write("%02h ", source_ip[8*i +: 8]);
      if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
    end
    for (int i = 0; i < 16;i++) begin
      $write("%02h ", destination_ip[8*i +: 8]);
      if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
    end
    if (++byte_count % bytes_per_line != 0) $write("\n"); 
  endfunction // 
 -----/\----- EXCLUDED -----/\----- */
endclass
