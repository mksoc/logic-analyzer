LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY register_rst_N IS
	GENERIC ( N_BITS : INTEGER := 18 );
	PORT ( EN_REG, CLK, RST_N  : IN STD_LOGIC;
	       D                   : IN STD_LOGIC_VECTOR(N_BITS-1 DOWNTO 0);
	       Q                   : OUT STD_LOGIC_VECTOR(N_BITS-1 DOWNTO 0) );
END register_rst_N;

ARCHITECTURE behaviour OF register_rst_N IS
BEGIN

	PROCESS ( CLK, RST_N )
	BEGIN
		IF ( RST_N = '0' ) THEN
			Q <= (OTHERS => '0');
		ELSE
			IF ( CLK'EVENT AND CLK = '1' ) THEN
				IF ( EN_REG = '1' ) THEN
					Q <= D;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
END ARCHITECTURE;