class driver;

  virtual xge_mac_interface     drv_vi;
  packet                        xge_mac_pkt;
  mailbox                       drv2sb;

  // ======== Constructor ========
  function new( input virtual xge_mac_interface vif,
                input mailbox drv2sb                );
    $display("DRIVER :: inside new() function");
    this.drv_vi = vif;
    this.drv2sb = drv2sb;
    xge_mac_pkt = new();
  endfunction : new


  // ======== Class methods ========
  task send_packet(int num_packets);
    packet          drv_pkt;
    int unsigned    pkt_len_in_bytes;
    int unsigned    num_of_flits;
    bit [2:0]       last_flit_mod;
    bit [63:0]      tx_data;

    
    for (int j=0; j<num_packets; j++ ) begin
      drv_pkt     = new xge_mac_pkt;
      assert( drv_pkt.randomize() );
      pkt_len_in_bytes    = 6 + 6 + 2 + drv_pkt.payload.size();
      num_of_flits        = ( pkt_len_in_bytes%8 ) ? pkt_len_in_bytes/8 + 1 : pkt_len_in_bytes/8;
      last_flit_mod       = pkt_len_in_bytes%8;
      //$display("DRIVER DEBUG :: pkt_len_in_bytes =%0d", pkt_len_in_bytes);    
      //$display("DRIVER DEBUG :: num_of_flits     =%0d", num_of_flits);
      //$display("DRIVER DEBUG :: last_flit_mod    =%0d", last_flit_mod);

      for ( int i=0; i<num_of_flits; i++ ) begin
        tx_data = 64'h0;
        @(drv_vi.cb);
        if ( i==0 )  begin    // -------------------------------- SOP cycle ----------------
          tx_data     = { drv_pkt.mac_dst_addr, drv_pkt.mac_src_addr[47:32] };
          drv_vi.cb.pkt_tx_val    <= 1'b1;
          drv_vi.cb.pkt_tx_sop    <= drv_pkt.sop_mark;
          drv_vi.cb.pkt_tx_eop    <= 1'b0;
          drv_vi.cb.pkt_tx_mod    <= $urandom_range(0,7);
          drv_vi.cb.pkt_tx_data   <= tx_data;
        end                   // -------------------------------- SOP cycle ----------------
        else if ( i==(num_of_flits-1) ) begin // ---------------- EOP cycle ----------------
          if ( num_of_flits==2 ) begin
            tx_data[63:16]    = { drv_pkt.mac_src_addr[31:0], drv_pkt.ether_type };
            tx_data[15:0]     = $urandom_range(0,16'hFFFF);
            for ( int j=0; j<drv_pkt.payload.size(); j++ ) begin
              if ( j==0 ) begin
                tx_data[15:8] = drv_pkt.payload[0];
              end
              else begin
                tx_data[7:0]  = drv_pkt.payload[1];
              end
            end
          end
          else begin
            for ( int j=0; j<8; j++ ) begin
              if (j<(((drv_pkt.payload.size()-3)%8)+1)) begin
                tx_data       = tx_data | ( drv_pkt.payload[8*i+j-14] << (56-8*j) ); 
              end
              else begin
                tx_data       = tx_data | ( $urandom_range(0,8'hFF) << (56-8*j) );
              end
            end
          end
          drv_vi.cb.pkt_tx_val    <= 1'b1;
          drv_vi.cb.pkt_tx_sop    <= 1'b0;
          drv_vi.cb.pkt_tx_eop    <= drv_pkt.eop_mark;
          drv_vi.cb.pkt_tx_mod    <= last_flit_mod;
          drv_vi.cb.pkt_tx_data   <= tx_data;
        end                   // -------------------------------- EOP cycle ----------------
        else begin            // -------------------------------- MOP cycle ----------------
          if ( i==1 ) begin
            tx_data           = { drv_pkt.mac_src_addr[31:0], drv_pkt.ether_type, 
                                  drv_pkt.payload[0], drv_pkt.payload[1] };
          end
          else begin
            for ( int j=0; j<8; j++ ) begin
              tx_data         = (tx_data<<8) | drv_pkt.payload[8*i+j-14];
            end
          end
          drv_vi.cb.pkt_tx_val    <= 1'b1;
          drv_vi.cb.pkt_tx_sop    <= 1'b0;
          drv_vi.cb.pkt_tx_eop    <= 1'b0;
          drv_vi.cb.pkt_tx_mod    <= $urandom_range(0,7);
          drv_vi.cb.pkt_tx_data   <= tx_data;
        end                   // -------------------------------- MOP cycle ----------------
      end
      drv_pkt.increase_pktid();
      drv_pkt.print("FROM DRIVER");
      // Put the packet into the mailbox
      if ( drv_pkt.sop_mark ) begin
        drv2sb.put(drv_pkt);
      end
      repeat ( drv_pkt.ipg ) begin
        @(drv_vi.cb);
        drv_vi.cb.pkt_tx_val    <= 1'b0;
        drv_vi.cb.pkt_tx_sop    <= 1'b0;
        drv_vi.cb.pkt_tx_eop    <= 1'b0;
        drv_vi.cb.pkt_tx_mod    <= $urandom_range(0,7);
        drv_vi.cb.pkt_tx_data   <= { $urandom, $urandom_range(0,65535) };
      end
      if ( (j==num_packets-1) && drv_pkt.ipg==0 ) begin
        // Explicitly close the transfer of the last packet if its
        // inter-packet gap is zero.  Otherwise, the repeat(drv_pkt.ipg) 
        // block does not get executed the the signals are kept at the 
        // same values that they had on the last EOP cycle
        @(drv_vi.cb);
        drv_vi.cb.pkt_tx_val    <= 1'b0;
        drv_vi.cb.pkt_tx_sop    <= 1'b0;
        drv_vi.cb.pkt_tx_eop    <= 1'b0;
        drv_vi.cb.pkt_tx_mod    <= $urandom_range(0,7);
        drv_vi.cb.pkt_tx_data   <= { $urandom, $urandom_range(0,65535) };
      end
      while ( drv_vi.cb.pkt_tx_full ) begin
        // When the pkt_tx_full signal is asserted, transfers should
        // be suspended at the end of the current packet.  Transfer of
        // next packet can begin as soon as this signal is de-asserted.
        @(drv_vi.cb);
        drv_vi.cb.pkt_tx_val    <= 1'b0;
        drv_vi.cb.pkt_tx_sop    <= 1'b0;
        drv_vi.cb.pkt_tx_eop    <= 1'b0;
        drv_vi.cb.pkt_tx_mod    <= $urandom_range(0,7);
        drv_vi.cb.pkt_tx_data   <= { $urandom, $urandom_range(0,65535) };
      end
    end
  endtask : send_packet

endclass
