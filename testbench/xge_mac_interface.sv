//////////////////////////////////////////////////////////////////////
//                                                                  //
//  File name : xge_mac_interface.sv                                //
//  Author    : G. Andres Mancera                                   //
//  License   : GNU Lesser General Public License                   //
//                                                                  //
//////////////////////////////////////////////////////////////////////

interface xge_mac_interface (   input   clk_156m25,
                                input   clk_xgmii_rx,
                                input   clk_xgmii_tx,
                                input   wb_clk_i,
                                input   reset_156m25_n,
                                input   reset_xgmii_rx_n,
                                input   reset_xgmii_tx_n,
                                input   wb_rst_i            );

  logic         pkt_rx_ren, pkt_tx_eop, pkt_tx_sop, pkt_tx_val;
  logic         wb_cyc_i, wb_stb_i, wb_we_i, wb_ack_o, wb_int_o;
  logic         pkt_rx_avail, pkt_rx_eop, pkt_rx_err, pkt_rx_sop, pkt_rx_val, pkt_tx_full;
  logic [63:0]  pkt_tx_data, xgmii_rxd, pkt_rx_data, xgmii_txd;
  logic [31:0]  wb_dat_i, wb_dat_o;
  logic [7:0]   wb_adr_i, xgmii_rxc, xgmii_txc;
  logic [2:0]   pkt_tx_mod, pkt_rx_mod;


  parameter INPUT_SKEW  = 1;
  parameter OUTPUT_SKEW = 1;

  default clocking cb @(posedge clk_156m25);
    default input   #INPUT_SKEW;
    default output  #OUTPUT_SKEW;
    input   #1  pkt_rx_avail;
    input   #1  pkt_rx_data;
    input   #1  pkt_rx_eop;
    input   #1  pkt_rx_err;
    input   #1  pkt_rx_mod;
    input   #1  pkt_rx_sop;
    input   #1  pkt_rx_val;
    input   #1  pkt_tx_full;
    input   #1  wb_ack_o;
    input   #1  wb_dat_o;
    input   #1  wb_int_o;
    input   #1  xgmii_txc;
    input   #1  xgmii_txd;
    output  #1  pkt_rx_ren;
    output  #1  pkt_tx_data;
    output  #1  pkt_tx_eop;
    output  #1  pkt_tx_mod;
    output  #1  pkt_tx_sop;
    output  #1  pkt_tx_val;
    output  #1  wb_adr_i;
    output  #1  wb_cyc_i;
    output  #1  wb_dat_i;
    output  #1  wb_stb_i;
    output  #1  wb_we_i;
    output  #1  xgmii_rxc;
    output  #1  xgmii_rxd;
  endclocking

  // modport to connect to the testcase
  modport testcase_port ( clocking cb );


  // task to wait a given number of nanoseconds
  task wait_ns(input [31:0] delay);
    #(1000*delay);
  endtask : wait_ns

  // task to drive all the DUT input signals to some 
  // appropriate value after the DUT comes out of reset
  task init_tb_signals();
    pkt_rx_ren      <= 1'b0;
    pkt_tx_data     <= { $urandom, $urandom_range(0,65535) };
    pkt_tx_val      <= 1'b0;
    pkt_tx_sop      <= 1'b0;
    pkt_tx_eop      <= 1'b0;
    pkt_tx_mod      <= $urandom_range(0,7);
    wb_adr_i        <= $urandom_range(0,255);
    wb_cyc_i        <= 1'b0;
    wb_dat_i        <= $urandom;
    wb_stb_i        <= 1'b0;
    wb_we_i         <= $urandom_range(0,1);
  endtask : init_tb_signals

  // task to configure the DUT in loopback mode
  // input 'xgmii_rxc' connected to output 'xgmii_txc'
  // input 'xgmii_rxd' connected to output 'xgmii_txd'
  task make_loopback_connection();
    assign  xgmii_rxc = xgmii_txc;
    assign  xgmii_rxd = xgmii_txd;
  endtask : make_loopback_connection


  // ================================= Assertions
  property no_two_consecutive_sop_without_eop;
    @(cb) pkt_rx_sop |=> !pkt_rx_sop throughout pkt_rx_eop [->1];
  endproperty
  assert property ( no_two_consecutive_sop_without_eop ) 
    else $error ("ASSERTION FAILED : Got 2 consecutive SOPs without EOP in between");

  property no_two_consecutive_eop_without_sop;
    @(cb) pkt_rx_eop |=> !pkt_rx_eop throughout pkt_rx_sop [->1];
  endproperty
  assert property ( no_two_consecutive_eop_without_sop )
    else $error ("ASSERTION FAILED : Got 2 consecutive EOPs without SOP in between");

  property data_never_not_unknown_on_valid;
    @(cb) pkt_rx_val |-> not($isunknown(pkt_rx_data));
  endproperty
  assert property ( data_never_not_unknown_on_valid )
    else $error ("ASSERTION FAILED : Packet RX Data is unknown when valid is asserted");
  // ============================================


endinterface : xge_mac_interface
