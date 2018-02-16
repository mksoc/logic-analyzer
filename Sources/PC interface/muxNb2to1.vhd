-- file muxNb2to1.vhd
library ieee;
use ieee.std_logic_1164.all;

entity muxNb2to1 is
	generic (N: positive := 1);
	port (A, B: in std_logic_vector(N-1 downto 0);
		  sel: in std_logic;
		  M: out std_logic_vector(N-1 downto 0));
end entity muxNb2to1;

architecture behavior of muxNb2to1 is
begin
	M <= B when sel = '1' else
		 A;
end architecture behavior; 