LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY signals_generator_GLITCH_ONBOARD IS
	GENERIC ( n_signals : INTEGER := 2 );
	
	PORT ( clk,nRESET : in std_logic ;
	signals_to_be_analyzed : OUT STD_LOGIC_VECTOR(n_signals-1 downto 0) );
END ENTITY;

ARCHITECTURE beh OF signals_generator_GLITCH_ONBOARD IS



BEGIN


P0: PROCESS (CLK,nRESET )
VARIABLE CNT, tmp : INTEGER := 0;

BEGIN

	if (nreset = '0') then
		tmp := 0;
	else
		if(clk'event and clk = '1') then
			cnt := cnt + 1;
			if (cnt = 250) then
				tmp := tmp + 1;
				cnt := 0;
		   end if;
		end if;
	
	
	if(cnt = 125) then
		tmp := tmp - 1;
	elsif (cnt = 126) then
		tmp := tmp + 1;
   end if;
	end if;
	
	signals_to_be_analyzed <= std_logic_vector(to_unsigned(tmp, signals_to_be_analyzed'length));
	
end process;



end beh;
