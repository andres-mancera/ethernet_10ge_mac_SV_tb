module testbench();

  reg           clk_156m25, clk_xgmii_rx, clk_xgmii_tx;
  reg           reset_156m25_n, reset_xgmii_rx_n, reset_xgmii_tx_n;
  reg           pkt_rx_ren, pkt_tx_eop, pkt_tx_sop, pkt_tx_val; 
  reg           wb_clk_i, wb_cyc_i, wb_rst_i, wb_stb_i, wb_we_i;
  reg [63:0]    pkt_tx_data, xgmii_rxd;
  reg [2:0]     pkt_tx_mod;
  reg [7:0]     wb_adr_i, xgmii_rxc;
  reg [31:0]    wb_dat_i;
  wire          pkt_rx_avail, pkt_rx_eop, pkt_rx_err, pkt_rx_sop, pkt_rx_val, pkt_tx_full;
  wire          wb_ack_o, wb_int_o;
  wire [63:0]   pkt_rx_data, xgmii_txd;
  wire [2:0]    pkt_rx_mod;
  wire [31:0]   wb_dat_o;
  wire [7:0]    xgmii_txc;

  initial begin
    $vcdpluson;     // Enable waveform dumping
  end

  // Generate free running clocks
  initial begin
    clk_156m25 = 1'b0;
    clk_xgmii_rx = 1'b0;
    clk_xgmii_tx = 1'b0;
    forever begin
      #3200;
      clk_156m25 = ~clk_156m25;
      clk_xgmii_rx = ~clk_xgmii_rx;
      clk_xgmii_tx = ~clk_xgmii_tx;
    end
  end

  // DUT instantiated here
  xge_mac   mac_core_dut  ( // Outputs
                            .pkt_rx_avail       (pkt_rx_avail),
                            .pkt_rx_data        (pkt_rx_data),
                            .pkt_rx_eop         (pkt_rx_eop),
                            .pkt_rx_err         (pkt_rx_err),
                            .pkt_rx_mod         (pkt_rx_mod),
                            .pkt_rx_sop         (pkt_rx_sop),
                            .pkt_rx_val         (pkt_rx_val),
                            .pkt_tx_full        (pkt_tx_full),
                            .wb_ack_o           (wb_ack_o),
                            .wb_dat_o           (wb_dat_o),
                            .wb_int_o           (wb_int_o),
                            .xgmii_txc          (xgmii_txc),
                            .xgmii_txd          (xgmii_txd),
                            // Inputs           
                            .clk_156m25         (clk_156m25),
                            .clk_xgmii_rx       (clk_xgmii_rx),
                            .clk_xgmii_tx       (clk_xgmii_tx),
                            .pkt_rx_ren         (pkt_rx_ren),
                            .pkt_tx_data        (pkt_tx_data),
                            .pkt_tx_eop         (pkt_tx_eop),
                            .pkt_tx_mod         (pkt_tx_mod),
                            .pkt_tx_sop         (pkt_tx_sop),
                            .pkt_tx_val         (pkt_tx_val),
                            .reset_156m25_n     (reset_156m25_n),
                            .reset_xgmii_rx_n   (reset_xgmii_rx_n),
                            .reset_xgmii_tx_n   (reset_xgmii_tx_n),
                            .wb_adr_i           (wb_adr_i),
                            .wb_clk_i           (wb_clk_i),
                            .wb_cyc_i           (wb_cyc_i),
                            .wb_dat_i           (wb_dat_i),
                            .wb_rst_i           (wb_rst_i),
                            .wb_stb_i           (wb_stb_i),
                            .wb_we_i            (wb_we_i),
                            .xgmii_rxc          (xgmii_rxc),
                            .xgmii_rxd          (xgmii_rxd)
                          );

  // Testcase instantiated here
  testcase  itestcase (     // Inputs
                            .clk_156m25         (clk_156m25),
                            .clk_xgmii_rx       (clk_xgmii_rx),
                            .clk_xgmii_tx       (clk_xgmii_tx),
                            .pkt_rx_avail       (pkt_rx_avail),
                            .pkt_rx_data        (pkt_rx_data),
                            .pkt_rx_eop         (pkt_rx_eop),
                            .pkt_rx_err         (pkt_rx_err),
                            .pkt_rx_mod         (pkt_rx_mod),
                            .pkt_rx_sop         (pkt_rx_sop),
                            .pkt_rx_val         (pkt_rx_val),
                            .pkt_tx_full        (pkt_tx_full),
                            .wb_ack_o           (wb_ack_o),
                            .wb_dat_o           (wb_dat_o),
                            .wb_int_o           (wb_int_o),
                            .xgmii_txc          (xgmii_txc),
                            .xgmii_txd          (xgmii_txd),
                            // Outputs
                            .pkt_rx_ren         (pkt_rx_ren),
                            .pkt_tx_data        (pkt_tx_data),
                            .pkt_tx_eop         (pkt_tx_eop),
                            .pkt_tx_mod         (pkt_tx_mod),
                            .pkt_tx_sop         (pkt_tx_sop),
                            .pkt_tx_val         (pkt_tx_val),
                            .reset_156m25_n     (reset_156m25_n),
                            .reset_xgmii_rx_n   (reset_xgmii_rx_n),
                            .reset_xgmii_tx_n   (reset_xgmii_tx_n),
                            .wb_adr_i           (wb_adr_i),
                            .wb_clk_i           (wb_clk_i),
                            .wb_cyc_i           (wb_cyc_i),
                            .wb_dat_i           (wb_dat_i),
                            .wb_rst_i           (wb_rst_i),
                            .wb_stb_i           (wb_stb_i),
                            .wb_we_i            (wb_we_i),
                            .xgmii_rxc          (xgmii_rxc),
                            .xgmii_rxd          (xgmii_rxd)
                      );

endmodule
