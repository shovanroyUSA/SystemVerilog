```systemverilog
module dut
  (input logic   clk,
   input logic   rst_n,

   mon_intf.dut  intf          
   );

  logic       ready;
  logic       valid;
  logic       ready_d1;
  logic [7:0] rand_8;
  logic [2:0] rdy_low_cnt;

  parameter   SEED = 2;
  
  // Interface signals
  assign valid = intf.valid;
  assign intf.ready = ready;
                 
  // Randon Number Generator
  /*
  rng AUTO_TEMPLATE 
    (.rnd_16  (),
     );
   */
  rng rng_i 
    #(/*AUTOINSTPARAM*/
      // Parameters
      .SEED                             (SEED))
  (/*AUTOINST*/
   // Outputs
   .rnd_8                               (rnd_8[7:0]),
   .rnd_16                              (),                      // Templated
   // Inputs
   .clk                                 (clk),
   .rst_n                               (rst_n));

  
  // Capture a 3b random value whenever ready goes low. From that point, count down to 0
  always @(posedge clk) ready_d1 <= ready;
  always @(posedge clk) begin
    if(!ready) begin
      if(ready_d1) rdy_low_cnt <= rand_8[2:0];
      else if(rdy_low_cnt > 0) rdy_low_cnt <= rdy_low_cnt - 8'h1;
    end
  end
  
  // Ready is low around 20% of the time valid is high. Once ready is low it remains low for any number of cycles up to 7
  always @(posege clk or negedge rst_n) begin
    if(!rst_n) ready <= 1'b1;
    else begin
      if(!ready && (rdy_low_cnt == 0)) ready <= 1'b1;
      else if(valid && ready && (rand_8 > 200)) ready <= 1'b0;
    end
  end

endmodule // dut

 ```
