class scoreboard;

  mailbox   rcv_from_drv;
  mailbox   rcv_from_mon;

  // Constructor
  function new( input mailbox drv2sb, input mailbox mon2sb );
    $display("SCBD :: inside new() function");
    this.rcv_from_drv   = drv2sb;
    this.rcv_from_mon   = mon2sb;
  endfunction : new

  // Class methods
  task compare( input mailbox rcv_from_drv,
                input mailbox rcv_from_mon  );
    
    bit     error;
    packet  drv_pkt;
    packet  mon_pkt;
    error   = 0;

    forever begin
      rcv_from_drv.get(drv_pkt);
      drv_pkt.print("SCOREBOARD EXPECTED");

      rcv_from_mon.get(mon_pkt);
      mon_pkt.print("SCOREBOARD ACTUAL");

      // FIXME: Do something here!

    end
  endtask : compare

endclass
