class scoreboard;

  mailbox       rcv_from_drv;
  mailbox       rcv_from_mon;
  int unsigned  num_of_mismatches;

  // Constructor
  function new( input mailbox drv2sb, input mailbox mon2sb );
    $display("SCBD :: inside new() function");
    this.rcv_from_drv   = drv2sb;
    this.rcv_from_mon   = mon2sb;
    num_of_mismatches   = 0;
  endfunction : new

  // Class methods
  task compare( input mailbox rcv_from_drv,
                input mailbox rcv_from_mon  );
    
    bit     error;
    packet  drv_pkt;
    packet  mon_pkt;

    forever begin
      error   = 0;

      // Get the packet from the driver through the mailbox.
      rcv_from_drv.get(drv_pkt);
      //drv_pkt.print("SCBD EXPECTED");

      // Get the packet from the monitor through the mailbox.
      rcv_from_mon.get(mon_pkt);
      //mon_pkt.print("SCBD ACTUAL");

      // Compare driver packet and monitor packet
      if ( drv_pkt.mac_dst_addr != mon_pkt.mac_dst_addr ) begin
        $display("SCBD ERROR :: t=%2t, PACKET MAC_DST_ADDR MISMATCH!, EXPECTED=%h, ACTUAL=%h", 
                  $time, drv_pkt.mac_dst_addr, mon_pkt.mac_dst_addr );
        error = 1;
      end
      if ( drv_pkt.mac_src_addr != mon_pkt.mac_src_addr ) begin
        $display("SCBD ERROR :: t=%2t, PACKET MAC_SRC_ADDR MISMATCH!, EXPECTED=%h, ACTUAL=%h",
                  $time, drv_pkt.mac_src_addr, mon_pkt.mac_src_addr );
        error = 1;
      end
      if ( drv_pkt.ether_type != mon_pkt.ether_type ) begin
        $display("SCBD ERROR :: t=%2t, PACKET ETHER_TYPE MISMATCH!, EXPECTED=%h, ACTUAL=%h",
                  $time, drv_pkt.mac_src_addr, mon_pkt.mac_src_addr );
        error = 1;
      end
      if ( drv_pkt.payload.size() > mon_pkt.payload.size() ) begin
        $display("SCBD ERROR :: t=%2t, PAYLOAD TX SIZE=%h; RX SIZE=%h, BYTES DROPPED!",
                  $time, drv_pkt.payload.size(), mon_pkt.payload.size() );
        error = 1;
      end
      else begin
        for ( int i=0; i<mon_pkt.payload.size(); i++ ) begin
          //$display("SCBD DEBUG :: COMPARE PAYLOAD[%0d] : DRIVER=%h, MONITOR=%h",
          //          i, drv_pkt.payload[i], mon_pkt.payload[i] );
          if ( i<drv_pkt.payload.size() ) begin
            if ( drv_pkt.payload[i] != mon_pkt.payload[i] ) begin
              $display("SCBD ERROR :: t=%2t, PACKET PAYLOAD[%0d] MISMATCH!, EXPECTED=%h, ACTUAL=%h",
                        $time, i, drv_pkt.payload[i], mon_pkt.payload[i] );
              error = 1;
            end
          end
          else begin
            if ( mon_pkt.payload[i] != 8'h0 ) begin
              $display("SCBD ERROR :: t=%2t, PACKET PAYLOAD[%0d] MISMATCH!, EXPECTED=%h, ACTUAL=%h",
                        $time, i, 8'h0, mon_pkt.payload[i] );
              error = 1;
            end
          end
        end
      end

      if ( error ) begin
        num_of_mismatches++;
      end
      else begin
        $display("SCBD :: t=%2t, EXPECTED AND ACTUAL PACKETS MATCH", $time);
      end
    end
  endtask : compare

endclass
