-- file counterNb.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
	generic (N: positive := 6);
	port (clock, clear, enable: in std_logic;
		  Q: out std_logic_vector(N-1 downto 0));
end counter;

architecture behavior of counter is
	signal Q_int: std_logic_vector(N-1 downto 0);
	
begin
	count: process (clock, clear)
	begin
		if (clock'event and clock = '1') then 
			if (clear = '0') then
				Q_int <= (others => '0');
			elsif (enable = '1') then
				Q_int <= std_logic_vector(unsigned(Q_int) + 1);
			end if;
		end if;
	end process;
	
	Q <= Q_int;
	
end behavior;
			