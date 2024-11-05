interface drv_intf(input logic clk);
  //input logic clk = clk; 
  logic  sop;
  logic valid;
  logic [63:0] data;
  logic        eop;
  //create modports
  modport mport_drv(output sop, eop, valid, data);
endinterface // drv_intf
