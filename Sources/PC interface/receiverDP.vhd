-- file receiverDP.vhd

library ieee;
use ieee.std_logic_1164.all;

entity receiverDP is 
	port (clock: in std_logic;
		  rx: in std_logic;
		  sr_sh, sr_ld, sr_clr, cnt8x_en, cnt8x_clr, cnt1x_en, cnt1x_clr, reg_ld, reg_clr: in std_logic; --controls from FSM
		  cnt8x_tc, cnt1x_tc, start_bit_detected, stop_bit: out std_logic; --status to FSM
		  data_out: out std_logic_vector(7 downto 0));
end receiverDP;

architecture structure of receiverDP is
	--component declarations
	component reg is
		generic (N: positive := 8);
		port (R: in std_logic_vector(N-1 downto 0);
			  clock, clear, load: in std_logic;
			  Q: out std_logic_vector(N-1 downto 0));
	end component;
	
	component shiftRight is
		generic (N: positive := 10);
		port (parallel_in: in std_logic_vector(N-1 downto 0);
			  serial_in: in std_logic;
			  clock, clear, load, shift: in std_logic;
			  parallel_out: buffer std_logic_vector(N-1 downto 0));
	end component;
	
	component counter is 
		generic (N: positive := 6);
		port (clock, clear, enable: in std_logic;
			  Q: out std_logic_vector(N-1 downto 0));
	end component;
	
	--signal declarations
	signal parallel_out_int: std_logic_vector(9 downto 0);
	signal count8x_int: std_logic_vector(5 downto 0);
	signal count1x_int: std_logic_vector(8 downto 0);
	
begin
	--component instantiation
	shift0: shiftRight port map (parallel_in => (others => '1'),
								 serial_in => rx,
								 clock => clock,
								 clear => sr_clr,
								 load => sr_ld,
								 shift => sr_sh,
								 parallel_out => parallel_out_int);
								 
	count8x: counter port map (clock => clock,
							   clear => cnt8x_clr,
							   enable => cnt8x_en,
							   Q => count8x_int);
							   
	count1x: counter generic map (N => 9)
					 port map (clock => clock,
							   clear => cnt1x_clr,
							   enable => cnt1x_en,
							   Q => count1x_int);
							  
	reg0: reg port map (R => parallel_out_int(8 downto 1),
						clock => clock,
						clear => reg_clr,
						load => reg_ld,
						Q => data_out);
						
	cnt8x_tc <= '1' when count8x_int = "110100" else '0';
	cnt1x_tc <= '1' when count1x_int = "110110000" else '0';
	start_bit_detected <= '1' when parallel_out_int = "0000111111" else '0';
	stop_bit <= rx;
	
end structure;
					