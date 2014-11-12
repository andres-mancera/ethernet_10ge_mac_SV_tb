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
    ipg inside {[10:20]};
  }


  // ======== Constructor ========
  function new(input packet myself=null);
  endfunction : new


  // ======== Class methods ========
  function void print();
    // FIXME: Implement this function. 
  endfunction : print

  static function increase_pktid();
    pkt_id++;
  endfunction : increase_pktid

  static function bit [15:0] get_pktid();
    return pkt_id;
  endfunction : get_pktid

endclass
