//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : coverage.sv                                         //
//  Author    : G. Andres Mancera                                   //
//  Course    : Advanced Verification with SystemVerilog OOP        //
//              Testbench - UCSC Silicon Valley Extension           //
//                                                                  //
//////////////////////////////////////////////////////////////////////

class coverage;

  packet    cov_packet;

  covergroup cov_packet_cg;
    mac_dst_addr : coverpoint cov_packet.mac_dst_addr
                    {
                        option.auto_bin_max = 4;
                    }
    mac_src_addr : coverpoint cov_packet.mac_src_addr
                    {
                        option.auto_bin_max = 4;
                    }
    ether_type   : coverpoint cov_packet.ether_type
                    {
                        option.auto_bin_max = 4;
                    }
    payload      : coverpoint cov_packet.payload.size()
                    {
                        option.auto_bin_max = 4;
                    }
    ipg          : coverpoint cov_packet.ipg
                    {
                        option.auto_bin_max = 4;
                    }
  endgroup

  
  // Constructor
  function new();
    cov_packet_cg = new();
  endfunction : new


  // Class methods
  task collect_coverage( input packet drv_pkt );
    this.cov_packet = drv_pkt;
    cov_packet_cg.sample();
  endtask : collect_coverage

endclass
