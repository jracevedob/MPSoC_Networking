# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param power.BramSDPPropagationFix 1
set_param synth.incrementalSynthesisCache ./.Xil/Vivado-53963-supersonic/incrSyn
set_param power.enableUnconnectedCarry8PinPower 1
set_param power.enableCarry8RouteBelPower 1
set_param power.enableLutRouteBelPower 1
set_msg_config -id {Synth 8-256} -limit 10000
set_msg_config -id {Synth 8-638} -limit 10000
create_project -in_memory -part xczu9eg-ffvb1156-2-e

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.cache/wt [current_project]
set_property parent.project_path /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.xpr [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_FIFO XPM_MEMORY} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_verilog -library xil_defaultlib /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/hdl/pl_eth_10g_wrapper.v
add_files /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/pl_eth_10g.bd
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_axi_dma_0_0/pl_eth_10g_axi_dma_0_0.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_axi_dma_0_0/pl_eth_10g_axi_dma_0_0_clocks.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/ip_0/synth/pl_eth_10g_xxv_ethernet_0_0_gt_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/ip_0/synth/pl_eth_10g_xxv_ethernet_0_0_gt.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/synth/pl_eth_10g_xxv_ethernet_0_0_board.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/synth/pl_eth_10g_xxv_ethernet_0_0.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/synth/pl_eth_10g_xxv_ethernet_0_0_exceptions.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/synth/pl_eth_10g_xxv_ethernet_0_0_ooc.xdc]
set_property used_in_synthesis false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_us_0/pl_eth_10g_auto_us_0_clocks.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_us_0/pl_eth_10g_auto_us_0_clocks.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_us_0/pl_eth_10g_auto_us_0_ooc.xdc]
set_property used_in_synthesis false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_us_1/pl_eth_10g_auto_us_1_clocks.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_us_1/pl_eth_10g_auto_us_1_clocks.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_us_1/pl_eth_10g_auto_us_1_ooc.xdc]
set_property used_in_synthesis false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_cc_0/pl_eth_10g_auto_cc_0_clocks.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_cc_0/pl_eth_10g_auto_cc_0_clocks.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_cc_0/pl_eth_10g_auto_cc_0_ooc.xdc]
set_property used_in_synthesis false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_us_2/pl_eth_10g_auto_us_2_clocks.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_us_2/pl_eth_10g_auto_us_2_clocks.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_us_2/pl_eth_10g_auto_us_2_ooc.xdc]
set_property used_in_synthesis false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_cc_1/pl_eth_10g_auto_cc_1_clocks.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_cc_1/pl_eth_10g_auto_cc_1_clocks.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_cc_1/pl_eth_10g_auto_cc_1_ooc.xdc]
set_property used_in_synthesis false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_ds_0/pl_eth_10g_auto_ds_0_clocks.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_ds_0/pl_eth_10g_auto_ds_0_clocks.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_ds_0/pl_eth_10g_auto_ds_0_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_pc_0/pl_eth_10g_auto_pc_0_ooc.xdc]
set_property used_in_synthesis false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_ds_1/pl_eth_10g_auto_ds_1_clocks.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_ds_1/pl_eth_10g_auto_ds_1_clocks.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_ds_1/pl_eth_10g_auto_ds_1_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_pc_1/pl_eth_10g_auto_pc_1_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_rst_ps8_0_99M_0/pl_eth_10g_rst_ps8_0_99M_0_board.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_rst_ps8_0_99M_0/pl_eth_10g_rst_ps8_0_99M_0.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/pl_eth_10g_zynq_ultra_ps_e_0_0_ooc.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/pl_eth_10g_zynq_ultra_ps_e_0_0.xdc]
set_property used_in_implementation false [get_files -all /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/pl_eth_10g_hw/pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/pl_eth_10g_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/constraints/constraints.xdc
set_property used_in_implementation false [get_files /home/supersonic/Lab/ZCU102-Ethernet/2019.2/pl_eth_10g/Hardware/constraints/constraints.xdc]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top pl_eth_10g_wrapper -part xczu9eg-ffvb1156-2-e


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef pl_eth_10g_wrapper.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file pl_eth_10g_wrapper_utilization_synth.rpt -pb pl_eth_10g_wrapper_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]