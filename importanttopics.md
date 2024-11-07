# Systemverilog programming helpful tricks for quick references

## 1. Delay Operators
- `##n`: Introduces a fixed delay of n clock cycles. For example, `a ##2 b` means that b will be evaluated 2 clock cycles after a is true.
- `##[m:n]`: Specifies a range of delays. For instance, `a ##[3:5] b` means that b can occur between 3 to 5 clock cycles after a.

## 2. Implication Operators
- `|->`: This is the overlapping implication operator. It checks if the right-hand side (RHS) condition holds true from the same cycle when the left-hand side (LHS) condition is true. For example, `a |-> b` means if a is true, then b must also be true in the same cycle.
- `|=>`: This is the non-overlapping implication operator. It checks if the RHS condition holds true one clock cycle after the LHS condition is true. For example, `a |=> b` means if a is true, then b must be true in the next clock cycle.

## 3. Repetition Operators
- `[*n]`: This operator allows you to specify that an expression should repeat continuously for n cycles. For example, `a[*3]` means a should be true for 3 consecutive cycles.
- `[->n]`: Indicates that there should be one or more delay cycles between repetitions. For example, `a[->2]` means a can repeat with at least 2 clock cycles in between.

## 4. Stability and Change Operators
- `$stable(expression)`: Returns true if the value of expression has not changed over the specified time period.
- `$rose(expression)`: Returns true if the least significant bit of expression changed from 0 to 1.
- `$fell(expression)`: Returns true if the least significant bit of expression changed from 1 to 0.


# The Stream Operator

The `stream_operator` determines the order in which blocks of data are streamed:

- `<<`: Causes blocks of data to be streamed in left-to-right order.
- `>>`: Causes blocks of data to be streamed in right-to-left order.
## Example of Stream Operator Usage

int j = { "A", "B", "C", "D" };
{ >> {j}} // generates stream "A" "B" "C" "D"
## little endian
{ << byte {j}} // generates stream "D" "C" "B" "A" (little endian)

{ << 16 {j}} // generates stream "C" "D" "A" "B"
## bit reverse
{ << { 8'b0011_0101 }} // generates stream 'b1010_1100 (bit reverse)
```c
{ << 4 { 6'b11_0101 }} // generates stream 'b0101_11
{ >> 4 { 6'b11_0101 }} // generates stream 'b1101_01 (same)
{ << 2 { { << { 4'b1101 }} }} // generates stream 'b1110
```
# Streaming operators (pack/unpack): unpack()
```c
int a, b, c;
logic [10:0] up [3:0];
logic [11:1] p1, p2, p3, p4;
bit [96:1] y = {>>{ a, b, c }}; // OK: pack a, b, c
int j = {>>{ a, b, c }}; // error: j is 32 bits < 96 bits
bit [99:0] d = {>>{ a, b, c }}; // OK: d is padded with 4 bits
{>>{ a, b, c }} = 23'b1; // error: too few bits in stream
{>>{ a, b, c }} = 96'b1; // OK: unpack a = 0, b = 0, c = 1
{>>{ a, b, c }} = 100'b11111; // OK: unpack a = 0, b = 0, c = 1
// 96 MSBs unpacked, 4 LSBs truncated
{ >> {p1, p2, p3, p4}} = up; // OK: unpack p1 = up[3], p2 = up[2],
// p3 = up[1], p4 = up[0]
```
## pack/unpack example
the following code uses streaming operators to model a packet transfer over a byte stream that
uses little-endian encoding:
```c
byte stream[$]; // byte stream
class Packet;
rand int header;
rand int len;
rand byte payload[];
int crc;
constraint G { len > 1; payload.size == len ; }
function void post_randomize; crc = payload.sum; endfunction
endclass
...
send: begin // Create random packet and transmit
byte q[$];
Packet p = new;
void'(p.randomize());
q = {<< byte{p.header, p.len, p.payload, p.crc}}; // pack
stream = {stream, q}; // append to stream
end
...
receive: begin // Receive packet, unpack, and remove
byte q[$];
Packet p = new;
{<< byte{ p.header, p.len, p.payload with [0 +: p.len], p.crc }} = stream;
stream = stream[ $bits(p) / 8 : $ ]; // remove packet
end
```
In the preceding example, the pack operation could have been written as either:
```c
q = {<<byte{p.header, p.len, p.payload with [0 +: p.len], p.crc}};
or
q = {<<byte{p.header, p.len, p.payload with [0 : p.len-1], p.crc}};
or
q = {<<byte{p}};
```
