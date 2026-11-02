-- Testbench autoverificable para las variantes J y MV.
-- El programa de la BlockRam calcula 7 * 3 mediante sumas sucesivas y deja
-- el resultado en x12 (a2), que el procesador expone por la señal A2.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_riscv is
end tb_riscv;

architecture sim of tb_riscv is

	constant CLK_PERIOD : time := 10 ns;
	constant ESPERADO   : natural := 21;

	signal clk            : std_logic := '0';
	signal rst            : std_logic := '1';
	signal modo           : std_logic := '0';  -- 0 = ejecución continua
	signal siguiente      : std_logic := '0';
	signal display        : std_logic_vector(6 downto 0);
	signal display_enable : std_logic_vector(3 downto 0);
	signal fin            : boolean := false;

begin

	uut : entity work.RISCVMulticiclo
		port map(
			clk            => clk,
			rst            => rst,
			display        => display,
			display_enable => display_enable,
			modo           => modo,
			siguiente      => siguiente
		);

	clk <= not clk after CLK_PERIOD / 2 when not fin;

	estimulos : process
		alias A2 is << signal .tb_riscv.uut.A2 : std_logic_vector(31 downto 0) >>;
	begin
		wait for 5 * CLK_PERIOD;
		rst <= '0';
		wait for 2000 * CLK_PERIOD;

		assert to_integer(unsigned(A2)) = ESPERADO
			report "FALLO: x12 = " & integer'image(to_integer(unsigned(A2))) &
			       ", esperado " & integer'image(ESPERADO)
			severity failure;

		report "OK: x12 = " & integer'image(to_integer(unsigned(A2)));
		fin <= true;
		wait;
	end process;

end sim;
