`include "../../testbench/packet.sv"
`include "../../testbench/driver.sv"
`include "../../testbench/env.sv"

program testcase(interface tcif);

  // Since this is a bringup test, all the fields of the
  // packet will be heavily constrained
  class bringup_packet extends packet;
    constraint C_bringup_packet
      {
        mac_dst_addr    == 48'hAABB_CCDD_EEFF;
        mac_src_addr    == 48'h1122_4455_7788;
        ether_type      == 16'h0800;    // IPv4
        payload.size()  inside {[46:50]};
        ipg             == 10;
      }
  endclass : bringup_packet

  env               env0;
  int unsigned      num_packets;
  bringup_packet    testcase_packet;

  initial begin
    env0            = new(tcif);
    testcase_packet = new();

    // Connect packet handle from driver to testcase_packet
    env0.drv.xge_mac_pkt = testcase_packet;
    num_packets = 2;
    tcif.reset_dut();
    tcif.init_tb_signals();
    tcif.wait_ns(5000);
    env0.run(num_packets);

    #1000 $finish;
  end

  final begin
    bit [15:0]  num_pkts;
    num_pkts    = packet::get_pktid();
    $display("\nTESTCASE: ----------------- End Of Simulation -----------------");
    $display("TESTCASE: Number of packets sent :  %0d", num_pkts);
  end

endprogram
