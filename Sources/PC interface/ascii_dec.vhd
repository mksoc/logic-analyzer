-- file ascii_dec.vhd

library ieee;
use ieee.std_logic_1164.all;

entity ascii_dec is
	port (clock, reset_n: in std_logic;
		  data_in: in std_logic_vector(7 downto 0);
		  data_val: in std_logic;
		  command: out std_logic_vector(1 downto 0);
		  param: out std_logic_vector(7 downto 0);
		  ok, fail: out std_logic);
end ascii_dec;

architecture structure of ascii_dec is
	--component declarations
	component ascii_decDP is
		port (data_in: in std_logic_vector(7 downto 0);
			  clock: in std_logic;
			  num_sel, msb_ld, msb_clr, lsb_ld, lsb_clr: in std_logic; -- commands from FSM
			  freq, trig, start, read, num09, numAF: out std_logic; --status to FSM
			  param: out std_logic_vector(7 downto 0));
	end component;
	
	component ascii_decCU is 
		port (clock, reset_n: in std_logic;
			  data_val: in std_logic;
			  freq, trig, start, read, num09, numAF: in std_logic; --status from DP
			  num_sel, msb_ld, msb_clr, lsb_ld, lsb_clr: out std_logic; -- commands to DP
			  command: out std_logic_vector(1 downto 0);
			  ok, fail: out std_logic);
	end component;
	
	--signal declarations
	signal num_sel_int, msb_ld_int, msb_clr_int, lsb_ld_int, lsb_clr_int,
		freq_int, trig_int, start_int, read_int, num09_int, numAF_int: std_logic;
	
begin 
	--component instantiations
	DP: ascii_decDP port map (data_in => data_in,
							  clock => clock,
							  num_sel => num_sel_int,
							  msb_ld => msb_ld_int,
							  msb_clr => msb_clr_int,
							  lsb_ld => lsb_ld_int,
							  lsb_clr => lsb_clr_int,
							  freq => freq_int,
							  trig => trig_int,
							  start => start_int,
							  read => read_int,
							  num09 => num09_int,
							  numAF => numAF_int,
							  param => param);
							  
	CU: ascii_decCU port map (clock => clock,
							  reset_n => reset_n,
							  data_val => data_val,
							  freq => freq_int,
							  trig => trig_int,
							  start => start_int,
							  read => read_int,
							  num09 => num09_int,
							  numAF => numAF_int,
							  num_sel => num_sel_int,
							  msb_ld => msb_ld_int,
							  msb_clr => msb_clr_int,
							  lsb_ld => lsb_ld_int,
							  lsb_clr => lsb_clr_int,
							  command => command,
							  ok => ok,
							  fail => fail);
end structure;