-- file reg.vhd
-- load and async clear
library ieee;
use ieee.std_logic_1164.all;

entity reg is
    generic (N: positive := 8);
    port (R: in std_logic_vector(N-1 downto 0);
          clock, clear, load: in std_logic;
          Q: out std_logic_vector(N-1 downto 0));
end reg;

architecture behavior of reg is
begin
    process (clock, clear)
    begin
		if (clear = '0') then
			Q <= (others => '0');
		else
			if (clock'event and clock = '1') then
				if (load = '1') then
					Q <= R;
				end if;
			end if;
        end if;
    end process;
end behavior;