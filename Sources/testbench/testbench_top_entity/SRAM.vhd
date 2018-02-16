LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY SRAM IS
	GENERIC ( D_BITS    : INTEGER := 16;
             ADDR_BITS : INTEGER := 18 );
	PORT ( DATA_IN_OUT                         : INOUT STD_LOGIC_VECTOR(D_BITS-1 DOWNTO 0);
	       ADDR                                : IN STD_LOGIC_VECTOR(ADDR_BITS-1 DOWNTO 0);
		    CE_N, OE_N, WE_N, UB_N, LB_N        : IN STD_LOGIC);
END SRAM;

ARCHITECTURE behaviour OF SRAM IS

	TYPE SRAM_ARRAY IS ARRAY(0 TO 2**ADDR_BITS-1) OF STD_LOGIC_VECTOR(D_BITS-1 DOWNTO 0);
	SIGNAL SRAM_0  : SRAM_ARRAY;

BEGIN

	PROCESS ( DATA_IN_OUT, ADDR, CE_N, OE_N, WE_N, UB_N, LB_N )
	BEGIN
		IF (CE_N = '0') THEN -- if SRAM is selected
			IF (OE_N = '1') THEN -- if output is disabled
				DATA_IN_OUT <= (OTHERS => 'Z'); -- data line is driven by something else external
				IF (WE_N = '0') THEN -- if is write is enabled
					SRAM_0( TO_INTEGER(UNSIGNED((ADDR))) ) <= DATA_IN_OUT; -- write data from external
				END IF;
			ELSE -- if output is enabled
				IF (WE_N = '1') THEN -- if write is disabled
					DATA_IN_OUT <= SRAM_0( TO_INTEGER(UNSIGNED((ADDR))) ); -- read data from SRAM
				END IF;
			END IF;
		ELSE
			DATA_IN_OUT <= (OTHERS => 'Z');
		END IF;
	END PROCESS;

END ARCHITECTURE; 