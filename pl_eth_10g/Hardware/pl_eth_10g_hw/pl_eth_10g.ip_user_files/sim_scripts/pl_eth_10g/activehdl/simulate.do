onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+pl_eth_10g -L xilinx_vip -L xpm -L lib_pkg_v1_0_2 -L fifo_generator_v13_2_5 -L lib_fifo_v1_0_14 -L lib_srl_fifo_v1_0_2 -L lib_cdc_v1_0_2 -L axi_datamover_v5_1_22 -L axi_sg_v4_1_13 -L axi_dma_v7_1_21 -L xil_defaultlib -L util_vector_logic_v2_0_1 -L axis_infrastructure_v1_1_0 -L axis_data_fifo_v2_0_2 -L xlconstant_v1_1_6 -L gtwizard_ultrascale_v1_7_7 -L xxv_ethernet_v3_1_0 -L generic_baseblocks_v2_1_0 -L axi_infrastructure_v1_1_0 -L axi_register_slice_v2_1_20 -L axi_data_fifo_v2_1_19 -L axi_crossbar_v2_1_21 -L axi_protocol_converter_v2_1_20 -L axi_clock_converter_v2_1_19 -L blk_mem_gen_v8_4_4 -L axi_dwidth_converter_v2_1_20 -L axi_mmu_v2_1_18 -L proc_sys_reset_v5_0_13 -L xlconcat_v2_1_3 -L axi_vip_v1_1_6 -L zynq_ultra_ps_e_vip_v1_0_6 -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.pl_eth_10g xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {pl_eth_10g.udo}

run -all

endsim

quit -force
