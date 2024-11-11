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
# Part Select
The term part-select refers to a selection of one or more contiguous bits of a single-dimension packed array.
```c
logic [63:0] data;
logic [7:0] byte2;
byte2 = data[23:16]; // an 8-bit part-select from data
```
# Slicing
A single element of a packed or unpacked array can be selected using an indexed name.
```c
bit [3:0] [7:0] j; // j is a packed array
byte k;
k = j[2]; // select a single 8-bit element from j

bit signed [31:0] busA [7:0] ; // unpacked array of 8 32-bit vectors
int busB [1:0]; // unpacked array of 2 integers
busB = busA[7:6]; // select a 2-vector slice from busA
```
## The expression da[47 - 8*i -: 8] is used to extract 8-bit chunks from the 48-bit

# Array Assignment
Assignment shall be done by assigning each element of the source array to the corresponding element of the
target array. Correspondence between elements is determined by the left-to-right order of elements in each
array.
if array A is declared as int A[7:0] and array B is declared as int B[1:8], the
assignment A = B; will assign element B[1] to element A[7],
```c
int A[10:1]; // fixed-size array of 10 elements
int B[0:9]; // fixed-size array of 10 elements
int C[24:1]; // fixed-size array of 24 elements
A = B; // OK. Compatible type and same size
A = C; // type check error: different sizes
```
# Arithmatic Shift operator <<< or >>>
The arithmetic right shift shall fill the vacated bit positions with zeros if the result type is unsigned. It shall
fill the vacated bit positions with the value of the most significant (i.e., sign) bit of the left operand if the
result type is signed.
In this example, the variable result is assigned the binary value 1110, which is 1000 shifted to
the right two positions and sign-filled.
```c
module ashift;
  logic signed [3:0] start, result;
  start = 4'b1000;
  r  esult = (start >>> 2);
  end
endmodule
initial begin
