class packet;

  // Signals to be driven into the RTL
  rand bit [47:0]       mac_dst_addr;       // 6 Bytes
  rand bit [47:0]       mac_src_addr;       // 6 Bytes
  rand bit [15:0]       ether_type;         // 2 Bytes
  rand bit [7:0]        payload [];
  rand bit [31:0]       ipg;                // interpacket gap

  // Signals unrelated to the RTL 
  rand bit              sop_mark;
  rand bit              eop_mark;
  static bit [31:0]     pkt_id;

  // ======== Constraints ========
  constraint C_proper_sop_eop_marks {
    sop_mark == 1;  // SOP mark should be driven
    eop_mark == 1;  // EOP mark should be driven
  }

  constraint C_payload_size {
    payload.size() inside {[46:1500]};
  }

  constraint C_ipg {
    ipg inside {[10:1000]};
  }


  // ======== Constructor ========
  function new(input packet myself=null);
  endfunction : new


  // ======== Class methods ========
  function void print(string calling_class);
    int unsigned    Byte8_words;
    $display("PACKET %s :: t=%2t, pkt_id=%0d, mac_dst_addr=%h, mac_src_addr=%h, ether_type=%h, payload_size=%0d",
              calling_class, $time, pkt_id, mac_dst_addr, mac_src_addr, ether_type, payload.size());
    if ( payload.size()>0 ) begin
      Byte8_words = payload.size()%8 ? payload.size()/8+1 : payload.size()/8;
      for ( int i=0; i<Byte8_words; i++ ) begin
        if ( i!=Byte8_words-1 ) begin
          $display("PACKET %s :: t=%2t, payloadBytes[%0d:%0d]=%h%h%h%h_%h%h%h%h", calling_class, 
                    $time, 8*i, 8*i+7, payload[8*i], payload[8*i+1], payload[8*i+2], payload[8*i+3],
                    payload[8*i+4], payload[8*i+5], payload[8*i+6], payload[8*i+7]);
        end
        else begin
          case (payload.size()%8)
            0: begin
              $display("PACKET %s :: t=%2t, payloadBytes[%0d:%0d]=%h%h%h%h_%h%h%h%h", calling_class,
                        $time, 8*i, 8*i+7, payload[8*i], payload[8*i+1], payload[8*i+2], 
                        payload[8*i+3], payload[8*i+4], payload[8*i+5], payload[8*i+6], 
                        payload[8*i+7]);
            end
            1: begin
              $display("PACKET %s :: t=%2t, payloadBytes[%0d]=%h", calling_class, $time,
                        8*i, payload[8*i]);
            end
            2: begin
              $display("PACKET %s :: t=%2t, payloadBytes[%0d:%0d]=%h%h", calling_class, $time,
                        8*i, 8*i+1, payload[8*i], payload[8*i+1]);
            end
            3: begin
              $display("PACKET %s :: t=%2t, payloadBytes[%0d:%0d]=%h%h%h", calling_class, $time,
                        8*i, 8*i+2, payload[8*i], payload[8*i+1], payload[8*i+2]);
            end
            4: begin
              $display("PACKET %s :: t=%2t, payloadBytes[%0d:%0d]=%h%h%h%h", calling_class, $time,
                        8*i, 8*i+3, payload[8*i], payload[8*i+1], payload[8*i+2], payload[8*i+3]);
            end
            5: begin
              $display("PACKET %s :: t=%2t, payloadBytes[%0d:%0d]=%h%h%h%h_%h", calling_class, $time,
                        8*i, 8*i+4, payload[8*i], payload[8*i+1], payload[8*i+2], payload[8*i+3],
                        payload[8*i+4]);
            end
            6: begin
              $display("PACKET %s :: t=%2t, payloadBytes[%0d:%0d]=%h%h%h%h_%h%h", calling_class, 
                        $time, 8*i, 8*i+5, payload[8*i], payload[8*i+1], payload[8*i+2], 
                        payload[8*i+3], payload[8*i+4], payload[8*i+5]);
            end
            7: begin
              $display("PACKET %s :: t=%2t, payloadBytes[%0d:%0d]=%h%h%h%h_%h%h%h", calling_class, 
                        $time, 8*i, 8*i+6, payload[8*i], payload[8*i+1], payload[8*i+2], 
                        payload[8*i+3], payload[8*i+4], payload[8*i+5], payload[8*i+6]);
            end
          endcase
        end
      end
    end
  endfunction : print

  static function increase_pktid();
    pkt_id++;
  endfunction : increase_pktid

  static function bit [15:0] get_pktid();
    return pkt_id;
  endfunction : get_pktid

endclass
