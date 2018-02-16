-- file transmitterCU.vhd

library ieee;
use ieee.std_logic_1164.all;

entity transmitterCU is
	port (clock, reset_n: in std_logic;
	      start: in std_logic; --controls from outside
		  stop_next, cnt_tc: in std_logic; --status from DP
	      sr_ld, sr_sh, sr_clr, mux_sel, cnt_clr, cnt_en: out std_logic; --controls to DP
		  tx_rdy: out std_logic); --status to outside 
end transmitterCU;

architecture behavior of transmitterCU is
	type state_type is (RESET, IDLE, LOAD, WAIT_BR, SHIFT_START_BIT, WAIT_NEXT, SHIFT, SHIFT_STOP_BIT);
	signal present_state, next_state: state_type;
	
begin
	next_state_gen: process (present_state, start, cnt_tc, stop_next)
	begin
		case present_state is 
			when RESET => 	if (start = '1') then
								next_state <= LOAD;
							else 
								next_state <= IDLE;
							end if;
			
			when IDLE =>	if (start = '1') then
								next_state <= LOAD;
							else 
								next_state <= IDLE;
							end if;
			
			when LOAD => next_state <= WAIT_BR;
			
			when WAIT_BR =>	if (cnt_tc = '1') then
								next_state <= SHIFT_START_BIT;
							else 
								next_state <= WAIT_BR;
							end if;
							
			when SHIFT_START_BIT =>	next_state <= WAIT_NEXT;
			
			when WAIT_NEXT =>	if (cnt_tc = '0') then
									next_state <= WAIT_NEXT;
								else 
									if (stop_next = '0') then
										next_state <= SHIFT;
									else
										next_state <= SHIFT_STOP_BIT;
									end if;
								end if;
								
			when SHIFT =>	next_state <= WAIT_NEXT;
									
			when SHIFT_STOP_BIT =>	if (start = '0') then
										next_state <= IDLE;
									else 
										next_state <= WAIT_BR; -- was LOAD
									end if;
							
			when others => next_state <= RESET;
		end case;
	end process;
	
	state_update: process (clock, reset_n)
	begin 
		if (reset_n = '1') then
			if (clock'event and clock = '1') then
				present_state <= next_state;
			end if;
		else
			present_state <= RESET;
		end if;
	end process;
	
	output_gen: process (present_state)
	begin
		--defaults
		sr_ld <= '0';
		sr_sh <= '0';
		sr_clr <= '1';
		mux_sel <= '0';
		tx_rdy <= '0';
		cnt_clr <= '1';
		cnt_en <= '0';
		
		case present_state is 
			when RESET =>	sr_clr <= '0';
							cnt_clr <= '0';
							tx_rdy <= '1';
							
			when IDLE =>	tx_rdy <= '1';
			
			when LOAD =>	sr_ld <= '1';
							cnt_en <= '1';
			
			when WAIT_BR =>	mux_sel <= '1';
							cnt_en <= '1';
							
			when SHIFT_START_BIT =>	sr_sh <= '1';
									mux_sel <= '1';
									cnt_clr <= '0';
									cnt_en <= '1';
			
			when WAIT_NEXT =>	mux_sel <= '1';
								cnt_en <= '1';
								
			when SHIFT =>	sr_sh <= '1';
							mux_sel <= '1';
							cnt_clr <= '0';
							cnt_en <= '1';
			
			when SHIFT_STOP_BIT =>	sr_ld <= '1';
									mux_sel <= '1';
									cnt_clr <= '0';
									cnt_en <= '1';
									tx_rdy <= '1';

		end case; 
	end process;
end behavior;