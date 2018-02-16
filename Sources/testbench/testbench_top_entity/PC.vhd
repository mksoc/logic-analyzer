LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY PC IS
	GENERIC ( no_communication_time : time := 230 ns; 
	          time_interval_between_two_commands : time := 100 us);
	PORT ( tx_PC : OUT STD_LOGIC;
	       rx_PC : IN STD_LOGIC );
END ENTITY;

ARCHITECTURE behaviour OF PC IS

	CONSTANT T_bit: TIME := 8681 ns;
	
	--tx simulation procedure
	PROCEDURE tx_byte
		(char: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 SIGNAL tx: OUT STD_LOGIC) IS
	BEGIN
		--send start bit
		tx <= '0';
		WAIT FOR T_bit;
		
		--send char
		FOR i IN 0 TO 7 LOOP
			tx <= char(i);
			WAIT FOR T_bit;
		END LOOP;
		
		--send stop bit
		tx <= '1';
		WAIT FOR T_bit;
	END PROCEDURE;

BEGIN

	-- CHAR | VHDL HEX ASCII
	-- F | X"46"
	-- T | X"54"
	-- S | X"53"
	-- R | X"52"

	--tx process
	tx_sim: PROCESS -- default tx -> F30, T0C, S, R -> freq 10 MHz, trig "00001100", S, R
	BEGIN
		tx_PC <= '1';
		WAIT FOR no_communication_time;
		tx_byte(X"46", tx_PC); --send F
		tx_byte(X"31", tx_PC); --send 1
		WAIT FOR time_interval_between_two_commands;
		tx_byte(X"54", tx_PC); --send T
		tx_byte(X"30", tx_PC); --send 0
		tx_byte(X"31", tx_PC); --send 1
	   WAIT FOR time_interval_between_two_commands; 
	   tx_byte(X"53", tx_PC); --send S
		WAIT FOR time_interval_between_two_commands; 
		tx_byte(X"52", tx_PC); --send R
		WAIT FOR 7 ms;
		WAIT FOR time_interval_between_two_commands; 
		tx_byte(X"52", tx_PC); --send R
		WAIT;--wait forever
	END PROCESS;

END ARCHITECTURE;