-- file transmitterDP.vhd

library ieee;
use ieee.std_logic_1164.all;

entity transmitterDP is
	port (data_in: in std_logic_vector(7 downto 0); --parallel in
		  clock: std_logic; 
		  sr_ld, sr_sh, sr_clr, mux_sel, cnt_clr, cnt_en: in std_logic; --controls from FSM
		  stop_next, cnt_tc: out std_logic; --status to FSM
		  tx: out std_logic); --serial out
end transmitterDP;

architecture structure of transmitterDP is
	--component declarations
	component shiftRight is
		generic (N: positive := 10);
		port (parallel_in: in std_logic_vector(N-1 downto 0);
			  serial_in: in std_logic;
			  clock, clear, load, shift: in std_logic;
			  parallel_out: buffer std_logic_vector(N-1 downto 0));
	end component;
	
	component muxNb2to1 is
		generic (N: positive := 1);
		port (A, B: in std_logic_vector(N-1 downto 0);
			  sel: in std_logic;
			  M: out std_logic_vector(N-1 downto 0));
	end component;
	
	component counter is
		generic (N: positive := 6);
		port (clock, clear, enable: in std_logic;
			  Q: out std_logic_vector(N-1 downto 0));
	end component;
	
	--signal declarations
	signal parallel_out: std_logic_vector(9 downto 0);
	signal serial_out: std_logic;
	signal count: std_logic_vector(8 downto 0);
	signal parallel_in_int: std_logic_vector(9 downto 0);
	
begin
	--component instantiations							  
	sh: shiftRight port map (parallel_in => parallel_in_int,
				             serial_in => '0', 
							 clock => clock,
							 clear => sr_clr,
							 load => sr_ld,
							 shift => sr_sh,
							 parallel_out => parallel_out);
							 
	mux: muxNb2to1 port map (A => (others => '1'),
							 B(0) => parallel_out(0),
							 sel => mux_sel,
							 M(0) => tx);
							 
	count0: counter generic map (N => 9)
					port map (clock => clock,
							  clear => cnt_clr,
							  enable => cnt_en,
							  Q => count);
	
	stop_next <= '1' when parallel_out(9 downto 0) = "0000000001" else '0';
	cnt_tc <= '1' when count = "110110000" else '0'; -- check when = 432
	parallel_in_int <= '1' & data_in & '0';
	
end structure;