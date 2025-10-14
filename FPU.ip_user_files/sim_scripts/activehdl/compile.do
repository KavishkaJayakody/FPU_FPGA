transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib activehdl/xil_defaultlib

vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xil_defaultlib  -sv2k12 -l xil_defaultlib \
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

