LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY mux_NbitData_MbitSel IS
	GENERIC ( NbitData : INTEGER := 12;
	          MbitSel : INTEGER := 4 );
	PORT ( dataIn : IN STD_LOGIC_VECTOR ( NbitData*(2**MbitSel)-1 DOWNTO 0 );
          dataOut : OUT STD_LOGIC_VECTOR ( NbitData-1 DOWNTO 0 );
			 sel : IN STD_LOGIC_VECTOR ( MbitSel-1 DOWNTO 0 ) );
END mux_NbitData_MbitSel;

ARCHITECTURE behaviour OF mux_NbitData_MbitSel IS
BEGIN

	mux_process : PROCESS (dataIn, sel)
	VARIABLE sel_var : INTEGER := TO_INTEGER(UNSIGNED(sel));
	BEGIN
		sel_var := TO_INTEGER(UNSIGNED(sel));
		dataOut <= dataIn(NbitData*(sel_var+1)-1 DOWNTO NbitData*(sel_var)); 
	END PROCESS;
	
END ARCHITECTURE;