//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : env.sv                                              //
//  Author    : G. Andres Mancera                                   //
//  Course    : Advanced Verification with SystemVerilog OOP        //
//              Testbench - UCSC Silicon Valley Extension           //
//                                                                  //
//////////////////////////////////////////////////////////////////////

class env;

  driver                        drv;
  monitor                       mon;
  scoreboard                    scbd;
  mailbox                       drv2scbd;
  mailbox                       mon2scbd;
  virtual xge_mac_interface     drv_vi;
  virtual xge_mac_interface     mon_vi;

  // Constructor
  function new( input virtual xge_mac_interface dvif,
                input virtual xge_mac_interface mvif  );
    $display("ENV :: inside new() function");
    this.drv_vi = dvif;
    this.mon_vi = mvif;
    drv2scbd    = new();
    mon2scbd    = new();
    drv         = new(dvif, drv2scbd);
    mon         = new(mvif, mon2scbd);
    scbd        = new(drv2scbd, mon2scbd);
  endfunction : new


  // Class methods
  task run(int num_packets=4);

    // Fork off two threads
    fork
      // Driver thread will send the packets.
      begin
        drv.send_packet(num_packets);
      end
      // Monitor thread will collect the packets.
      begin
        mon.collect_packet();
      end
      // Scoreboard thread to make the comparison.
      begin
        scbd.compare(drv2scbd, mon2scbd);
      end
    join_any

  endtask : run

endclass
