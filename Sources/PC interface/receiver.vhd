-- file receiver.vhd

library ieee;
use ieee.std_logic_1164.all;

entity receiver is
	port (clock, reset_n: in std_logic;
		  rx: in std_logic;
		  data_available, frame_error: out std_logic;
		  data_out: out std_logic_vector(7 downto 0));
end receiver;

architecture structure of receiver is
	--component declarations
	component receiverDP is
		port (clock: in std_logic;
			  rx: in std_logic;
			  sr_sh, sr_ld, sr_clr, cnt8x_en, cnt8x_clr, cnt1x_en, cnt1x_clr, reg_ld, reg_clr: in std_logic; --controls from FSM
			  cnt8x_tc, cnt1x_tc, start_bit_detected, stop_bit: out std_logic; --status to FSM
			  data_out: out std_logic_vector(7 downto 0));
    end component;
	
	component receiverCU is
		port (clock, reset_n: in std_logic;
			  cnt8x_tc, cnt1x_tc, start_bit_detected, stop_bit: in std_logic; --status from DP
			  sr_sh, sr_ld, sr_clr, cnt8x_en, cnt8x_clr, cnt1x_en, cnt1x_clr, reg_ld, reg_clr: out std_logic; --controls to DP
			  data_available, frame_error: out std_logic); --status to outside
	end component;
	
	--signal declarations
	signal sr_sh, sr_ld, sr_clr, cnt8x_en, cnt8x_clr, cnt1x_en, cnt1x_clr, reg_ld, reg_clr: std_logic;
	signal cnt8x_tc, cnt1x_tc, start_bit_detected, stop_bit: std_logic;
	
begin 
	--component instantiations
	DP: receiverDP port map (clock => clock,
							 rx => rx,
							 sr_sh => sr_sh,
							 sr_ld => sr_ld,
							 sr_clr => sr_clr,
							 cnt8x_en => cnt8x_en,
							 cnt8x_clr => cnt8x_clr,
							 cnt1x_en => cnt1x_en,
							 cnt1x_clr => cnt1x_clr,
							 reg_ld => reg_ld,
							 reg_clr => reg_clr,
							 cnt8x_tc => cnt8x_tc,
							 cnt1x_tc => cnt1x_tc,
							 start_bit_detected => start_bit_detected,
							 stop_bit => stop_bit,
							 data_out => data_out);
							 
	CU: receiverCU port map (clock => clock,
							 reset_n => reset_n,
							 cnt8x_tc => cnt8x_tc,
							 cnt1x_tc => cnt1x_tc,
							 start_bit_detected => start_bit_detected,
							 stop_bit => stop_bit,
							 sr_sh => sr_sh,
							 sr_ld => sr_ld,
							 sr_clr => sr_clr,
							 cnt8x_en => cnt8x_en,
							 cnt8x_clr => cnt8x_clr,
							 cnt1x_en => cnt1x_en,
							 cnt1x_clr => cnt1x_clr,
							 reg_ld => reg_ld,
							 reg_clr => reg_clr,
							 data_available => data_available,
							 frame_error => frame_error);
end structure;