LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY signals_generator_GLITCH IS
	GENERIC ( n_signals : INTEGER := 8 );
	PORT ( en_EXT_SIGNAL : std_logic ;
	signals_to_be_analyzed : OUT STD_LOGIC_VECTOR(n_signals-1 DOWNTO 0) );
END ENTITY;

ARCHITECTURE BHV OF signals_generator_GLITCH IS

BEGIN


EXT_SING : process
begin 
	if (en_EXT_SIGNAL = '1' ) then
wait for 10 ns;
	signals_to_be_analyzed <= "00101110" ;
   wait for 15 ns;
	signals_to_be_analyzed <= "11010010";
	wait for 5 ns ;
	
	signals_to_be_analyzed <= "01001110";
	wait for 5 ns ;
	signals_to_be_analyzed <= "11001010";
	wait for 90 ns;
	end if ;
	end process EXT_SING;

end BHV;