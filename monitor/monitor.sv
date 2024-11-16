```systemverilog
class monitor ;
  virtual drv_intf intf;
  packet mon_pkt;
  byte         stream[]; // byte stream
  int          pkt_size;
  function new();
  endfunction // new
  
  function void set_pktsize(int byte_count);
    pkt_size = byte_count;
  endfunction // set_pktsize
  
  function void unpack(input byte byte_array[]);
    int byte_count = 0;
    bit [15:0] EtherType, EType;
    int        pl_size;
    bit [31:0] vl;
    
    $display("#### byte_array.size() = %0d ", byte_array.size());
    
    // Unpack DA
    for (int i = 5; i >= 0; i--) begin
      $write("%02h ", byte_array[byte_count]);
      mon_pkt.DA[8*i +: 8] = byte_array[byte_count++];
    end
    // unPack SA
    for (int i = 5; i >= 0; i--) mon_pkt.SA[8*i +: 8] = byte_array[byte_count++];
    $write("p.DA: %02h ", mon_pkt.DA);
    $write("mon_pkt.SA: %02h ", mon_pkt.SA);
    $write("Vlan[%0d]: 0x%02h VLAN[%0d] = 0x%02h ", byte_count, byte_array[byte_count], byte_count + 1, byte_array[byte_count + 1]);
    $write("Vlan[%0d]: 0x%02h VLAN[%0d] = 0x%02h ", byte_count + 2, byte_array[byte_count +2], byte_count + 3, byte_array[byte_count + 3]);
    vl = { >> 16 {byte_array[byte_count], byte_array[byte_count + 1], byte_array[byte_count + 2], byte_array[byte_count + 3]}};
    $display("%h ", vl);
    EtherType = {byte_array[byte_count], byte_array[byte_count + 1]};
    /////// logic for VLAN presence unpack VLAN tag
    if (EtherType == 16'h8100) begin
      //for (int i = 0; i < 4; i++) mon_pkt.VLAN[8*i +: 8] = byte_array[byte_count++];
      mon_pkt.VLAN = { >> 16 {byte_array[byte_count], byte_array[byte_count + 1], byte_array[byte_count + 2], byte_array[byte_count + 3]}};
      byte_count += 4;
      $write("VLAN tag: 0x%h ", mon_pkt.VLAN);
    end
    // unPack EType
    mon_pkt.EType = { >> {byte_array[byte_count], byte_array[byte_count + 1]}};
    byte_count += 2;
    $display("mon_pkt.EType = %h", mon_pkt.EType);
    if (mon_pkt.EType == 16'h0800 || mon_pkt.EType == 16'h0080) begin // need to change byte reverse mon_pkt.EType == 16'h0080
      if ( mon_pkt.ipv4 != null) begin 
        mon_pkt.ipv4.unpack(byte_count, byte_array); byte_count += 20;
        
      end
    end
    else if (mon_pkt.EType == 16'h86DD || mon_pkt.EType == 16'hDD86) begin // need to change byte reverse mon_pkt.EType == 16'hDD86
      $display("else if p.EType = %h", mon_pkt.EType);
      if ( mon_pkt.ipv6 != null) begin 
        mon_pkt.ipv6.unpack(byte_count, byte_array); byte_count += 8;
        mon_pkt.ipv6.display_fields();
      end
    end
    
    //Check protocol of IPV4 and next_header 0f IPV6 header and unpack l4-TCP header
    if ( mon_pkt.ipv4 != null && mon_pkt.ipv4.protocol == 8'h06 || mon_pkt.ipv6 != null && mon_pkt.ipv6.next_header == 8'h06) begin
      mon_pkt.tcp.unpack(byte_count, byte_array);
      byte_count += 20;
    end
    else if (mon_pkt.ipv4 != null && mon_pkt.ipv4.protocol == 8'h11 || mon_pkt.ipv6 != null && mon_pkt.ipv6.next_header == 8'h11) begin
      mon_pkt.udp.unpack(byte_count, byte_array);
      byte_count += 8;
      mon_pkt.udp.display_fields();
    end
    //unpack payload bytes
    pl_size = pkt_size - byte_count;
    $display("pkt_size = %0d byte_array.size() = %0d, pl_size = %0d", pkt_size, byte_array.size(), pl_size);
    mon_pkt.payload = new[pl_size];
    for (int i = 0; i < pl_size; i++) mon_pkt.payload[i] = byte_array[byte_count++];
    /////// display playload
    foreach(mon_pkt.payload[i]) $write("%02h ", mon_pkt.payload[i]);
    
  endfunction // signal_to_packet
  
/* -----\/----- EXCLUDED -----\/-----
  task receive_pkt(ref byte byte_array[]);
    logic valid, sop, eop;
    logic [63:0] data;
    byte         stream[4096];
    
    @(posedge intf.clk);
    $display("Monitor:: intf: sop = %0d, valid = %0d, data = %0h, eop = %0d", intf.sop, intf.valid, intf.data, intf.eop);
    $display("Monitor::intf.mport_drv: sop = %0d, valid = %0d, data = %0h, eop = %0d", intf.mport_drv.sop, intf.mport_drv.valid, intf.mport_drv.data, intf.mport_drv.eop);
    valid = intf.valid;
    sop = intf.sop;
    eop = intf.eop;
    if(valid == 1) begin
      if(sop == 1) begin //first fleet received
        byte_count = 0;
        data = intf.data;
        for (int i = 0; i < 8; i++) stream[byte_count++] = data[8*i +: 8];
      end
      if (eop == 1) begin //last fleets received
        data = intf.data;
        for (int i = 0; i < 8; i++) stream[byte_count++] = data[8*i +: 8];
        byte_array = new[byte_count](stream); // create the byte arrray of size eop this is not the packet size, end of fleet means fleet size
        set_pktsize(byte_count);
        unpack(byte_array); //full packet received, now unpack it
      end
      else begin
        data = intf.data;
        for (int i = 0; i < $bits(data)/8; i++) stream[byte_count++] = data[8*i +: 8];
      end
      //@(posedge intf.clk);
    end // if (valid == 1)
  endtask // receive_pkt
 -----/\----- EXCLUDED -----/\----- */
  
  task run();
    byte pkt_stream[];
    int  byte_count = 0;
    logic ready, valid, sop, eop;
    logic [7:0][7:0] data;
    byte         stream[$];
    mon_pkt = new;
    forever begin
      @(posedge intf.clk);
      $display("Monitor:: intf: sop = %0d, ready = %0d valid = %0d, data = %0h, eop = %0d", intf.sop, intf.ready, intf.valid, intf.data, intf.eop);
      //$display("Monitor::intf.mport_drv: sop = %0d, ready = %0d valid = %0d, data = %0h, eop = %0d", intf.mport_drv.sop,  intf.mport_drv.valid, intf.mport_drv.data, intf.mport_drv.eop);
      ready = intf.ready;
      valid = intf.valid;
      sop = intf.sop;
      eop = intf.eop;
      data = intf.data;
      //$write("Data[%0h %0h %0h", data, data[0], data[1]);
      
      if(valid == 1 && ready == 1) begin
        //@(posedge intf.clk);
        //for (int j = 0; j < 8; j++) begin
        for (int j = 7; j >= 0; j--) begin
          stream[byte_count++] = data[j];
          $write("mB[%0d]:%h ", j, data[j]);
        end
        $display("d.fleet: %h", data);
        if(eop == 1) begin
          //for (int j = 7; j >= 0; j--) stream[byte_count++] = data[j];
          set_pktsize(byte_count - 1); 
          $display("@@@@ byte_count = %0d ", byte_count);
          //// copy the stream into pkt_stream and unpack it
          pkt_stream = new[byte_count -1];
          foreach(stream[i]) $write("%02h ", (pkt_stream[i] = stream[i]));
          unpack(pkt_stream);
          mon_pkt.display_fields();
        end
        //@(posedge intf.clk);
        //valid = intf.valid;
        //eop = intf.eop;
        //data = intf.data;
      end // if (valid == 1)
      //else @(posedge intf.clk); //wait for next signal
      
      
/* -----\/----- EXCLUDED -----\/-----
      if(valid == 1) begin
        if(sop == 1) begin //first fleet received
          byte_count = 0;
          data = intf.data;
          for (int i = 0; i < 8; i++) stream[byte_count++] = data[8*i +: 8];
        end
        if (eop == 1) begin //last fleets received
          data = intf.data;
          for (int i = 0; i < 8; i++) stream[byte_count++] = data[8*i +: 8];
          byte_array = new[byte_count](stream); // create the byte arrray of size eomon_pkt this is not the packet size, end of fleet means fleet size
          set_pktsize(byte_count);
          unpack(byte_array); //full packet received, now unpack it
          mon_pkt.display_fields(); // display packet
        end
        else begin
          data = intf.data;
          for (int i = 0; i < $bits(data)/8; i++) stream[byte_count++] = data[8*i +: 8];
        end
      end // if (valid == 1)
 -----/\----- EXCLUDED -----/\----- */
  
    end
  endtask // run 
endclass // monitor


```
