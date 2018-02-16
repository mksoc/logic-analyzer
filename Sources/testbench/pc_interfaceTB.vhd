--file pc_interfaceTB.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_interfaceTB is
end pc_interfaceTB;

architecture behavior of pc_interfaceTB is
	--clock period
	constant T: time := 20 ns;
	--bit period
	constant T_bit: time := 8681 ns;
	
	--component declaration
	component pc_interface is
		port (clock, reset_n: in std_logic;
			  --input data
			  data_in: in std_logic_vector(15 downto 0);
			  rx: in std_logic;
			  --input controls
			  data_in_val: in std_logic;
			  end_of_buffer: in std_logic;
			  --output data
			  command: out std_logic_vector(1 downto 0);
			  param: out std_logic_vector(7 downto 0);
			  tx: out std_logic;
			  --output controls
			  read_req: out std_logic;
			  command_val: out std_logic);
	end component;
	
	--signal declarations
	signal clock, reset_n, tx_from_outside, read_req: std_logic;
	signal data_in_val: std_logic := '0';
	signal end_of_buffer: std_logic := '0';
	signal data_in: std_logic_vector(15 downto 0) := X"0000";
	
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
	--clock generation process
	clock_gen: process
	begin
		clock <= '1';
		wait for T/2;
		clock <= '0';
		wait for T/2;
	end process;
	
	--reset gen
	reset_n <= '0', '1' after 15 ns;
	
	--component instantiation
	DUT: pc_interface port map (clock => clock,
								reset_n => reset_n,
								data_in => data_in,
								rx => tx_from_outside,
								data_in_val => data_in_val,
								end_of_buffer => end_of_buffer,
								read_req => read_req);
								
	--tx process
	tx_sim: process
	begin
		tx_from_outside <= '1';
		wait for 74 ns;
		tx_byte(X"54", tx_from_outside); --send T
		tx_byte(X"30", tx_from_outside); --send 0
		tx_byte(X"31", tx_from_outside); --send 1
		wait for 67 ns;
		tx_byte(X"52", tx_from_outside); --send R
		wait; --wait forever
	end process;
	
	--data transfer process
	read_sim: process (clock)
		variable data_count: integer := 0;
	begin
		if (clock'event and clock = '1') then
			if (read_req = '1') then
				case data_count is
					when 0 =>	data_in <= X"FF00"; --all 1, no glitch
								data_in_val <= '1';
								end_of_buffer <= '0';
					when 1 =>	data_in <= X"FFAA"; --all 1, alternate glitch
								data_in_val <= '1';
								end_of_buffer <= '0';
					when 2 =>	data_in <= X"00AA";
								data_in_val <= '1';
								end_of_buffer <= '1';
					when others =>	end_of_buffer <= '0';
									data_in_val <= '0';
				end case;
				data_count := data_count + 1;
			end if;
		end if;
	end process;			
	
end behavior;