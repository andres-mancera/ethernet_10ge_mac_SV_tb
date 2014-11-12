class driver;

  virtual xge_mac_interface     drv_vi;
  packet                        xge_mac_pkt;

  // ======== Constructor ========
  function new(input virtual xge_mac_interface vif);
    $display("DRIVER :: inside new() function");
    this.drv_vi = vif;
    xge_mac_pkt = new();
  endfunction : new


  // ======== Class methods ========
  task send_packet();
    packet          drv_pkt;
    int unsigned    pkt_len_in_bytes;
    int unsigned    num_of_flits;
    bit [2:0]       last_flit_mod;
    bit [63:0]      tx_data;

    drv_pkt     = new xge_mac_pkt;
 
    assert( drv_pkt.randomize() );
    pkt_len_in_bytes    = 6 + 6 + 2 + drv_pkt.payload.size();
    num_of_flits        = pkt_len_in_bytes/8 + 1;
    last_flit_mod       = num_of_flits%8;

    for ( int i=0; i<num_of_flits; i++ ) begin
      tx_data = 64'h0;
      @(drv_vi.cb);
      if ( i==0 )  begin    // -------------------------------- SOP cycle ----------------
        tx_data     = { drv_pkt.mac_dst_addr, drv_pkt.mac_src_addr[47:32] };
        drv_vi.cb.pkt_tx_val    <= 1'b1;
        drv_vi.cb.pkt_tx_sop    <= drv_pkt.sop_mark;
        drv_vi.cb.pkt_tx_eop    <= 1'b0;
        drv_vi.cb.pkt_tx_mod    <= 1'b0;
        drv_vi.cb.pkt_tx_data   <= tx_data;
      end                   // -------------------------------- SOP cycle ----------------
      else if ( i==(num_of_flits-1) ) begin // ---------------- EOP cycle ----------------
        if ( num_of_flits==2 ) begin
          tx_data[63:16]    = { drv_pkt.mac_src_addr[31:0], drv_pkt.ether_type };
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
          for ( int j=0; j<(((drv_pkt.payload.size()-3)%8)+1); j++ ) begin
            tx_data         = tx_data | ( drv_pkt.payload[8*i+j-13] << (56-8*j) );
            //tx_data[63-8*j:56-8*j]  = drv_pkt.payload[8*i+j-13];
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
          tx_data[63:16]    = { drv_pkt.mac_src_addr[31:0], drv_pkt.ether_type, 
                                drv_pkt.payload[0], drv_pkt.payload[1] };
        end
        else begin
          for ( int j=0; j<8; j++ ) begin
            tx_data         = (tx_data<<8) + drv_pkt.payload[8*i+j-13];
            //tx_data[63-8*j:56-8*j]  = drv_pkt.payload[8*i+j-13];
          end
        end
        drv_vi.cb.pkt_tx_val    <= 1'b1;
        drv_vi.cb.pkt_tx_sop    <= 1'b0;
        drv_vi.cb.pkt_tx_eop    <= 1'b0;
        drv_vi.cb.pkt_tx_mod    <= 1'b0;
        drv_vi.cb.pkt_tx_data   <= tx_data;
      end                   // -------------------------------- MOP cycle ----------------

    end
    repeat ( drv_pkt.ipg ) begin
      @(drv_vi.cb);
      drv_vi.cb.pkt_tx_val    <= 1'b0;
      drv_vi.cb.pkt_tx_sop    <= 1'b0;
      drv_vi.cb.pkt_tx_eop    <= 1'b0;
      drv_vi.cb.pkt_tx_mod    <= 1'b0;
      drv_vi.cb.pkt_tx_data   <= { $urandom, $urandom_range(0,65535) };
    end

    drv_pkt.increase_pktid();
    drv_pkt.print();
  endtask : send_packet

endclass
