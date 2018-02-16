LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY boardSignals_gen IS
	PORT ( clk_50MHz, 
	       rst_n : OUT STD_LOGIC );
END ENTITY;

ARCHITECTURE behaviour OF boardSignals_gen IS
BEGIN
	
	-- clk gen process
	clk_50Mhz_process : PROCESS
	BEGIN
		clk_50MHz <= '1';
		WAIT FOR 10 ns;
		clk_50MHz <= '0';
		WAIT FOR 10 ns;
	END PROCESS;
	
	-- rst_n gen process
	rst_n <=  '1', '0' AFTER 3 ns, '1' AFTER 30 ns;
	
END ARCHITECTURE;