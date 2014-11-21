class env;

  driver                        drv;
  monitor                       mon;
  virtual xge_mac_interface     drv_vi;
  virtual xge_mac_interface     mon_vi;

  // Constructor
  function new( input virtual xge_mac_interface dvif,
                input virtual xge_mac_interface mvif  );
    $display("ENV :: inside new() function");
    this.drv_vi = dvif;
    this.mon_vi = mvif;
    drv         = new(dvif);
    mon         = new(mvif);
  endfunction : new


  // Class methods
  task run(int num_packets=4);

    // Fork off two threads
    fork
      // Driver thread will send the packets.
      begin
        for (int i=0; i<num_packets; i++) begin
          drv.send_packet();
        end
      end
      // Monitor thread will collect the packets.
      begin
        mon.collect_packet();
      end
    join_none

  endtask : run

endclass
