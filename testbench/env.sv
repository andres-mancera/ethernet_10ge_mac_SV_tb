class env;

  driver                        drv;
  virtual xge_mac_interface     vi;


  // Constructor
  function new(input virtual xge_mac_interface vif);
    this.vi = vif;
    drv     = new(vif);
  endfunction : new


  // Class methods
  task run(int num_packets=4);
    for (int i=0; i<num_packets; i++) begin
      drv.send_packet();
    end
  endtask : run

endclass
