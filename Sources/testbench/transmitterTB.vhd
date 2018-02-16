--file transmitterTB.vhd

library ieee;
use ieee.std_logic_1164.all;

entity transmitterTB is
end entity;

architecture behavior of transmitterTB is
	constant T: time := 20 ns;
	
	--component declarations
	component transmitter is
		port (data_in: in std_logic_vector(7 downto 0);
			  clock, reset_n: in std_logic;
			  tx_start: in std_logic;
			  tx: out std_logic;
			  tx_rdy: out std_logic);
	end component;
	
	--signal declarations
	signal clock, reset_n, tx_start: std_logic;
	signal data_in: std_logic_vector(7 downto 0);
	
begin
	--component instantiation
	tx: transmitter port map (data_in => data_in,
							  clock => clock,
							  reset_n => reset_n,
							  tx_start => tx_start);

	clock_gen : process
	begin
		clock <= '1';
		wait for T/2;
		clock <= '0';
		wait for T/2;
	end process;
	
	reset_n <= '1', '0' after 15 ns, '1' after 36 ns;
	
	tx_start <= '0', '1' after 4*T + 1 ns, '0' after 5*T + 1 ns;
	--tx_start <= '1';
	data_in <= (others => '0'), "01010101" after 5*T + 1 ns, (others => '0') after 6*T + 1 ns;
	--data_in <= "01010101";
end behavior;