LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY signals_generator IS
	GENERIC ( n_signals : INTEGER := 8 );
	PORT ( signals_to_be_analyzed : OUT STD_LOGIC_VECTOR(n_signals-1 DOWNTO 0) );
END ENTITY;

ARCHITECTURE behaviour OF signals_generator IS

	SIGNAL clk : STD_LOGIC;

BEGIN

	-- 2 MHz clk generator async from 50MHz board clk
	clk_process : PROCESS
	VARIABLE delay : INTEGER := 0;
	BEGIN
		IF (delay = 0) THEN -- 13 ns of delay
			clk <= '1';
			delay := 1;
			WAIT FOR 13 ns;
		ELSE
			clk <= '1';
			WAIT FOR 250 ns;
			clk <= '0';
			WAIT FOR 250 ns;
		END IF;
	END PROCESS;

	-- counter with "n_signals" bits at 2*f_clk
	counter_simulation : PROCESS ( clk )
		VARIABLE cnt_var : INTEGER := 0;
	BEGIN
		signals_to_be_analyzed <= STD_LOGIC_VECTOR(TO_UNSIGNED(cnt_var, signals_to_be_analyzed'LENGTH));
		cnt_var := cnt_var + 1;
		IF (cnt_var = 2**n_signals) THEN -- reset at TC+1 (cnt update after assignment, so "cnt" can reach TC+1)
			cnt_var := 0;
		END IF;
	END PROCESS;

END ARCHITECTURE;