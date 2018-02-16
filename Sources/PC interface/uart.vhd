-- file uart.vhd

library ieee;
use ieee.std_logic_1164.all;

entity uart is 
	port (clock, reset_n: in std_logic;
		  loopback: in std_logic;
		  tx_start: in std_logic;
		  data_in: in std_logic_vector(7 downto 0);
		  rx: in std_logic;
		  data_available: buffer std_logic;
		  tx_rdy, frame_error: out std_logic;
		  data_out: buffer std_logic_vector(7 downto 0);
		  tx: out std_logic);
end uart;

architecture structure of uart is
	--component declarations
	component transmitter is
		port (data_in: in std_logic_vector(7 downto 0);
			  clock, reset_n: in std_logic;
			  tx_start: in std_logic;
			  tx: out std_logic;
			  tx_rdy: out std_logic);
    end component;
    
	component receiver is 
		port (clock, reset_n: in std_logic;
			  rx: in std_logic;
			  data_available, frame_error: out std_logic;
			  data_out: out std_logic_vector(7 downto 0));
	end component;
		
	--signal declarations
	signal data_in_int: std_logic_vector(7 downto 0);
	signal tx_start_int: std_logic;
	
begin
	--component instantiations
	tx0: transmitter port map (data_in => data_in_int,
							  clock => clock,
							  reset_n => reset_n,
							  tx_start => tx_start_int,
							  tx => tx,
							  tx_rdy => tx_rdy);
							   
	rx0: receiver port map (clock => clock,
						   reset_n => reset_n,
						   rx => rx,
						   data_available => data_available,
						   frame_error => frame_error,
						   data_out => data_out);
							
	--signal assignments
	data_in_int <= data_out when loopback = '1' else data_in;
	tx_start_int <= data_available when loopback = '1' else tx_start;

end structure;