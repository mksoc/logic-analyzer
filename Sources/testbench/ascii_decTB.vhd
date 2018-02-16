-- file ascii_decTB.vhd

library ieee;
use ieee.std_logic_1164.all;

entity ascii_decTB is
end ascii_decTB;

architecture behavior of ascii_decTB is
	--clock period
	constant T: time := 20 ns;

	--component declaration
	component ascii_dec is
		port (clock, reset_n: in std_logic;
			  data_in: in std_logic_vector(7 downto 0);
			  data_val: in std_logic;
			  command: out std_logic_vector(1 downto 0);
			  param: out std_logic_vector(7 downto 0);
			  ok, fail: out std_logic);
	end component;
	
	--signal declarations
	signal clock, reset_n, data_val: std_logic := '0';
	signal data_in: std_logic_vector(7 downto 0) := "00000000";
	
begin
	--component instantiation
	ascii_dec0: ascii_dec port map (clock => clock,
									reset_n => reset_n,
									data_in => data_in,
									data_val => data_val);

	clock_gen: process
	begin
		clock <= '1';
		wait for T/2;
		clock <= '0';
		wait for T/2;
	end process;
	
	reset_n <= '0', '1' after 15 ns;
	
	signal_gen: process (clock)
		variable clock_count: integer := 0;
	begin
		if (clock'event and clock = '1') then
			case clock_count is
				when 2 => data_in <= "01010010"; --send R
				when 3 => data_val <= '1';
				when 6 => data_in <= X"71"; -- a caso
				when 7 => data_val <= '1';
				when 10 => data_in <= "01010100"; --send T
				when 11 => data_val <= '1';
				when 15 => data_in <= "01000001"; --send A
				when 16 => data_val <= '1';
				when 23 => data_in <= "00110000"; --send 0
				when 24 => data_val <= '1';
				when 28 => data_in <= X"46"; -- send F
				when 29 => data_val <= '1';
				when 32 => data_in <= X"34"; -- send 4
				when 33 => data_val <= '1';
				when 38 => data_in <= X"53"; -- send S
				when 39 => data_val <= '1';
				when others => data_val <= '0';
			end case;
			
			clock_count := clock_count + 1;
		end if;
	end process;
end behavior;
	
	