```systemverilog
interface drv_intf(input logic clk);
  logic ready; 
  logic  sop;
  logic valid;
  logic [63:0] data;
  logic        eop;
  logic [6:0]  bc;
  //create modports
  modport mport_drv(output sop, eop, valid, data, bc);
  //modport m_monitor (input data, valid, ready, sop, eop, bc);
  modport mport_dut (output ready, input data, valid, sop, eop, bc);
  
endinterface // drv_intf
```
