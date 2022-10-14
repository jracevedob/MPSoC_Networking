////------------------------------------------------------------------------------
////  (c) Copyright 2013 Xilinx, Inc. All rights reserved.
////
////  This file contains confidential and proprietary information
////  of Xilinx, Inc. and is protected under U.S. and
////  international copyright and other intellectual property
////  laws.
////
////  DISCLAIMER
////  This disclaimer is not a license and does not grant any
////  rights to the materials distributed herewith. Except as
////  otherwise provided in a valid license issued to you by
////  Xilinx, and to the maximum extent permitted by applicable
////  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
////  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
////  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
////  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
////  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
////  (2) Xilinx shall not be liable (whether in contract or tort,
////  including negligence, or under any other theory of
////  liability) for any loss or damage of any kind or nature
////  related to, arising under or in connection with these
////  materials, including for any direct, or any indirect,
////  special, incidental, or consequential loss or damage
////  (including loss of data, profits, goodwill, or any type of
////  loss or damage suffered as a result of any action brought
////  by a third party) even if such damage or loss was
////  reasonably foreseeable or Xilinx had been advised of the
////  possibility of the same.
////
////  CRITICAL APPLICATIONS
////  Xilinx products are not designed or intended to be fail-
////  safe, or for use in any application requiring fail-safe
////  performance, such as life-support or safety devices or
////  systems, Class III medical devices, nuclear facilities,
////  applications related to the deployment of airbags, or any
////  other applications that could lead to death, personal
////  injury, or severe property or environmental damage
////  (individually and collectively, "Critical
////  Applications"). Customer assumes the sole risk and
////  liability of any use of Xilinx products in Critical
////  Applications, subject only to applicable laws and
////  regulations governing limitations on product liability.
////
////  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
////  PART OF THIS FILE AT ALL TIMES.
////------------------------------------------------------------------------------

`timescale 1fs/1fs
(* DowngradeIPIdentifiedWarnings="yes" *)
module pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_reset
#(
  parameter RESET_PIPE_LEN = 3
 )
(
  input  wire clk,
  input  wire reset_async,
  output wire reset
);

  (* ASYNC_REG = "TRUE" *) reg  [2:0] reset_pipe_stretch;
  (* ASYNC_REG = "TRUE" *) reg  [RESET_PIPE_LEN-1:0] reset_pipe_retime;
  (* max_fanout = 500 *) reg  reset_pipe_out;

// synthesis translate_off

  initial reset_pipe_stretch = {2{1'b1}};
  initial reset_pipe_retime  = {RESET_PIPE_LEN{1'b1}};
  initial reset_pipe_out     = 1'b1;

// synthesis translate_on

  always @(posedge clk or posedge reset_async)
    begin
      if (reset_async == 1'b1)
        begin
          reset_pipe_stretch <= {3{1'b1}};
        end
      else
        begin
          reset_pipe_stretch <= {reset_pipe_stretch[1:0], 1'b0};
        end
    end

  always @(posedge clk)
    begin
      reset_pipe_retime <= {reset_pipe_retime[RESET_PIPE_LEN-2:0], reset_pipe_stretch[2]};
      reset_pipe_out    <= reset_pipe_retime[RESET_PIPE_LEN-1];
    end

  assign reset = reset_pipe_out;

endmodule

module pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_reset_flop
(
  input  wire clk,
  input  wire reset_async,
  output wire reset
);

  (* keep = "true" *) reg  reset_flop_out;

// synthesis translate_off

  initial reset_flop_out = 1'b1;

// synthesis translate_on

  assign reset = reset_flop_out;

  always @(posedge clk)
    begin
      if (reset_async == 1'b1)
        begin
          reset_flop_out <= 1'b1;
        end
      else
        begin
          reset_flop_out <= 1'b0;
        end
    end

endmodule


module pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level
#(
  parameter WIDTH       = 1,
  parameter RESET_VALUE = 1'b0
 )
(
  input  wire clk,
  input  wire reset,

  input  wire [WIDTH-1:0] datain,
  output wire [WIDTH-1:0] dataout
);

  (* ASYNC_REG = "TRUE" *) reg  [WIDTH-1:0] dataout_reg;
  reg  [WIDTH-1:0] meta_nxt;
  wire [WIDTH-1:0] dataout_nxt;

`ifdef SARANCE_RTL_DEBUG
// pragma translate_off

  integer i;
  integer seed;
  (* ASYNC_REG = "TRUE" *) reg  [WIDTH-1:0] meta;
  (* ASYNC_REG = "TRUE" *) reg  [WIDTH-1:0] meta2;
  reg  [WIDTH-1:0] meta_state;
  reg  [WIDTH-1:0] meta_state_nxt;


  initial seed       = `SEED;
  initial meta_state = {WIDTH{RESET_VALUE}};

  always @*
    begin
      for (i=0; i < WIDTH; i = i + 1)
        begin
          if ( meta_state[i] !== 1'b1 &&

               $dist_uniform(seed,0,9999) < 5000 &&
               meta[i] !== datain[i] )
            begin
              meta_nxt[i]       = meta[i];
              meta_state_nxt[i] = 1'b1;
            end
          else
            begin
              meta_nxt[i]       = datain[i];
              meta_state_nxt[i] = 1'b0;
            end
        end // for


    end

  always @( posedge clk )
    begin
      meta_state <= meta_state_nxt;
    end


// pragma translate_on
`else
  (* ASYNC_REG = "TRUE" *) reg  [WIDTH-1:0] meta;
  (* ASYNC_REG = "TRUE" *) reg  [WIDTH-1:0] meta2;
  always @*
    begin
      meta_nxt = datain;
    end

`endif

  always @( posedge clk )
    begin
      if ( reset == 1'b1 )
        begin
          meta  <= {WIDTH{RESET_VALUE}};
          meta2 <= {WIDTH{RESET_VALUE}};
        end
      else
        begin
          meta  <= meta_nxt;
          meta2 <= meta;
        end
    end

  assign dataout_nxt = meta2;

  always @( posedge clk )
    begin
      if ( reset == 1'b1 )
        begin
          dataout_reg <= {WIDTH{RESET_VALUE}};
        end
      else
        begin
          dataout_reg <= dataout_nxt;
        end
    end

  assign dataout = dataout_reg;

`ifdef SARANCE_RTL_DEBUG
// pragma translate_off

