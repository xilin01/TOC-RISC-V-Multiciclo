-- Testbench autoverificable para la variante LSW.
-- El programa lee los dos operandos de los switches con la instrucción lsw
-- (nibble alto y nibble bajo) y deja su producto en x12 (a2).
-- Se prueba con dos combinaciones de switches para comprobar que se leen de verdad.
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_riscv_lsw is
end tb_riscv_lsw;

architecture sim of tb_riscv_lsw is

	constant CLK_PERIOD : time := 10 ns;

	signal clk            : std_logic := '0';
	signal rst            : std_logic := '1';
	signal modo           : std_logic := '0';  -- 0 = ejecución continua
	signal siguiente      : std_logic := '0';
	signal switches       : std_logic_vector(7 downto 0) := (others => '0');
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
			siguiente      => siguiente,
			switches       => switches
		);

	clk <= not clk after CLK_PERIOD / 2 when not fin;

	estimulos : process
		alias A2 is << signal .tb_riscv_lsw.uut.A2 : std_logic_vector(31 downto 0) >>;

		-- Pone los switches (alto, bajo), reinicia, ejecuta y comprueba x12 = alto * bajo
		procedure probar(alto, bajo : natural) is
			constant esperado : natural := alto * bajo;
		begin
			rst <= '1';
			switches <= std_logic_vector(to_unsigned(alto, 4)) & std_logic_vector(to_unsigned(bajo, 4));
			wait for 5 * CLK_PERIOD;
			rst <= '0';
			wait for 3000 * CLK_PERIOD;

			assert to_integer(unsigned(A2)) = esperado
				report "FALLO: " & integer'image(alto) & " * " & integer'image(bajo) &
				       " -> x12 = " & integer'image(to_integer(unsigned(A2))) &
				       ", esperado " & integer'image(esperado)
				severity failure;

			report "OK: " & integer'image(alto) & " * " & integer'image(bajo) &
			       " = " & integer'image(to_integer(unsigned(A2)));
		end procedure;

	begin
		probar(7, 3);
		probar(5, 10);
		fin <= true;
		wait;
	end process;

end sim;
