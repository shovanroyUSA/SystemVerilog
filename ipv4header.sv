//ipv4header.sv
class ipv4header;
  bit [3:0] version = 4;
  rand bit [3:0] ip_header_length;
  rand bit [7:0] type_of_service;
  rand bit [15:0] total_length;
  rand bit [15:0] ip_identification_number;
  rand bit [2:0]  flags;
  rand bit [12:0] fragment_offset;
  rand bit [7:0]  ttl;
  rand bit [7:0]  protocol;
  rand bit [15:0] header_checksum;
  rand bit [31:0] source_ip;
  rand bit [31:0] dest_ip;
  /* IPV4 header = 20 bytes */
  constraint protocol_c {
    protocol inside {8'h06, 8'h11};
  }
  function void display_fields();
    $write("version: 0x%h ", version);
    $write("ip_header_length: 0x%h ", ip_header_length);
    $write("type_of_service: 0x%h ", type_of_service);
    $write("total_length: 0x%h ", total_length);
    $write("ip_identification_number: 0x%h ", ip_identification_number);
    $write("flags: 0x%h ", flags);
    $write("fragment_offset: 0x%h ", fragment_offset);
    $write("ttl: 0x%h ", ttl);
    $write("protocol: 0x%h ", protocol);
    $write("header_checksum: 0x%h ", header_checksum);
    $write("source_ip: 0x%h ", source_ip);
    $write("dest_ip: 0x%02h ", dest_ip);
  endfunction // print

  function void copy_data(input ipv4header copy_to);
    copy_to.version = this.version;
    copy_to.ip_header_length = this.ip_header_length;
    copy_to.type_of_service = this.type_of_service;
    copy_to.total_length = this.total_length;
    copy_to.ip_identification_number = this.ip_identification_number;
    copy_to.flags = this.flags;
    copy_to.fragment_offset = this.fragment_offset;
    copy_to.ttl = this.ttl;
    copy_to.protocol = this.protocol;
    copy_to.header_checksum = this.header_checksum;
    copy_to.source_ip = this.source_ip;
    copy_to.dest_ip = this.dest_ip;
  endfunction // copy
   
  function int header_size();
    //return 20 + (protocol == 8'h06 ? 20 : (protocol == 8'h11 ? 8 : 0));
    return 20;   
  endfunction // header_size
  
  function void pack(ref byte byte_array[]);
    int offset = 0;
    byte_array = new[this.header_size()];
    // Pack version and ip_header_length
    byte_array[offset] = {version, ip_header_length};
    offset += 1;
    // Pack type_of_service
    for (int i = 0; i < $bits(type_of_service)/8;i++) byte_array[offset++] = type_of_service[8*i +: 8];
    // Pack total_length
    for (int i =0; i<$bits(total_length)/8; i++) byte_array[offset++] = total_length[8*i +: 8];
    // Pack ip_identification_number
    for (int i = 0; i < $bits(ip_identification_number)/8;i++) byte_array[offset++] = ip_identification_number[8*i +: 8];
    // Pack flags and fragment_offset
    byte_array[offset++] = {flags, fragment_offset[12:8]};
    for (int i = 0; i < $bits(fragment_offset)/8;i++) byte_array[offset++] = fragment_offset[8*i +: 8];
    // Pack ttl
    for (int i = 0; i < $bits(ttl)/8;i++) byte_array[offset++] = ttl[8*i +: 8];
    // Pack protocol
    for (int i = 0; i < $bits(protocol)/8;i++) byte_array[offset++] = protocol[8*i +: 8];
    // Pack header_checksum
    for (int i = 0; i < $bits(header_checksum)/8;i++) byte_array[offset++] = header_checksum[8*i +: 8];
    // Pack source_ip
    for (int i = 0; i < $bits(source_ip)/8;i++) byte_array[offset++] = source_ip[8*i +: 8];
    // Pack dest_ip
    for (int i = 0; i < $bits(dest_ip)/8;i++) byte_array[offset++] = dest_ip[8*i +: 8];
  endfunction //pack
  
/* -----\/----- EXCLUDED -----\/-----
 function ipv4header copy();
    copy = new();
    copy.version = this.version;
    copy.ip_header_length = this.ip_header_length;
    copy.type_of_service = this.type_of_service;
    copy.total_length = this.total_length;
    copy.ip_identification_number = this.ip_identification_number;
    copy.flags = this.flags;
    copy.fragment_offset = this.fragment_offset;
    copy.ttl = this.ttl;
    copy.protocol = this.protocol;
    copy.header_checksum = this.header_checksum;
    copy.source_ip = this.source_ip;
    copy.dest_ip = this.dest_ip;
    return copy;   
  endfunction // copy
 
 function void display(int offset, int bytes_per_line);
      int byte_count = offset; 
      $write("%02h ", version[3 : 0]);
      $write("%02h ", ip_header_length[3 : 0]);
      if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
      $write("%02h ", type_of_service[7 : 0]);
      if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
      
      for (int i = 0; i < 2;i++) begin
        $write("%02h ", total_length[8*i +: 8]);
        if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
      end
      for (int i = 0; i < 2;i++) begin
        $write("%02h ", ip_identification_number[8*i +: 8]);
        if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
      end
      $write("%02h ", flags[2 : 0]);
      $write("%02h ", fragment_offset[12 : 8]);
      if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
      $write("%02h ", fragment_offset[7 : 0]);
      if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
      for (int i = 0; i < 1;i++) begin
        $write("%02h ", ttl[8*i +: 8]);
        if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
      end
      for (int i = 0; i < 1;i++) begin
        $write("%02h ", protocol[8*i +: 8]);
        if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
      end
      for (int i = 0; i < 2;i++) begin
        $write("%02h ", header_checksum[8*i +: 8]);
        if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
      end
      for (int i = 0; i < 4;i++) begin
        $write("%02h ", source_ip[8*i +: 8]);
        if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);// problem
        //$display("byte_count:%0d", byte_count);
      end
      for (int i = 0; i < 4;i++) begin
        $write("%02h ", dest_ip[8*i +: 8]);
        if (++byte_count % bytes_per_line == 0) $write("\n[B%02d]:",byte_count);
      end
      if (++byte_count % bytes_per_line != 0) $write("\n"); 
    endfunction  
 -----/\----- EXCLUDED -----/\----- */
endclass
