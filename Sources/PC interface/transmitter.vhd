-- file transmitterTOP.vhd

library ieee;
use ieee.std_logic_1164.all;

entity transmitter is
	port (data_in: in std_logic_vector(7 downto 0);
		  clock, reset_n: in std_logic;
		  tx_start: in std_logic;
		  tx: out std_logic;
		  tx_rdy: out std_logic);
end transmitter;

architecture structure of transmitter is
	--component declarations
	component transmitterDP is
		port (data_in: in std_logic_vector(7 downto 0); --parallel in
			  clock: std_logic; 
			  sr_ld, sr_sh, sr_clr, mux_sel, cnt_clr, cnt_en: in std_logic; --controls from FSM
			  stop_next, cnt_tc: out std_logic; --status to FSM
			  tx: out std_logic); --serial out
	end component;
	
	component transmitterCU is
		port (clock, reset_n: in std_logic;
			  start: in std_logic; --controls from outside
			  stop_next, cnt_tc: in std_logic; --status from DP
			  sr_ld, sr_sh, sr_clr, mux_sel, cnt_clr, cnt_en: out std_logic; --controls to DP
			  tx_rdy: out std_logic); --status to outside 
	end component;
	
	--signal declarations
	signal sr_ld, sr_sh, sr_clr, mux_sel, stop_next, cnt_clr, cnt_en, cnt_tc: std_logic;
	
begin
	--component instantiations
	DP: transmitterDP port map (data_in => data_in,
								clock => clock,
								sr_ld => sr_ld,
								sr_sh => sr_sh,
								sr_clr => sr_clr,
								mux_sel => mux_sel,
								cnt_clr => cnt_clr,
								cnt_en => cnt_en,
								stop_next => stop_next,
								cnt_tc => cnt_tc,
								tx => tx);
								
	CU: transmitterCU port map (clock => clock,
								reset_n => reset_n,
								start => tx_start,
								stop_next => stop_next,
								cnt_tc => cnt_tc,
								sr_ld => sr_ld,
								sr_sh => sr_sh,
								sr_clr => sr_clr,
								mux_sel => mux_sel,
								cnt_clr => cnt_clr,
								cnt_en => cnt_en,
								tx_rdy => tx_rdy);
end structure;