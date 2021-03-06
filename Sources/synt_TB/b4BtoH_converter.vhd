LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY b4BtoH_converter IS
	PORT ( BIN_N     : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			 SEG       : OUT STD_LOGIC_VECTOR(0 TO 6) );
END b4BtoH_converter;

ARCHITECTURE Behavior OF b4BtoH_converter IS
BEGIN
	SEG <= "0000001" WHEN BIN_N = "0000" ELSE
			 "1001111" WHEN BIN_N = "0001" ELSE
			 "0010010" WHEN BIN_N = "0010" ELSE
			 "0000110" WHEN BIN_N = "0011" ELSE
			 "1001100" WHEN BIN_N = "0100" ELSE
			 "0100100" WHEN BIN_N = "0101" ELSE
			 "0100000" WHEN BIN_N = "0110" ELSE
			 "0001111" WHEN BIN_N = "0111" ELSE
			 "0000000" WHEN BIN_N = "1000" ELSE
			 "0000100" WHEN BIN_N = "1001" ELSE
			 "0001000" WHEN BIN_N = "1010" ELSE
			 "1100000" WHEN BIN_N = "1011" ELSE
			 "0110001" WHEN BIN_N = "1100" ELSE
			 "1000010" WHEN BIN_N = "1101" ELSE
			 "0110000" WHEN BIN_N = "1110" ELSE
			 "0111000" WHEN BIN_N = "1111";
END Behavior;