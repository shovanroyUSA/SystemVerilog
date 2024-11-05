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
