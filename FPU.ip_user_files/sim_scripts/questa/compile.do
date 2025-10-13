vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu  -sv \
"../../../FPU.srcs/sources_1/new/add_sub.sv" \
"../../../FPU.srcs/sources_1/new/align_exp.sv" \
"../../../FPU.srcs/sources_1/new/fpu.sv" \
"../../../FPU.srcs/sources_1/new/normalize.sv" \
"../../../FPU.srcs/sources_1/new/pack.sv" \
"../../../FPU.srcs/sources_1/new/unpack.sv" \
"../../../FPU.srcs/sim_1/new/fpu_tb.sv" \


vlog -work xil_defaultlib \
"glbl.v"

