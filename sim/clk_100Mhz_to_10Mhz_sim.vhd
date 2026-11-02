-- Modelo solo para simulación del IP Clocking Wizard de Xilinx (clk_100Mhz_to_10Mhz).
-- Deja pasar el reloj tal cual: en simulación la frecuencia no importa,
-- y así el testbench se puede ejecutar con GHDL sin las librerías de Vivado.
library IEEE;
use IEEE.std_logic_1164.all;

entity clk_100Mhz_to_10Mhz is
	port(
		clk_in1  : in  std_logic;
		clk_out1 : out std_logic
	);
end clk_100Mhz_to_10Mhz;

architecture sim of clk_100Mhz_to_10Mhz is
begin
	clk_out1 <= clk_in1;
end sim;
