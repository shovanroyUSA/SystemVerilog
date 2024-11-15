```systemverilog
module rng 
  (input logic         clk,
   input logic         rst_n,
   
   output logic [7:0]  rnd_8,
   output logic [15:0] rnd_16
   );
  
  parameter    SEED = 1;
  
  logic [31:0] shift;
  logic [31:0] shift_c;
  logic [31:0] shiftl_13;
  logic [31:0] shiftr_17;
  logic [31:0] shiftl_5;

  assign shiftl_13 = shift ^ (shift << 13);
  assign shiftr_17 = shiftl_13 ^ (shiftl_13 >> 17);
  assign shiftl_5 = shiftr_17 ^ (shiftr_17 << 5);
  assign shift_c = shiftl_5;

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) shift <= SEED;
    else shift <= shift_c;
  end

  assign rnd_8 = shift[7:0];
  assign rnd_16 = shift[15:0];

  // always @(posedge clk) $display("shift = 0x%0h, rnd_8 = %0d, rnd_16 = %0d", shift, rnd_8, rnd_16);
endmodule // rng
```
