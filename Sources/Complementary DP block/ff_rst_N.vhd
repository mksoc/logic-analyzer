LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ff_rst_N IS
	PORT ( EN_FF, CLK, RST_N : IN STD_LOGIC;
	       D                 : IN STD_LOGIC;
	       Q                 : OUT STD_LOGIC );
END ff_rst_N;

ARCHITECTURE behaviour OF ff_rst_N IS
BEGIN

	PROCESS ( CLK, RST_N )
	BEGIN
		IF ( RST_N = '0' ) THEN
			Q <= '0';
		ELSE
			IF ( CLK'EVENT AND CLK = '1' ) THEN
				IF ( EN_FF = '1' ) THEN
					Q <= D;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
END ARCHITECTURE;