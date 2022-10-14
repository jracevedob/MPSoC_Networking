#------------------------------------------------------------------------------
#  (c) Copyright 2013 Xilinx, Inc. All rights reserved.
#
#  This file contains confidential and proprietary information
#  of Xilinx, Inc. and is protected under U.S. and
#  international copyright and other intellectual property
#  laws.
#
#  DISCLAIMER
#  This disclaimer is not a license and does not grant any
#  rights to the materials distributed herewith. Except as
#  otherwise provided in a valid license issued to you by
#  Xilinx, and to the maximum extent permitted by applicable
#  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
#  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
#  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
#  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
#  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
#  (2) Xilinx shall not be liable (whether in contract or tort,
#  including negligence, or under any other theory of
#  liability) for any loss or damage of any kind or nature
#  related to, arising under or in connection with these
#  materials, including for any direct, or any indirect,
#  special, incidental, or consequential loss or damage
#  (including loss of data, profits, goodwill, or any type of
#  loss or damage suffered as a result of any action brought
#  by a third party) even if such damage or loss was
#  reasonably foreseeable or Xilinx had been advised of the
#  possibility of the same.
#
#  CRITICAL APPLICATIONS
#  Xilinx products are not designed or intended to be fail-
#  safe, or for use in any application requiring fail-safe
#  performance, such as life-support or safety devices or
#  systems, Class III medical devices, nuclear facilities,
#  applications related to the deployment of airbags, or any
#  other applications that could lead to death, personal
#  injury, or severe property or environmental damage
#  (individually and collectively, "Critical
#  Applications"). Customer assumes the sole risk and
#  liability of any use of Xilinx products in Critical
#  Applications, subject only to applicable laws and
#  regulations governing limitations on product liability.
#
#  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
#  PART OF THIS FILE AT ALL TIMES.
#------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# CMAC core-level XDC file
# ----------------------------------------------------------------------------------------------------------------------


create_clock -period 6.400 [get_ports gt_refclk_p]
set_false_path -to [get_pins -leaf -of_objects [get_cells -hier *cdc_to* -filter {is_sequential}] -filter {NAME=~*core_cdc*/*/D}]

set_false_path -from [get_pins -of [get_cells -hierarchical -filter {NAME =~*i_pif_registers/*/reset_flop_out_reg*}] -filter REF_PIN_NAME=~C]
set_false_path -from [get_pins -of [get_cells -hierarchical -filter {NAME =~*i_pif_registers/*/reset_pipe_out_reg*}] -filter REF_PIN_NAME=~C]

set_false_path -to [get_pins -leaf -of_objects [get_cells -hier *cdc_to* -filter {is_sequential}] -filter {NAME=~*_d2_cdc_to_reg*/D}]
set_false_path -to [get_cells -hierarchical -filter {NAME =~ */i_*_axi_if_top/*/i_*_syncer/*meta_reg*}]
set_false_path -to [get_cells -hierarchical -filter {NAME =~ */i_*_sync*/*stretch_reg*}]
set_false_path -to [get_cells -hierarchical -filter {NAME =~ */i_*_SYNC*/*stretch_reg*}]



## Following constraints are needed only for 2013.4 (or till the RX/TX helper clock modules is outside GT). When these modules move into GTWiz, these constraints will come from GT.xdc

set_false_path -to [get_cells -hierarchical -filter {NAME =~ *bit_synchronizer*inst/i_in_meta_reg}]
set_false_path -to [get_cells -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_*_reg}]
set_false_path -to [get_cells -hierarchical -filter {NAME =~ *core_gtwiz_userclk_tx_inst_*/*gtwiz_userclk_tx_active_out_reg}]
set_false_path -to [get_cells -hierarchical -filter {NAME =~ *core_gtwiz_userclk_rx_inst_*/*gtwiz_userclk_rx_active_out_reg}]

set_property DONT_TOUCH true [get_cells -hierarchical -filter {NAME =~ */*if_top/*/*axi_araddr_reg*}]
set_property DONT_TOUCH true [get_cells -hierarchical -filter {NAME =~ */*if_top/*/*axi_rdata_reg*}]
