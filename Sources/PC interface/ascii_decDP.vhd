-- file ascii_decDP.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ascii_decDP is
	port (data_in: in std_logic_vector(7 downto 0);
		  clock: in std_logic;
		  num_sel, msb_ld, msb_clr, lsb_ld, lsb_clr: in std_logic; -- commands from FSM
		  freq, trig, start, read, num09, numAF: out std_logic; --status to FSM
		  param: out std_logic_vector(7 downto 0));
end ascii_decDP;

architecture structure of ascii_decDP is
	--components declarations
	component signal_dec is
		port (data_in: in std_logic_vector(7 downto 0);
			  freq, trig, start, read, num09, numAF: out std_logic);
	end component;
	
	component reg is
		generic (N: positive := 8);
		port (R: in std_logic_vector(N-1 downto 0);
			  clock, clear, load: in std_logic;
			  Q: out std_logic_vector(N-1 downto 0));
	end component;
	
	component muxNb2to1 is
		generic (N: positive := 1);
		port (A, B: in std_logic_vector(N-1 downto 0);
			  sel: in std_logic;
			  M: out std_logic_vector(N-1 downto 0));
	end component;
	
	--signal declarations
	signal hex_digit: std_logic_vector(3 downto 0);
	signal mux_out: std_logic_vector(3 downto 0);
	
begin 
	--component instantiations
	signal_dec0: signal_dec port map (data_in => data_in,
									  freq => freq,
									  trig => trig,
									  start => start,
									  read => read,
									  num09 => num09,
									  numAF => numAF);
									  
	regMSB: reg generic map (N => 4)
				port map (R => mux_out,
						  clock => clock,
						  clear => msb_clr,
						  load => msb_ld,
						  Q => param(7 downto 4));
						  
	regLSB: reg generic map (N => 4)
				port map (R => mux_out,
						  clock => clock,
						  clear => lsb_clr,
						  load => lsb_ld,
						  Q => param(3 downto 0));
						  
	mux0: muxNb2to1 generic map (N => 4)
					port map (A => data_in(3 downto 0),
							  B => hex_digit,
							  sel => num_sel,
							  M => mux_out);
							  
	--signal assignments
	hex_digit <= std_logic_vector(unsigned(data_in(3 downto 0)) + "1001");
	
end structure;