vlib work
vlib activehdl

vlib activehdl/xilinx_vip
vlib activehdl/xpm
vlib activehdl/lib_pkg_v1_0_2
vlib activehdl/fifo_generator_v13_2_5
vlib activehdl/lib_fifo_v1_0_14
vlib activehdl/lib_srl_fifo_v1_0_2
vlib activehdl/lib_cdc_v1_0_2
vlib activehdl/axi_datamover_v5_1_22
vlib activehdl/axi_sg_v4_1_13
vlib activehdl/axi_dma_v7_1_21
vlib activehdl/xil_defaultlib
vlib activehdl/util_vector_logic_v2_0_1
vlib activehdl/axis_infrastructure_v1_1_0
vlib activehdl/axis_data_fifo_v2_0_2
vlib activehdl/xlconstant_v1_1_6
vlib activehdl/gtwizard_ultrascale_v1_7_7
vlib activehdl/xxv_ethernet_v3_1_0
vlib activehdl/generic_baseblocks_v2_1_0
vlib activehdl/axi_infrastructure_v1_1_0
vlib activehdl/axi_register_slice_v2_1_20
vlib activehdl/axi_data_fifo_v2_1_19
vlib activehdl/axi_crossbar_v2_1_21
vlib activehdl/axi_protocol_converter_v2_1_20
vlib activehdl/axi_clock_converter_v2_1_19
vlib activehdl/blk_mem_gen_v8_4_4
vlib activehdl/axi_dwidth_converter_v2_1_20
vlib activehdl/axi_mmu_v2_1_18
vlib activehdl/proc_sys_reset_v5_0_13
vlib activehdl/xlconcat_v2_1_3
vlib activehdl/axi_vip_v1_1_6
vlib activehdl/zynq_ultra_ps_e_vip_v1_0_6

vmap xilinx_vip activehdl/xilinx_vip
vmap xpm activehdl/xpm
vmap lib_pkg_v1_0_2 activehdl/lib_pkg_v1_0_2
vmap fifo_generator_v13_2_5 activehdl/fifo_generator_v13_2_5
vmap lib_fifo_v1_0_14 activehdl/lib_fifo_v1_0_14
vmap lib_srl_fifo_v1_0_2 activehdl/lib_srl_fifo_v1_0_2
vmap lib_cdc_v1_0_2 activehdl/lib_cdc_v1_0_2
vmap axi_datamover_v5_1_22 activehdl/axi_datamover_v5_1_22
vmap axi_sg_v4_1_13 activehdl/axi_sg_v4_1_13
vmap axi_dma_v7_1_21 activehdl/axi_dma_v7_1_21
vmap xil_defaultlib activehdl/xil_defaultlib
vmap util_vector_logic_v2_0_1 activehdl/util_vector_logic_v2_0_1
vmap axis_infrastructure_v1_1_0 activehdl/axis_infrastructure_v1_1_0
vmap axis_data_fifo_v2_0_2 activehdl/axis_data_fifo_v2_0_2
vmap xlconstant_v1_1_6 activehdl/xlconstant_v1_1_6
vmap gtwizard_ultrascale_v1_7_7 activehdl/gtwizard_ultrascale_v1_7_7
vmap xxv_ethernet_v3_1_0 activehdl/xxv_ethernet_v3_1_0
vmap generic_baseblocks_v2_1_0 activehdl/generic_baseblocks_v2_1_0
vmap axi_infrastructure_v1_1_0 activehdl/axi_infrastructure_v1_1_0
vmap axi_register_slice_v2_1_20 activehdl/axi_register_slice_v2_1_20
vmap axi_data_fifo_v2_1_19 activehdl/axi_data_fifo_v2_1_19
vmap axi_crossbar_v2_1_21 activehdl/axi_crossbar_v2_1_21
vmap axi_protocol_converter_v2_1_20 activehdl/axi_protocol_converter_v2_1_20
vmap axi_clock_converter_v2_1_19 activehdl/axi_clock_converter_v2_1_19
vmap blk_mem_gen_v8_4_4 activehdl/blk_mem_gen_v8_4_4
vmap axi_dwidth_converter_v2_1_20 activehdl/axi_dwidth_converter_v2_1_20
vmap axi_mmu_v2_1_18 activehdl/axi_mmu_v2_1_18
vmap proc_sys_reset_v5_0_13 activehdl/proc_sys_reset_v5_0_13
vmap xlconcat_v2_1_3 activehdl/xlconcat_v2_1_3
vmap axi_vip_v1_1_6 activehdl/axi_vip_v1_1_6
vmap zynq_ultra_ps_e_vip_v1_0_6 activehdl/zynq_ultra_ps_e_vip_v1_0_6

