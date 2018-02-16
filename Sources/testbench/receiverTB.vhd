library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity receiverTB is
end entity;

architecture behavior of receiverTB is

	component receiver is
		port (clock, reset_n              : in std_logic;
			  rx                          : in std_logic;
			  data_available, frame_error : out std_logic;
			  data_out                    : out std_logic_vector(7 downto 0));
	end component;

	signal clock, reset_n, rx : std_logic;	
	signal data_available, frame_error : std_logic;
	signal data_out : std_logic_vector(7 downto 0);

begin

	-- clk gen
	clk_gen : process
	begin
		clock <= '0';
		wait for 10 ns;
		clock <= '1';
		wait for 10 ns;
	end process;
	
	-- rst_n gen
	reset_n <= '1', '0' after 15 ns, '1' after 36 ns;
	
	-- tx_simulation
	tx_sim : process
	 variable tmp_tx : integer := 0;
	 variable delay_tx : integer := 0;
	 variable byte: std_logic_vector(7 downto 0) := "01010101";
	begin
		case tmp_tx is
			when 3 => rx <= '0'; -- bit 0
			when 4 => rx <= byte(0);
			when 5 => rx <= byte(1);
			when 6 => rx <= byte(2);
			when 7 => rx <= byte(3);
			when 8 => rx <= byte(4);
			when 9 => rx <= byte(5);
			when 10 => rx <= byte(6);
			when 11 => rx <= byte(7);
			when 12 => rx <= '1'; -- bit 9
			when others => rx <= '1';
		end case;
		tmp_tx := tmp_tx + 1;
		if(delay_tx = 0) then
			wait for 5 ns;
			delay_tx := 1;
		else
			wait for 8681 ns;
		end if;
	end process;	
	
	DUT : receiver PORT MAP (clock => clock,
							 reset_n => reset_n,
							 rx => rx,
							 data_available => data_available,
							 frame_error => frame_error,
							 data_out => data_out);

end architecture;