// pragma translate_on
`endif

endmodule // syncer_level

module pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_pulse (

  input  wire clkin,
  input  wire clkin_reset,
  input  wire clkout,
  input  wire clkout_reset,

  input  wire pulsein,  // clkin domain
  output reg  pulseout  // clkout domain
);

  reg  pulsein_d1;
  reg  pulsein_d1_nxt;
  reg  pulseout_nxt;

  reg  req_event;
  reg  req_event_nxt;
  wire sync_req_event;
  reg  ack_event;
  reg  ack_event_nxt;
  wire sync_ack_event;

  wire clkin_reset_out_sync;
  wire clkout_reset_in_sync;

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level i_syncpls_req (

    .clk        (clkout),
    .reset      (clkout_reset),

    .datain     (req_event),
    .dataout    (sync_req_event)

  );  // i_syncpls_req

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level i_syncpls_ack (

    .clk        (clkin),
    .reset      (clkin_reset),

    .datain     (ack_event),
    .dataout    (sync_ack_event)

  );  // i_syncpls_ack

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_reset i_syncpls_clkin_rstsync (

    .clk         (clkout),
    .reset_async (clkin_reset),
    .reset       (clkin_reset_out_sync)

  );  // i_syncpls_clkin_rstsync

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_reset i_syncpls_clkout_rstsync (

    .clk         (clkin),
    .reset_async (clkout_reset),
    .reset       (clkout_reset_in_sync)

  );  // i_syncpls_clkout_rstsync


  always @*
    begin
      pulsein_d1_nxt = pulsein;
      req_event_nxt  = req_event;

      if (pulsein && !pulsein_d1 && req_event == sync_ack_event)
        begin
          req_event_nxt = ~req_event;
        end
    end


  always @*
    begin
      ack_event_nxt = sync_req_event;
      pulseout_nxt  = (ack_event != sync_req_event);
    end


  always @( posedge clkin )
    begin
      if ( clkout_reset_in_sync == 1'b1 )
        begin
          pulsein_d1 <= 1'b0;
          req_event  <= 1'b0;
        end
      else
        begin
          pulsein_d1 <= pulsein_d1_nxt;
          req_event  <= req_event_nxt;
        end
    end


  always @( posedge clkout )
    begin
      if ( clkin_reset_out_sync == 1'b1 )
        begin
          ack_event <= 1'b0;
          pulseout  <= 1'b0;
        end
      else
        begin
          ack_event <= ack_event_nxt;
          pulseout  <= pulseout_nxt;
        end
    end

`ifdef SARANCE_RTL_DEBUG
`endif


endmodule // syncer_pulse

//////////////////////////////////////////////////////////////////////////////

(* DowngradeIPIdentifiedWarnings="yes" *)
module pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage
#(
 parameter WIDTH  = 1
)
(
 input  clk,
 input  [WIDTH-1:0] signal_in,
 output wire [WIDTH-1:0]  signal_out
);

                          wire [WIDTH-1:0] sig_in_cdc_from;
 (* ASYNC_REG = "TRUE" *) reg  [WIDTH-1:0] s_out_d2_cdc_to;
 (* ASYNC_REG = "TRUE" *) reg  [WIDTH-1:0] data_out_d3;

assign sig_in_cdc_from = signal_in;
assign signal_out      = data_out_d3;

always @(posedge clk) 
begin
  s_out_d2_cdc_to  <= sig_in_cdc_from;
  data_out_d3      <= s_out_d2_cdc_to;
end

endmodule


module pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_pulse_no_syncer_reset (
  input  wire clkin,
  input  wire clkin_reset,
  input  wire clkout_reset_synced2clkin,
  input  wire clkout,
  input  wire clkout_reset,
  input  wire clkin_reset_synced2clkout,

  input  wire pulsein,  // clkin domain
  output reg  pulseout  // clkout domain
);

  reg  pulsein_d1;
  reg  pulsein_d1_nxt;
  reg  pulseout_nxt;

  reg  req_event;
  reg  req_event_nxt;
  wire sync_req_event;
  reg  ack_event;
  reg  ack_event_nxt;
  wire sync_ack_event;

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level i_syncpls_req (

    .clk        (clkout),
    .reset      (clkout_reset),

    .datain     (req_event),
    .dataout    (sync_req_event)

  );  // i_syncpls_req

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level i_syncpls_ack (

    .clk        (clkin),
    .reset      (clkin_reset),

    .datain     (ack_event),
    .dataout    (sync_ack_event)

  );  // i_syncpls_ack


  always @*
    begin
      pulsein_d1_nxt = pulsein;
      req_event_nxt  = req_event;

      if (pulsein && !pulsein_d1 && req_event == sync_ack_event)
        begin
          req_event_nxt = ~req_event;
        end
    end


  always @*
    begin
      ack_event_nxt = sync_req_event;
      pulseout_nxt  = (ack_event != sync_req_event);
    end


  always @( posedge clkin )
    begin
      if ( clkout_reset_synced2clkin == 1'b1 )
        begin
          pulsein_d1 <= 1'b0;
          req_event  <= 1'b0;
        end
      else
        begin
          pulsein_d1 <= pulsein_d1_nxt;
          req_event  <= req_event_nxt;
        end
    end


  always @( posedge clkout )
    begin
      if ( clkin_reset_synced2clkout == 1'b1 )
        begin
          ack_event <= 1'b0;
          pulseout  <= 1'b0;
        end
      else
        begin
          ack_event <= ack_event_nxt;
          pulseout  <= pulseout_nxt;
        end
    end

`ifdef SARANCE_RTL_DEBUG
`endif


endmodule  // syncer_pulse_no_syncer_reset

//////////////////////////////////////////////////////////////////////////////
module pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
#(
  parameter OUTWIDTH = 16,
  parameter INWIDTH = 16
 )
(
   input wire                       clk,
   input wire                       resetn,
   input wire                       pm_tick,
   input wire [INWIDTH-1:0]         pulsein,
   input wire                       hold_output,
   output reg [OUTWIDTH-1:0]        statsout
);

  wire pm_tick_pipe;
  wire pm_tick_post_pipe;

  assign pm_tick_pipe = pm_tick;

  reg  pm_tick_pipe_d1;
  wire pm_tick_pipe_d1_nxt = pm_tick_pipe;

  always @( posedge clk )
    begin
      if ( resetn == 1'b1 )
        begin
          pm_tick_pipe_d1 <= 1'b0;
        end
      else
        begin
          pm_tick_pipe_d1 <= pm_tick_pipe_d1_nxt;
      end
  end

  assign pm_tick_post_pipe = pm_tick_pipe_d1;

  wire hold_output_pipe;
  reg  pass_statshold_value;

  reg           hold_output_pipe_d1;
  wire          hold_output_pipe_d1_nxt = hold_output_pipe;

  assign hold_output_pipe = hold_output;

  always @( posedge clk )
    begin
      if ( resetn == 1'b1 )
        begin
        hold_output_pipe_d1 <= 1'b0;
        pass_statshold_value <= 1'b1;
        end
      else
        begin
          hold_output_pipe_d1 <= hold_output_pipe_d1_nxt;
        pass_statshold_value <= ~hold_output_pipe_d1;
        end
    end


  wire [INWIDTH-1:0] pulsein_r;
  wire [INWIDTH-1:0] pulsein_bus;


  assign pulsein_bus = pulsein;

  assign pulsein_r = pulsein_bus;

   //
   // The following alternative logic breaks up the pm_tick counter into two half-size counters.
   // It is intended to improve timing characteristics of the design mainly for 64-bit counters.
   //

   (* keep = "true" *) reg pm_tick_r;
   (* keep = "true" *) reg pm_tick_d1;

   reg [OUTWIDTH-1:0]      statsout_next;
   reg [OUTWIDTH-1:0]      statshold, statshold_next;
   reg [OUTWIDTH/2-1:0]    counter_lsb, counter_lsb_next;
   reg [OUTWIDTH/2-1:0]    counter_lsb_d1;
   reg                     counter_lsb_ovf, counter_lsb_ovf_next;
   reg [OUTWIDTH/2-1:0]    counter_msb, counter_msb_next;
   reg                     overflow;
   reg                     overflow_next;

   always @* begin

      // LSB counter
      if ( pm_tick_r ) begin
         counter_lsb_next = pulsein_r;
         counter_lsb_ovf_next = 1'b0;
      end
      else begin
         {counter_lsb_ovf_next, counter_lsb_next} = counter_lsb + pulsein_r;
      end

      // MSB counter
      if ( pm_tick_d1 ) begin
         counter_msb_next = 0;
         overflow_next = 1'b0;
         statshold_next = {counter_msb, counter_lsb_d1};
      end
      else begin
         {overflow_next, counter_msb_next} = ( !overflow ) ? counter_msb + counter_lsb_ovf : {1'b1,{(OUTWIDTH/2){1'b1}}};
         statshold_next = statshold;
      end

      statsout_next = pass_statshold_value ? statshold : statsout;
   end


   always @( posedge clk ) begin

      counter_lsb_d1 <= ( !overflow ) ? counter_lsb : {(OUTWIDTH/2){1'b1}};

   end


  always @( posedge clk )
    begin

         statshold <= statshold_next;
         statsout  <= statsout_next;
      end

always @( posedge clk )
    begin
      if ( resetn == 1'b1 )
      begin
        `ifdef HIGH_STATSREG_COUNTER
         // pragma translate_off
         pm_tick_r <= 1'b0;
         pm_tick_d1 <= 1'b0;
         counter_lsb <= {(OUTWIDTH/2){1'b1}}-10;
         counter_lsb_ovf <= 1'b0;
         counter_msb <= {(OUTWIDTH/2){1'b1}};
         overflow <= 1'b0;
         // pragma translate_on
        `elsif LSB_OVF_STATSREG_COUNTER
         // pragma translate_off
         pm_tick_r <= 1'b0;
         pm_tick_d1 <= 1'b0;
         counter_lsb <= {(OUTWIDTH/2){1'b1}}-10;
         counter_lsb_ovf <= 1'b0;
         counter_msb <= {{(OUTWIDTH/3){1'b0}},{(OUTWIDTH/6){1'b1}}};
         overflow <= 1'b0;
         // pragma translate_on
         `else
         pm_tick_r <= 1'b0;
         pm_tick_d1 <= 1'b0;
         counter_lsb <= 0;
         counter_lsb_ovf <= 1'b0;
         counter_msb <= 0;
         overflow <= 1'b0;
         `endif
      end
      else begin
         pm_tick_r <= pm_tick_post_pipe;
         pm_tick_d1 <= pm_tick_r;
         counter_lsb <= counter_lsb_next;
         counter_lsb_ovf <= counter_lsb_ovf_next;
         counter_msb <= counter_msb_next;
         overflow <= overflow_next;
      end
   end


endmodule // pmtick_statsreg


module pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pif_registers
#(
  parameter ADDR_WIDTH = 16,
  parameter DATA_WIDTH = 32
 )
(
  output wire ctl_tx_test_pattern,
  output wire ctl_rx_test_pattern,
  output wire ctl_tx_test_pattern_enable,
  output wire ctl_tx_test_pattern_select,
  output wire ctl_tx_data_pattern_select,
  output wire [57:0] ctl_tx_test_pattern_seed_a,
  output wire [57:0] ctl_tx_test_pattern_seed_b,
  output wire ctl_rx_test_pattern_enable,
  output wire ctl_rx_data_pattern_select,
  output wire axi_ctl_core_mode_switch,
  output wire ctl_tx_enable,
  output wire ctl_rx_enable,
  output wire ctl_tx_fcs_ins_enable,
  output wire ctl_rx_delete_fcs,
  output wire ctl_rx_ignore_fcs,
  output wire [14:0] ctl_rx_max_packet_len,
  output wire [7:0] ctl_rx_min_packet_len,
  output wire [3:0] ctl_tx_ipg_value,
  output wire ctl_tx_send_lfi,
  output wire ctl_tx_send_rfi,
  output wire ctl_tx_send_idle,
  output wire ctl_tx_custom_preamble_enable,
  output wire ctl_rx_custom_preamble_enable,
  output wire ctl_local_loopback,
  output wire ctl_gt_reset_all,
  output wire ctl_gt_tx_reset,
  output wire ctl_gt_rx_reset,
  output wire ctl_rx_check_sfd,
  output wire ctl_rx_check_preamble,
  output wire ctl_rx_process_lfi,
  output wire ctl_rx_force_resync,
  output wire ctl_tx_ignore_fcs,
  output wire [31:0] user_reg0,
  
  input  wire stat_rx_block_lock,
  input  wire stat_rx_status,
  input  wire stat_rx_framing_err_valid,
  input  wire stat_rx_framing_err,
  input  wire stat_rx_hi_ber,
  input  wire stat_rx_valid_ctrl_code,
  input  wire stat_rx_bad_code,
  input  wire [1:0] stat_rx_total_packets,
  input  wire stat_rx_total_good_packets,
  input  wire [3:0] stat_rx_total_bytes,
  input  wire [13:0] stat_rx_total_good_bytes,
  input  wire stat_rx_packet_small,
  input  wire stat_rx_jabber,
  input  wire stat_rx_packet_large,
  input  wire stat_rx_oversize,
  input  wire stat_rx_undersize,
  input  wire stat_rx_toolong,
  input  wire stat_rx_fragment,
  input  wire stat_rx_packet_64_bytes,
  input  wire stat_rx_packet_65_127_bytes,
  input  wire stat_rx_packet_128_255_bytes,
  input  wire stat_rx_packet_256_511_bytes,
  input  wire stat_rx_packet_512_1023_bytes,
  input  wire stat_rx_packet_1024_1518_bytes,
  input  wire stat_rx_packet_1519_1522_bytes,
  input  wire stat_rx_packet_1523_1548_bytes,
  input  wire [1:0] stat_rx_bad_fcs,
  input  wire stat_rx_packet_bad_fcs,
  input  wire [1:0] stat_rx_stomped_fcs,
  input  wire stat_rx_packet_1549_2047_bytes,
  input  wire stat_rx_packet_2048_4095_bytes,
  input  wire stat_rx_packet_4096_8191_bytes,
  input  wire stat_rx_packet_8192_9215_bytes,
  input  wire stat_rx_bad_preamble,
  input  wire stat_rx_bad_sfd,
  input  wire stat_rx_got_signal_os,
  input  wire stat_rx_test_pattern_mismatch,
  input  wire stat_rx_truncated,
  input  wire stat_rx_unicast,
  input  wire stat_rx_multicast,
  input  wire stat_rx_broadcast,
  input  wire stat_rx_vlan,
  input  wire stat_rx_inrangeerr,
  input  wire stat_rx_local_fault,
  input  wire stat_rx_remote_fault,
  input  wire stat_rx_internal_local_fault,
  input  wire stat_rx_received_local_fault,
  input  wire stat_tx_total_packets,
  input  wire [3:0] stat_tx_total_bytes,
  input  wire stat_tx_total_good_packets,
  input  wire [13:0] stat_tx_total_good_bytes,
  input  wire stat_tx_packet_64_bytes,
  input  wire stat_tx_packet_65_127_bytes,
  input  wire stat_tx_packet_128_255_bytes,
  input  wire stat_tx_packet_256_511_bytes,
  input  wire stat_tx_packet_512_1023_bytes,
  input  wire stat_tx_packet_1024_1518_bytes,
  input  wire stat_tx_packet_1519_1522_bytes,
  input  wire stat_tx_packet_1523_1548_bytes,
  input  wire stat_tx_packet_small,
  input  wire stat_tx_packet_large,
  input  wire stat_tx_packet_1549_2047_bytes,
  input  wire stat_tx_packet_2048_4095_bytes,
  input  wire stat_tx_packet_4096_8191_bytes,
  input  wire stat_tx_packet_8192_9215_bytes,
  input  wire stat_tx_unicast,
  input  wire stat_tx_multicast,
  input  wire stat_tx_broadcast,
  input  wire stat_tx_vlan,
  input  wire stat_tx_bad_fcs,
  input  wire stat_tx_frame_error,
  input  wire stat_tx_bad_parity,
  input  wire stat_tx_local_fault,
  input  wire stat_core_speed,

  input  rx_clk,
  input  rx_reset,
  input  tx_clk,
  input  tx_reset,

  output reg  rx_reset_out,
  output reg  tx_reset_out,
  output reg  [1-1:0] rx_serdes_reset_out,
  output reg  tx_serdes_reset_out,

  input  wire pm_tick,
  input  wire Bus2IP_Clk,
  input  wire Bus2IP_Resetn,
  input  wire [ADDR_WIDTH-1:0] Bus2IP_Addr,
  input  wire Bus2IP_RNW,
  input  wire Bus2IP_CS,
  input  wire Bus2IP_RdCE,
  input  wire Bus2IP_WrCE,
  input  wire [DATA_WIDTH-1:0] Bus2IP_Data,
  output reg  [DATA_WIDTH-1:0] IP2Bus_Data,
  output reg  IP2Bus_WrAck,
  output reg  IP2Bus_RdAck,
  output reg  IP2Bus_WrError,
  output reg  IP2Bus_RdError

);


  reg  AXI_Reset;
  reg  [ADDR_WIDTH-1:0] Bus2IP_Addr_reg;
  reg  Bus2IP_RNW_reg;
  reg  Bus2IP_CS_reg;
  reg  Bus2IP_RdCE_reg;
  reg  Bus2IP_WrCE_reg;
  reg  [DATA_WIDTH-1:0] Bus2IP_Data_reg;

  always @( posedge Bus2IP_Clk )
    begin
      AXI_Reset       <= ~Bus2IP_Resetn;
      Bus2IP_Addr_reg <= Bus2IP_Addr;
      Bus2IP_RNW_reg  <= Bus2IP_RNW;
      Bus2IP_CS_reg   <= Bus2IP_CS;
      Bus2IP_RdCE_reg <= Bus2IP_RdCE;
      Bus2IP_WrCE_reg <= Bus2IP_WrCE;
      Bus2IP_Data_reg <= Bus2IP_Data;
    end
  reg [1-1:0] rx_serdes_reset_r;
  reg tx_serdes_reset_r;
  reg rx_reset_r;
  reg tx_reset_r;

  always @(posedge Bus2IP_Clk)
    begin
      rx_reset_out       <= rx_reset_r | AXI_Reset;
      tx_reset_out       <= tx_reset_r | AXI_Reset;
      rx_serdes_reset_out <= rx_serdes_reset_r | AXI_Reset;
      tx_serdes_reset_out <= tx_serdes_reset_r | AXI_Reset;
    end

  reg  ctl_tx_test_pattern_r;
  reg  ctl_rx_test_pattern_r;
  reg  ctl_tx_test_pattern_enable_r;
  reg  ctl_tx_test_pattern_select_r;
  reg  ctl_tx_data_pattern_select_r;
  reg  [57:0] ctl_tx_test_pattern_seed_a_r;
  reg  [57:0] ctl_tx_test_pattern_seed_b_r;
  reg  ctl_rx_test_pattern_enable_r;
  reg  ctl_rx_data_pattern_select_r;
  reg  axi_ctl_core_mode_switch_r;
  reg  ctl_tx_enable_r;
  reg  ctl_rx_enable_r;
  reg  ctl_tx_fcs_ins_enable_r;
  reg  ctl_rx_delete_fcs_r;
  reg  ctl_rx_ignore_fcs_r;
  reg  [14:0] ctl_rx_max_packet_len_r;
  reg  [7:0] ctl_rx_min_packet_len_r;
  reg  [3:0] ctl_tx_ipg_value_r;
  reg  ctl_tx_send_lfi_r;
  reg  ctl_tx_send_rfi_r;
  reg  ctl_tx_send_idle_r;
  reg  ctl_tx_custom_preamble_enable_r;
  reg  ctl_rx_custom_preamble_enable_r;
  reg  ctl_local_loopback_r;
  reg  ctl_gt_reset_all_r;
  reg  ctl_gt_tx_reset_r;
  reg  ctl_gt_rx_reset_r;
  reg  ctl_rx_check_sfd_r;
  reg  ctl_rx_check_preamble_r;
  reg  ctl_rx_process_lfi_r;
  reg  ctl_rx_force_resync_r;
  reg  ctl_tx_ignore_fcs_r;
  reg  [31:0] user_reg0_r;
  reg  ctl_tx_test_pattern_out;
  reg  ctl_rx_test_pattern_out;
  reg  ctl_tx_test_pattern_enable_out;
  reg  ctl_tx_test_pattern_select_out;
  reg  ctl_tx_data_pattern_select_out;
  reg  [57:0] ctl_tx_test_pattern_seed_a_out;
  reg  [57:0] ctl_tx_test_pattern_seed_b_out;
  reg  ctl_rx_test_pattern_enable_out;
  reg  ctl_rx_data_pattern_select_out;
  reg  axi_ctl_core_mode_switch_out;
  reg  ctl_tx_enable_out;
  reg  ctl_rx_enable_out;
  reg  ctl_tx_fcs_ins_enable_out;
  reg  ctl_rx_delete_fcs_out;
  reg  ctl_rx_ignore_fcs_out;
  reg  [14:0] ctl_rx_max_packet_len_out;
  reg  [7:0] ctl_rx_min_packet_len_out;
  reg  [3:0] ctl_tx_ipg_value_out;
  reg  ctl_tx_send_lfi_out;
  reg  ctl_tx_send_rfi_out;
  reg  ctl_tx_send_idle_out;
  reg  ctl_tx_custom_preamble_enable_out;
  reg  ctl_rx_custom_preamble_enable_out;
  reg  ctl_local_loopback_out;
  reg  ctl_gt_reset_all_out;
  reg  ctl_gt_tx_reset_out;
  reg  ctl_gt_rx_reset_out;
  reg  ctl_rx_check_sfd_out;
  reg  ctl_rx_check_preamble_out;
  reg  ctl_rx_process_lfi_out;
  reg  ctl_rx_force_resync_out;
  reg  ctl_tx_ignore_fcs_out;
  reg  ctl_rx_forward_control_out;
  reg  [31:0] user_reg0_out;
  wire ctl_tx_test_pattern_r_sync;
  wire ctl_rx_test_pattern_r_sync;
  wire ctl_tx_test_pattern_enable_r_sync;
  wire ctl_tx_test_pattern_select_r_sync;
  wire ctl_tx_data_pattern_select_r_sync;
  wire [57:0] ctl_tx_test_pattern_seed_a_r_sync;
  wire [57:0] ctl_tx_test_pattern_seed_b_r_sync;
  wire ctl_rx_test_pattern_enable_r_sync;
  wire ctl_rx_data_pattern_select_r_sync;
  wire axi_ctl_core_mode_switch_r_sync;
  wire ctl_tx_enable_r_sync;
  wire ctl_rx_enable_r_sync;
  wire ctl_tx_fcs_ins_enable_r_sync;
  wire ctl_rx_delete_fcs_r_sync;
  wire ctl_rx_ignore_fcs_r_sync;
  wire [14:0] ctl_rx_max_packet_len_r_sync;
  wire [7:0] ctl_rx_min_packet_len_r_sync;
  wire [3:0] ctl_tx_ipg_value_r_sync;
  wire ctl_tx_send_lfi_r_sync;
  wire ctl_tx_send_rfi_r_sync;
  wire ctl_tx_send_idle_r_sync;
  wire ctl_tx_custom_preamble_enable_r_sync;
  wire ctl_rx_custom_preamble_enable_r_sync;
  wire ctl_rx_check_sfd_r_sync;
  wire ctl_rx_check_preamble_r_sync;
  wire ctl_rx_process_lfi_r_sync;
  wire ctl_rx_force_resync_r_sync;
  wire ctl_tx_ignore_fcs_r_sync;
  wire [31:0] user_reg0_r_sync;

  assign ctl_tx_test_pattern = ctl_tx_test_pattern_out;
  assign ctl_rx_test_pattern = ctl_rx_test_pattern_out;
  assign ctl_tx_test_pattern_enable = ctl_tx_test_pattern_enable_out;
  assign ctl_tx_test_pattern_select = ctl_tx_test_pattern_select_out;
  assign ctl_tx_data_pattern_select = ctl_tx_data_pattern_select_out;
  assign ctl_tx_test_pattern_seed_a = ctl_tx_test_pattern_seed_a_out;
  assign ctl_tx_test_pattern_seed_b = ctl_tx_test_pattern_seed_b_out;
  assign ctl_rx_test_pattern_enable = ctl_rx_test_pattern_enable_out;
  assign ctl_rx_data_pattern_select = ctl_rx_data_pattern_select_out;
  assign axi_ctl_core_mode_switch = axi_ctl_core_mode_switch_out;
  assign ctl_tx_enable = ctl_tx_enable_out;
  assign ctl_rx_enable = ctl_rx_enable_out;
  assign ctl_tx_fcs_ins_enable = ctl_tx_fcs_ins_enable_out;
  assign ctl_rx_delete_fcs = ctl_rx_delete_fcs_out;
  assign ctl_rx_ignore_fcs = ctl_rx_ignore_fcs_out;
  assign ctl_rx_max_packet_len = ctl_rx_max_packet_len_out;
  assign ctl_rx_min_packet_len = ctl_rx_min_packet_len_out;
  assign ctl_tx_ipg_value = ctl_tx_ipg_value_out;
  assign ctl_tx_send_lfi = ctl_tx_send_lfi_out;
  assign ctl_tx_send_rfi = ctl_tx_send_rfi_out;
  assign ctl_tx_send_idle = ctl_tx_send_idle_out;
  assign ctl_tx_custom_preamble_enable = ctl_tx_custom_preamble_enable_out;
  assign ctl_rx_custom_preamble_enable = ctl_rx_custom_preamble_enable_out;
  assign ctl_local_loopback = ctl_local_loopback_out;
  assign ctl_gt_reset_all = ctl_gt_reset_all_out;
  assign ctl_gt_tx_reset = ctl_gt_tx_reset_out;
  assign ctl_gt_rx_reset = ctl_gt_rx_reset_out;
  assign ctl_rx_check_sfd = ctl_rx_check_sfd_out;
  assign ctl_rx_check_preamble = ctl_rx_check_preamble_out;
  assign ctl_rx_process_lfi = ctl_rx_process_lfi_out;
  assign ctl_rx_force_resync = ctl_rx_force_resync_out;
  assign ctl_tx_ignore_fcs = ctl_tx_ignore_fcs_out;

  assign user_reg0 = user_reg0_out;

  wire [8-1:0] patch_rev;
  assign patch_rev = 8'd0;
  wire [8-1:0] major_rev;
  assign major_rev = 8'd3;
  wire [8-1:0] minor_rev;
  assign minor_rev = 8'd1;

  wire AXI_Reset_rx_clk_sync;
  wire AXI_Reset_tx_clk_sync;

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_reset i_AXI_RESET_RX_SYNC (

    .clk             (rx_clk),
    .reset_async     (AXI_Reset),
    .reset           (AXI_Reset_rx_clk_sync)

  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_reset i_AXI_RESET_TX_SYNC (

    .clk             (tx_clk),
    .reset_async     (AXI_Reset),
    .reset           (AXI_Reset_tx_clk_sync)

  );

  reg [10-1:0] rx_reset_pulse_len;
  reg [10-1:0] tx_reset_pulse_len;
  reg rx_reset_d1;
  reg tx_reset_d1;

  always @( posedge rx_clk )
    begin
      if ( AXI_Reset_rx_clk_sync == 1'b1 )
        begin
          rx_reset_d1        <= 1'b0;
          rx_reset_pulse_len <= {10{1'b1}};
        end
      else if ( (rx_reset_d1 == 1'b0) && (rx_reset == 1'b1) )
        begin
          rx_reset_d1        <= rx_reset;
          rx_reset_pulse_len <= {10{1'b1}};
        end
      else
        begin
          rx_reset_d1        <= rx_reset;
          rx_reset_pulse_len <= {1'b0, rx_reset_pulse_len[10-1:1]};
        end
    end

  always @( posedge tx_clk )
    begin
      if ( AXI_Reset_tx_clk_sync == 1'b1 )
        begin
          tx_reset_d1        <= 1'b0;
          tx_reset_pulse_len <= {10{1'b1}};
        end
      else if ( (tx_reset_d1 == 1'b0) && (tx_reset == 1'b1) )
        begin
          tx_reset_d1        <= tx_reset;
          tx_reset_pulse_len <= {10{1'b1}};
        end
      else
        begin
          tx_reset_d1        <= tx_reset;
          tx_reset_pulse_len <= {1'b0, tx_reset_pulse_len[10-1:1]};
        end
    end

  wire rx_reset_pulse;
  wire tx_reset_pulse;
  assign rx_reset_pulse = rx_reset_pulse_len[0];
  assign tx_reset_pulse = tx_reset_pulse_len[0];


  reg  tick_reg_mode_sel_r;
  reg  tick_reg_r;
  reg  tick_r;
  wire rx_clk_tick_r;
  wire tx_clk_tick_r;
  wire rx_clk_tick_retimed;
  wire tx_clk_tick_retimed;

  reg           rx_clk_tick_retimed_d1;
  wire          rx_clk_tick_retimed_d1_nxt = rx_clk_tick_retimed;

  reg           tx_clk_tick_retimed_d1;
  wire          tx_clk_tick_retimed_d1_nxt = tx_clk_tick_retimed;

  //reg  [31:0] user_reg0_r;


  reg  statsreg_read_req;
  reg  statsreg_read_ack;
  wire  rx_clk_statsreg_hold_r;
  wire  tx_clk_statsreg_hold_r;
  wire rx_clk_statsreg_hold;
  wire tx_clk_statsreg_hold;

  reg           rx_clk_statsreg_hold_d1;
  wire          rx_clk_statsreg_hold_d1_nxt = rx_clk_statsreg_hold;

  reg           tx_clk_statsreg_hold_d1;
  wire          tx_clk_statsreg_hold_d1_nxt = tx_clk_statsreg_hold;

  reg  [7-1:0] timeout_counter;
  reg  timeout_error;

  wire stat_cycle = 1'b1;

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (58)
  ) i_reg_ctl_tx_test_pattern_seed_a_r_syncer (
    .clk          (tx_clk),
    .reset        (AXI_Reset_tx_clk_sync),
    .datain       (ctl_tx_test_pattern_seed_a_r),
    .dataout      (ctl_tx_test_pattern_seed_a_r_sync )
  );


  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (58)
  ) i_reg_ctl_tx_test_pattern_seed_b_r_syncer (
    .clk          (tx_clk),
    .reset        (AXI_Reset_tx_clk_sync),
    .datain       (ctl_tx_test_pattern_seed_b_r),
    .dataout      (ctl_tx_test_pattern_seed_b_r_sync )
  );


  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_tx_test_pattern_select_r_syncer (
    .clk          (tx_clk),
    .reset        (AXI_Reset_tx_clk_sync),
    .datain       (ctl_tx_test_pattern_select_r),
    .dataout      (ctl_tx_test_pattern_select_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_tx_fcs_ins_enable_r_syncer (
    .clk          (tx_clk),
    .reset        (AXI_Reset_tx_clk_sync),
    .datain       (ctl_tx_fcs_ins_enable_r),
    .dataout      (ctl_tx_fcs_ins_enable_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_tx_enable_r_syncer (
    .clk          (tx_clk),
    .reset        (AXI_Reset_tx_clk_sync),
    .datain       (ctl_tx_enable_r),
    .dataout      (ctl_tx_enable_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_tx_custom_preamble_enable_r_syncer (
    .clk          (tx_clk),
    .reset        (AXI_Reset_tx_clk_sync),
    .datain       (ctl_tx_custom_preamble_enable_r),
    .dataout      (ctl_tx_custom_preamble_enable_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_tx_send_idle_r_syncer (
    .clk          (tx_clk),
    .reset        (AXI_Reset_tx_clk_sync),
    .datain       (ctl_tx_send_idle_r),
    .dataout      (ctl_tx_send_idle_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_tx_ignore_fcs_r_syncer (
    .clk          (tx_clk),
    .reset        (AXI_Reset_tx_clk_sync),
    .datain       (ctl_tx_ignore_fcs_r),
    .dataout      (ctl_tx_ignore_fcs_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_tx_test_pattern_r_syncer (
    .clk          (tx_clk),
    .reset        (AXI_Reset_tx_clk_sync),
    .datain       (ctl_tx_test_pattern_r),
    .dataout      (ctl_tx_test_pattern_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_tx_data_pattern_select_r_syncer (
    .clk          (tx_clk),
    .reset        (AXI_Reset_tx_clk_sync),
    .datain       (ctl_tx_data_pattern_select_r),
    .dataout      (ctl_tx_data_pattern_select_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (4)
  ) i_reg_ctl_tx_ipg_value_r_syncer (
    .clk          (tx_clk),
    .reset        (AXI_Reset_tx_clk_sync),
    .datain       (ctl_tx_ipg_value_r),
    .dataout      (ctl_tx_ipg_value_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_tx_send_lfi_r_syncer (
    .clk          (tx_clk),
    .reset        (AXI_Reset_tx_clk_sync),
    .datain       (ctl_tx_send_lfi_r),
    .dataout      (ctl_tx_send_lfi_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_tx_test_pattern_enable_r_syncer (
    .clk          (tx_clk),
    .reset        (AXI_Reset_tx_clk_sync),
    .datain       (ctl_tx_test_pattern_enable_r),
    .dataout      (ctl_tx_test_pattern_enable_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_tx_send_rfi_r_syncer (
    .clk          (tx_clk),
    .reset        (AXI_Reset_tx_clk_sync),
    .datain       (ctl_tx_send_rfi_r),
    .dataout      (ctl_tx_send_rfi_r_sync )
  );


  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_rx_check_preamble_r_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (ctl_rx_check_preamble_r),
    .dataout      (ctl_rx_check_preamble_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_rx_ignore_fcs_r_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (ctl_rx_ignore_fcs_r),
    .dataout      (ctl_rx_ignore_fcs_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_rx_force_resync_r_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (ctl_rx_force_resync_r),
    .dataout      (ctl_rx_force_resync_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_rx_test_pattern_enable_r_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (ctl_rx_test_pattern_enable_r),
    .dataout      (ctl_rx_test_pattern_enable_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_rx_custom_preamble_enable_r_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (ctl_rx_custom_preamble_enable_r),
    .dataout      (ctl_rx_custom_preamble_enable_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_rx_delete_fcs_r_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (ctl_rx_delete_fcs_r),
    .dataout      (ctl_rx_delete_fcs_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_rx_test_pattern_r_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (ctl_rx_test_pattern_r),
    .dataout      (ctl_rx_test_pattern_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_rx_enable_r_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (ctl_rx_enable_r),
    .dataout      (ctl_rx_enable_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_rx_process_lfi_r_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (ctl_rx_process_lfi_r),
    .dataout      (ctl_rx_process_lfi_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_rx_data_pattern_select_r_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (ctl_rx_data_pattern_select_r),
    .dataout      (ctl_rx_data_pattern_select_r_sync )
  );


  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_axi_ctl_core_mode_switch_r_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (axi_ctl_core_mode_switch_r),
    .dataout      (axi_ctl_core_mode_switch_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_ctl_rx_check_sfd_r_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (ctl_rx_check_sfd_r),
    .dataout      (ctl_rx_check_sfd_r_sync )
  );






  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (8)
  ) i_reg_ctl_rx_min_packet_len_r_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (ctl_rx_min_packet_len_r),
    .dataout      (ctl_rx_min_packet_len_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (15)
  ) i_reg_ctl_rx_max_packet_len_r_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (ctl_rx_max_packet_len_r),
    .dataout      (ctl_rx_max_packet_len_r_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (32)
  ) i_reg_user_reg0_r_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (user_reg0_r),
    .dataout      (user_reg0_r_sync )
  );

  wire write_req;
  reg  write_req_d1;
  reg  write_req_d2;
  wire AXI_write;
  reg  ctl_reg_write_hold;
  assign write_req = Bus2IP_CS_reg & ~Bus2IP_RNW_reg;
  assign AXI_write = write_req & write_req_d2;

  always @( posedge Bus2IP_Clk )
    begin
      if ( AXI_Reset == 1'b1 )
        begin
          ctl_reg_write_hold <= 1'b0;
          write_req_d1       <= 1'b0;
          write_req_d2       <= 1'b0;
        end
      else
        begin
          ctl_reg_write_hold <= write_req | IP2Bus_WrAck;
          write_req_d1       <= write_req;
          write_req_d2       <= write_req_d1;
        end
    end

  wire ctl_reg_write_enable_tx_clk_sync;

  // The dataout FF typically drives the CE pin on FFs in the tx_clk domain.
  // Invert going into the syncer_level module so that the CE pin can be
  // driven directly, which can be better-handled by Vivado during replication.
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_ctl_reg_tx_clk_write_hold_syncer (
    .clk          (tx_clk),
    .reset        (tx_reset_pulse),
    .datain       (!ctl_reg_write_hold),
    .dataout      (ctl_reg_write_enable_tx_clk_sync )
  );

  wire ctl_reg_write_enable_rx_clk_sync;

  // The dataout FF typically drives the CE pin on FFs in the rx_clk domain.
  // Invert going into the syncer_level module so that the CE pin can be
  // driven directly, which can be better-handled by Vivado during replication.

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_ctl_reg_rx_clk_write_hold_syncer (
    .clk          (rx_clk),
    .reset        (rx_reset_pulse),
    .datain       (!ctl_reg_write_hold),
    .dataout      (ctl_reg_write_enable_rx_clk_sync )
  );



  always @( posedge tx_clk )
    begin
      if (ctl_reg_write_enable_tx_clk_sync == 1'b1) begin
        ctl_tx_test_pattern_seed_a_out <= ctl_tx_test_pattern_seed_a_r_sync;
      end
    end


  always @( posedge tx_clk )
    begin
      if (ctl_reg_write_enable_tx_clk_sync == 1'b1) begin
        ctl_tx_test_pattern_seed_b_out <= ctl_tx_test_pattern_seed_b_r_sync;
      end
    end



  always @( posedge tx_clk )
    begin
      if (ctl_reg_write_enable_tx_clk_sync == 1'b1) begin
        ctl_tx_test_pattern_select_out <= ctl_tx_test_pattern_select_r_sync;
      end
    end

  always @( posedge tx_clk )
    begin
      if (ctl_reg_write_enable_tx_clk_sync == 1'b1) begin
        ctl_tx_fcs_ins_enable_out <= ctl_tx_fcs_ins_enable_r_sync;
      end
    end

  always @( posedge tx_clk )
    begin
      if (ctl_reg_write_enable_tx_clk_sync == 1'b1) begin
        ctl_tx_enable_out <= ctl_tx_enable_r_sync;
      end
    end

  always @( posedge tx_clk )
    begin
      if (ctl_reg_write_enable_tx_clk_sync == 1'b1) begin
        ctl_tx_custom_preamble_enable_out <= ctl_tx_custom_preamble_enable_r_sync;
      end
    end

  always @( posedge tx_clk )
    begin
      if (ctl_reg_write_enable_tx_clk_sync == 1'b1) begin
        ctl_tx_send_idle_out <= ctl_tx_send_idle_r_sync;
      end
    end

  always @( posedge tx_clk )
    begin
      if (ctl_reg_write_enable_tx_clk_sync == 1'b1) begin
        ctl_tx_ignore_fcs_out <= ctl_tx_ignore_fcs_r_sync;
      end
    end

  always @( posedge tx_clk )
    begin
      if (ctl_reg_write_enable_tx_clk_sync == 1'b1) begin
        ctl_tx_test_pattern_out <= ctl_tx_test_pattern_r_sync;
      end
    end

  always @( posedge tx_clk )
    begin
      if (ctl_reg_write_enable_tx_clk_sync == 1'b1) begin
        ctl_tx_data_pattern_select_out <= ctl_tx_data_pattern_select_r_sync;
      end
    end

  always @( posedge tx_clk )
    begin
      if (ctl_reg_write_enable_tx_clk_sync == 1'b1) begin
        ctl_tx_ipg_value_out <= ctl_tx_ipg_value_r_sync;
      end
    end

  always @( posedge tx_clk )
    begin
      if (ctl_reg_write_enable_tx_clk_sync == 1'b1) begin
        ctl_tx_send_lfi_out <= ctl_tx_send_lfi_r_sync;
      end
    end

  always @( posedge tx_clk )
    begin
      if (ctl_reg_write_enable_tx_clk_sync == 1'b1) begin
        ctl_tx_test_pattern_enable_out <= ctl_tx_test_pattern_enable_r_sync;
      end
    end

  always @( posedge tx_clk )
    begin
      if (ctl_reg_write_enable_tx_clk_sync == 1'b1) begin
        ctl_tx_send_rfi_out <= ctl_tx_send_rfi_r_sync;
      end
    end


  always @( posedge Bus2IP_Clk )
    begin
      ctl_gt_reset_all_out <= ctl_gt_reset_all_r;
    end

  always @( posedge Bus2IP_Clk )
    begin
      ctl_gt_tx_reset_out <= ctl_gt_tx_reset_r;
    end

  always @( posedge Bus2IP_Clk )
    begin
      ctl_gt_rx_reset_out <= ctl_gt_rx_reset_r;
    end


  always @( posedge Bus2IP_Clk )
    begin
      ctl_local_loopback_out <= ctl_local_loopback_r;
    end

  always @( posedge rx_clk )
    begin
      if (ctl_reg_write_enable_rx_clk_sync == 1'b1) begin
        ctl_rx_check_preamble_out <= ctl_rx_check_preamble_r_sync;
      end
    end

  always @( posedge rx_clk )
    begin
      if (ctl_reg_write_enable_rx_clk_sync == 1'b1) begin
        ctl_rx_ignore_fcs_out <= ctl_rx_ignore_fcs_r_sync;
      end
    end

  always @( posedge rx_clk )
    begin
      if (ctl_reg_write_enable_rx_clk_sync == 1'b1) begin
        ctl_rx_force_resync_out <= ctl_rx_force_resync_r_sync;
      end
    end

  always @( posedge rx_clk )
    begin
      if (ctl_reg_write_enable_rx_clk_sync == 1'b1) begin
        ctl_rx_test_pattern_enable_out <= ctl_rx_test_pattern_enable_r_sync;
      end
    end

  always @( posedge rx_clk )
    begin
      if (ctl_reg_write_enable_rx_clk_sync == 1'b1) begin
        ctl_rx_custom_preamble_enable_out <= ctl_rx_custom_preamble_enable_r_sync;
      end
    end

  always @( posedge rx_clk )
    begin
      if (ctl_reg_write_enable_rx_clk_sync == 1'b1) begin
        ctl_rx_delete_fcs_out <= ctl_rx_delete_fcs_r_sync;
      end
    end

  always @( posedge rx_clk )
    begin
      if (ctl_reg_write_enable_rx_clk_sync == 1'b1) begin
        ctl_rx_test_pattern_out <= ctl_rx_test_pattern_r_sync;
      end
    end

  always @( posedge rx_clk )
    begin
      if (ctl_reg_write_enable_rx_clk_sync == 1'b1) begin
        ctl_rx_enable_out <= ctl_rx_enable_r_sync;
      end
    end

  always @( posedge rx_clk )
    begin
      if (ctl_reg_write_enable_rx_clk_sync == 1'b1) begin
        ctl_rx_process_lfi_out <= ctl_rx_process_lfi_r_sync;
      end
    end

  always @( posedge rx_clk )
    begin
      if (ctl_reg_write_enable_rx_clk_sync == 1'b1) begin
        ctl_rx_data_pattern_select_out <= ctl_rx_data_pattern_select_r_sync;
      end
    end

  always @( posedge rx_clk )
    begin
      if (ctl_reg_write_enable_rx_clk_sync == 1'b1) begin
        axi_ctl_core_mode_switch_out <= axi_ctl_core_mode_switch_r_sync;
      end
    end

  always @( posedge rx_clk )
    begin
      if (ctl_reg_write_enable_rx_clk_sync == 1'b1) begin
        ctl_rx_check_sfd_out <= ctl_rx_check_sfd_r_sync;
      end
    end





  always @( posedge rx_clk )
    begin
      if (ctl_reg_write_enable_rx_clk_sync == 1'b1) begin
        ctl_rx_min_packet_len_out <= ctl_rx_min_packet_len_r_sync;
      end
    end

  always @( posedge rx_clk )
    begin
      if (ctl_reg_write_enable_rx_clk_sync == 1'b1) begin
        ctl_rx_max_packet_len_out <= ctl_rx_max_packet_len_r_sync;
      end
    end


  reg  [DATA_WIDTH-1:0] write_data_r;
  reg  IP2Bus_WrAck_d1;

  always @( posedge tx_clk )
    begin
      if (ctl_reg_write_enable_rx_clk_sync == 1'b1) begin
        user_reg0_out <= user_reg0_r_sync;
      end
    end

  always @( posedge Bus2IP_Clk )
    begin
      if ( AXI_Reset == 1'b1 )
      begin
         IP2Bus_WrAck  <= 1'b0;
         IP2Bus_WrAck_d1 <= 1'b0;
         IP2Bus_WrError <= 1'b0;
         write_data_r <= 'b0;
         // Registers resets.
         ctl_tx_test_pattern_seed_a_r <= 'b0;
         ctl_tx_enable_r <= 'b1;
         ctl_tx_fcs_ins_enable_r <= 'b1;
         ctl_tx_custom_preamble_enable_r <= 'b0;
         ctl_tx_test_pattern_select_r <= 'b0;
         ctl_tx_send_idle_r <= 'b0;
         ctl_tx_ignore_fcs_r <= 'b0;
         ctl_tx_test_pattern_r <= 'b0;
         ctl_tx_data_pattern_select_r <= 'b0;
         ctl_tx_test_pattern_seed_b_r <= 'b0;
         ctl_tx_ipg_value_r <= 'd12;
         ctl_tx_send_lfi_r <= 'b0;
         ctl_tx_test_pattern_enable_r <= 'b0;
         ctl_tx_send_rfi_r <= 'b0;
         ctl_gt_reset_all_r <= 'b0;
         ctl_gt_tx_reset_r <= 'b0;
         ctl_gt_rx_reset_r <= 'b0;
         user_reg0_r <= 'b0;
         ctl_local_loopback_r <= 'b0;
         tick_reg_mode_sel_r <= 'b1;
         ctl_rx_check_preamble_r <= 'b1;
         ctl_rx_ignore_fcs_r <= 'b0;
         ctl_rx_force_resync_r <= 'b0;
         ctl_rx_test_pattern_enable_r <= 'b0;
         ctl_rx_custom_preamble_enable_r <= 'b0;
         ctl_rx_delete_fcs_r <= 'b1;
         ctl_rx_test_pattern_r <= 'b0;
         ctl_rx_enable_r <= 'b1;
         ctl_rx_process_lfi_r <= 'b0;
         ctl_rx_data_pattern_select_r <= 'b0;
         axi_ctl_core_mode_switch_r <= 1'b0;
         ctl_rx_check_sfd_r <= 'b1;
         rx_reset_r <= 'b0;
         rx_serdes_reset_r <= 'b0;
         tx_serdes_reset_r <= 'b0;
         tx_reset_r <= 'b0;
         ctl_rx_min_packet_len_r <= 'd64;
         ctl_rx_max_packet_len_r <= 'd9600;
         tick_reg_r <= 'b0;

      end
    else
      begin

         // Self clearing
         tick_reg_r <= 'b0;
         write_data_r <= 'b0;
         IP2Bus_WrAck_d1 <= 1'b0;	 
         axi_ctl_core_mode_switch_r <= 'b0;
	 ctl_gt_reset_all_r <= 'b0;
         IP2Bus_WrError <= 1'b0;	 
         //- Write transaction

         if (AXI_write)
          begin
            IP2Bus_WrError <= 1'b1; // Assume it is a bad write unless it hits an address with at least one writeable bit
            write_data_r <= Bus2IP_Data_reg;
            case ({Bus2IP_Addr_reg[ADDR_WIDTH-1:2],2'b0})


               'h0000 : begin  // GT_RESET_REG
                          ctl_gt_reset_all_r <= Bus2IP_Data_reg[0];
                          ctl_gt_rx_reset_r <= Bus2IP_Data_reg[1];
                          ctl_gt_tx_reset_r <= Bus2IP_Data_reg[2];
                          IP2Bus_WrError <= 1'b0;
                        end

               'h0004 : begin  // RESET_REG
                          rx_serdes_reset_r <= Bus2IP_Data_reg[0];
                          tx_serdes_reset_r <= Bus2IP_Data_reg[29];
                          rx_reset_r <= Bus2IP_Data_reg[30];
                          tx_reset_r <= Bus2IP_Data_reg[31];
                          IP2Bus_WrError <= 1'b0;
                        end

               'h0008 : begin  // MODE_REG
                          tick_reg_mode_sel_r <= Bus2IP_Data_reg[30];
                          ctl_local_loopback_r <= Bus2IP_Data_reg[31];
                          IP2Bus_WrError <= 1'b0;
                        end

               'h000C : begin  // CONFIGURATION_TX_REG1
                          ctl_tx_enable_r <= Bus2IP_Data_reg[0];
                          ctl_tx_fcs_ins_enable_r <= Bus2IP_Data_reg[1];
                          ctl_tx_ignore_fcs_r <= Bus2IP_Data_reg[2];
                          ctl_tx_send_lfi_r <= Bus2IP_Data_reg[3];
                          ctl_tx_send_rfi_r <= Bus2IP_Data_reg[4];
                          ctl_tx_send_idle_r <= Bus2IP_Data_reg[5];
                          ctl_tx_ipg_value_r <= Bus2IP_Data_reg[14-1:10];
                          ctl_tx_test_pattern_r <= Bus2IP_Data_reg[14];
                          ctl_tx_test_pattern_enable_r <= Bus2IP_Data_reg[15];
                          ctl_tx_test_pattern_select_r <= Bus2IP_Data_reg[16];
                          ctl_tx_data_pattern_select_r <= Bus2IP_Data_reg[17];
                          ctl_tx_custom_preamble_enable_r <= Bus2IP_Data_reg[18];
                          IP2Bus_WrError <= 1'b0;
                        end

               'h0014 : begin  // CONFIGURATION_RX_REG1
                          ctl_rx_enable_r <= Bus2IP_Data_reg[0];
                          ctl_rx_delete_fcs_r <= Bus2IP_Data_reg[1];
                          ctl_rx_ignore_fcs_r <= Bus2IP_Data_reg[2];
                          ctl_rx_process_lfi_r <= Bus2IP_Data_reg[3];
                          ctl_rx_check_sfd_r <= Bus2IP_Data_reg[4];
                          ctl_rx_check_preamble_r <= Bus2IP_Data_reg[5];
                          ctl_rx_force_resync_r <= Bus2IP_Data_reg[6];
                          ctl_rx_test_pattern_r <= Bus2IP_Data_reg[7];
                          ctl_rx_test_pattern_enable_r <= Bus2IP_Data_reg[8];
                          ctl_rx_data_pattern_select_r <= Bus2IP_Data_reg[9];
                          ctl_rx_custom_preamble_enable_r <= Bus2IP_Data_reg[11];
                          IP2Bus_WrError <= 1'b0;
                        end

               'h0018 : begin  // CONFIGURATION_RX_MTU
                          ctl_rx_min_packet_len_r <= Bus2IP_Data_reg[8-1:0];
                          ctl_rx_max_packet_len_r <= Bus2IP_Data_reg[31-1:16];
                          IP2Bus_WrError <= 1'b0;
                        end

               'h0020 : begin  // TICK_REG
                          tick_reg_r <= Bus2IP_Data_reg[0];
                          IP2Bus_WrError <= 1'b0;
                        end

               'h0024 : begin  // CONFIGURATION_REVISION_REG
                        end

               'h0028 : begin  // CONFIGURATION_TX_TEST_PAT_SEED_A_LSB
                          ctl_tx_test_pattern_seed_a_r[31:0] <= Bus2IP_Data_reg[32-1:0];
                          IP2Bus_WrError <= 1'b0;
                        end

               'h002C : begin  // CONFIGURATION_TX_TEST_PAT_SEED_A_MSB
                          ctl_tx_test_pattern_seed_a_r[57:32] <= Bus2IP_Data_reg[26-1:0];
                          IP2Bus_WrError <= 1'b0;
                        end

               'h0030 : begin  // CONFIGURATION_TX_TEST_PAT_SEED_B_LSB
                          ctl_tx_test_pattern_seed_b_r[31:0] <= Bus2IP_Data_reg[32-1:0];
                          IP2Bus_WrError <= 1'b0;
                        end

               'h0034 : begin  // CONFIGURATION_TX_TEST_PAT_SEED_B_MSB
                          ctl_tx_test_pattern_seed_b_r[57:32] <= Bus2IP_Data_reg[26-1:0];
                          IP2Bus_WrError <= 1'b0;
                        end

               'h0134 : begin  // USER_REG_0
                          user_reg0_r <= Bus2IP_Data_reg[32-1:0];
                          IP2Bus_WrError <= 1'b0;
                        end

               'h0138 : begin  // SWITCH_CORE_SPEED_REG
                          axi_ctl_core_mode_switch_r <= Bus2IP_Data_reg[0];
                          IP2Bus_WrError <= 1'b0;
                        end

            endcase
            IP2Bus_WrAck  <= 1'b1;
          end // cs
        else
          begin
            IP2Bus_WrAck  <= 1'b0;
          end // cs
       end // reset
      end // always @ block. WRITE

//
// Setup Stats: latch regs, counters.
//

  wire [48-1:0] stat_rx_packet_1549_2047_bytes_count;
  wire [48-1:0] stat_rx_packet_1549_2047_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_1549_2047_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_1549_2047_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_1549_2047_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_packet_1549_2047_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_packet_1549_2047_bytes_count),
    .signal_out   (stat_rx_packet_1549_2047_bytes_count_sync)
  );

  wire [48-1:0] stat_rx_jabber_count;
  wire [48-1:0] stat_rx_jabber_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_jabber_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_jabber ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_jabber_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_jabber_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_jabber_count),
    .signal_out   (stat_rx_jabber_count_sync)
  );

  wire [48-1:0] stat_rx_total_good_packets_count;
  wire [48-1:0] stat_rx_total_good_packets_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_total_good_packets_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_total_good_packets ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_total_good_packets_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_total_good_packets_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_total_good_packets_count),
    .signal_out   (stat_rx_total_good_packets_count_sync)
  );

  wire [48-1:0] stat_rx_stomped_fcs_count;
  wire [48-1:0] stat_rx_stomped_fcs_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(2),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_stomped_fcs_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_stomped_fcs ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_stomped_fcs_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_stomped_fcs_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_stomped_fcs_count),
    .signal_out   (stat_rx_stomped_fcs_count_sync)
  );

  wire [48-1:0] stat_rx_broadcast_count;
  wire [48-1:0] stat_rx_broadcast_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_broadcast_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_broadcast ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_broadcast_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_broadcast_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_broadcast_count),
    .signal_out   (stat_rx_broadcast_count_sync)
  );

  wire [48-1:0] stat_rx_packet_512_1023_bytes_count;
  wire [48-1:0] stat_rx_packet_512_1023_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_512_1023_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_512_1023_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_512_1023_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_packet_512_1023_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_packet_512_1023_bytes_count),
    .signal_out   (stat_rx_packet_512_1023_bytes_count_sync)
  );

  wire [48-1:0] stat_tx_vlan_count;
  wire [48-1:0] stat_tx_vlan_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_vlan_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_vlan ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_vlan_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_vlan_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_vlan_count),
    .signal_out   (stat_tx_vlan_count_sync)
  );

  wire [48-1:0] stat_rx_total_packets_count;
  wire [48-1:0] stat_rx_total_packets_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(2),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_total_packets_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_total_packets ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_total_packets_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_total_packets_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_total_packets_count),
    .signal_out   (stat_rx_total_packets_count_sync)
  );

  wire [48-1:0] stat_tx_packet_1523_1548_bytes_count;
  wire [48-1:0] stat_tx_packet_1523_1548_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_1523_1548_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_1523_1548_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_1523_1548_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_packet_1523_1548_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_packet_1523_1548_bytes_count),
    .signal_out   (stat_tx_packet_1523_1548_bytes_count_sync)
  );

  wire [48-1:0] stat_rx_framing_err_count;
  wire [48-1:0] stat_rx_framing_err_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_framing_err_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_framing_err & {1{stat_rx_framing_err_valid}}),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_framing_err_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_framing_err_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_framing_err_count),
    .signal_out   (stat_rx_framing_err_count_sync)
  );


  wire [48-1:0] stat_tx_packet_512_1023_bytes_count;
  wire [48-1:0] stat_tx_packet_512_1023_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_512_1023_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_512_1023_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_512_1023_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_packet_512_1023_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_packet_512_1023_bytes_count),
    .signal_out   (stat_tx_packet_512_1023_bytes_count_sync)
  );

  reg  STAT_RX_STATUS_REG1_clear_r;
  wire STAT_RX_STATUS_REG1_clear_ack;
  wire STAT_RX_STATUS_REG1_clear_cond;
  wire STAT_RX_STATUS_REG1_clear_sync;
  reg  STAT_RX_STATUS_REG1_clear_sync_d1;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_STAT_RX_STATUS_REG1_clear_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (STAT_RX_STATUS_REG1_clear_r),
    .dataout      (STAT_RX_STATUS_REG1_clear_sync )
  );



  wire reset_from_axi_into_rx_clk;
  wire reset_from_rx_clk_into_axi;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_reset syncer_reset_from_Bus2IP_clk_to_rx_clk (
    // Reset from axi domain
    .reset_async ( 1'b0 ),
    // Retiming into rx_clk domain
    .clk         ( rx_clk ),
    .reset       ( reset_from_axi_into_rx_clk )
  );
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_reset syncer_reset_from_rx_clk_to_Bus2IP_clk (
    // Reset from rx_clk domain
    .reset_async ( AXI_Reset_rx_clk_sync ),
    // Retiming into axi domain
    .clk         ( Bus2IP_Clk ),
    .reset       ( reset_from_rx_clk_into_axi )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_pulse_no_syncer_reset i_reg_STAT_RX_STATUS_REG1_clear_ack_syncer (
    .clkin                     ( rx_clk ),
    .clkin_reset               ( AXI_Reset_rx_clk_sync ),
    .clkout_reset_synced2clkin ( reset_from_axi_into_rx_clk ),
    .pulsein                   ( STAT_RX_STATUS_REG1_clear_sync_d1 ),
    .clkout                    ( Bus2IP_Clk ),
    .clkout_reset              ( 1'b0 ),
    .clkin_reset_synced2clkout ( reset_from_rx_clk_into_axi ),
    .pulseout                  ( STAT_RX_STATUS_REG1_clear_ack )
  );

  always @( posedge rx_clk )
    begin
      if ( AXI_Reset_rx_clk_sync == 1'b1 )
        begin
          STAT_RX_STATUS_REG1_clear_sync_d1 <= 1'b0;
        end
      else
        begin
          STAT_RX_STATUS_REG1_clear_sync_d1 <= STAT_RX_STATUS_REG1_clear_sync;
        end
    end
  assign STAT_RX_STATUS_REG1_clear_cond = (STAT_RX_STATUS_REG1_clear_sync_d1 == 0) && (STAT_RX_STATUS_REG1_clear_sync == 1);

  reg [1-1:0] stat_rx_remote_fault_lh_r;
  reg [1-1:0] stat_rx_remote_fault_lh_r_out;
  wire [1-1:0] stat_rx_remote_fault_lh_r_out_sync;
  always @( posedge rx_clk )
    begin
      if ( rx_reset_pulse == 1'b1 )
      begin
        stat_rx_remote_fault_lh_r     <= {1{1'b0}};
        stat_rx_remote_fault_lh_r_out <= {1{1'b0}};
      end
    else
      begin
        stat_rx_remote_fault_lh_r     <= STAT_RX_STATUS_REG1_clear_cond ? stat_rx_remote_fault : (stat_rx_remote_fault_lh_r | stat_rx_remote_fault ) ;
        stat_rx_remote_fault_lh_r_out <= STAT_RX_STATUS_REG1_clear_cond ? stat_rx_remote_fault_lh_r : stat_rx_remote_fault_lh_r_out;
      end
    end

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (1)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_remote_fault_lh_r_out_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_remote_fault_lh_r_out),
    .signal_out   (stat_rx_remote_fault_lh_r_out_sync)
  );

  reg [1-1:0] stat_rx_bad_sfd_lh_r;
  reg [1-1:0] stat_rx_bad_sfd_lh_r_out;
  wire [1-1:0] stat_rx_bad_sfd_lh_r_out_sync;
  always @( posedge rx_clk )
    begin
      if ( rx_reset_pulse == 1'b1 )
      begin
        stat_rx_bad_sfd_lh_r     <= {1{1'b0}};
        stat_rx_bad_sfd_lh_r_out <= {1{1'b0}};
      end
    else
      begin
        stat_rx_bad_sfd_lh_r     <= STAT_RX_STATUS_REG1_clear_cond ? stat_rx_bad_sfd : (stat_rx_bad_sfd_lh_r | stat_rx_bad_sfd ) ;
        stat_rx_bad_sfd_lh_r_out <= STAT_RX_STATUS_REG1_clear_cond ? stat_rx_bad_sfd_lh_r : stat_rx_bad_sfd_lh_r_out;
      end
    end

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (1)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_bad_sfd_lh_r_out_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_bad_sfd_lh_r_out),
    .signal_out   (stat_rx_bad_sfd_lh_r_out_sync)
  );

  reg [1-1:0] stat_rx_local_fault_lh_r;
  reg [1-1:0] stat_rx_local_fault_lh_r_out;
  wire [1-1:0] stat_rx_local_fault_lh_r_out_sync;
  always @( posedge rx_clk )
    begin
      if ( rx_reset_pulse == 1'b1 )
      begin
        stat_rx_local_fault_lh_r     <= {1{1'b0}};
        stat_rx_local_fault_lh_r_out <= {1{1'b0}};
      end
    else
      begin
        stat_rx_local_fault_lh_r     <= STAT_RX_STATUS_REG1_clear_cond ? stat_rx_local_fault : (stat_rx_local_fault_lh_r | stat_rx_local_fault ) ;
        stat_rx_local_fault_lh_r_out <= STAT_RX_STATUS_REG1_clear_cond ? stat_rx_local_fault_lh_r : stat_rx_local_fault_lh_r_out;
      end
    end

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (1)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_local_fault_lh_r_out_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_local_fault_lh_r_out),
    .signal_out   (stat_rx_local_fault_lh_r_out_sync)
  );

  reg [1-1:0] stat_rx_received_local_fault_lh_r;
  reg [1-1:0] stat_rx_received_local_fault_lh_r_out;
  wire [1-1:0] stat_rx_received_local_fault_lh_r_out_sync;
  always @( posedge rx_clk )
    begin
      if ( rx_reset_pulse == 1'b1 )
      begin
        stat_rx_received_local_fault_lh_r     <= {1{1'b0}};
        stat_rx_received_local_fault_lh_r_out <= {1{1'b0}};
      end
    else
      begin
        stat_rx_received_local_fault_lh_r     <= STAT_RX_STATUS_REG1_clear_cond ? stat_rx_received_local_fault : (stat_rx_received_local_fault_lh_r | stat_rx_received_local_fault ) ;
        stat_rx_received_local_fault_lh_r_out <= STAT_RX_STATUS_REG1_clear_cond ? stat_rx_received_local_fault_lh_r : stat_rx_received_local_fault_lh_r_out;
      end
    end

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (1)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_received_local_fault_lh_r_out_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_received_local_fault_lh_r_out),
    .signal_out   (stat_rx_received_local_fault_lh_r_out_sync)
  );

  reg [1-1:0] stat_rx_got_signal_os_lh_r;
  reg [1-1:0] stat_rx_got_signal_os_lh_r_out;
  wire [1-1:0] stat_rx_got_signal_os_lh_r_out_sync;
  always @( posedge rx_clk )
    begin
      if ( rx_reset_pulse == 1'b1 )
      begin
        stat_rx_got_signal_os_lh_r     <= {1{1'b0}};
        stat_rx_got_signal_os_lh_r_out <= {1{1'b0}};
      end
    else
      begin
        stat_rx_got_signal_os_lh_r     <= STAT_RX_STATUS_REG1_clear_cond ? stat_rx_got_signal_os : (stat_rx_got_signal_os_lh_r | stat_rx_got_signal_os ) ;
        stat_rx_got_signal_os_lh_r_out <= STAT_RX_STATUS_REG1_clear_cond ? stat_rx_got_signal_os_lh_r : stat_rx_got_signal_os_lh_r_out;
      end
    end

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (1)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_got_signal_os_lh_r_out_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_got_signal_os_lh_r_out),
    .signal_out   (stat_rx_got_signal_os_lh_r_out_sync)
  );

  reg [1-1:0] stat_rx_internal_local_fault_lh_r;
  reg [1-1:0] stat_rx_internal_local_fault_lh_r_out;
  wire [1-1:0] stat_rx_internal_local_fault_lh_r_out_sync;
  always @( posedge rx_clk )
    begin
      if ( rx_reset_pulse == 1'b1 )
      begin
        stat_rx_internal_local_fault_lh_r     <= {1{1'b0}};
        stat_rx_internal_local_fault_lh_r_out <= {1{1'b0}};
      end
    else
      begin
        stat_rx_internal_local_fault_lh_r     <= STAT_RX_STATUS_REG1_clear_cond ? stat_rx_internal_local_fault : (stat_rx_internal_local_fault_lh_r | stat_rx_internal_local_fault ) ;
        stat_rx_internal_local_fault_lh_r_out <= STAT_RX_STATUS_REG1_clear_cond ? stat_rx_internal_local_fault_lh_r : stat_rx_internal_local_fault_lh_r_out;
      end
    end

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (1)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_internal_local_fault_lh_r_out_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_internal_local_fault_lh_r_out),
    .signal_out   (stat_rx_internal_local_fault_lh_r_out_sync)
  );

  reg [1-1:0] stat_rx_bad_preamble_lh_r;
  reg [1-1:0] stat_rx_bad_preamble_lh_r_out;
  wire [1-1:0] stat_rx_bad_preamble_lh_r_out_sync;
  always @( posedge rx_clk )
    begin
      if ( rx_reset_pulse == 1'b1 )
      begin
        stat_rx_bad_preamble_lh_r     <= {1{1'b0}};
        stat_rx_bad_preamble_lh_r_out <= {1{1'b0}};
      end
    else
      begin
        stat_rx_bad_preamble_lh_r     <= STAT_RX_STATUS_REG1_clear_cond ? stat_rx_bad_preamble : (stat_rx_bad_preamble_lh_r | stat_rx_bad_preamble ) ;
        stat_rx_bad_preamble_lh_r_out <= STAT_RX_STATUS_REG1_clear_cond ? stat_rx_bad_preamble_lh_r : stat_rx_bad_preamble_lh_r_out;
      end
    end

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (1)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_bad_preamble_lh_r_out_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_bad_preamble_lh_r_out),
    .signal_out   (stat_rx_bad_preamble_lh_r_out_sync)
  );

  reg [1-1:0] stat_rx_hi_ber_lh_r;
  reg [1-1:0] stat_rx_hi_ber_lh_r_out;
  wire [1-1:0] stat_rx_hi_ber_lh_r_out_sync;
  always @( posedge rx_clk )
    begin
      if ( rx_reset_pulse == 1'b1 )
      begin
        stat_rx_hi_ber_lh_r     <= {1{1'b0}};
        stat_rx_hi_ber_lh_r_out <= {1{1'b0}};
      end
    else
      begin
        stat_rx_hi_ber_lh_r     <= STAT_RX_STATUS_REG1_clear_cond ? stat_rx_hi_ber : (stat_rx_hi_ber_lh_r | stat_rx_hi_ber ) ;
        stat_rx_hi_ber_lh_r_out <= STAT_RX_STATUS_REG1_clear_cond ? stat_rx_hi_ber_lh_r : stat_rx_hi_ber_lh_r_out;
      end
    end

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (1)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_hi_ber_lh_r_out_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_hi_ber_lh_r_out),
    .signal_out   (stat_rx_hi_ber_lh_r_out_sync)
  );

  wire [48-1:0] stat_rx_vlan_count;
  wire [48-1:0] stat_rx_vlan_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_vlan_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_vlan ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_vlan_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_vlan_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_vlan_count),
    .signal_out   (stat_rx_vlan_count_sync)
  );

  reg  STAT_TX_STATUS_REG1_clear_r;
  wire STAT_TX_STATUS_REG1_clear_ack;
  wire STAT_TX_STATUS_REG1_clear_cond;
  wire STAT_TX_STATUS_REG1_clear_sync;
  reg  STAT_TX_STATUS_REG1_clear_sync_d1;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_STAT_TX_STATUS_REG1_clear_syncer (
    .clk          (tx_clk),
    .reset        (AXI_Reset_tx_clk_sync),
    .datain       (STAT_TX_STATUS_REG1_clear_r),
    .dataout      (STAT_TX_STATUS_REG1_clear_sync )
  );



  wire reset_from_axi_into_tx_clk;
  wire reset_from_tx_clk_into_axi;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_reset syncer_reset_from_Bus2IP_clk_to_tx_clk (
    // Reset from axi domain
    .reset_async ( 1'b0 ),
    // Retiming into tx_clk domain
    .clk         ( tx_clk ),
    .reset       ( reset_from_axi_into_tx_clk )
  );
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_reset syncer_reset_from_tx_clk_to_Bus2IP_clk (
    // Reset from tx_clk domain
    .reset_async ( AXI_Reset_tx_clk_sync ),
    // Retiming into axi domain
    .clk         ( Bus2IP_Clk ),
    .reset       ( reset_from_tx_clk_into_axi )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_pulse_no_syncer_reset i_reg_STAT_TX_STATUS_REG1_clear_ack_syncer (
    .clkin                     ( tx_clk ),
    .clkin_reset               ( AXI_Reset_tx_clk_sync ),
    .clkout_reset_synced2clkin ( reset_from_axi_into_tx_clk ),
    .pulsein                   ( STAT_TX_STATUS_REG1_clear_sync_d1 ),
    .clkout                    ( Bus2IP_Clk ),
    .clkout_reset              ( 1'b0 ),
    .clkin_reset_synced2clkout ( reset_from_tx_clk_into_axi ),
    .pulseout                  ( STAT_TX_STATUS_REG1_clear_ack )
  );

  always @( posedge tx_clk )
    begin
      if ( AXI_Reset_tx_clk_sync == 1'b1 )
        begin
          STAT_TX_STATUS_REG1_clear_sync_d1 <= 1'b0;
        end
      else
        begin
          STAT_TX_STATUS_REG1_clear_sync_d1 <= STAT_TX_STATUS_REG1_clear_sync;
        end
    end
  assign STAT_TX_STATUS_REG1_clear_cond = (STAT_TX_STATUS_REG1_clear_sync_d1 == 0) && (STAT_TX_STATUS_REG1_clear_sync == 1);

  reg [1-1:0] stat_tx_local_fault_lh_r;
  reg [1-1:0] stat_tx_local_fault_lh_r_out;
  wire [1-1:0] stat_tx_local_fault_lh_r_out_sync;

  always @( posedge tx_clk )
    begin
      if ( tx_reset_pulse == 1'b1 )
      begin
        stat_tx_local_fault_lh_r     <= {1{1'b0}};
        stat_tx_local_fault_lh_r_out <= {1{1'b0}};
      end
    else
      begin
        stat_tx_local_fault_lh_r     <= STAT_TX_STATUS_REG1_clear_cond ? stat_tx_local_fault : (stat_tx_local_fault_lh_r | stat_tx_local_fault ) ;
        stat_tx_local_fault_lh_r_out <= STAT_TX_STATUS_REG1_clear_cond ? stat_tx_local_fault_lh_r : stat_tx_local_fault_lh_r_out;
      end
    end

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (1)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_local_fault_lh_r_out_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_local_fault_lh_r_out),
    .signal_out   (stat_tx_local_fault_lh_r_out_sync)
  );
  reg [1-1:0] stat_tx_bad_parity_lh_r;
  reg [1-1:0] stat_tx_bad_parity_lh_r_out;
  wire [1-1:0] stat_tx_bad_parity_lh_r_out_sync;


  always @( posedge tx_clk )
    begin
      if ( tx_reset_pulse == 1'b1 )
      begin
        stat_tx_bad_parity_lh_r     <= {1{1'b0}};
        stat_tx_bad_parity_lh_r_out <= {1{1'b0}};
      end
    else
      begin
        stat_tx_bad_parity_lh_r     <= STAT_TX_STATUS_REG1_clear_cond ? stat_tx_bad_parity : (stat_tx_bad_parity_lh_r | stat_tx_bad_parity ) ;
        stat_tx_bad_parity_lh_r_out <= STAT_TX_STATUS_REG1_clear_cond ? stat_tx_bad_parity_lh_r : stat_tx_bad_parity_lh_r_out;
      end
    end

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (1)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_bad_parity_lh_r_out_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_bad_parity_lh_r_out),
    .signal_out   (stat_tx_bad_parity_lh_r_out_sync)
  );


  wire [48-1:0] stat_tx_packet_8192_9215_bytes_count;
  wire [48-1:0] stat_tx_packet_8192_9215_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_8192_9215_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_8192_9215_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_8192_9215_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_packet_8192_9215_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_packet_8192_9215_bytes_count),
    .signal_out   (stat_tx_packet_8192_9215_bytes_count_sync)
  );

  wire [48-1:0] stat_tx_packet_1519_1522_bytes_count;
  wire [48-1:0] stat_tx_packet_1519_1522_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_1519_1522_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_1519_1522_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_1519_1522_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_packet_1519_1522_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_packet_1519_1522_bytes_count),
    .signal_out   (stat_tx_packet_1519_1522_bytes_count_sync)
  );


  wire [1-1:0] stat_core_speed_sync;
  wire [1-1:0] stat_core_speed_r = stat_core_speed_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_stat_core_speed_syncer (
    .clk          (Bus2IP_Clk),
    .reset        (AXI_Reset),
    .datain       (stat_core_speed),
    .dataout      (stat_core_speed_sync)
  );



  wire [48-1:0] stat_tx_packet_256_511_bytes_count;
  wire [48-1:0] stat_tx_packet_256_511_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_256_511_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_256_511_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_256_511_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_packet_256_511_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_packet_256_511_bytes_count),
    .signal_out   (stat_tx_packet_256_511_bytes_count_sync)
  );

  wire [48-1:0] stat_rx_multicast_count;
  wire [48-1:0] stat_rx_multicast_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_multicast_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_multicast ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_multicast_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_multicast_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_multicast_count),
    .signal_out   (stat_rx_multicast_count_sync)
  );


  reg  STAT_STATUS_REG1_clear_r;
  wire STAT_STATUS_REG1_clear_ack;
  wire STAT_STATUS_REG1_clear_cond;
  wire STAT_STATUS_REG1_clear_sync;
  reg  STAT_STATUS_REG1_clear_sync_d1;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_STAT_STATUS_REG1_clear_syncer (
    .clk          (tx_clk),
    .reset        (AXI_Reset_tx_clk_sync),
    .datain       (STAT_STATUS_REG1_clear_r),
    .dataout      (STAT_STATUS_REG1_clear_sync )
  );



  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_pulse_no_syncer_reset i_reg_STAT_STATUS_REG1_clear_ack_syncer (
    .clkin                     ( tx_clk ),
    .clkin_reset               ( AXI_Reset_tx_clk_sync ),
    .clkout_reset_synced2clkin ( reset_from_axi_into_tx_clk ),
    .pulsein                   ( STAT_STATUS_REG1_clear_sync_d1 ),
    .clkout                    ( Bus2IP_Clk ),
    .clkout_reset              ( 1'b0 ),
    .clkin_reset_synced2clkout ( reset_from_tx_clk_into_axi ),
    .pulseout                  ( STAT_STATUS_REG1_clear_ack )
  );

  always @( posedge tx_clk )
    begin
      if ( AXI_Reset_tx_clk_sync == 1'b1 )
        begin
          STAT_STATUS_REG1_clear_sync_d1 <= 1'b0;
        end
      else
        begin
          STAT_STATUS_REG1_clear_sync_d1 <= STAT_STATUS_REG1_clear_sync;
        end
    end
  assign STAT_STATUS_REG1_clear_cond = (STAT_STATUS_REG1_clear_sync_d1 == 0) && (STAT_STATUS_REG1_clear_sync == 1);

  wire [48-1:0] stat_rx_inrangeerr_count;
  wire [48-1:0] stat_rx_inrangeerr_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_inrangeerr_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_inrangeerr ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_inrangeerr_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_inrangeerr_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_inrangeerr_count),
    .signal_out   (stat_rx_inrangeerr_count_sync)
  );

  wire [48-1:0] stat_rx_packet_1519_1522_bytes_count;
  wire [48-1:0] stat_rx_packet_1519_1522_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_1519_1522_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_1519_1522_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_1519_1522_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_packet_1519_1522_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_packet_1519_1522_bytes_count),
    .signal_out   (stat_rx_packet_1519_1522_bytes_count_sync)
  );

  wire [48-1:0] stat_rx_packet_64_bytes_count;
  wire [48-1:0] stat_rx_packet_64_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_64_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_64_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_64_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_packet_64_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_packet_64_bytes_count),
    .signal_out   (stat_rx_packet_64_bytes_count_sync)
  );

  wire [48-1:0] stat_rx_packet_bad_fcs_count;
  wire [48-1:0] stat_rx_packet_bad_fcs_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_bad_fcs_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_bad_fcs ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_bad_fcs_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_packet_bad_fcs_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_packet_bad_fcs_count),
    .signal_out   (stat_rx_packet_bad_fcs_count_sync)
  );

  wire [48-1:0] stat_tx_packet_1024_1518_bytes_count;
  wire [48-1:0] stat_tx_packet_1024_1518_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_1024_1518_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_1024_1518_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_1024_1518_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_packet_1024_1518_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_packet_1024_1518_bytes_count),
    .signal_out   (stat_tx_packet_1024_1518_bytes_count_sync)
  );

  wire [48-1:0] stat_tx_total_good_bytes_count;
  wire [48-1:0] stat_tx_total_good_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(14),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_total_good_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_total_good_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_total_good_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_total_good_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_total_good_bytes_count),
    .signal_out   (stat_tx_total_good_bytes_count_sync)
  );

  wire [48-1:0] stat_tx_bad_fcs_count;
  wire [48-1:0] stat_tx_bad_fcs_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_bad_fcs_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_bad_fcs ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_bad_fcs_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_bad_fcs_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_bad_fcs_count),
    .signal_out   (stat_tx_bad_fcs_count_sync)
  );

  wire [48-1:0] stat_tx_total_good_packets_count;
  wire [48-1:0] stat_tx_total_good_packets_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_total_good_packets_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_total_good_packets ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_total_good_packets_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_total_good_packets_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_total_good_packets_count),
    .signal_out   (stat_tx_total_good_packets_count_sync)
  );

  wire [48-1:0] stat_rx_packet_128_255_bytes_count;
  wire [48-1:0] stat_rx_packet_128_255_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_128_255_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_128_255_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_128_255_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_packet_128_255_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_packet_128_255_bytes_count),
    .signal_out   (stat_rx_packet_128_255_bytes_count_sync)
  );

  wire [48-1:0] stat_rx_packet_8192_9215_bytes_count;
  wire [48-1:0] stat_rx_packet_8192_9215_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_8192_9215_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_8192_9215_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_8192_9215_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_packet_8192_9215_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_packet_8192_9215_bytes_count),
    .signal_out   (stat_rx_packet_8192_9215_bytes_count_sync)
  );

  wire [48-1:0] stat_rx_total_good_bytes_count;
  wire [48-1:0] stat_rx_total_good_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(14),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_total_good_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_total_good_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_total_good_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_total_good_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_total_good_bytes_count),
    .signal_out   (stat_rx_total_good_bytes_count_sync)
  );

  wire [48-1:0] stat_rx_toolong_count;
  wire [48-1:0] stat_rx_toolong_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_toolong_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_toolong ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_toolong_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_toolong_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_toolong_count),
    .signal_out   (stat_rx_toolong_count_sync)
  );

  wire [48-1:0] stat_rx_bad_fcs_count;
  wire [48-1:0] stat_rx_bad_fcs_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(2),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_bad_fcs_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_bad_fcs ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_bad_fcs_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_bad_fcs_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_bad_fcs_count),
    .signal_out   (stat_rx_bad_fcs_count_sync)
  );

  wire [48-1:0] stat_rx_bad_code_count;
  wire [48-1:0] stat_rx_bad_code_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_bad_code_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_bad_code ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_bad_code_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_bad_code_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_bad_code_count),
    .signal_out   (stat_rx_bad_code_count_sync)
  );

  wire [48-1:0] stat_tx_packet_64_bytes_count;
  wire [48-1:0] stat_tx_packet_64_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_64_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_64_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_64_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_packet_64_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_packet_64_bytes_count),
    .signal_out   (stat_tx_packet_64_bytes_count_sync)
  );

  wire [48-1:0] stat_rx_packet_small_count;
  wire [48-1:0] stat_rx_packet_small_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_small_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_small ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_small_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_packet_small_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_packet_small_count),
    .signal_out   (stat_rx_packet_small_count_sync)
  );

  wire [48-1:0] stat_rx_unicast_count;
  wire [48-1:0] stat_rx_unicast_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_unicast_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_unicast ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_unicast_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_unicast_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_unicast_count),
    .signal_out   (stat_rx_unicast_count_sync)
  );

  wire [48-1:0] stat_rx_packet_65_127_bytes_count;
  wire [48-1:0] stat_rx_packet_65_127_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_65_127_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_65_127_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_65_127_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_packet_65_127_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_packet_65_127_bytes_count),
    .signal_out   (stat_rx_packet_65_127_bytes_count_sync)
  );

  wire [48-1:0] stat_cycle_count;
  wire [48-1:0] stat_cycle_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_cycle_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_cycle ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_cycle_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_cycle_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_cycle_count),
    .signal_out   (stat_cycle_count_sync)
  );

  wire [48-1:0] stat_tx_packet_4096_8191_bytes_count;
  wire [48-1:0] stat_tx_packet_4096_8191_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_4096_8191_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_4096_8191_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_4096_8191_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_packet_4096_8191_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_packet_4096_8191_bytes_count),
    .signal_out   (stat_tx_packet_4096_8191_bytes_count_sync)
  );

  reg  STAT_RX_BLOCK_LOCK_REG_clear_r;
  wire STAT_RX_BLOCK_LOCK_REG_clear_ack;
  wire STAT_RX_BLOCK_LOCK_REG_clear_cond;
  wire STAT_RX_BLOCK_LOCK_REG_clear_sync;
  reg  STAT_RX_BLOCK_LOCK_REG_clear_sync_d1;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_STAT_RX_BLOCK_LOCK_REG_clear_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (STAT_RX_BLOCK_LOCK_REG_clear_r),
    .dataout      (STAT_RX_BLOCK_LOCK_REG_clear_sync )
  );



  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_pulse_no_syncer_reset i_reg_STAT_RX_BLOCK_LOCK_REG_clear_ack_syncer (
    .clkin                     ( rx_clk ),
    .clkin_reset               ( AXI_Reset_rx_clk_sync ),
    .clkout_reset_synced2clkin ( reset_from_axi_into_rx_clk ),
    .pulsein                   ( STAT_RX_BLOCK_LOCK_REG_clear_sync_d1 ),
    .clkout                    ( Bus2IP_Clk ),
    .clkout_reset              ( 1'b0 ),
    .clkin_reset_synced2clkout ( reset_from_rx_clk_into_axi ),
    .pulseout                  ( STAT_RX_BLOCK_LOCK_REG_clear_ack )
  );

  always @( posedge rx_clk )
    begin
      if ( AXI_Reset_rx_clk_sync == 1'b1 )
        begin
          STAT_RX_BLOCK_LOCK_REG_clear_sync_d1 <= 1'b0;
        end
      else
        begin
          STAT_RX_BLOCK_LOCK_REG_clear_sync_d1 <= STAT_RX_BLOCK_LOCK_REG_clear_sync;
        end
    end
  assign STAT_RX_BLOCK_LOCK_REG_clear_cond = (STAT_RX_BLOCK_LOCK_REG_clear_sync_d1 == 0) && (STAT_RX_BLOCK_LOCK_REG_clear_sync == 1);

  reg [1-1:0] stat_rx_block_lock_ll_r;
  reg [1-1:0] stat_rx_block_lock_ll_r_out;
  wire [1-1:0] stat_rx_block_lock_ll_r_out_sync;
  always @( posedge rx_clk )
    begin
      if ( rx_reset_pulse == 1'b1 )
      begin
        stat_rx_block_lock_ll_r     <= {1{1'b1}};
        stat_rx_block_lock_ll_r_out <= {1{1'b1}};
      end
    else
      begin
        stat_rx_block_lock_ll_r     <= STAT_RX_BLOCK_LOCK_REG_clear_cond ? stat_rx_block_lock : (stat_rx_block_lock_ll_r & stat_rx_block_lock ) ;
        stat_rx_block_lock_ll_r_out <= STAT_RX_BLOCK_LOCK_REG_clear_cond ? stat_rx_block_lock_ll_r : stat_rx_block_lock_ll_r_out;
      end
    end

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (1)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_block_lock_ll_r_out_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_block_lock_ll_r_out),
    .signal_out   (stat_rx_block_lock_ll_r_out_sync)
  );



  reg [1-1:0] stat_rx_status_ll_r;
  reg [1-1:0] stat_rx_status_ll_r_out;
  wire [1-1:0] stat_rx_status_ll_r_out_sync;
  always @( posedge rx_clk )
    begin
      if ( rx_reset_pulse == 1'b1 )
      begin
        stat_rx_status_ll_r     <= {1{1'b1}};
        stat_rx_status_ll_r_out <= {1{1'b1}};
      end
    else
      begin
        stat_rx_status_ll_r     <= STAT_RX_STATUS_REG1_clear_cond ? stat_rx_status : (stat_rx_status_ll_r & stat_rx_status ) ;
        stat_rx_status_ll_r_out <= STAT_RX_STATUS_REG1_clear_cond ? stat_rx_status_ll_r : stat_rx_status_ll_r_out;
     end
    end

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (1)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_status_ll_r_out_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_status_ll_r_out),
    .signal_out   (stat_rx_status_ll_r_out_sync)
  );


  wire [48-1:0] stat_tx_packet_1549_2047_bytes_count;
  wire [48-1:0] stat_tx_packet_1549_2047_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_1549_2047_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_1549_2047_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_1549_2047_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_packet_1549_2047_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_packet_1549_2047_bytes_count),
    .signal_out   (stat_tx_packet_1549_2047_bytes_count_sync)
  );

  reg  STAT_RX_VALID_CTRL_CODE_clear_r;
  wire STAT_RX_VALID_CTRL_CODE_clear_ack;
  wire STAT_RX_VALID_CTRL_CODE_clear_cond;
  wire STAT_RX_VALID_CTRL_CODE_clear_sync;
  reg  STAT_RX_VALID_CTRL_CODE_clear_sync_d1;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_STAT_RX_VALID_CTRL_CODE_clear_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (STAT_RX_VALID_CTRL_CODE_clear_r),
    .dataout      (STAT_RX_VALID_CTRL_CODE_clear_sync )
  );



  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_pulse_no_syncer_reset i_reg_STAT_RX_VALID_CTRL_CODE_clear_ack_syncer (
    .clkin                     ( rx_clk ),
    .clkin_reset               ( AXI_Reset_rx_clk_sync ),
    .clkout_reset_synced2clkin ( reset_from_axi_into_rx_clk ),
    .pulsein                   ( STAT_RX_VALID_CTRL_CODE_clear_sync_d1 ),
    .clkout                    ( Bus2IP_Clk ),
    .clkout_reset              ( 1'b0 ),
    .clkin_reset_synced2clkout ( reset_from_rx_clk_into_axi ),
    .pulseout                  ( STAT_RX_VALID_CTRL_CODE_clear_ack )
  );

  always @( posedge rx_clk )
    begin
      if ( AXI_Reset_rx_clk_sync == 1'b1 )
        begin
          STAT_RX_VALID_CTRL_CODE_clear_sync_d1 <= 1'b0;
        end
      else
        begin
          STAT_RX_VALID_CTRL_CODE_clear_sync_d1 <= STAT_RX_VALID_CTRL_CODE_clear_sync;
        end
    end
  assign STAT_RX_VALID_CTRL_CODE_clear_cond = (STAT_RX_VALID_CTRL_CODE_clear_sync_d1 == 0) && (STAT_RX_VALID_CTRL_CODE_clear_sync == 1);

  reg [1-1:0] stat_rx_valid_ctrl_code_lh_r;
  reg [1-1:0] stat_rx_valid_ctrl_code_lh_r_out;
  wire [1-1:0] stat_rx_valid_ctrl_code_lh_r_out_sync;
  always @( posedge rx_clk )
    begin
      if ( rx_reset_pulse == 1'b1 )
      begin
        stat_rx_valid_ctrl_code_lh_r     <= {1{1'b0}};
        stat_rx_valid_ctrl_code_lh_r_out <= {1{1'b0}};
      end
    else
      begin
        stat_rx_valid_ctrl_code_lh_r     <= STAT_RX_VALID_CTRL_CODE_clear_cond ? stat_rx_valid_ctrl_code : (stat_rx_valid_ctrl_code_lh_r | stat_rx_valid_ctrl_code ) ;
        stat_rx_valid_ctrl_code_lh_r_out <= STAT_RX_VALID_CTRL_CODE_clear_cond ? stat_rx_valid_ctrl_code_lh_r : stat_rx_valid_ctrl_code_lh_r_out;
      end
    end

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (1)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_valid_ctrl_code_lh_r_out_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_valid_ctrl_code_lh_r_out),
    .signal_out   (stat_rx_valid_ctrl_code_lh_r_out_sync)
  );


  wire [48-1:0] stat_tx_multicast_count;
  wire [48-1:0] stat_tx_multicast_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_multicast_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_multicast ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_multicast_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_multicast_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_multicast_count),
    .signal_out   (stat_tx_multicast_count_sync)
  );

  wire [48-1:0] stat_tx_packet_large_count;
  wire [48-1:0] stat_tx_packet_large_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_large_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_large ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_large_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_packet_large_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_packet_large_count),
    .signal_out   (stat_tx_packet_large_count_sync)
  );

  wire [48-1:0] stat_tx_packet_65_127_bytes_count;
  wire [48-1:0] stat_tx_packet_65_127_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_65_127_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_65_127_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_65_127_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_packet_65_127_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_packet_65_127_bytes_count),
    .signal_out   (stat_tx_packet_65_127_bytes_count_sync)
  );

  wire [48-1:0] stat_rx_test_pattern_mismatch_count;
  wire [48-1:0] stat_rx_test_pattern_mismatch_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_test_pattern_mismatch_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_test_pattern_mismatch ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_test_pattern_mismatch_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_test_pattern_mismatch_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_test_pattern_mismatch_count),
    .signal_out   (stat_rx_test_pattern_mismatch_count_sync)
  );

  wire [48-1:0] stat_tx_total_bytes_count;
  wire [48-1:0] stat_tx_total_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(4),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_total_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_total_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_total_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_total_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_total_bytes_count),
    .signal_out   (stat_tx_total_bytes_count_sync)
  );

  wire [48-1:0] stat_rx_packet_large_count;
  wire [48-1:0] stat_rx_packet_large_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_large_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_large ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_large_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_packet_large_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_packet_large_count),
    .signal_out   (stat_rx_packet_large_count_sync)
  );

  wire [48-1:0] stat_rx_oversize_count;
  wire [48-1:0] stat_rx_oversize_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_oversize_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_oversize ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_oversize_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_oversize_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_oversize_count),
    .signal_out   (stat_rx_oversize_count_sync)
  );

  wire [48-1:0] stat_tx_total_packets_count;
  wire [48-1:0] stat_tx_total_packets_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_total_packets_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_total_packets ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_total_packets_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_total_packets_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_total_packets_count),
    .signal_out   (stat_tx_total_packets_count_sync)
  );

  wire [48-1:0] stat_tx_packet_small_count;
  wire [48-1:0] stat_tx_packet_small_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_small_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_small ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_small_count )
   );


  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_packet_small_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_packet_small_count),
    .signal_out   (stat_tx_packet_small_count_sync)
  );

  wire [48-1:0] stat_tx_packet_2048_4095_bytes_count;
  wire [48-1:0] stat_tx_packet_2048_4095_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_2048_4095_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_2048_4095_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_2048_4095_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_packet_2048_4095_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_packet_2048_4095_bytes_count),
    .signal_out   (stat_tx_packet_2048_4095_bytes_count_sync)
  );

  wire [48-1:0] stat_rx_packet_1024_1518_bytes_count;
  wire [48-1:0] stat_rx_packet_1024_1518_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_1024_1518_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_1024_1518_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_1024_1518_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_packet_1024_1518_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_packet_1024_1518_bytes_count),
    .signal_out   (stat_rx_packet_1024_1518_bytes_count_sync)
  );

  wire [48-1:0] stat_tx_broadcast_count;
  wire [48-1:0] stat_tx_broadcast_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_broadcast_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_broadcast ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_broadcast_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_broadcast_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_broadcast_count),
    .signal_out   (stat_tx_broadcast_count_sync)
  );

  wire [48-1:0] stat_rx_packet_256_511_bytes_count;
  wire [48-1:0] stat_rx_packet_256_511_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_256_511_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_256_511_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_256_511_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_packet_256_511_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_packet_256_511_bytes_count),
    .signal_out   (stat_rx_packet_256_511_bytes_count_sync)
  );

  wire [48-1:0] stat_rx_packet_2048_4095_bytes_count;
  wire [48-1:0] stat_rx_packet_2048_4095_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_2048_4095_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_2048_4095_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_2048_4095_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_packet_2048_4095_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_packet_2048_4095_bytes_count),
    .signal_out   (stat_rx_packet_2048_4095_bytes_count_sync)
  );


  wire [48-1:0] stat_tx_unicast_count;
  wire [48-1:0] stat_tx_unicast_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_unicast_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_unicast ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_unicast_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_unicast_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_unicast_count),
    .signal_out   (stat_tx_unicast_count_sync)
  );

  wire [48-1:0] stat_rx_packet_4096_8191_bytes_count;
  wire [48-1:0] stat_rx_packet_4096_8191_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_4096_8191_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_4096_8191_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_4096_8191_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_packet_4096_8191_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_packet_4096_8191_bytes_count),
    .signal_out   (stat_rx_packet_4096_8191_bytes_count_sync)
  );


  wire [48-1:0] stat_rx_fragment_count;
  wire [48-1:0] stat_rx_fragment_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_fragment_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_fragment ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_fragment_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_fragment_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_fragment_count),
    .signal_out   (stat_rx_fragment_count_sync)
  );

  wire [48-1:0] stat_tx_packet_128_255_bytes_count;
  wire [48-1:0] stat_tx_packet_128_255_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_packet_128_255_bytes_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_packet_128_255_bytes ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_packet_128_255_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_packet_128_255_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_packet_128_255_bytes_count),
    .signal_out   (stat_tx_packet_128_255_bytes_count_sync)
  );

  wire [48-1:0] stat_tx_frame_error_count;
  wire [48-1:0] stat_tx_frame_error_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_tx_frame_error_accumulator (
      .clk         ( tx_clk ),
      .resetn      ( tx_reset_pulse ),
      .pm_tick     ( tx_clk_tick_retimed ),
      .pulsein     ( stat_tx_frame_error ),
      .hold_output ( tx_clk_statsreg_hold ),
      .statsout    ( stat_tx_frame_error_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_tx_frame_error_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_tx_frame_error_count),
    .signal_out   (stat_tx_frame_error_count_sync)
  );

  wire [48-1:0] stat_rx_packet_1523_1548_bytes_count;
  wire [48-1:0] stat_rx_packet_1523_1548_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_packet_1523_1548_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_packet_1523_1548_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_packet_1523_1548_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_packet_1523_1548_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_packet_1523_1548_bytes_count),
    .signal_out   (stat_rx_packet_1523_1548_bytes_count_sync)
  );

  wire [48-1:0] stat_rx_undersize_count;
  wire [48-1:0] stat_rx_undersize_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(1),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_undersize_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_undersize ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_undersize_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_undersize_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_undersize_count),
    .signal_out   (stat_rx_undersize_count_sync)
  );


  wire [48-1:0] stat_rx_total_bytes_count;
  wire [48-1:0] stat_rx_total_bytes_count_sync;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pmtick_statsreg
   #(
      .INWIDTH(4),
      .OUTWIDTH(48)
   ) i_stats_stat_rx_total_bytes_accumulator (
      .clk         ( rx_clk ),
      .resetn      ( rx_reset_pulse ),
      .pm_tick     ( rx_clk_tick_retimed ),
      .pulsein     ( stat_rx_total_bytes ),
      .hold_output ( rx_clk_statsreg_hold ),
      .statsout    ( stat_rx_total_bytes_count )
   );

  pl_eth_10g_xxv_ethernet_0_0_axi_cdc_sync_2stage 
  #(
    .WIDTH        (48)
  ) i_pl_eth_10g_xxv_ethernet_0_0_stat_rx_total_bytes_count_syncer (
    .clk          (Bus2IP_Clk ),
    .signal_in    (stat_rx_total_bytes_count),
    .signal_out   (stat_rx_total_bytes_count_sync)
  );


  wire tick_rx_clk_not_ready_r = 1'b0;
  wire tick_tx_clk_not_ready_r = 1'b0;
  // read side.
  always @( posedge Bus2IP_Clk )
    begin
      if ( AXI_Reset == 1'b1 )
      begin
        IP2Bus_RdAck   <= 1'b0;
        IP2Bus_RdError <= 1'b0;
        IP2Bus_Data    <= 'b0;
        statsreg_read_req <= 1'b0;
        STAT_RX_STATUS_REG1_clear_r  <= 1'b0;
        STAT_TX_STATUS_REG1_clear_r  <= 1'b0;
        STAT_STATUS_REG1_clear_r  <= 1'b0;
        STAT_RX_BLOCK_LOCK_REG_clear_r  <= 1'b0;
        STAT_RX_VALID_CTRL_CODE_clear_r  <= 1'b0;

      end
    else
      begin

         // clear on read signals.
        STAT_RX_STATUS_REG1_clear_r <= 1'b0;
        STAT_TX_STATUS_REG1_clear_r <= 1'b0;
        STAT_STATUS_REG1_clear_r <= 1'b0;
        STAT_RX_BLOCK_LOCK_REG_clear_r <= 1'b0;
        STAT_RX_VALID_CTRL_CODE_clear_r <= 1'b0;

         //- Read transaction
         IP2Bus_Data    <= 'b0;
         IP2Bus_RdAck   <= 1'b1;
         IP2Bus_RdError <= 1'b0;

         statsreg_read_req <= 1'b0;

         if (Bus2IP_CS_reg & Bus2IP_RNW_reg)
          begin
            IP2Bus_RdError <= 1'b1; // Assume it is a bad read unless it hits an address with at least one readable bit
            case ({Bus2IP_Addr_reg[ADDR_WIDTH-1:2],2'b0})


               'h0000 : begin  // GT_RESET_REG
                          IP2Bus_Data[0] <= ctl_gt_reset_all_r;
                          IP2Bus_Data[1] <= ctl_gt_rx_reset_r;
                          IP2Bus_Data[2] <= ctl_gt_tx_reset_r;
                          IP2Bus_RdError <= 1'b0;
                        end

               'h0004 : begin  // RESET_REG
                          IP2Bus_Data[0] <= rx_serdes_reset_r;
                          IP2Bus_Data[29] <= tx_serdes_reset_r;
                          IP2Bus_Data[30] <= rx_reset_r;
                          IP2Bus_Data[31] <= tx_reset_r;
                          IP2Bus_RdError <= 1'b0;
                        end

               'h0008 : begin  // MODE_REG
                          IP2Bus_Data[30] <= tick_reg_mode_sel_r;
                          IP2Bus_Data[31] <= ctl_local_loopback_r;
                          IP2Bus_RdError <= 1'b0;
                        end

               'h000C : begin  // CONFIGURATION_TX_REG1
                          IP2Bus_Data[0] <= ctl_tx_enable_r;
                          IP2Bus_Data[1] <= ctl_tx_fcs_ins_enable_r;
                          IP2Bus_Data[2] <= ctl_tx_ignore_fcs_r;
                          IP2Bus_Data[3] <= ctl_tx_send_lfi_r;
                          IP2Bus_Data[4] <= ctl_tx_send_rfi_r;
                          IP2Bus_Data[5] <= ctl_tx_send_idle_r;
                          IP2Bus_Data[14-1:10] <= ctl_tx_ipg_value_r;
                          IP2Bus_Data[14] <= ctl_tx_test_pattern_r;
                          IP2Bus_Data[15] <= ctl_tx_test_pattern_enable_r;
                          IP2Bus_Data[16] <= ctl_tx_test_pattern_select_r;
                          IP2Bus_Data[17] <= ctl_tx_data_pattern_select_r;
                          IP2Bus_Data[18] <= ctl_tx_custom_preamble_enable_r;
                          IP2Bus_RdError <= 1'b0;
                        end

               'h0014 : begin  // CONFIGURATION_RX_REG1
                          IP2Bus_Data[0] <= ctl_rx_enable_r;
                          IP2Bus_Data[1] <= ctl_rx_delete_fcs_r;
                          IP2Bus_Data[2] <= ctl_rx_ignore_fcs_r;
                          IP2Bus_Data[3] <= ctl_rx_process_lfi_r;
                          IP2Bus_Data[4] <= ctl_rx_check_sfd_r;
                          IP2Bus_Data[5] <= ctl_rx_check_preamble_r;
                          IP2Bus_Data[6] <= ctl_rx_force_resync_r;
                          IP2Bus_Data[7] <= ctl_rx_test_pattern_r;
                          IP2Bus_Data[8] <= ctl_rx_test_pattern_enable_r;
                          IP2Bus_Data[9] <= ctl_rx_data_pattern_select_r;
                          IP2Bus_Data[11] <= ctl_rx_custom_preamble_enable_r;
                          IP2Bus_RdError <= 1'b0;
                        end

               'h0018 : begin  // CONFIGURATION_RX_MTU
                          IP2Bus_Data[8-1:0] <= ctl_rx_min_packet_len_r;
                          IP2Bus_Data[31-1:16] <= ctl_rx_max_packet_len_r;
                          IP2Bus_RdError <= 1'b0;
                        end

               'h0024 : begin  // CONFIGURATION_REVISION_REG
                          IP2Bus_Data[8-1:0] <= major_rev;
                          IP2Bus_Data[16-1:8] <= minor_rev;
                          IP2Bus_Data[32-1:24] <= patch_rev;
                          IP2Bus_RdError <= 1'b0;
                        end

               'h0028 : begin  // CONFIGURATION_TX_TEST_PAT_SEED_A_LSB
                          IP2Bus_Data[32-1:0] <= ctl_tx_test_pattern_seed_a_r[31:0];
                          IP2Bus_RdError <= 1'b0;
                        end

               'h002C : begin  // CONFIGURATION_TX_TEST_PAT_SEED_A_MSB
                          IP2Bus_Data[26-1:0] <= ctl_tx_test_pattern_seed_a_r[57:32];
                          IP2Bus_RdError <= 1'b0;
                        end

               'h0030 : begin  // CONFIGURATION_TX_TEST_PAT_SEED_B_LSB
                          IP2Bus_Data[32-1:0] <= ctl_tx_test_pattern_seed_b_r[31:0];
                          IP2Bus_RdError <= 1'b0;
                        end

               'h0034 : begin  // CONFIGURATION_TX_TEST_PAT_SEED_B_MSB
                          IP2Bus_Data[26-1:0] <= ctl_tx_test_pattern_seed_b_r[57:32];
                          IP2Bus_RdError <= 1'b0;
                        end


               'h0134 : begin  // USER_REG_0
                          IP2Bus_Data[32-1:0] <= user_reg0_r;
                          IP2Bus_RdError <= 1'b0;
                        end

               'h0138 : begin  // SWITCH_CORE_SPEED_REG
                          IP2Bus_Data[0] <= axi_ctl_core_mode_switch_r;
                          IP2Bus_RdError <= 1'b0;
                        end

               'h0400 : begin  // STAT_TX_STATUS_REG1
                          STAT_TX_STATUS_REG1_clear_r <= 1'b1;
                          IP2Bus_RdAck   <= STAT_TX_STATUS_REG1_clear_ack | timeout_error;
                          IP2Bus_RdError <= timeout_error;
                          IP2Bus_Data[0] <= stat_tx_local_fault_lh_r_out_sync;
                          IP2Bus_Data[7] <= stat_tx_bad_parity_lh_r_out_sync;
                        end

               'h0404 : begin  // STAT_RX_STATUS_REG1
                          STAT_RX_STATUS_REG1_clear_r <= 1'b1;
                          IP2Bus_RdAck   <= STAT_RX_STATUS_REG1_clear_ack | timeout_error;
                          IP2Bus_RdError <= timeout_error;
                          IP2Bus_Data[0] <= stat_rx_status_ll_r_out_sync;
                          IP2Bus_Data[4] <= stat_rx_hi_ber_lh_r_out_sync;
                          IP2Bus_Data[5] <= stat_rx_remote_fault_lh_r_out_sync;
                          IP2Bus_Data[6] <= stat_rx_local_fault_lh_r_out_sync;
                          IP2Bus_Data[7] <= stat_rx_internal_local_fault_lh_r_out_sync;
                          IP2Bus_Data[8] <= stat_rx_received_local_fault_lh_r_out_sync;
                          IP2Bus_Data[9] <= stat_rx_bad_preamble_lh_r_out_sync;
                          IP2Bus_Data[10] <= stat_rx_bad_sfd_lh_r_out_sync;
                          IP2Bus_Data[11] <= stat_rx_got_signal_os_lh_r_out_sync;
                          IP2Bus_RdError <= timeout_error;
                        end

               'h0408 : begin  // STAT_STATUS_REG1
                          STAT_STATUS_REG1_clear_r <= 1'b1;
                          IP2Bus_RdAck   <= STAT_STATUS_REG1_clear_ack | timeout_error;
                          IP2Bus_RdError <= timeout_error;
                        end

               'h040C : begin  // STAT_RX_BLOCK_LOCK_REG
                          STAT_RX_BLOCK_LOCK_REG_clear_r <= 1'b1;
                          IP2Bus_RdAck   <= STAT_RX_BLOCK_LOCK_REG_clear_ack | timeout_error;
                          IP2Bus_RdError <= timeout_error;
                          IP2Bus_Data[0] <= stat_rx_block_lock_ll_r_out_sync;
                        end


               'h0494 : begin  // STAT_RX_VALID_CTRL_CODE
                          STAT_RX_VALID_CTRL_CODE_clear_r <= 1'b1;
                          IP2Bus_RdAck   <= STAT_RX_VALID_CTRL_CODE_clear_ack | timeout_error;
                          IP2Bus_RdError <= timeout_error;
                          IP2Bus_Data[0] <= stat_rx_valid_ctrl_code_lh_r_out_sync;
                        end

               'h0498 : begin  // STAT_CORE_SPEED_REG
                          IP2Bus_Data[0] <= stat_core_speed_r;
                          IP2Bus_Data[1] <= 1'b0;
                        end

               'h0500 : begin  // STATUS_CYCLE_COUNT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_cycle_count_sync[31:0];
                        end

               'h0504 : begin  // STATUS_CYCLE_COUNT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_cycle_count_sync[47:32];
                        end

               'h0648 : begin  // STAT_RX_FRAMING_ERR_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_framing_err_count_sync[31:0];
                        end

               'h064C : begin  // STAT_RX_FRAMING_ERR_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_framing_err_count_sync[47:32];
                        end

               'h0660 : begin  // STAT_RX_BAD_CODE_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_bad_code_count_sync[31:0];
                        end

               'h0664 : begin  // STAT_RX_BAD_CODE_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_bad_code_count_sync[47:32];
                        end

               'h06A0 : begin  // STAT_TX_FRAME_ERROR_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_frame_error_count_sync[31:0];
                        end

               'h06A4 : begin  // STAT_TX_FRAME_ERROR_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_frame_error_count_sync[47:32];
                        end

               'h0700 : begin  // STAT_TX_TOTAL_PACKETS_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_total_packets_count_sync[31:0];
                        end

               'h0704 : begin  // STAT_TX_TOTAL_PACKETS_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_total_packets_count_sync[47:32];
                        end

               'h0708 : begin  // STAT_TX_TOTAL_GOOD_PACKETS_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_total_good_packets_count_sync[31:0];
                        end

               'h070C : begin  // STAT_TX_TOTAL_GOOD_PACKETS_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_total_good_packets_count_sync[47:32];
                        end

               'h0710 : begin  // STAT_TX_TOTAL_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_total_bytes_count_sync[31:0];
                        end

               'h0714 : begin  // STAT_TX_TOTAL_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_total_bytes_count_sync[47:32];
                        end

               'h0718 : begin  // STAT_TX_TOTAL_GOOD_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_total_good_bytes_count_sync[31:0];
                        end

               'h071C : begin  // STAT_TX_TOTAL_GOOD_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_total_good_bytes_count_sync[47:32];
                        end

               'h0720 : begin  // STAT_TX_PACKET_64_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_packet_64_bytes_count_sync[31:0];
                        end

               'h0724 : begin  // STAT_TX_PACKET_64_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_packet_64_bytes_count_sync[47:32];
                        end

               'h0728 : begin  // STAT_TX_PACKET_65_127_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_packet_65_127_bytes_count_sync[31:0];
                        end

               'h072C : begin  // STAT_TX_PACKET_65_127_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_packet_65_127_bytes_count_sync[47:32];
                        end

               'h0730 : begin  // STAT_TX_PACKET_128_255_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_packet_128_255_bytes_count_sync[31:0];
                        end

               'h0734 : begin  // STAT_TX_PACKET_128_255_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_packet_128_255_bytes_count_sync[47:32];
                        end

               'h0738 : begin  // STAT_TX_PACKET_256_511_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_packet_256_511_bytes_count_sync[31:0];
                        end

               'h073C : begin  // STAT_TX_PACKET_256_511_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_packet_256_511_bytes_count_sync[47:32];
                        end

               'h0740 : begin  // STAT_TX_PACKET_512_1023_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_packet_512_1023_bytes_count_sync[31:0];
                        end

               'h0744 : begin  // STAT_TX_PACKET_512_1023_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_packet_512_1023_bytes_count_sync[47:32];
                        end

               'h0748 : begin  // STAT_TX_PACKET_1024_1518_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_packet_1024_1518_bytes_count_sync[31:0];
                        end

               'h074C : begin  // STAT_TX_PACKET_1024_1518_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_packet_1024_1518_bytes_count_sync[47:32];
                        end

               'h0750 : begin  // STAT_TX_PACKET_1519_1522_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_packet_1519_1522_bytes_count_sync[31:0];
                        end

               'h0754 : begin  // STAT_TX_PACKET_1519_1522_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_packet_1519_1522_bytes_count_sync[47:32];
                        end

               'h0758 : begin  // STAT_TX_PACKET_1523_1548_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_packet_1523_1548_bytes_count_sync[31:0];
                        end

               'h075C : begin  // STAT_TX_PACKET_1523_1548_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_packet_1523_1548_bytes_count_sync[47:32];
                        end

               'h0760 : begin  // STAT_TX_PACKET_1549_2047_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_packet_1549_2047_bytes_count_sync[31:0];
                        end

               'h0764 : begin  // STAT_TX_PACKET_1549_2047_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_packet_1549_2047_bytes_count_sync[47:32];
                        end

               'h0768 : begin  // STAT_TX_PACKET_2048_4095_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_packet_2048_4095_bytes_count_sync[31:0];
                        end

               'h076C : begin  // STAT_TX_PACKET_2048_4095_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_packet_2048_4095_bytes_count_sync[47:32];
                        end

               'h0770 : begin  // STAT_TX_PACKET_4096_8191_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_packet_4096_8191_bytes_count_sync[31:0];
                        end

               'h0774 : begin  // STAT_TX_PACKET_4096_8191_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_packet_4096_8191_bytes_count_sync[47:32];
                        end

               'h0778 : begin  // STAT_TX_PACKET_8192_9215_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_packet_8192_9215_bytes_count_sync[31:0];
                        end

               'h077C : begin  // STAT_TX_PACKET_8192_9215_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_packet_8192_9215_bytes_count_sync[47:32];
                        end

               'h0780 : begin  // STAT_TX_PACKET_LARGE_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_packet_large_count_sync[31:0];
                        end

               'h0784 : begin  // STAT_TX_PACKET_LARGE_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_packet_large_count_sync[47:32];
                        end

               'h0788 : begin  // STAT_TX_PACKET_SMALL_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_packet_small_count_sync[31:0];
                        end

               'h078C : begin  // STAT_TX_PACKET_SMALL_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_packet_small_count_sync[47:32];
                        end

               'h07B8 : begin  // STAT_TX_BAD_FCS_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_bad_fcs_count_sync[31:0];
                        end

               'h07BC : begin  // STAT_TX_BAD_FCS_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_bad_fcs_count_sync[47:32];
                        end
               'h07D0 : begin  // STAT_TX_UNICAST_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_unicast_count_sync[31:0];
                        end

               'h07D4 : begin  // STAT_TX_UNICAST_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_unicast_count_sync[47:32];
                        end

               'h07D8 : begin  // STAT_TX_MULTICAST_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_multicast_count_sync[31:0];
                        end

               'h07DC : begin  // STAT_TX_MULTICAST_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_multicast_count_sync[47:32];
                        end

               'h07E0 : begin  // STAT_TX_BROADCAST_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_broadcast_count_sync[31:0];
                        end

               'h07E4 : begin  // STAT_TX_BROADCAST_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_broadcast_count_sync[47:32];
                        end

               'h07E8 : begin  // STAT_TX_VLAN_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_tx_vlan_count_sync[31:0];
                        end

               'h07EC : begin  // STAT_TX_VLAN_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_tx_vlan_count_sync[47:32];
                        end


               'h0808 : begin  // STAT_RX_TOTAL_PACKETS_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_total_packets_count_sync[31:0];
                        end

               'h080C : begin  // STAT_RX_TOTAL_PACKETS_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_total_packets_count_sync[47:32];
                        end

               'h0810 : begin  // STAT_RX_TOTAL_GOOD_PACKETS_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_total_good_packets_count_sync[31:0];
                        end

               'h0814 : begin  // STAT_RX_TOTAL_GOOD_PACKETS_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_total_good_packets_count_sync[47:32];
                        end

               'h0818 : begin  // STAT_RX_TOTAL_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_total_bytes_count_sync[31:0];
                        end

               'h081C : begin  // STAT_RX_TOTAL_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_total_bytes_count_sync[47:32];
                        end

               'h0820 : begin  // STAT_RX_TOTAL_GOOD_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_total_good_bytes_count_sync[31:0];
                        end

               'h0824 : begin  // STAT_RX_TOTAL_GOOD_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_total_good_bytes_count_sync[47:32];
                        end

               'h0828 : begin  // STAT_RX_PACKET_64_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_packet_64_bytes_count_sync[31:0];
                        end

               'h082C : begin  // STAT_RX_PACKET_64_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_packet_64_bytes_count_sync[47:32];
                        end

               'h0830 : begin  // STAT_RX_PACKET_65_127_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_packet_65_127_bytes_count_sync[31:0];
                        end

               'h0834 : begin  // STAT_RX_PACKET_65_127_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_packet_65_127_bytes_count_sync[47:32];
                        end

               'h0838 : begin  // STAT_RX_PACKET_128_255_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_packet_128_255_bytes_count_sync[31:0];
                        end

               'h083C : begin  // STAT_RX_PACKET_128_255_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_packet_128_255_bytes_count_sync[47:32];
                        end

               'h0840 : begin  // STAT_RX_PACKET_256_511_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_packet_256_511_bytes_count_sync[31:0];
                        end

               'h0844 : begin  // STAT_RX_PACKET_256_511_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_packet_256_511_bytes_count_sync[47:32];
                        end

               'h0848 : begin  // STAT_RX_PACKET_512_1023_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_packet_512_1023_bytes_count_sync[31:0];
                        end

               'h084C : begin  // STAT_RX_PACKET_512_1023_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_packet_512_1023_bytes_count_sync[47:32];
                        end

               'h0850 : begin  // STAT_RX_PACKET_1024_1518_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_packet_1024_1518_bytes_count_sync[31:0];
                        end

               'h0854 : begin  // STAT_RX_PACKET_1024_1518_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_packet_1024_1518_bytes_count_sync[47:32];
                        end

               'h0858 : begin  // STAT_RX_PACKET_1519_1522_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_packet_1519_1522_bytes_count_sync[31:0];
                        end

               'h085C : begin  // STAT_RX_PACKET_1519_1522_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_packet_1519_1522_bytes_count_sync[47:32];
                        end

               'h0860 : begin  // STAT_RX_PACKET_1523_1548_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_packet_1523_1548_bytes_count_sync[31:0];
                        end

               'h0864 : begin  // STAT_RX_PACKET_1523_1548_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_packet_1523_1548_bytes_count_sync[47:32];
                        end

               'h0868 : begin  // STAT_RX_PACKET_1549_2047_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_packet_1549_2047_bytes_count_sync[31:0];
                        end

               'h086C : begin  // STAT_RX_PACKET_1549_2047_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_packet_1549_2047_bytes_count_sync[47:32];
                        end

               'h0870 : begin  // STAT_RX_PACKET_2048_4095_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_packet_2048_4095_bytes_count_sync[31:0];
                        end

               'h0874 : begin  // STAT_RX_PACKET_2048_4095_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_packet_2048_4095_bytes_count_sync[47:32];
                        end

               'h0878 : begin  // STAT_RX_PACKET_4096_8191_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_packet_4096_8191_bytes_count_sync[31:0];
                        end

               'h087C : begin  // STAT_RX_PACKET_4096_8191_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_packet_4096_8191_bytes_count_sync[47:32];
                        end

               'h0880 : begin  // STAT_RX_PACKET_8192_9215_BYTES_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_packet_8192_9215_bytes_count_sync[31:0];
                        end

               'h0884 : begin  // STAT_RX_PACKET_8192_9215_BYTES_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_packet_8192_9215_bytes_count_sync[47:32];
                        end

               'h0888 : begin  // STAT_RX_PACKET_LARGE_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_packet_large_count_sync[31:0];
                        end

               'h088C : begin  // STAT_RX_PACKET_LARGE_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_packet_large_count_sync[47:32];
                        end

               'h0890 : begin  // STAT_RX_PACKET_SMALL_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_packet_small_count_sync[31:0];
                        end

               'h0894 : begin  // STAT_RX_PACKET_SMALL_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_packet_small_count_sync[47:32];
                        end

               'h0898 : begin  // STAT_RX_UNDERSIZE_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_undersize_count_sync[31:0];
                        end

               'h089C : begin  // STAT_RX_UNDERSIZE_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_undersize_count_sync[47:32];
                        end

               'h08A0 : begin  // STAT_RX_FRAGMENT_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_fragment_count_sync[31:0];
                        end

               'h08A4 : begin  // STAT_RX_FRAGMENT_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_fragment_count_sync[47:32];
                        end

               'h08A8 : begin  // STAT_RX_OVERSIZE_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_oversize_count_sync[31:0];
                        end

               'h08AC : begin  // STAT_RX_OVERSIZE_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_oversize_count_sync[47:32];
                        end

               'h08B0 : begin  // STAT_RX_TOOLONG_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_toolong_count_sync[31:0];
                        end

               'h08B4 : begin  // STAT_RX_TOOLONG_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_toolong_count_sync[47:32];
                        end

               'h08B8 : begin  // STAT_RX_JABBER_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_jabber_count_sync[31:0];
                        end

               'h08BC : begin  // STAT_RX_JABBER_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_jabber_count_sync[47:32];
                        end

               'h08C0 : begin  // STAT_RX_BAD_FCS_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_bad_fcs_count_sync[31:0];
                        end

               'h08C4 : begin  // STAT_RX_BAD_FCS_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_bad_fcs_count_sync[47:32];
                        end

               'h08C8 : begin  // STAT_RX_PACKET_BAD_FCS_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_packet_bad_fcs_count_sync[31:0];
                        end

               'h08CC : begin  // STAT_RX_PACKET_BAD_FCS_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_packet_bad_fcs_count_sync[47:32];
                        end

               'h08D0 : begin  // STAT_RX_STOMPED_FCS_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_stomped_fcs_count_sync[31:0];
                        end

               'h08D4 : begin  // STAT_RX_STOMPED_FCS_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_stomped_fcs_count_sync[47:32];
                        end

               'h08D8 : begin  // STAT_RX_UNICAST_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_unicast_count_sync[31:0];
                        end

               'h08DC : begin  // STAT_RX_UNICAST_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_unicast_count_sync[47:32];
                        end

               'h08E0 : begin  // STAT_RX_MULTICAST_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_multicast_count_sync[31:0];
                        end

               'h08E4 : begin  // STAT_RX_MULTICAST_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_multicast_count_sync[47:32];
                        end

               'h08E8 : begin  // STAT_RX_BROADCAST_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_broadcast_count_sync[31:0];
                        end

               'h08EC : begin  // STAT_RX_BROADCAST_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_broadcast_count_sync[47:32];
                        end

               'h08F0 : begin  // STAT_RX_VLAN_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_vlan_count_sync[31:0];
                        end

               'h08F4 : begin  // STAT_RX_VLAN_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_vlan_count_sync[47:32];
                        end




               'h0908 : begin  // STAT_RX_INRANGEERR_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_inrangeerr_count_sync[31:0];
                        end

               'h090C : begin  // STAT_RX_INRANGEERR_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_inrangeerr_count_sync[47:32];
                        end


               'h0918 : begin  // STAT_RX_TEST_PATTERN_MISMATCH_LSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[32-1:0] <= stat_rx_test_pattern_mismatch_count_sync[31:0];
                        end

               'h091C : begin  // STAT_RX_TEST_PATTERN_MISMATCH_MSB
                          statsreg_read_req <= 1'b1;
                          IP2Bus_RdAck      <= statsreg_read_ack | timeout_error;
                          IP2Bus_RdError    <= timeout_error;
                          IP2Bus_Data[16-1:0] <= stat_rx_test_pattern_mismatch_count_sync[47:32];
                        end

            endcase
          end
        else
          begin
            IP2Bus_RdAck  <= 1'b0;
          end
        end
      end // always @ block. READ



  wire pm_tick_sync;
  wire rx_sreset;
  wire tx_sreset;

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_reset_flop i_RX_RESET_BUFFER (
    .clk         ( rx_clk ),
    .reset_async ( rx_reset ),
    .reset       ( rx_sreset )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_reset_flop i_TX_RESET_BUFFER (
    .clk         ( tx_clk ),
    .reset_async ( tx_reset ),
    .reset       ( tx_sreset )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_reg_pm_tick_syncer (
    .clk          (Bus2IP_Clk),
    .reset        (AXI_Reset),
    .datain       (pm_tick),
    .dataout      (pm_tick_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_pulse i_pmtick_rx_clk_syncer (

  .clkin        ( Bus2IP_Clk ),
  .clkin_reset  ( 1'b0 ),
  .clkout       ( rx_clk ),
  .clkout_reset ( rx_sreset ),
  .pulsein      ( tick_r ),  // clkin domain
  .pulseout     ( rx_clk_tick_retimed )  // clkout domain
  );

  always @( posedge rx_clk )
    begin
      if ( rx_reset == 1'b1 )
        begin
          rx_clk_tick_retimed_d1 <= 1'b0;
        end
      else
        begin
          rx_clk_tick_retimed_d1 <= rx_clk_tick_retimed_d1_nxt;
        end
    end

  assign rx_clk_tick_r = rx_clk_tick_retimed_d1;
  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_pulse i_pmtick_tx_clk_syncer (

  .clkin        ( Bus2IP_Clk ),
  .clkin_reset  ( 1'b0 ),
  .clkout       ( tx_clk ),
  .clkout_reset ( tx_sreset ),
  .pulsein      ( tick_r ),  // clkin domain
  .pulseout     ( tx_clk_tick_retimed )  // clkout domain
  );

  always @( posedge tx_clk )
    begin
      if ( tx_reset == 1'b1 )
        begin
          tx_clk_tick_retimed_d1 <= 1'b0;
        end
      else
        begin
          tx_clk_tick_retimed_d1 <= tx_clk_tick_retimed_d1_nxt;
        end
    end

  assign tx_clk_tick_r = tx_clk_tick_retimed_d1;

  reg  [3:0] tick_rr;
  wire tick_out;

  assign tick_out = tick_reg_mode_sel_r ? tick_reg_r : pm_tick_sync;

  always @( posedge Bus2IP_Clk )
    begin
      if ( AXI_Reset == 1'b1 )
        begin
          tick_r  <= 1'b0;
          tick_rr <=  'b0;
        end
      else
        begin
          tick_r  <= ~tick_rr[3] && tick_rr[2];
          tick_rr <= {tick_rr[2:0], tick_out};
        end
    end

  wire rx_clk_statsreg_read_req_sync;
  wire tx_clk_statsreg_read_req_sync;
  wire axi_rx_clk_statsreg_hold_sync;
  wire axi_tx_clk_statsreg_hold_sync;
  wire statsreg_hold_sync;
  reg  statsreg_hold_sync_d1;

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_statsreg_read_req_rx_clk_syncer (
    .clk          (rx_clk),
    .reset        (AXI_Reset_rx_clk_sync),
    .datain       (statsreg_read_req),
    .dataout      (rx_clk_statsreg_read_req_sync)
  );

  assign rx_clk_statsreg_hold = rx_clk_statsreg_read_req_sync;

  always @( posedge rx_clk )
    begin
      if ( AXI_Reset_rx_clk_sync == 1'b1 )
        begin
          rx_clk_statsreg_hold_d1 <= 1'b0;
        end
      else
        begin
          rx_clk_statsreg_hold_d1 <= rx_clk_statsreg_hold_d1_nxt && ~tick_rx_clk_not_ready_r;
        end
    end

  assign rx_clk_statsreg_hold_r = rx_clk_statsreg_hold_d1;

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_rx_clk_statsreg_hold_syncer (
    .clk         ( Bus2IP_Clk ),
    .reset       ( AXI_Reset ),
    .datain      ( rx_clk_statsreg_hold_r ),
    .dataout     ( axi_rx_clk_statsreg_hold_sync )
  );

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_statsreg_read_req_tx_clk_syncer (
    .clk          (tx_clk),
    .reset        (AXI_Reset_tx_clk_sync),
    .datain       (statsreg_read_req),
    .dataout      (tx_clk_statsreg_read_req_sync)
  );

  assign tx_clk_statsreg_hold = tx_clk_statsreg_read_req_sync;

  always @( posedge tx_clk )
    begin
      if ( AXI_Reset_tx_clk_sync == 1'b1 )
        begin
          tx_clk_statsreg_hold_d1 <= 1'b0;
        end
      else
        begin
          tx_clk_statsreg_hold_d1 <= tx_clk_statsreg_hold_d1_nxt && ~tick_tx_clk_not_ready_r;
        end
    end

  assign tx_clk_statsreg_hold_r = tx_clk_statsreg_hold_d1;

  pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_syncer_level #(
    .WIDTH        (1)
  ) i_tx_clk_statsreg_hold_syncer (
    .clk         ( Bus2IP_Clk ),
    .reset       ( AXI_Reset ),
    .datain      ( tx_clk_statsreg_hold_r ),
    .dataout     ( axi_tx_clk_statsreg_hold_sync )
  );

  assign statsreg_hold_sync = axi_rx_clk_statsreg_hold_sync & axi_tx_clk_statsreg_hold_sync;

  always @( posedge Bus2IP_Clk )
    begin
      if ( AXI_Reset == 1'b1 )
        begin
          statsreg_read_ack     <= 1'b0;
          statsreg_hold_sync_d1 <= 1'b0;
        end
      else
        begin
          statsreg_hold_sync_d1 <= statsreg_hold_sync;
          statsreg_read_ack     <= statsreg_hold_sync & ~statsreg_hold_sync_d1;
        end
    end


  always @( posedge Bus2IP_Clk )
    begin
      if ( AXI_Reset == 1'b1 )
        begin
          timeout_counter <= 7'd0;
          timeout_error   <= 1'b0;
        end
      else
        begin
          timeout_error <= &timeout_counter;
          if (Bus2IP_CS_reg & Bus2IP_RNW_reg)
            timeout_counter <= timeout_counter + 1;
          else
            timeout_counter <= 7'd0;
        end
    end

endmodule

////////////////////////////////////////////////////////////////////////////
//
// AXI4-Lite Slave interface example
//
// The purpose of this design is to provide a simple AXI4-Lite Slave interface.
//
// The AXI4-Lite interface is a subset of the AXI4 interface intended for
// communication with control registers in components.
// The key features of the AXI4-Lite interface are:
//         >> all transactions are burst length of 1
//         >> all data accesses are the same size as the width of the data bus
//         >> support for data bus width of 32-bit or 64-bit
//
// This design implements AXI Slave to IPIF master
//
////////////////////////////////////////////////////////////////////////////

module pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_axi_slave_2_ipif #(
  parameter C_S_AXI_ADDR_WIDTH = 32,   // Width of M_AXI address bus
  parameter C_S_AXI_DATA_WIDTH = 32    // Width of M_AXI data bus
)
(
  ////////////////////////////////////////////////////////////////////////////
  // System Signals

  ////////////////////////////////////////////////////////////////////////////
  // AXI clock signal
  input wire s_axi_aclk,
  ////////////////////////////////////////////////////////////////////////////
  // AXI active low reset signal
  input wire s_axi_aresetn,

  ////////////////////////////////////////////////////////////////////////////
  // Slave Interface Write Address channel Ports

  ////////////////////////////////////////////////////////////////////////////
  // Master Interface Write Address Channel ports
  // Write address (issued by master, acceped by Slave)
  input  wire [C_S_AXI_ADDR_WIDTH - 1:0] s_axi_awaddr,
  ////////////////////////////////////////////////////////////////////////////
  // Write address valid. This signal indicates that the master signaling
  // valid write address and control information.
  input  wire                          s_axi_awvalid,
  ////////////////////////////////////////////////////////////////////////////
  // Write address ready. This signal indicates that the slave is ready
  // to accept an address and associated control signals.
  output wire                          s_axi_awready,

  ////////////////////////////////////////////////////////////////////////////
  // Slave Interface Write Data channel Ports
  // Write data (issued by master, acceped by Slave)
  input  wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_wdata,
  ////////////////////////////////////////////////////////////////////////////
  // Write strobes. This signal indicates which byte lanes hold
  // valid data. There is one write strobe bit for each eight
  // bits of the write data bus.
  input  wire [C_S_AXI_DATA_WIDTH/8-1:0] s_axi_wstrb,
  ////////////////////////////////////////////////////////////////////////////
  //Write valid. This signal indicates that valid write
  // data and strobes are available.
  input  wire                          s_axi_wvalid,
  ////////////////////////////////////////////////////////////////////////////
  // Write ready. This signal indicates that the slave
  // can accept the write data.
  output wire                          s_axi_wready,

  ////////////////////////////////////////////////////////////////////////////
  // Slave Interface Write Response channel Ports

  ////////////////////////////////////////////////////////////////////////////
  // Write response. This signal indicates the status
  // of the write transaction.
  output wire [1:0]                    s_axi_bresp,
  ////////////////////////////////////////////////////////////////////////////
  // Write response valid. This signal indicates that the channel
  // is signaling a valid write response.
  output wire                          s_axi_bvalid,
  ////////////////////////////////////////////////////////////////////////////
  // Response ready. This signal indicates that the master
  // can accept a write response.
  input  wire                          s_axi_bready,

  ////////////////////////////////////////////////////////////////////////////
  // Slave Interface Read Address channel Ports
  // Read address (issued by master, acceped by Slave)
  input  wire [C_S_AXI_ADDR_WIDTH - 1:0] s_axi_araddr,
  ////////////////////////////////////////////////////////////////////////////
  // Read address valid. This signal indicates that the channel
  // is signaling valid read address and control information.
  input  wire                          s_axi_arvalid,
  ////////////////////////////////////////////////////////////////////////////
  // Read address ready. This signal indicates that the slave is
  // ready to accept an address and associated control signals.
  output wire                          s_axi_arready,

  ////////////////////////////////////////////////////////////////////////////
  // Slave Interface Read Data channel Ports
  // Read data (issued by slave)
  output wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata,
  ////////////////////////////////////////////////////////////////////////////
  // Read response. This signal indicates the status of the
  // read transfer.
  output wire [1:0]                    s_axi_rresp,
  ////////////////////////////////////////////////////////////////////////////
  // Read valid. This signal indicates that the channel is
  // signaling the required read data.
  output wire                          s_axi_rvalid,
  ////////////////////////////////////////////////////////////////////////////
  // Read ready. This signal indicates that the master can
  // accept the read data and response information.
  input  wire                          s_axi_rready,

  output wire                            Bus2IP_Clk,
  output wire                            Bus2IP_Resetn,
  output wire [C_S_AXI_ADDR_WIDTH-1:0]   Bus2IP_Addr,
  output wire                            Bus2IP_RNW,
  output wire                            Bus2IP_CS,
  output wire                            Bus2IP_RdCE,    // Not used
  output wire                            Bus2IP_WrCE,    // Not used
  output wire [C_S_AXI_DATA_WIDTH-1:0]   Bus2IP_Data,
  output wire [C_S_AXI_DATA_WIDTH/8-1:0] Bus2IP_BE,
  input       [C_S_AXI_DATA_WIDTH-1:0]   IP2Bus_Data,
  input                                  IP2Bus_WrAck,
  input                                  IP2Bus_RdAck,
  input                                  IP2Bus_WrError,
  input                                  IP2Bus_RdError
);

////////////////////////////////////////////////////////////////////////////
// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
// ADDR_LSB is used for addressing 32/64 bit registers/memories
// ADDR_LSB = 2 for 32 bits (n downto 2)
// ADDR_LSB = 3 for 64 bits (n downto 3)

////////////////////////////////////////////////////////////////////////////
// function called clogb2 that returns an integer which has the
// value of the ceiling of the log base 2.
function integer clogb2 (input integer bd);
integer bit_depth;
begin
  bit_depth = bd;
  for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
    bit_depth = bit_depth >> 1;
  end
endfunction

localparam integer ADDR_LSB = clogb2(C_S_AXI_DATA_WIDTH/8)-1;
localparam integer ADDR_MSB = C_S_AXI_ADDR_WIDTH;

////////////////////////////////////////////////////////////////////////////
// AXI4 Lite internal signals

////////////////////////////////////////////////////////////////////////////
// read response
reg [1 :0]                   axi_rresp;
////////////////////////////////////////////////////////////////////////////
// write response
reg [1 :0]                   axi_bresp;
////////////////////////////////////////////////////////////////////////////
// write address acceptance
reg                          axi_awready;
////////////////////////////////////////////////////////////////////////////
// write data acceptance
reg                          axi_wready;
////////////////////////////////////////////////////////////////////////////
// write response valid
reg                          axi_bvalid;
////////////////////////////////////////////////////////////////////////////
// read data valid
reg                          axi_rvalid;
////////////////////////////////////////////////////////////////////////////
// write address
reg [ADDR_MSB-1:0] axi_awaddr;
////////////////////////////////////////////////////////////////////////////
// write data
reg [C_S_AXI_DATA_WIDTH-1:0] axi_wdata;
////////////////////////////////////////////////////////////////////////////
// write strobe
reg [C_S_AXI_DATA_WIDTH/8-1:0] axi_wstrb_reg;
reg [C_S_AXI_DATA_WIDTH/8-1:0] axi_wstrb;
////////////////////////////////////////////////////////////////////////////
// read address valid
reg [ADDR_MSB-1:0] axi_araddr;
////////////////////////////////////////////////////////////////////////////
// read data
reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata;
////////////////////////////////////////////////////////////////////////////
// read address acceptance
reg                          axi_arready;

////////////////////////////////////////////////////////////////////////////
// Example-specific design signals


////////////////////////////////////////////////////////////////////////////
// Signals for user logic chip select generation

////////////////////////////////////////////////////////////////////////////
// Signals for user logic register space example
// Four slave register

////////////////////////////////////////////////////////////////////////////
// Slave register read enable
reg                             slv_reg_rden;
////////////////////////////////////////////////////////////////////////////
// Slave register write enable
reg                             slv_reg_wren;
////////////////////////////////////////////////////////////////////////////

integer                         byte_index;

////////////////////////////////////////////////////////////////////////////
//I/O Connections assignments

////////////////////////////////////////////////////////////////////////////
//Write Address Ready (AWREADY)
assign s_axi_awready = axi_awready;

////////////////////////////////////////////////////////////////////////////
//Write Data Ready(WREADY)
assign s_axi_wready  = axi_wready;

////////////////////////////////////////////////////////////////////////////
//Write Response (BResp)and response valid (BVALID)
assign s_axi_bresp  = axi_bresp;
assign s_axi_bvalid = axi_bvalid;

////////////////////////////////////////////////////////////////////////////
//Read Address Ready(AREADY)
assign s_axi_arready = axi_arready;

////////////////////////////////////////////////////////////////////////////
//Read and Read Data (RDATA), Read Valid (RVALID) and Response (RRESP)
assign s_axi_rdata  = axi_rdata;
assign s_axi_rvalid = axi_rvalid;
assign s_axi_rresp  = axi_rresp;


////////////////////////////////////////////////////////////////////////////
// Implement axi_awready generation
//
//  axi_awready is asserted for one s_axi_aclk clock cycle when both
//  s_axi_awvalid and s_axi_wvalid are asserted. axi_awready is
//  de-asserted when reset is low.

  always @( posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0 )
      begin
        axi_awready <= 1'b0;
      end
    else
      begin
        if (~axi_awready && s_axi_awvalid && s_axi_wvalid && ~slv_reg_wren)
          begin
            ////////////////////////////////////////////////////////////////////////////
            // slave is ready to accept write address when
            // there is a valid write address and write data
            // on the write address and data bus. This design
            // expects no outstanding transactions.
            axi_awready <= 1'b1;
          end
        else
          begin
            axi_awready <= 1'b0;
          end
      end
  end

////////////////////////////////////////////////////////////////////////////
// Implement axi_awaddr latching
//
//  This process is used to latch the address when both
//  s_axi_awvalid and s_axi_wvalid are valid.

  always @( posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0 )
      begin
        axi_awaddr <= 0;
      end
    else
      begin
        if (~axi_awready && s_axi_awvalid && s_axi_wvalid)
          begin
            ////////////////////////////////////////////////////////////////////////////
            // address latching
            axi_awaddr <= s_axi_awaddr;
          end
      end
  end

// -------------------------------------------------------------------------
////////////////////////////////////////////////////////////////////////////
// Implement axi_wdata latching
//
//  This process is used to latch the address when both
//  S_AXI_WVALID and S_AXI_WREADY are valid.

  always @( posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0 )
      begin
        axi_wdata <= 0;
      end
    else
      begin
        if (~axi_wready && s_axi_wvalid)
          begin
            ////////////////////////////////////////////////////////////////////////////
            // data latching
            axi_wdata <= s_axi_wdata;
          end
      end
  end

////////////////////////////////////////////////////////////////////////////
// Registering axi_wstrb

  always @( posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0 )
      begin
        axi_wstrb_reg <= 0;
        axi_wstrb     <= 0;
      end
    else
      begin
        axi_wstrb_reg <= s_axi_wstrb;
        axi_wstrb     <= axi_wstrb_reg;
      end
  end
// -------------------------------------------------------------------------

////////////////////////////////////////////////////////////////////////////
// Implement axi_wready generation
//
//  axi_wready is asserted for one s_axi_aclk clock cycle when both
//  s_axi_awvalid and s_axi_wvalid are asserted. axi_wready is
//  de-asserted when reset is low.

  always @( posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0 )
      begin
        axi_wready <= 1'b0;
      end
    else
      begin
        if (~axi_wready && s_axi_wvalid && s_axi_awvalid && ~slv_reg_wren)
          begin
            ////////////////////////////////////////////////////////////////////////////
            // slave is ready to accept write data when
            // there is a valid write address and write data
            // on the write address and data bus. This design
            // expects no outstanding transactions.
            axi_wready <= 1'b1;
          end
        else
          begin
            axi_wready <= 1'b0;
          end
      end
  end

// Slave register write enable is asserted when valid address and data are available
// and the slave is ready to accept the write address and write data.
  always @ (posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0)
      slv_reg_wren <= 0;
    else if (axi_wready && s_axi_wvalid && axi_awready && s_axi_awvalid)
      slv_reg_wren <= 1;
    else if (IP2Bus_WrAck || IP2Bus_WrError)
      slv_reg_wren <= 0;
  end

////////////////////////////////////////////////////////////////////////////
// Implement write response logic generation
//
//  The write response and response valid signals are asserted by the slave
//  when axi_wready, s_axi_wvalid, axi_wready and s_axi_wvalid are asserted.
//  This marks the acceptance of address and indicates the status of
//  write transaction.

  always @( posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0 )
      begin
        axi_bvalid  <= 0;
        axi_bresp   <= 2'b0;
      end
    else
      begin
        // if (axi_awready && s_axi_awvalid && ~axi_bvalid && axi_wready && s_axi_wvalid)
        // ------------------------
        // write response is set to 2'b10 when there is a write error/failure
        if (IP2Bus_WrError)
          begin
            axi_bvalid <= 1'b1;
            axi_bresp  <= 2'b10; // write side 'SLVERR' respose
          end
        // ------------------------
        else if (slv_reg_wren && IP2Bus_WrAck)
          begin
            // indicates a valid write response is available
            axi_bvalid <= 1'b1;
            axi_bresp  <= 2'b0; // 'OKAY' response
          end
        else if (s_axi_bready && axi_bvalid)
          begin
            //check if bready is asserted while bvalid is high)
            //(there is a possibility that bready is always asserted high)
            axi_bvalid <= 1'b0;
            axi_bresp  <= 2'b0; // 'OKAY' response
          end
      end
  end


////////////////////////////////////////////////////////////////////////////
// Implement axi_arready generation
//
//  axi_arready is asserted for one s_axi_aclk clock cycle when
//  s_axi_arvalid is asserted. axi_awready is
//  de-asserted when reset (active low) is asserted.
//  The read address is also latched when s_axi_arvalid is
//  asserted. axi_araddr is reset to zero on reset assertion.

  always @( posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0 )
      begin
        axi_arready <= 1'b0;
        axi_araddr  <= {ADDR_MSB{1'b0}};
      end
    else
      begin
        if (~axi_arready && s_axi_arvalid && ~axi_rvalid && ~slv_reg_rden)
          begin
            // indicates that the slave has acceped the valid read address
            axi_arready <= 1'b1;
            axi_araddr  <= s_axi_araddr;
          end
        else
          begin
            axi_arready <= 1'b0;
          end
      end
  end

////////////////////////////////////////////////////////////////////////////
// Implement memory mapped register select and read logic generation
//
//  axi_rvalid is asserted for one s_axi_aclk clock cycle when both
//  a read is outstand (slv_reg_rden) and the IPIF Read is acknolwedged 
//  (IP2Bus_RdAck). It is deasserted on reset (active low). 
//  axi_rresp and axi_rdata are cleared to zero on reset (active low).

  always @( posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0 )
      begin
        axi_rvalid <= 0;
        axi_rresp  <= 0;
      end
    else
      begin
        // if (axi_arready && s_axi_arvalid && ~axi_rvalid && IP2Bus_RdAck)
        // ------------------------
        //read response is set to 2'b10 when there is a read error/failure
        if (IP2Bus_RdError)
          begin
            axi_rvalid <= 1'b1;
            axi_rresp  <= 2'b10; // read side 'SLVERR' respose
          end
        // ------------------------
        else if (slv_reg_rden && IP2Bus_RdAck)
          begin
            // Valid read data is available at the read data bus
            axi_rvalid <= 1'b1;
            axi_rresp  <= 2'b0; // 'OKAY' response
          end
        else if (axi_rvalid && s_axi_rready)
          begin
            // Read data is accepted by the master
            axi_rvalid <= 1'b0;
            axi_rresp  <= 2'b0; // 'OKAY' response
          end
      end
  end


////////////////////////////////////////////////////////////////////////////
// Slave register read enable is asserted when valid address is available
// and the slave is ready to accept the read address.
  always @ (posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0)
      slv_reg_rden <= 0;
    else if (axi_arready && s_axi_arvalid && ~axi_rvalid)
      slv_reg_rden <= 1;
    else if (IP2Bus_RdAck || IP2Bus_RdError)
      slv_reg_rden <= 0;
  end

  always @( posedge s_axi_aclk )
  begin
    if ( s_axi_aresetn == 1'b0 )
      begin
        axi_rdata  <= 0;
      end
    else
      begin
        ////////////////////////////////////////////////////////////////////////////
        // When there is a valid read response from the IPIF 
        // output the read dada
        if (slv_reg_rden && IP2Bus_RdAck)
          begin
            axi_rdata <= IP2Bus_Data;     // register read data
          end
      end
  end

  assign Bus2IP_Clk    = s_axi_aclk;
  assign Bus2IP_Resetn = s_axi_aresetn;
  assign Bus2IP_Addr   = slv_reg_wren ? axi_awaddr : axi_araddr ;
  assign Bus2IP_RNW    = slv_reg_rden;
  assign Bus2IP_CS     = slv_reg_rden | slv_reg_wren;
  assign Bus2IP_RdCE   = 1'b0;
  assign Bus2IP_WrCE   = 1'b0;
  //assign Bus2IP_Data   = s_axi_wdata;
  assign Bus2IP_Data   = slv_reg_wren ? axi_wdata : 32'd0;
  //assign Bus2IP_BE     = slv_reg_wren ? s_axi_wstrb : {C_S_AXI_DATA_WIDTH{1'b1}};
  assign Bus2IP_BE     = slv_reg_wren ? axi_wstrb : {C_S_AXI_DATA_WIDTH{1'b1}};

endmodule

module pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_axi_if_top #(
  parameter C_S_AXI_ADDR_WIDTH = 32,   // Width of M_AXI address bus
  parameter C_S_AXI_DATA_WIDTH = 32    // Width of M_AXI data bus
)
(
  output wire ctl_tx_test_pattern,
  output wire ctl_rx_test_pattern,
  output wire ctl_tx_test_pattern_enable,
  output wire ctl_tx_test_pattern_select,
  output wire ctl_tx_data_pattern_select,
  output wire [57:0] ctl_tx_test_pattern_seed_a,
  output wire [57:0] ctl_tx_test_pattern_seed_b,
  output wire ctl_rx_test_pattern_enable,
  output wire ctl_rx_data_pattern_select,
  output wire axi_ctl_core_mode_switch,
  output wire ctl_tx_enable,
  output wire ctl_rx_enable,
  output wire ctl_tx_fcs_ins_enable,
  output wire ctl_rx_delete_fcs,
  output wire ctl_rx_ignore_fcs,
  output wire [14:0] ctl_rx_max_packet_len,
  output wire [7:0] ctl_rx_min_packet_len,
  output wire [3:0] ctl_tx_ipg_value,
  output wire ctl_tx_send_lfi,
  output wire ctl_tx_send_rfi,
  output wire ctl_tx_send_idle,
  output wire ctl_tx_custom_preamble_enable,
  output wire ctl_rx_custom_preamble_enable,
  output wire ctl_local_loopback,
  output wire ctl_gt_reset_all,
  output wire ctl_gt_tx_reset,
  output wire ctl_gt_rx_reset,
  output wire ctl_rx_check_sfd,
  output wire ctl_rx_check_preamble,
  output wire ctl_rx_process_lfi,
  output wire ctl_rx_force_resync,
  output wire ctl_tx_ignore_fcs,
  output wire [31:0] user_reg0,

  input  wire stat_rx_block_lock,
  input  wire stat_rx_status,
  input  wire stat_rx_framing_err_valid,
  input  wire stat_rx_framing_err,
  input  wire stat_rx_hi_ber,
  input  wire stat_rx_valid_ctrl_code,
  input  wire stat_rx_bad_code,
  input  wire [1:0] stat_rx_total_packets,
  input  wire stat_rx_total_good_packets,
  input  wire [3:0] stat_rx_total_bytes,
  input  wire [13:0] stat_rx_total_good_bytes,
  input  wire stat_rx_packet_small,
  input  wire stat_rx_jabber,
  input  wire stat_rx_packet_large,
  input  wire stat_rx_oversize,
  input  wire stat_rx_undersize,
  input  wire stat_rx_toolong,
  input  wire stat_rx_fragment,
  input  wire stat_rx_packet_64_bytes,
  input  wire stat_rx_packet_65_127_bytes,
  input  wire stat_rx_packet_128_255_bytes,
  input  wire stat_rx_packet_256_511_bytes,
  input  wire stat_rx_packet_512_1023_bytes,
  input  wire stat_rx_packet_1024_1518_bytes,
  input  wire stat_rx_packet_1519_1522_bytes,
  input  wire stat_rx_packet_1523_1548_bytes,
  input  wire [1:0] stat_rx_bad_fcs,
  input  wire stat_rx_packet_bad_fcs,
  input  wire [1:0] stat_rx_stomped_fcs,
  input  wire stat_rx_packet_1549_2047_bytes,
  input  wire stat_rx_packet_2048_4095_bytes,
  input  wire stat_rx_packet_4096_8191_bytes,
  input  wire stat_rx_packet_8192_9215_bytes,
  input  wire stat_rx_unicast,
  input  wire stat_rx_multicast,
  input  wire stat_rx_broadcast,
  input  wire stat_rx_vlan,
  input  wire stat_rx_inrangeerr,
  input  wire stat_rx_bad_preamble,
  input  wire stat_rx_bad_sfd,
  input  wire stat_rx_got_signal_os,
  input  wire stat_rx_test_pattern_mismatch,
  input  wire stat_rx_truncated,
  input  wire stat_rx_local_fault,
  input  wire stat_rx_remote_fault,
  input  wire stat_rx_internal_local_fault,
  input  wire stat_rx_received_local_fault,
  input  wire stat_tx_total_packets,
  input  wire [3:0] stat_tx_total_bytes,
  input  wire stat_tx_total_good_packets,
  input  wire [13:0] stat_tx_total_good_bytes,
  input  wire stat_tx_packet_64_bytes,
  input  wire stat_tx_packet_65_127_bytes,
  input  wire stat_tx_packet_128_255_bytes,
  input  wire stat_tx_packet_256_511_bytes,
  input  wire stat_tx_packet_512_1023_bytes,
  input  wire stat_tx_packet_1024_1518_bytes,
  input  wire stat_tx_packet_1519_1522_bytes,
  input  wire stat_tx_packet_1523_1548_bytes,
  input  wire stat_tx_packet_small,
  input  wire stat_tx_packet_large,
  input  wire stat_tx_packet_1549_2047_bytes,
  input  wire stat_tx_packet_2048_4095_bytes,
  input  wire stat_tx_packet_4096_8191_bytes,
  input  wire stat_tx_packet_8192_9215_bytes,
  input  wire stat_tx_unicast,
  input  wire stat_tx_multicast,
  input  wire stat_tx_broadcast,
  input  wire stat_tx_vlan,
  input  wire stat_tx_bad_fcs,
  input  wire stat_tx_frame_error,
  input  wire stat_tx_bad_parity,
  input  wire stat_tx_local_fault,
  input  wire stat_core_speed,

  input  rx_clk,
  input  rx_reset,
  input  tx_clk,
  input  tx_reset,

  output wire rx_reset_out,
  output wire tx_reset_out,
  output wire [1-1:0] rx_serdes_reset_out,
  output wire tx_serdes_reset_out,

  input  wire s_axi_aclk,
  input  wire s_axi_aresetn,
  input  wire [31:0] s_axi_awaddr,
  input  wire s_axi_awvalid,
  output wire s_axi_awready,
  input  wire [31:0] s_axi_wdata,
  input  wire [3:0] s_axi_wstrb,
  input  wire s_axi_wvalid,
  output wire s_axi_wready,
  output wire [1:0] s_axi_bresp,
  output wire s_axi_bvalid,
  input  wire s_axi_bready,
  input  wire [31:0] s_axi_araddr,
  input  wire s_axi_arvalid,
  output wire s_axi_arready,
  output wire [31:0] s_axi_rdata,
  output wire [1:0] s_axi_rresp,
  output wire s_axi_rvalid,
  input  wire s_axi_rready,
  input  wire pm_tick
);

  wire Bus2IP_Clk;
  wire Bus2IP_Resetn;
  wire [C_S_AXI_ADDR_WIDTH-1:0]   Bus2IP_Addr;
  wire Bus2IP_RNW;
  wire Bus2IP_CS;
  wire Bus2IP_RdCE;    // Not used
  wire Bus2IP_WrCE;    // Not used
  wire [C_S_AXI_DATA_WIDTH-1:0]   Bus2IP_Data;
  wire [C_S_AXI_DATA_WIDTH/8-1:0] Bus2IP_BE;
  wire [C_S_AXI_DATA_WIDTH-1:0]   IP2Bus_Data;
  wire IP2Bus_WrAck;
  wire IP2Bus_RdAck;
  wire IP2Bus_WrError;
  wire IP2Bus_RdError;


 pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_pif_registers #(
  .ADDR_WIDTH(16),
  .DATA_WIDTH(C_S_AXI_DATA_WIDTH)
 ) i_pif_registers (
  // Stats and ctl
    .ctl_tx_test_pattern (ctl_tx_test_pattern),
    .ctl_rx_test_pattern (ctl_rx_test_pattern),
    .ctl_tx_test_pattern_enable (ctl_tx_test_pattern_enable),
    .ctl_tx_test_pattern_select (ctl_tx_test_pattern_select),
    .ctl_tx_data_pattern_select (ctl_tx_data_pattern_select),
    .ctl_tx_test_pattern_seed_a (ctl_tx_test_pattern_seed_a),
    .ctl_tx_test_pattern_seed_b (ctl_tx_test_pattern_seed_b),
    .ctl_rx_test_pattern_enable (ctl_rx_test_pattern_enable),
    .ctl_rx_data_pattern_select (ctl_rx_data_pattern_select),
    .axi_ctl_core_mode_switch (axi_ctl_core_mode_switch),
    .ctl_tx_enable (ctl_tx_enable),
    .ctl_rx_enable (ctl_rx_enable),
    .ctl_tx_fcs_ins_enable (ctl_tx_fcs_ins_enable),
    .ctl_rx_delete_fcs (ctl_rx_delete_fcs),
    .ctl_rx_ignore_fcs (ctl_rx_ignore_fcs),
    .ctl_rx_max_packet_len (ctl_rx_max_packet_len),
    .ctl_rx_min_packet_len (ctl_rx_min_packet_len),
    .ctl_tx_ipg_value (ctl_tx_ipg_value),
    .ctl_tx_send_lfi (ctl_tx_send_lfi),
    .ctl_tx_send_rfi (ctl_tx_send_rfi),
    .ctl_tx_send_idle (ctl_tx_send_idle),
    .ctl_tx_custom_preamble_enable (ctl_tx_custom_preamble_enable),
    .ctl_rx_custom_preamble_enable (ctl_rx_custom_preamble_enable),
    .ctl_local_loopback (ctl_local_loopback),
    .ctl_gt_reset_all (ctl_gt_reset_all),
    .ctl_gt_tx_reset (ctl_gt_tx_reset),
    .ctl_gt_rx_reset (ctl_gt_rx_reset),
    .ctl_rx_check_sfd (ctl_rx_check_sfd),
    .ctl_rx_check_preamble (ctl_rx_check_preamble),
    .ctl_rx_process_lfi (ctl_rx_process_lfi),
    .ctl_rx_force_resync (ctl_rx_force_resync),
    .ctl_tx_ignore_fcs (ctl_tx_ignore_fcs),
    .user_reg0 (user_reg0),
    .stat_rx_block_lock (stat_rx_block_lock),
    .stat_rx_status (stat_rx_status),
    .stat_rx_framing_err_valid (stat_rx_framing_err_valid),
    .stat_rx_framing_err (stat_rx_framing_err),
    .stat_rx_hi_ber (stat_rx_hi_ber),
    .stat_rx_valid_ctrl_code (stat_rx_valid_ctrl_code),
    .stat_rx_bad_code (stat_rx_bad_code),
    .stat_rx_total_packets (stat_rx_total_packets),
    .stat_rx_total_good_packets (stat_rx_total_good_packets),
    .stat_rx_total_bytes (stat_rx_total_bytes),
    .stat_rx_total_good_bytes (stat_rx_total_good_bytes),
    .stat_rx_packet_small (stat_rx_packet_small),
    .stat_rx_jabber (stat_rx_jabber),
    .stat_rx_packet_large (stat_rx_packet_large),
    .stat_rx_oversize (stat_rx_oversize),
    .stat_rx_undersize (stat_rx_undersize),
    .stat_rx_toolong (stat_rx_toolong),
    .stat_rx_fragment (stat_rx_fragment),
    .stat_rx_packet_64_bytes (stat_rx_packet_64_bytes),
    .stat_rx_packet_65_127_bytes (stat_rx_packet_65_127_bytes),
    .stat_rx_packet_128_255_bytes (stat_rx_packet_128_255_bytes),
    .stat_rx_packet_256_511_bytes (stat_rx_packet_256_511_bytes),
    .stat_rx_packet_512_1023_bytes (stat_rx_packet_512_1023_bytes),
    .stat_rx_packet_1024_1518_bytes (stat_rx_packet_1024_1518_bytes),
    .stat_rx_packet_1519_1522_bytes (stat_rx_packet_1519_1522_bytes),
    .stat_rx_packet_1523_1548_bytes (stat_rx_packet_1523_1548_bytes),
    .stat_rx_bad_fcs (stat_rx_bad_fcs),
    .stat_rx_packet_bad_fcs (stat_rx_packet_bad_fcs),
    .stat_rx_stomped_fcs (stat_rx_stomped_fcs),
    .stat_rx_packet_1549_2047_bytes (stat_rx_packet_1549_2047_bytes),
    .stat_rx_packet_2048_4095_bytes (stat_rx_packet_2048_4095_bytes),
    .stat_rx_packet_4096_8191_bytes (stat_rx_packet_4096_8191_bytes),
    .stat_rx_packet_8192_9215_bytes (stat_rx_packet_8192_9215_bytes),
    .stat_rx_bad_preamble (stat_rx_bad_preamble),
    .stat_rx_bad_sfd (stat_rx_bad_sfd),
    .stat_rx_got_signal_os (stat_rx_got_signal_os),
    .stat_rx_test_pattern_mismatch (stat_rx_test_pattern_mismatch),
    .stat_rx_truncated (stat_rx_truncated),
    .stat_rx_unicast (stat_rx_unicast),
    .stat_rx_multicast (stat_rx_multicast),
    .stat_rx_broadcast (stat_rx_broadcast),
    .stat_rx_vlan (stat_rx_vlan),
    .stat_rx_inrangeerr (stat_rx_inrangeerr),
    .stat_rx_local_fault (stat_rx_local_fault),
    .stat_rx_remote_fault (stat_rx_remote_fault),
    .stat_rx_internal_local_fault (stat_rx_internal_local_fault),
    .stat_rx_received_local_fault (stat_rx_received_local_fault),
    .stat_tx_total_packets (stat_tx_total_packets),
    .stat_tx_total_bytes (stat_tx_total_bytes),
    .stat_tx_total_good_packets (stat_tx_total_good_packets),
    .stat_tx_total_good_bytes (stat_tx_total_good_bytes),
    .stat_tx_packet_64_bytes (stat_tx_packet_64_bytes),
    .stat_tx_packet_65_127_bytes (stat_tx_packet_65_127_bytes),
    .stat_tx_packet_128_255_bytes (stat_tx_packet_128_255_bytes),
    .stat_tx_packet_256_511_bytes (stat_tx_packet_256_511_bytes),
    .stat_tx_packet_512_1023_bytes (stat_tx_packet_512_1023_bytes),
    .stat_tx_packet_1024_1518_bytes (stat_tx_packet_1024_1518_bytes),
    .stat_tx_packet_1519_1522_bytes (stat_tx_packet_1519_1522_bytes),
    .stat_tx_packet_1523_1548_bytes (stat_tx_packet_1523_1548_bytes),
    .stat_tx_packet_small (stat_tx_packet_small),
    .stat_tx_packet_large (stat_tx_packet_large),
    .stat_tx_packet_1549_2047_bytes (stat_tx_packet_1549_2047_bytes),
    .stat_tx_packet_2048_4095_bytes (stat_tx_packet_2048_4095_bytes),
    .stat_tx_packet_4096_8191_bytes (stat_tx_packet_4096_8191_bytes),
    .stat_tx_packet_8192_9215_bytes (stat_tx_packet_8192_9215_bytes),
    .stat_tx_unicast (stat_tx_unicast),
    .stat_tx_multicast (stat_tx_multicast),
    .stat_tx_broadcast (stat_tx_broadcast),
    .stat_tx_vlan (stat_tx_vlan),
    .stat_tx_bad_fcs (stat_tx_bad_fcs),
    .stat_tx_frame_error (stat_tx_frame_error),
    .stat_tx_bad_parity (stat_tx_bad_parity),
    .stat_tx_local_fault (stat_tx_local_fault),
    .stat_core_speed (stat_core_speed),

  .rx_clk                 ( rx_clk               ),
  .rx_reset      ( rx_reset    ),
  .tx_clk                 ( tx_clk               ),
  .tx_reset      ( tx_reset    ),

  .rx_reset_out  ( rx_reset_out),
  .tx_reset_out  ( tx_reset_out),
  .rx_serdes_reset_out    ( rx_serdes_reset_out  ),
  .tx_serdes_reset_out    ( tx_serdes_reset_out  ),

  .pm_tick                ( pm_tick              ),
  .Bus2IP_Clk             ( Bus2IP_Clk           ),
  .Bus2IP_Resetn          ( Bus2IP_Resetn        ),
  .Bus2IP_Addr            ( Bus2IP_Addr[16-1:0]  ),
  .Bus2IP_RNW             ( Bus2IP_RNW           ),
  .Bus2IP_CS              ( Bus2IP_CS            ),
  .Bus2IP_RdCE            ( Bus2IP_RdCE          ),
  .Bus2IP_WrCE            ( Bus2IP_WrCE          ),
  .Bus2IP_Data            ( Bus2IP_Data          ),
  .IP2Bus_Data            ( IP2Bus_Data          ),
  .IP2Bus_WrAck           ( IP2Bus_WrAck         ),
  .IP2Bus_RdAck           ( IP2Bus_RdAck         ),
  .IP2Bus_WrError         ( IP2Bus_WrError       ),
  .IP2Bus_RdError         ( IP2Bus_RdError       )

 );

 pl_eth_10g_xxv_ethernet_0_0_mac_baser_axis_axi_slave_2_ipif #(
  .C_S_AXI_ADDR_WIDTH (C_S_AXI_ADDR_WIDTH),   // Width of M_AXI address bus
  .C_S_AXI_DATA_WIDTH (C_S_AXI_DATA_WIDTH)    // Width of M_AXI data bus
 ) i_axi_slave_2_ipif (
  .s_axi_aclk       ( s_axi_aclk     ),
  .s_axi_aresetn    ( s_axi_aresetn  ),
  .s_axi_awaddr     ( s_axi_awaddr   ),
  .s_axi_awvalid    ( s_axi_awvalid  ),
  .s_axi_awready    ( s_axi_awready  ),
  .s_axi_wdata      ( s_axi_wdata    ),
  .s_axi_wstrb      ( s_axi_wstrb    ),
  .s_axi_wvalid     ( s_axi_wvalid   ),
  .s_axi_wready     ( s_axi_wready   ),
  .s_axi_bresp      ( s_axi_bresp    ),
  .s_axi_bvalid     ( s_axi_bvalid   ),
  .s_axi_bready     ( s_axi_bready   ),
  .s_axi_araddr     ( s_axi_araddr   ),
  .s_axi_arvalid    ( s_axi_arvalid  ),
  .s_axi_arready    ( s_axi_arready  ),
  .s_axi_rdata      ( s_axi_rdata    ),
  .s_axi_rresp      ( s_axi_rresp    ),
  .s_axi_rvalid     ( s_axi_rvalid   ),
  .s_axi_rready     ( s_axi_rready   ),
  .Bus2IP_Clk       ( Bus2IP_Clk     ),
  .Bus2IP_Resetn    ( Bus2IP_Resetn  ),
  .Bus2IP_Addr      ( Bus2IP_Addr    ),
  .Bus2IP_RNW       ( Bus2IP_RNW     ),
  .Bus2IP_CS        ( Bus2IP_CS      ),
  .Bus2IP_RdCE      ( Bus2IP_RdCE    ),    // Not used
  .Bus2IP_WrCE      ( Bus2IP_WrCE    ),    // Not used
  .Bus2IP_Data      ( Bus2IP_Data    ),
  .Bus2IP_BE        ( Bus2IP_BE      ),
  .IP2Bus_Data      ( IP2Bus_Data    ),
  .IP2Bus_WrAck     ( IP2Bus_WrAck   ),
  .IP2Bus_RdAck     ( IP2Bus_RdAck   ),
  .IP2Bus_WrError   ( IP2Bus_WrError ),
  .IP2Bus_RdError   ( IP2Bus_RdError )
 );


endmodule