vlog -work xilinx_vip  -sv2k12 "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work xpm  -sv2k12 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"/tools/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/tools/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"/tools/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"/tools/Xilinx/Vivado/2019.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work lib_pkg_v1_0_2 -93 \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0513/hdl/lib_pkg_v1_0_rfs.vhd" \

vlog -work fifo_generator_v13_2_5  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/276e/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_2_5 -93 \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/276e/hdl/fifo_generator_v13_2_rfs.vhd" \

vlog -work fifo_generator_v13_2_5  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/276e/hdl/fifo_generator_v13_2_rfs.v" \

vcom -work lib_fifo_v1_0_14 -93 \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/a5cb/hdl/lib_fifo_v1_0_rfs.vhd" \

vcom -work lib_srl_fifo_v1_0_2 -93 \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/51ce/hdl/lib_srl_fifo_v1_0_rfs.vhd" \

vcom -work lib_cdc_v1_0_2 -93 \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \

vcom -work axi_datamover_v5_1_22 -93 \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/1e40/hdl/axi_datamover_v5_1_vh_rfs.vhd" \

vcom -work axi_sg_v4_1_13 -93 \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/4919/hdl/axi_sg_v4_1_rfs.vhd" \

vcom -work axi_dma_v7_1_21 -93 \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec2a/hdl/axi_dma_v7_1_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_axi_dma_0_0/sim/pl_eth_10g_axi_dma_0_0.vhd" \

vlog -work util_vector_logic_v2_0_1  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/2137/hdl/util_vector_logic_v2_0_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_dma_rx_rst_0/sim/pl_eth_10g_dma_rx_rst_0.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_dma_tx_rst_0/sim/pl_eth_10g_dma_tx_rst_0.v" \

vlog -work axis_infrastructure_v1_1_0  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl/axis_infrastructure_v1_1_vl_rfs.v" \

vlog -work axis_data_fifo_v2_0_2  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/3341/hdl/axis_data_fifo_v2_0_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_rx_data_fifo_0/sim/pl_eth_10g_rx_data_fifo_0.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_rx_rst_n_0/sim/pl_eth_10g_rx_rst_n_0.v" \

vlog -work xlconstant_v1_1_6  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/34f7/hdl/xlconstant_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_sfp_tx_dis_0/sim/pl_eth_10g_sfp_tx_dis_0.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_tx_data_fifo_0/sim/pl_eth_10g_tx_data_fifo_0.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_tx_rst_n_0/sim/pl_eth_10g_tx_rst_n_0.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xlconstant_0_0/sim/pl_eth_10g_xlconstant_0_0.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xlconstant_1_0/sim/pl_eth_10g_xlconstant_1_0.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xlconstant_2_0/sim/pl_eth_10g_xlconstant_2_0.v" \

vlog -work gtwizard_ultrascale_v1_7_7  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_bit_sync.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gte4_drp_arb.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gthe4_delay_powergood.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gtye4_delay_powergood.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gthe3_cpll_cal.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gthe3_cal_freqcnt.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gthe4_cpll_cal.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gthe4_cpll_cal_rx.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gthe4_cpll_cal_tx.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gthe4_cal_freqcnt.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gtye4_cpll_cal.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gtye4_cpll_cal_rx.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gtye4_cpll_cal_tx.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gtye4_cal_freqcnt.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gtwiz_buffbypass_rx.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gtwiz_buffbypass_tx.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gtwiz_reset.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gtwiz_userclk_rx.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gtwiz_userclk_tx.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gtwiz_userdata_rx.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_gtwiz_userdata_tx.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_reset_sync.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b860/hdl/gtwizard_ultrascale_v1_7_reset_inv_sync.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/ip_0/sim/gtwizard_ultrascale_v1_7_gthe4_channel.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/ip_0/sim/pl_eth_10g_xxv_ethernet_0_0_gt_gthe4_channel_wrapper.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/ip_0/sim/pl_eth_10g_xxv_ethernet_0_0_gt_gtwizard_gthe4.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/ip_0/sim/pl_eth_10g_xxv_ethernet_0_0_gt_gtwizard_top.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/ip_0/sim/pl_eth_10g_xxv_ethernet_0_0_gt.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/xxv_ethernet_v3_1_0/pl_eth_10g_xxv_ethernet_0_0_wrapper.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/xxv_ethernet_v3_1_0/pl_eth_10g_xxv_ethernet_0_0_top.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/xxv_ethernet_v3_1_0/pl_eth_10g_xxv_ethernet_0_0_axi4_lite_if_wrapper.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/pl_eth_10g_xxv_ethernet_0_0/gtwizard_ultrascale_v1_7_gthe4_common.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/pl_eth_10g_xxv_ethernet_0_0/pl_eth_10g_xxv_ethernet_0_0_gt_gthe4_common_wrapper.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/xxv_ethernet_v3_1_0/pl_eth_10g_xxv_ethernet_0_0_common_wrapper.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/xxv_ethernet_v3_1_0/pl_eth_10g_xxv_ethernet_0_0_ultrascale_rx_userclk.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/xxv_ethernet_v3_1_0/pl_eth_10g_xxv_ethernet_0_0_ultrascale_tx_userclk.v" \

