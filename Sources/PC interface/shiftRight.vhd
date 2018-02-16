-- file shiftRight.vhd
-- right shift register
-- async clear, load, shift
library ieee;
use ieee.std_logic_1164.all;

entity shiftRight is
	generic (N: positive := 10);
	port (parallel_in: in std_logic_vector(N-1 downto 0);
		  serial_in: in std_logic;
		  clock, clear, load, shift: in std_logic;
		  parallel_out: buffer std_Logic_vector(N-1 downto 0));
end shiftRight;

architecture behavior of shiftRight is
begin
	shiftProc: process (clock, clear) is
	begin
		if (clear = '0') then
			parallel_out <= (others => '0');
		else
			if (clock'event and clock = '1') then
				if (load = '1') then
					parallel_out <= parallel_in;
				elsif (shift = '1') then
					for i in 0 to N-2 loop
						parallel_out(i) <= parallel_out(i+1);
					end loop; 
					parallel_out(N-1) <= serial_in;
				end if;
			end if;
		end if;
	end process;
end behavior;