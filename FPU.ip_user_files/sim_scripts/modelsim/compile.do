vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu  -sv \
"../../../FPU.srcs/sources_1/new/add_sub.sv" \
"../../../FPU.srcs/sources_1/new/align_exp.sv" \
"../../../FPU.srcs/sources_1/new/control_unit.sv" \
"../../../FPU.srcs/sources_1/new/fpu.sv" \
"../../../FPU.srcs/sources_1/new/normalize.sv" \
"../../../FPU.srcs/sources_1/new/pack.sv" \
"../../../FPU.srcs/sources_1/new/unpack.sv" \
"../../../FPU.srcs/sim_1/new/synchronus_addsub_tb.sv" \


vlog -work xil_defaultlib \
"glbl.v"

