```systemverilog
odule pkt_gen_tb;
  
  int number_of_pkts;
  int bytes_per_line;
  byte arr[];
  
  initial begin
    pkt_gen pkt;
    if(!$value$plusargs("number_of_pkts=%d",number_of_pkts)) number_of_pkts = 2; //Default 2
    if(!$value$plusargs("bytes_per_line=%d",bytes_per_line)) bytes_per_line = 16; //Default 16
    pkt = new();
    for(int i = 0; i < number_of_pkts; i++) begin
      pkt.randomize();
      pkt.pack(arr);
      
      $display("[pkt%0d size:%03d]",i,arr.size());
      pkt.display(arr, bytes_per_line);
      
    end
    
  end
  
endmodule // pkt_gen_tb
```
