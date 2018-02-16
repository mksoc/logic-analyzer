library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uartTB is
end entity;

architecture behavior of uartTB is
	--clock period
	constant T: time := 20 ns;
	--bit period
	constant T_bit: time := 8681 ns;
	
	--component declaration
	component uart is 
		port (clock, reset_n: in std_logic;
			  loopback: in std_logic;
			  tx_start: in std_logic;
			  data_in: in std_logic_vector(7 downto 0);
			  rx: in std_logic;
			  data_available: buffer std_logic;
			  tx_rdy, frame_error: out std_logic;
			  data_out: buffer std_logic_vector(7 downto 0);
			  tx: out std_logic);
	end component;
	
	--signal declarations
	signal clock, reset_n, tx_from_outside, tx_start_int: std_logic;	
	signal data_in_int: std_logic_vector(7 downto 0) := X"00";

	--tx simulation procedure
	procedure tx_byte
		(char: in std_logic_vector(7 downto 0);
		 signal tx: out std_logic) is
	begin
		--send start bit
		tx <= '0';
		wait for T_bit;
		
		--send char
		for i in 0 to 7 loop
			tx <= char(i);
			wait for T_bit;
		end loop;
		
		--send stop bit
		tx <= '1';
		wait for T_bit;
	end procedure;
	
begin

	-- clk gen
	clk_gen : process
	begin
		clock <= '1';
		wait for T/2;
		clock <= '0';
		wait for T/2;
	end process;
	
	-- rst_n gen
	reset_n <= '1', '0' after 15 ns, '1' after 36 ns;
	
	-- tx data
	data_in_int <= X"51" after 17*T, X"00" after 25*T;
	tx_start_int <= '0', '1' after 18*T, '0' after 19*T;
	
	--tx process
	tx_sim: process
	begin
		tx_from_outside <= '1';
		wait for 74 ns;
		tx_byte(X"52", tx_from_outside); --send R
		tx_byte(X"53", tx_from_outside); --send S
		wait; --wait forever
	end process;	
	
	DUT : uart port map	(clock => clock, 
						 reset_n => reset_n,
						 loopback => '0',
						  tx_start => tx_start_int,
						  data_in => data_in_int,
						  rx => tx_from_outside);

end architecture;