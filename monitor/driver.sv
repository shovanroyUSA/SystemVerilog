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
    number_of_fleets = ($size(byte_array) + 7) / 8;
    //$display("\ndriver::display packet() pkt_size = %0d number_of_fleets = %0d", $size(byte_array), number_of_fleets);
    //eth_pkt.display_fields(bytes_per_line);
    /* Set all signals low at first clock cycle */
    intf.mport_drv.valid <= 1'b0;
    intf.mport_drv.sop <= 1'b0;
    intf.mport_drv.eop <= 1'b0;
    @(posedge intf.clk);
    //$display("D: clk_cycle = %0d sop = %0d valid = %0d data =  %0h eop = %0d", 
    //             clk_cnt++, intf.mport_drv.sop, intf.mport_drv.valid, intf.mport_drv.data, intf.mport_drv.eop);
    //////// Drive packet in fleets /////////////////
    for (int i = 0; i < number_of_fleets; i++) begin
      std::randomize(valid) with { valid dist {1 := 90, 0 :=10}; };
      intf.mport_drv.valid <= valid; 
      if(i == 0) intf.mport_drv.sop <= 1'b1;
      else intf.mport_drv.sop <= 1'b0;
      if(i == (number_of_fleets - 1)) intf.mport_drv.eop <= 1'b1;
      else intf.mport_drv.eop <= 1'b0;
      //// prepare fleet ////////////////////////////////////////////////////
      for (int j = 7; j >= 0; j--) begin
        if(offset < $size(byte_array)) data[j] = byte_array[offset++];
        //data[j] = { >> {byte_array[offset++]}};
        
        $write("dB[%0d]:%h ", j, data[j]);
      end
      $display("d.fleet[%0d]: %h", i, data);
      
      ///// Assign fleet data to the modport data signal /////////////////////
      intf.mport_drv.data <= data;
      // Hold values if valid is low
      while(valid == 0) begin
        @(posedge intf.clk);
        //$display("D: clk_cycle = %0d sop = %0d valid = %0d fleet[%0d]: %h eop = %0d", 
        //         clk_cnt++, intf.mport_drv.sop, intf.mport_drv.valid, i, intf.mport_drv.data, intf.mport_drv.eop);
        std::randomize(valid) with { valid dist {1 := 90, 0 := 10}; };
        intf.mport_drv.valid <= valid;
      end // end while
      @(posedge intf.clk);
      //$display("D: clk_cycle = %0d sop = %0d valid = %0d fleet[%0d]: %h eop = %0d", 
      //          clk_cnt++, intf.mport_drv.sop, intf.mport_drv.valid, i, intf.mport_drv.data, intf.mport_drv.eop);
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
