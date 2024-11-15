```systemverilog
class generator;
  packet eth_pkt, copy_pkts;
  mailbox mbx;
  task run(int number_of_pkts, int bytes_per_line = 16);
    eth_pkt = new;
    for (int i = 0; i < number_of_pkts; i++) begin
      if(!eth_pkt.randomize())$error("Randomization Failed");
      //$display("eth_pkt $$$$$$$$$$$$$");
      //eth_pkt.display_fields();
      copy_pkts = new;
      copy_pkts.copy(eth_pkt);
      mbx.put(copy_pkts);
      //$display("\nGenerator::copy_pkts pkt_size = %0d display_fields()", copy_pkts.pkt_size);
      copy_pkts.display_fields(bytes_per_line);
    end // for (int i = 0; i < number_of_pkts; i++)
  endtask
endclass
```
