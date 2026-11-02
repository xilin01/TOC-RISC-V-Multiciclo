#!/usr/bin/env bash
# Simula una variante del procesador con GHDL y comprueba el resultado.
# Uso: sim/run_sim.sh <j|lsw|mv>
# Genera la forma de onda en build/<variante>/<testbench>.ghw (se abre con GTKWave).
set -euo pipefail

variante=${1:?"uso: $0 <j|lsw|mv>"}
cd "$(dirname "$0")/.."

tb=tb_riscv
[ "$variante" = lsw ] && tb=tb_riscv_lsw

work=build/$variante
mkdir -p "$work"
opts=(--std=08 -fsynopsys --workdir="$work")

ghdl -a "${opts[@]}" rtl/common/*.vhd "rtl/$variante"/*.vhd sim/clk_100Mhz_to_10Mhz_sim.vhd "sim/$tb.vhd"
ghdl --elab-run "${opts[@]}" "$tb" --assert-level=error --wave="$work/$tb.ghw"
