# Packet Generator
1. Requirement
Generate multiple Ethernet packets using SystemVerilog and display them. Use of UVM is not required

Number of packets should be taken from plusarg

Packet has 2 sections - Header and Payload

Header should contain the following fields

Destination MAC address (DA) - 48b

Source MAC address (SA) - 48b

VLAN tag - 32b

Eth Type - 16b

IPv4 header - 20B

UDP header - 8B

Payload

Variable size array of bytes

Packet length from 64B up to 1KB

All header fields and Payload should be assigned random values

Pack the generated packet into a byte array

Display the generated packets as byte array

4, 8 or 16 bytes per line

2. Design
The packet consists of two main sections: the Header and the Payload. The Header includes several fields with fixed sizes, while the Payload is a variable size array of bytes. The total packet length ranges from 64 bytes to 1KB. 


Class Diagram

The SystemVerilog module packet_gen_tb() generate number of packets based on the specified structure. The number of packets and line width are determined by plusargs . Default number of packets is 1 packet if plusargs is not provided. Similarly default line width is 16 bytes per line if plusargs is not provided. 

Display
The generated packets will be displayed as a byte array. The display format will be configurable to show 4, 8, or 16 bytes per line.

2.1. Header

Destination MAC address (DA): Randomly generated a 6-byte (bit array of 8 bits) MAC address.

Source MAC address (SA): Randomly generated a 6-byte MAC address.

VLAN tag: Randomly generated a 4-byte VLAN tag.

Eth Type: Randomly generated a 2-byte Eth Type value (e.g., 0x0800 for IPv4).

IPv4 header: Randomly generated a 20-byte IPv4 header.

UDP header: Randomly generated a 8-byte UDP header.

Header Generation
The Header is an object of header class. Each header class members are random variables. pack () method assemble the header into byte array.

2.2. Payload

Payload Generation
The payload is a variable size array of bytes, with its length equal to packet length - header length.

2.3 Packet Assembly
Packing of the Header and Payload: Combining the generated Header and Payload to form the complete packet.

Constraint on the Packet Length: Ensuring the total packet length is within the specified range (64 bytes to 1KB).

3 Generation flow
Module packet_gen_tb 
A packet_gen_tb module perform the following:

Parse the plusargs to determine the number of packets.

Parse the plusargs to determine the packet size.

Parse the plusargs to determine the number of bytes per lines.

Instantiate the packet generation objects.

Randomize the packets.

Display the generated packets.
