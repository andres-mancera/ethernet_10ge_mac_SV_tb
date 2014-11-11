module testbench();

  bit           clk_156m25, clk_xgmii_rx, clk_xgmii_tx;
  logic         reset_156m25_n, reset_xgmii_rx_n, reset_xgmii_tx_n;
  logic         pkt_rx_ren, pkt_tx_eop, pkt_tx_sop, pkt_tx_val; 
  logic         wb_clk_i, wb_cyc_i, wb_rst_i, wb_stb_i, wb_we_i;
  logic [63:0]  pkt_tx_data, xgmii_rxd;
  logic [2:0]   pkt_tx_mod;
  logic [7:0]   wb_adr_i, xgmii_rxc;
  logic [31:0]  wb_dat_i;
  logic         pkt_rx_avail, pkt_rx_eop, pkt_rx_err, pkt_rx_sop, pkt_rx_val, pkt_tx_full;
  logic         wb_ack_o, wb_int_o;
  logic [63:0]  pkt_rx_data, xgmii_txd;
  logic [2:0]   pkt_rx_mod;
  logic [31:0]  wb_dat_o;
  logic [7:0]   xgmii_txc;

  //-----------------------------------------------------------------
  // In order to enable waveform dumping, either uncomment the system
  // call below or use the +vcs+vcdpluson vcs command line option.
  //initial begin
  //  $vcdpluson;     // Enable waveform dumping
  //end

  // Generate free running clocks
  initial begin
    clk_156m25      = 1'b0;
    clk_xgmii_rx    = 1'b0;
    clk_xgmii_tx    = 1'b0;
    forever begin
      #3200;
      clk_156m25    = ~clk_156m25;
      clk_xgmii_rx  = ~clk_xgmii_rx;
      clk_xgmii_tx  = ~clk_xgmii_tx;
    end
  end

  // xge_mac_interface intantiated here
  xge_mac_interface     xge_mac_if  (   
                                        .clk_156m25     (clk_156m25),
                                        .clk_xgmii_rx   (clk_xgmii_rx),
                                        .clk_xgmii_tx   (clk_xgmii_tx)
                                    );

  // DUT instantiated here
  xge_mac   mac_core_dut  ( // Outputs
                            .pkt_rx_avail       (xge_mac_if.pkt_rx_avail),
                            .pkt_rx_data        (xge_mac_if.pkt_rx_data),
                            .pkt_rx_eop         (xge_mac_if.pkt_rx_eop),
                            .pkt_rx_err         (xge_mac_if.pkt_rx_err),
                            .pkt_rx_mod         (xge_mac_if.pkt_rx_mod),
                            .pkt_rx_sop         (xge_mac_if.pkt_rx_sop),
                            .pkt_rx_val         (xge_mac_if.pkt_rx_val),
                            .pkt_tx_full        (xge_mac_if.pkt_tx_full),
                            .wb_ack_o           (xge_mac_if.wb_ack_o),
                            .wb_dat_o           (xge_mac_if.wb_dat_o),
                            .wb_int_o           (xge_mac_if.wb_int_o),
                            .xgmii_txc          (xge_mac_if.xgmii_txc),
                            .xgmii_txd          (xge_mac_if.xgmii_txd),
                            // Inputs           
                            .clk_156m25         (clk_156m25),
                            .clk_xgmii_rx       (clk_xgmii_rx),
                            .clk_xgmii_tx       (clk_xgmii_tx),
                            .pkt_rx_ren         (xge_mac_if.pkt_rx_ren),
                            .pkt_tx_data        (xge_mac_if.pkt_tx_data),
                            .pkt_tx_eop         (xge_mac_if.pkt_tx_eop),
                            .pkt_tx_mod         (xge_mac_if.pkt_tx_mod),
                            .pkt_tx_sop         (xge_mac_if.pkt_tx_sop),
                            .pkt_tx_val         (xge_mac_if.pkt_tx_val),
                            .reset_156m25_n     (xge_mac_if.reset_156m25_n),
                            .reset_xgmii_rx_n   (xge_mac_if.reset_xgmii_rx_n),
                            .reset_xgmii_tx_n   (xge_mac_if.reset_xgmii_tx_n),
                            .wb_adr_i           (xge_mac_if.wb_adr_i),
                            .wb_clk_i           (xge_mac_if.wb_clk_i),
                            .wb_cyc_i           (xge_mac_if.wb_cyc_i),
                            .wb_dat_i           (xge_mac_if.wb_dat_i),
                            .wb_rst_i           (xge_mac_if.wb_rst_i),
                            .wb_stb_i           (xge_mac_if.wb_stb_i),
                            .wb_we_i            (xge_mac_if.wb_we_i),
                            // Following 2 connections are for loopback mode
                            // input 'xgmii_rxc' connected to output 'xgmii_txc'
                            // input 'xgmii_rxd' connected to output 'xgmii_txd'
                            .xgmii_rxc          (xge_mac_if.xgmii_txc),
                            .xgmii_rxd          (xge_mac_if.xgmii_txd)
                          );

  // Testcase instantiated here
  testcase  itestcase (     xge_mac_if.testcase_port    );

endmodule
