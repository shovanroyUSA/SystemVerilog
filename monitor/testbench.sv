```systemverilog
module tb;
  logic clk = 0;
  mailbox mbx;
  int number_of_pkts;
  int bytes_per_line;
  drv_intf intf(clk);
  driver drv_pkt;
  generator gen_pkt;
  monitor mon_pkt;
  
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
    mon_pkt = new();
    gen_pkt.mbx = mbx;
    drv_pkt.mbx = mbx; 
    drv_pkt.intf = intf;  
    mon_pkt.intf = intf;
    fork
      gen_pkt.run(number_of_pkts, bytes_per_line);
      drv_pkt.run(number_of_pkts, bytes_per_line);
      mon_pkt.run();
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
    $fsdbDumpfile("eth_pkt_waveform.fsdb");
    $fsdbDumpvars(0, tb);
    $fsdbDumpon;
  end

  initial begin
    $vcdplusfile("eth_pkt_waveform.vpd");
    $vcdpluson;
  end
 
endmodule
```
