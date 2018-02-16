-- file signal_dec.vhd

library ieee;
use ieee.std_logic_1164.all;

entity signal_dec is
	port (data_in: in std_logic_vector(7 downto 0);
		  freq, trig, start, read, num09, numAF: out std_logic);
end signal_dec;

architecture behavior of signal_dec is
begin
	freq <= '1' when data_in = "01000110" else '0';
	trig <= '1' when data_in = "01010100" else '0';
	start <= '1' when data_in = "01010011" else '0';
	read <= '1' when data_in = "01010010" else '0';
	-- num09 = x7'x6'x5 x4 (x3' + x2'x1')
	num09 <= not(data_in(7)) and not(data_in(6)) and data_in(5) and data_in(4) and ( not(data_in(3)) or ( not(data_in(2)) and not(data_in(1)) ) );
	-- numAF = x7'x6 x5'x4'x3'(xor(x2,x1) + xor(x2,x0))
	numAF <= not(data_in(7)) and data_in(6) and not(data_in(5)) and not(data_in(4)) and not(data_in(3)) and
				( (data_in(2) xor data_in(1)) or (data_in(2) xor data_in(0)) );
end behavior;