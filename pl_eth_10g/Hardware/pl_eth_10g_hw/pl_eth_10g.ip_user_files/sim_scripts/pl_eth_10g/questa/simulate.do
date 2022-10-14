onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib pl_eth_10g_opt

do {wave.do}

view wave
view structure
view signals

do {pl_eth_10g.udo}

run -all

quit -force
