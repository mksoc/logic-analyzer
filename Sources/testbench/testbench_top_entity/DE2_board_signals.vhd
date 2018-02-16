LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY DE2_board_signals IS
	PORT ( clk_50MHz, 
	       rst_n : OUT STD_LOGIC;
         leds : IN STD_LOGIC_VECTOR(8 DOWNTO 0) );		   
END ENTITY;

ARCHITECTURE behaviour OF DE2_board_signals IS
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
	rst_n <= '0', '1' AFTER 30 ns;
	
END ARCHITECTURE;