vlog -work xxv_ethernet_v3_1_0  -sv2k12 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/4caa/hdl/xxv_ethernet_v3_1_vl_rfs.sv" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/pl_eth_10g_xxv_ethernet_0_0.v" \

vlog -work generic_baseblocks_v2_1_0  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \

vlog -work axi_infrastructure_v1_1_0  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_register_slice_v2_1_20  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/72d4/hdl/axi_register_slice_v2_1_vl_rfs.v" \

vlog -work axi_data_fifo_v2_1_19  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/60de/hdl/axi_data_fifo_v2_1_vl_rfs.v" \

vlog -work axi_crossbar_v2_1_21  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/6b0d/hdl/axi_crossbar_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xbar_0/sim/pl_eth_10g_xbar_0.v" \

vlog -work axi_protocol_converter_v2_1_20  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/c4a6/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \

vlog -work axi_clock_converter_v2_1_19  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/9e81/hdl/axi_clock_converter_v2_1_vl_rfs.v" \

vlog -work blk_mem_gen_v8_4_4  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/2985/simulation/blk_mem_gen_v8_4.v" \

vlog -work axi_dwidth_converter_v2_1_20  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/d394/hdl/axi_dwidth_converter_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_us_0/sim/pl_eth_10g_auto_us_0.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_us_1/sim/pl_eth_10g_auto_us_1.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_cc_0/sim/pl_eth_10g_auto_cc_0.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_us_2/sim/pl_eth_10g_auto_us_2.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_cc_1/sim/pl_eth_10g_auto_cc_1.v" \

vlog -work axi_mmu_v2_1_18  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/cba0/hdl/axi_mmu_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_s00_mmu_0/sim/pl_eth_10g_s00_mmu_0.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_s01_mmu_0/sim/pl_eth_10g_s01_mmu_0.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_s02_mmu_0/sim/pl_eth_10g_s02_mmu_0.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xbar_1/sim/pl_eth_10g_xbar_1.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_ds_0/sim/pl_eth_10g_auto_ds_0.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_pc_0/sim/pl_eth_10g_auto_pc_0.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_ds_1/sim/pl_eth_10g_auto_ds_1.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_auto_pc_1/sim/pl_eth_10g_auto_pc_1.v" \

vcom -work proc_sys_reset_v5_0_13 -93 \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_rst_ps8_0_99M_0/sim/pl_eth_10g_rst_ps8_0_99M_0.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_util_vector_logic_0_0/sim/pl_eth_10g_util_vector_logic_0_0.v" \

vlog -work xlconcat_v2_1_3  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/442e/hdl/xlconcat_v2_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xlconcat_0_0/sim/pl_eth_10g_xlconcat_0_0.v" \

vlog -work axi_vip_v1_1_6  -sv2k12 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/dc12/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work zynq_ultra_ps_e_vip_v1_0_6  -sv2k12 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl/zynq_ultra_ps_e_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/8713/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_xxv_ethernet_0_0/header_files" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/ec67/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ipshared/0eaf/hdl" "+incdir+../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim_tlm" "+incdir+/tools/Xilinx/Vivado/2019.2/data/xilinx_vip/include" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/ip/pl_eth_10g_zynq_ultra_ps_e_0_0/sim/pl_eth_10g_zynq_ultra_ps_e_0_0_vip_wrapper.v" \
"../../../../pl_eth_10g.srcs/sources_1/bd/pl_eth_10g/sim/pl_eth_10g.v" \

vlog -work xil_defaultlib \
"glbl.v"

