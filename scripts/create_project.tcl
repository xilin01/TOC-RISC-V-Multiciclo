# Crea el proyecto de Vivado (2023.1) para una variante del procesador.
# Uso, desde la raíz del repositorio:
#   vivado -mode batch -source scripts/create_project.tcl -tclargs j          (solo crea el proyecto)
#   vivado -mode batch -source scripts/create_project.tcl -tclargs j bit      (y genera el bitstream)
# Variantes: j | lsw | mv. El proyecto queda en build/vivado_<variante>/.

set variante [lindex $argv 0]
if {[lsearch -exact {j lsw mv} $variante] < 0} {
    error "Uso: -tclargs <j|lsw|mv> \[bit\]"
}
set raiz [file normalize [file join [file dirname [info script]] ..]]

create_project riscv_$variante $raiz/build/vivado_$variante -part xc7a35tcpg236-1 -force

add_files [concat [glob $raiz/rtl/common/*.vhd] [glob $raiz/rtl/$variante/*.vhd]]
import_ip $raiz/ip/clk_100Mhz_to_10Mhz.xci
upgrade_ip [get_ips]

if {$variante eq "lsw"} {
    add_files -fileset constrs_1 $raiz/constraints/basys3_lsw.xdc
    set tb tb_riscv_lsw
} else {
    add_files -fileset constrs_1 $raiz/constraints/basys3.xdc
    set tb tb_riscv
}

# El testbench usa nombres externos de VHDL-2008
add_files -fileset sim_1 $raiz/sim/$tb.vhd
set_property file_type {VHDL 2008} [get_files $raiz/sim/$tb.vhd]

set_property top RISCVMulticiclo [current_fileset]
set_property top $tb [get_filesets sim_1]
update_compile_order -fileset sources_1

if {[lindex $argv 1] eq "bit"} {
    launch_runs impl_1 -to_step write_bitstream -jobs 4
    wait_on_run impl_1
    puts "Bitstream: $raiz/build/vivado_$variante/riscv_$variante.runs/impl_1/RISCVMulticiclo.bit"
}
