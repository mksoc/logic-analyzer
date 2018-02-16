LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY counter_x_bits IS
	GENERIC ( N_BITS : INTEGER := 18 );
	PORT ( EN_CNT, RST_N, CLK  : IN STD_LOGIC;
			 CLR_SYNC            : IN STD_LOGIC;
          CNT                 : OUT STD_LOGIC_VECTOR(N_BITS-1 DOWNTO 0) );
END counter_x_bits;

ARCHITECTURE behaviour OF counter_x_bits IS

	SIGNAL cnt_tmp : UNSIGNED(N_BITS-1 DOWNTO 0);

BEGIN

	PROCESS ( CLK, RST_N )
	BEGIN
		IF ( RST_N = '0' ) THEN
			cnt_tmp <= (OTHERS => '0');
		ELSE
			IF ( CLK'EVENT AND CLK = '1' ) THEN
				IF ( CLR_SYNC = '0' ) THEN
					IF ( EN_CNT = '1' ) THEN
						cnt_tmp <= cnt_tmp + 1;
					END IF;
				ELSE
					cnt_tmp <= (OTHERS => '0');
				END IF;
			END IF;
		END IF;
	END PROCESS;

	CNT <= STD_LOGIC_VECTOR(cnt_tmp);
	
END ARCHITECTURE;