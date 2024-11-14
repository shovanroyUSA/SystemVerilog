# Table of Contents
- [SystemVerilog Important Topics](#important-topics)
- [Projects](#projects)
# SystemVerilog
## Important Topics
[SytemVerilog]( https://github.com/shovanroyUSA/SystemVerilog/blob/main/importanttopics.md "Important references of Systemverilog")
## Projects
# Project1: SystemVerilog Testbench Essentials: Generators, Drivers, Interfaces, and More
SystemVerilog Verification Framework for Ethernet Protocol Testing

A comprehensive testbench implementation demonstrating:
- Complete testbench architecture with generator, driver, and interface components
- Constrained random generation of Ethernet frames
- Inter-process communication using SystemVerilog mailbox
- Interface-modport driven packet transmission
- Reusable verification components for networking protocols
  
Click here to see details about the project [https://github.com/shovanroyUSA/SystemVerilog/blob/main/Generate%20Eth%20packets%20and%20drive%20to%20DUT%20according%20to%20interface%20protocol.pdf]

Generate Eth packets and drive to DUT according to interface protocol

Packet Generator

1.  Generate Ethernet packets with following layers

    a.  L2

        i.  Eth header - DA: 48b, SA: 48b

        ii. VLAN may or may not be present: 32b

        iii. Eth type: 16b

    b.  L3: IP header should be one of the following types

        i.  IPv4: 20B

        ii. IPv6: 40B

    c.  L4: Should be one of the following types

        i.  TCP: 20B

        ii. UDP: 8B

2.  Packet size 64B up to 4KB

Driver

Driver gets the packet from generator and drives to DUT according to
interface protocol

![A diagram of a diagram Description automatically
generated](./media/media/image1.png){width="6.5in"
height="3.079861111111111in"}

Interface Protocol

The protocol is a simple data/valid type interface where valid qualifies
data and other control signals.

1.  Data transfer happens at every cycle, valid is high

2.  Data transfer stops if valid is low. Valid can be low for any number
    of times during packet transfer and may remain low for any number of
    cycles

3.  Packet is bounded by SOP and EOP

 

![A black and white diagram Description automatically generated with
medium confidence](./media/media/image2.png){width="6.5in"
height="1.2631944444444445in"}

Simple packet protocol

 

**Interface signals**

  ------------------------------------------------------------------------------------
  **Signal**   **Width   **Description**
               (bit)**   
  ------------ --------- -------------------------------------------------------------
  sop          1         If set, indicates start of the packet

  valid        1         If high, indicates all other signals in the interface is
                         valid. All signals should hold their previous value, each
                         cycle valid is low

  data         64        Packet data

  eop          1         If set, indicates end of the packet
  ------------------------------------------------------------------------------------

Implementation note

1.  Use SV constraint block to generate different packet types

2.  Implement packet functions to assemble header and payload bytes into
    an array

    a.  Packets represented as byte arrays is useful for the driver

3.  Use SV interface to dive the packets

Packet Generation Method

1.  **Ethernet Header object generation**

    -   destination MAC addresses generated using randomization.

    -   source MAC addresses generated using randomization.

    -   EtherType randomized with constraint value inside {**0x0800**,
        **0x86DD, 0x8100**}

        -   if generated EtherType is **0x8100**, indicates VLAN Tag is
            present and another 16 bits random value added for the Tag
            Control Information (TCI).

        -   otherwise, ignore.

    -   EType: 16 bits; EType randomized with constraint value inside
        {**0x0800**, **0x86DD**}

    -   post_randomization() generates ipv4 or ipv6 object based on the
        EType

    -   IP4 Header: IPv4 Object if EType == **0x0800**

    -   IP6 Header: IPv6 Object if EType == **0x86DD**

    -   l4_header: post_randomization() generates l4_header based on the
        ipv4 protocol or ipv6 next_header.

    -   if ipv4 protocol == 8\'h06, l4_header = 20 Bytes TCP header
        generated as random values.

    -   if ipv4 protocol == 8'h11, l4_header = 8 Bytes UDP header
        generated as random values.

    -   if ipv6 next_header == 8\'h06, l4_header = 20 Bytes TCP header
        generated as random values.

    -   if ipv6 next_header == 8'h16, l4_header = 8 Bytes UDP header
        generated as random values.

2.  **IPv4 Header object generation**

    -   IPv4 header is an object of 20 bytes defined with the following
        fields:

        -   version : 4 bits; assigned default value 4

        -   ip header length : 4 bits; generated using randomization

        -   type of service : 8 bits; generated using randomization

        -   total_length : 16 bits; generated using randomization

        -   ip identification number : 16 bits; generated using
            randomization

        -   flags : 3 bits; generated using randomization

        -   fragment_offset : 13 bits; generated using randomization

        -   ttl : 8 bits; generated using randomization

        -   protocol : 8 bits; **generated using randomization with
            constraint inside {0x06, 0x11}**

        -   header_checksum : 16 bits; generated using randomization

        -   source_ip : 32 bits; generated using randomization

        -   dest_ip : 32 bits; generated using randomization

3.  **IPv6 Header object generation**

    -   IPv6 header is an object of 40 bytes with the following fields:

        -   version : 4 bits; assigned default value 6

        -   traffic_class : 8 bits; generated using randomization

        -   flow_label : 20 bits; generated using randomization

        -   payload_length : 16 bits; generated using randomization

        -   next_header : 8 bits; **generated using randomization with
            constraint inside {0x06, 0x11}**

        -   hop_limit : 8 bits; generated using randomization

        -   source_ip : 128 bits; generated using randomization

        -   destination_ip : 128 bit; generated using randomization

4.  **Transport Layer header (l4_header) generation:**

It is implemented as a byte array. The protocol field in the **IPv4
Header** or the next_header field in the **IPv6 Header** specifies
whether it is TCP or UDP:

if protocol field in the **IPv4 Header** is **0x06**, 20 bytes are
appended as TCP header with random values.

if protocol field in the **IPv4 Header** is **0x11**, 8 bytes are
appended as UDP header with random values.

similarly,

if next_header field in the **IPv6 Header** is **0x06**, 20 bytes are
appended as TCP header with random values.

if next_header field in the **IPv6 Header** is **0x11**, 8 bytes are
appended as UDP header with random values.

5.  **Payloads generation:**

    a.  Based on the packet size (64 B - 4 KB) a variable size random
        bytes will be added as payload. the size should be constrained.

6.  **Assembling the ethernet header, ipv4 header/ipv6 header, l4 header
    and payloads into packets: pack() function:**

Combining the generated Ethernet header object, IPv4 or IPv6 header
object and transport layer byte array.

Adding any additional payload data based on the packet size.

A pack function assembles a byte array into a packet.

![A diagram of a flowchart Description automatically
generated](./media/media/image3.png){width="6.5in"
height="7.759722222222222in"}

2\. Generator Implementation

Generator - Generates (create and randomize) the ethernet packets and
send to driver through mailbox.

Generator class has the following members:

-   Packet object,

-   mailbox handle,

-   put the packet into the mailbox

Mailbox.put() method is called to place the packet in the mailbox.

**3. Mailbox Implementation**

Mailboxes are used as a communication mechanism to transfer data between
a packet generator to a driver.

-   Mailbox object is instantiated in the top module

**4. Driver Implementation**

Driver gets the packet from the mailbox, breaks it into fleets, and
drive fleets to the signals in the interface modport.

Driver Gets the packet from generator using mailbox.

Driver implemented as a class, has the following members:

-   virtual Interface

-   Packet handle

-   mailbox handle

-   Method to drive packet in fleets

Mailbox.get() method is called to retrieve a packet from the mailbox.

Flowchart that describes the process of transferring a packet in chunks
from the driver to the interface:

1.  **Start**: Begin the transfer process.

2.  **Retrieve Packet**: Use Mailbox.get() to retrieve the packet from
    the mailbox.

3.  Calculate the number of fleets needed to drive a packet.

4.  **While Loop**: Continue transferring fleets until the entire packet
    is transferred.

    -   **Prepare next fleet**: Extract the next 64-bits from the
        packet.

    -   **Set SOP**: If it's the first chunk, set SOP (Start of Packet)
        to 1; otherwise, set it to 0.

    -   **Set eop**: If it's the last chunk, set eop (End of Packet) to
        1; otherwise, set it to 0.

    -   **Drive signal to the interface**: drive signals (SOP, valid,
        data, eop) according to the protocol. if valid is low, hold
        values etc.

    -   **Wait for Clock Edge**: Wait for the next clock edge to
        synchronize the transfer.

5.  **End**: Complete the transfer process.

![A diagram of a flowchart Description automatically
generated](./media/media/image4.png){width="5.972222222222222in"
height="9.0in"}

**5. Interface Implementation**

**Interface Defines the signals (clock, SOP, valid, data, eop) and
a modport**

Interface is instantiated inside the top module.

**6. Top Module**

-   At the top module packet generator, driver, mailbox, interface
    objects are instantiated. mailbox handle is passed to the generator
    and driver class.

-   Clock is created for sampling

-   bounded mailbox of depth 1 is implemented

-   Two parallel processes are forked:

    a.  generator to generate packets and put it into the mailbox

    b.  driver to get a packet from mailbox to drive it to the modport
        of the interface

-   vpd file generated to see the waveform.

## testbench.sv
```systemverilog
module tb;
  logic clk = 0;
  mailbox mbx;
  int number_of_pkts;
  int bytes_per_line;
  drv_intf intf(clk);
  driver drv_pkt;
  generator gen_pkt; 
  // Clock generation
  initial begin
    clk = 0; // Initialize clock to 0
    forever begin #1 clk = ~clk; // Toggle clock every 5 time units
    end 
  end
   
  initial begin
    // Get the number of packets from plusarg
    if (!$value$plusargs("number_of_pkts=%d", number_of_pkts)) begin
      number_of_pkts = 4; // Default to 4 packet if plusarg is not provided
    end
     // Get the line width from plusarg
    if (!$value$plusargs("line_width=%d", bytes_per_line)) begin
      bytes_per_line = 16; // Default to 16 bytes per line if plusarg is not provided
    end
    mbx = new(1);
    drv_pkt = new();
    gen_pkt = new();
    gen_pkt.mbx = mbx;
    drv_pkt.mbx = mbx; 
    drv_pkt.intf = intf;   
    fork
      gen_pkt.run(number_of_pkts, bytes_per_line);
      drv_pkt.run(number_of_pkts, bytes_per_line);
    join_none
    forever begin
      @(posedge clk);
      if(drv_pkt.pkt_cnt() == number_of_pkts) begin
        repeat(5) begin @(posedge clk); end
        $finish;
        end
    end
  end // initial begin

  initial begin
    $vcdplusfile("eth_pkt_waveform.vpd");
    $vcdpluson;
  end
endmodule
```
## intf.sv
```systemverilog
interface drv_intf(input logic clk);
  //input logic clk = clk; 
  logic  sop;
  logic valid;
  logic [63:0] data;
  logic        eop;
  //create modports
  modport mport_drv(output sop, eop, valid, data);
endinterface // drv_intf
```
## ipv4header.sv
```systemverilog
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
```
## ipv6header.sv
```systemverilog
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
```
## packet.sv
```systemverilog
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
```
## generator.sv
```systemverilog
class generator;
  packet eth_pkt, copy_pkts;
  mailbox mbx;
  task run(int number_of_pkts, int bytes_per_line = 16);
    for (int i = 0; i < number_of_pkts; i++) begin
      eth_pkt = new();
      copy_pkts = eth_pkt;
      if(!eth_pkt.randomize())$display("Randomization Failed");
      eth_pkt.copy_data(copy_pkts);
      mbx.put(copy_pkts);
      $display("\nGenerator::display packet() pkt_size = %0d", copy_pkts.pkt_size);
      copy_pkts.display_fields(bytes_per_line);
    end // for (int i = 0; i < number_of_pkts; i++)
  endtask
endclass
```
## driver.sv
```systemverilog
class driver;
  mailbox mbx;
  virtual drv_intf intf;
  int num_pkt_received = 0;
  packet eth_pkt;
  
  function int pkt_cnt();
    return num_pkt_received;
  endfunction // pkt_cnt
  
  // Task to drive a packet
  task drive_packet(packet eth_pkt, int bytes_per_line = 16);
    logic [7:0][7:0] data;
    logic            valid = 0;
    int              number_of_fleets;
    int              offset = 0;
    int              clk_cnt = 0;
    byte             byte_array[];
    eth_pkt.pack(byte_array);
    eth_pkt.display_fields(bytes_per_line);
    number_of_fleets = ($size(byte_array) + 7) / 8;
    $display("\ndriver::display packet() pkt_size = %0d number_of_fleets = %0d", $size(byte_array), number_of_fleets);
    /* Set all signals low at first clock cycle */
    intf.mport_drv.valid <= 1'b0;
    intf.mport_drv.sop <= 1'b0;
    intf.mport_drv.eop <= 1'b0;
    @(posedge intf.clk);
    $display("clk_cycle = %0d sop = %0d valid = %0d data =  %0h eop = %0d", 
                 clk_cnt++, intf.mport_drv.sop, intf.mport_drv.valid, intf.mport_drv.data, intf.mport_drv.eop);
    for (int i = 0; i < number_of_fleets; i++) begin
      std::randomize(valid) with { valid dist {1 := 90, 0 :=10}; };
      intf.mport_drv.valid <= valid; 
      if(i == 0) intf.mport_drv.sop <= 1'b1;
      else intf.mport_drv.sop <= 1'b0;
      if(i == (number_of_fleets - 1)) intf.mport_drv.eop <= 1'b1;
      else intf.mport_drv.eop <= 1'b0;
      for (int j = 7; j >= 0; j--) begin
        if(offset < $size(byte_array)) data[j] = byte_array[offset++];
      end
      intf.mport_drv.data <= data;
      // Hold values if valid is low
      while(valid == 0) begin
        @(posedge intf.clk);
        $display("clk_cycle = %0d sop = %0d valid = %0d fleet%0d: %0h eop = %0d", 
                 clk_cnt++, intf.mport_drv.sop, intf.mport_drv.valid, i, intf.mport_drv.data, intf.mport_drv.eop);
        std::randomize(valid) with { valid dist {1 := 90, 0 := 10}; };
        intf.mport_drv.valid <= valid;
      end // end while
      @(posedge intf.clk);
      $display("clk_cycle = %0d sop = %0d valid = %0d fleet%0d: %0h eop = %0d", 
               clk_cnt++, intf.mport_drv.sop, intf.mport_drv.valid, i, intf.mport_drv.data, intf.mport_drv.eop);
    end // for (int i = 0; i < number_of_fleets; i++)
    //After all packet transfer set valid = 0, sop = 0, eop = 0
    intf.mport_drv.valid <= 1'b0;
    intf.mport_drv.sop <= 1'b0;
    intf.mport_drv.eop <= 1'b0;
    @(posedge intf.clk);
  endtask // drive_packet
    
  task run(int number_of_pkts, int bytes_per_line = 16);
    forever begin
      mbx.get(eth_pkt);
      drive_packet(eth_pkt);
      num_pkt_received++;
    end
  endtask
endclass
```
# How to build and run the project?
## bld.sh
```sh
#!/bin/bash

# Initialize the environment
source .init

# Clean up previous build files
rm -rf ./AN.DB ./csrc ./DVEfiles ./simv ./simv.daidir ./ucli.key ./vc_hdrs.h simulation.log

# Compile the SystemVerilog files
vcs                                                      \
-sverilog                                                \
-kdb -full64 -debug_access+all                           \
-top tb \
 ../src/ipv4header.sv ../src/ipv6header.sv ../src/packet.sv ../src/generator.sv ../src/driver.sv ../src/intf.sv ../src/testbench.sv
```
## run.sh
```sh
#!/bin/bash

# Run the simulation with specified parameters
./simv +number_of_pkts=100   \
       +bytes_per_line=8   \
       +vcd+vcdpluson | tee simulation.log
````
## run_gui.sh
```sh
#!/bin/bash
  
./simv -gui=dve +number_of_pkts=4 +bytes_per_line=8 \
       +vcd+vcdpluson 2> error.log | tee simulation.log
````
## installation
1. use src and run folders to separate source code and shell script
2. execute bld.sh
3. execute run.sh
4. to see waveform using DVE execute run_gui.sh
