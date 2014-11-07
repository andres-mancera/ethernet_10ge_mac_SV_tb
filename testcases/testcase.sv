program testcase (
                    // Clocks are inputs for DUT and testcase
                    input logic             clk_156m25,
                    input logic             clk_xgmii_rx,
                    input logic             clk_xgmii_tx,
                    // DUT outputs
                    input logic             pkt_rx_avail,
                    input logic [63:0]      pkt_rx_data,
                    input logic             pkt_rx_eop,
                    input logic             pkt_rx_err,
                    input logic [2:0]       pkt_rx_mod,
                    input logic             pkt_rx_sop,
                    input logic             pkt_rx_val,
                    input logic             pkt_tx_full,
                    input logic             wb_ack_o,
                    input logic [31:0]      wb_dat_o,
                    input logic             wb_int_o,
                    input logic [7:0]       xgmii_txc,
                    input logic [63:0]      xgmii_txd,
                    // DUT inputs
                    output logic            pkt_rx_ren,
                    output logic [63:0]     pkt_tx_data,
                    output logic            pkt_tx_eop,
                    output logic [2:0]      pkt_tx_mod,
                    output logic            pkt_tx_sop,
                    output logic            pkt_tx_val,
                    output logic            reset_156m25_n,
                    output logic            reset_xgmii_rx_n,
                    output logic            reset_xgmii_tx_n,
                    output logic [7:0]      wb_adr_i,
                    output logic            wb_clk_i,
                    output logic            wb_cyc_i,
                    output logic [31:0]     wb_dat_i,
                    output logic            wb_rst_i,
                    output logic            wb_stb_i,
                    output logic            wb_we_i,
                    output logic [7:0]      xgmii_rxc,
                    output logic [63:0]     xgmii_rxd
                  );

  reg [7:0]     tx_buffer[0:10000];
  integer       tx_length;
  integer       tx_count;
  integer       rx_count;
  
  initial begin
    tx_count = 0;
    rx_count = 0;
  end

  assign xgmii_rxc  = xgmii_txc;
  assign xgmii_rxd  = xgmii_txd;
  assign wb_adr_i   = 8'b0;
  assign wb_clk_i   = 1'b0;
  assign wb_cyc_i   = 1'b0;
  assign wb_dat_i   = 32'b0;
  assign wb_rst_i   = 1'b1;
  assign wb_stb_i   = 1'b0;
  assign wb_we_i    = 1'b0;

  // Reset generation
  initial begin
    reset_156m25_n <= 1'b0;
    reset_xgmii_rx_n <= 1'b0;
    reset_xgmii_tx_n <= 1'b0;
    WaitNS(20);
    reset_156m25_n <= 1'b1;
    reset_xgmii_rx_n <= 1'b1;
    reset_xgmii_tx_n <= 1'b1;
  end

  // Init signals
  initial begin
    for (tx_length = 0; tx_length <= 1000; tx_length = tx_length + 1) begin
      tx_buffer[tx_length] = 0;
    end
    pkt_rx_ren <= 1'b0;
    pkt_tx_data <= 64'b0;
    pkt_tx_val <= 1'b0;
    pkt_tx_sop <= 1'b0;
    pkt_tx_eop <= 1'b0;
    pkt_tx_mod <= 3'b0;
  end

  initial begin
    WaitNS(5000);
`ifdef XIL
    WaitNS(200000);
`endif
    ProcessCmdFile();
  end

  initial begin
    forever begin
      if (pkt_rx_avail) begin
        RxPacket();
        if (rx_count == tx_count) begin
          $display("All packets received. Sumulation done!!!\n");
        end
      end
      @(posedge clk_156m25);
    end
  end


  // Other tasks
  task WaitNS(input [31:0] delay);
    begin
      #(1000*delay);
    end
  endtask : WaitNS


  task TxPacket;
    integer     i;
    begin
      $display("Transmit packet with length: %d", tx_length);
      @(posedge clk_156m25);
      WaitNS(1);
      pkt_tx_val <= 1'b1;
      for (i = 0; i < tx_length; i = i + 8) begin
        pkt_tx_sop <= 1'b0;
        pkt_tx_eop <= 1'b0;
        pkt_tx_mod <= 2'b0;
        if (i == 0) pkt_tx_sop <= 1'b1;
        if (i + 8 >= tx_length) begin
          pkt_tx_eop <= 1'b1;
          pkt_tx_mod <= tx_length % 8;
        end
        pkt_tx_data[`LANE7] <= tx_buffer[i];
        pkt_tx_data[`LANE6] <= tx_buffer[i+1];
        pkt_tx_data[`LANE5] <= tx_buffer[i+2];
        pkt_tx_data[`LANE4] <= tx_buffer[i+3];
        pkt_tx_data[`LANE3] <= tx_buffer[i+4];
        pkt_tx_data[`LANE2] <= tx_buffer[i+5];
        pkt_tx_data[`LANE1] <= tx_buffer[i+6];
        pkt_tx_data[`LANE0] <= tx_buffer[i+7];
        @(posedge clk_156m25);
        WaitNS(1);
      end
      pkt_tx_val <= 1'b0;
      pkt_tx_eop <= 1'b0;
      pkt_tx_mod <= 3'b0;
      tx_count = tx_count + 1;
    end
  endtask : TxPacket

  task CmdTxPacket(input [31:0] file);
    integer     count;
    integer     data;
    integer     i;
    begin
      count = $fscanf(file, "%2d", tx_length);
      if (count == 1) begin
        for (i = 0; i < tx_length; i = i + 1) begin
          count = $fscanf(file, "%2X", data);
          if (count) begin
            tx_buffer[i] = data;
          end
        end
        TxPacket();
      end
    end
  endtask : CmdTxPacket
  
  task ProcessCmdFile;
    integer         file_cmd;
    integer         count;
    reg [8*8-1:0]   str;
    begin
      file_cmd = $fopen("../testbench/verilog/packets_tx.txt", "r");
      if (!file_cmd) $stop;
      while (!$feof(file_cmd)) begin
        count = $fscanf(file_cmd, "%s", str);
        if (count != 1) continue;
        $display("CMD %s", str);
        case (str)
          "SEND_PKT": begin
                        CmdTxPacket(file_cmd);
                      end  
        endcase
      end
      $fclose(file_cmd);
      WaitNS(50000);
      $finish;
    end
  endtask : ProcessCmdFile

  // Task to read a single packet from receive interface and display
  task RxPacket;
    reg     done;
    begin
      done = 0;
      pkt_rx_ren <= 1'b1;
      @(posedge clk_156m25);
      while (!done) begin
        if (pkt_rx_val) begin
          if (pkt_rx_sop) begin
            $display("\n\n------------------------");
            $display("Received Packet");
            $display("------------------------");
          end
          $display("%x", pkt_rx_data);
          if (pkt_rx_eop) begin
            done <= 1;
            pkt_rx_ren <= 1'b0;
          end
          if (pkt_rx_eop) begin
            $display("------------------------\n\n");
          end
        end
        @(posedge clk_156m25);
      end
      rx_count = rx_count + 1;
    end
  endtask : RxPacket

endprogram
