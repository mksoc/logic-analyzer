-- file receiverCU.vhd

library ieee;
use ieee.std_logic_1164.all;

entity receiverCU is
	port (clock, reset_n: in std_logic;
		  cnt8x_tc, cnt1x_tc, start_bit_detected, stop_bit: in std_logic; --status from DP
		  sr_sh, sr_ld, sr_clr, cnt8x_en, cnt8x_clr, cnt1x_en, cnt1x_clr, reg_ld, reg_clr: out std_logic; --controls to DP
		  data_available, frame_error: out std_logic); --status to outside
end receiverCU;

architecture behavior of receiverCU is
	type state_type is (RESET, CLK_RECOVER, SAMPLE, CHECK_START, WAIT_B0, WRITE_B0, WAIT_B1, WRITE_B1, WAIT_B2, WRITE_B2,
						WAIT_B3, WRITE_B3, WAIT_B4, WRITE_B4, WAIT_B5, WRITE_B5, WAIT_B6, WRITE_B6, WAIT_B7, WRITE_B7,
						WAIT_STOP_BIT, WRITE_STOP_BIT, DONE, DONE_ERR);
	signal present_state, next_state: state_type;
	
begin 
	next_state_gen: process (present_state, cnt8x_tc, cnt1x_tc, start_bit_detected, stop_bit)
	begin
		case present_state is
			when RESET => next_state <= CLK_RECOVER;
			
			when CLK_RECOVER =>	if (cnt8x_tc = '0') then 
									next_state <= CLK_RECOVER;
								else 
									next_state <= SAMPLE;
								end if;
								
			when SAMPLE => next_state <= CHECK_START;
			
			when CHECK_START =>	if (start_bit_detected = '0') then
									next_state <= CLK_RECOVER;
								else 
									next_state <= WAIT_B0;
								end if;
								
			when WAIT_B0 =>	if (cnt1x_tc = '0') then
								next_state <= WAIT_B0;
							else
								next_state <= WRITE_B0;
							end if;
							
			when WRITE_B0 => next_state <= WAIT_B1;
							
			when WAIT_B1 =>	if (cnt1x_tc = '0') then
								next_state <= WAIT_B1;
							else
								next_state <= WRITE_B1;
							end if;
							
			when WRITE_B1 => next_state <= WAIT_B2;
			
			when WAIT_B2 =>	if (cnt1x_tc = '0') then
								next_state <= WAIT_B2;
							else
								next_state <= WRITE_B2;
							end if;
							
			when WRITE_B2 => next_state <= WAIT_B3;
			
			when WAIT_B3 =>	if (cnt1x_tc = '0') then
								next_state <= WAIT_B3;
							else
								next_state <= WRITE_B3;
							end if;
							
			when WRITE_B3 => next_state <= WAIT_B4;
			
			when WAIT_B4 =>	if (cnt1x_tc = '0') then
								next_state <= WAIT_B4;
							else
								next_state <= WRITE_B4;
							end if;
							
			when WRITE_B4 => next_state <= WAIT_B5;
			
			when WAIT_B5 =>	if (cnt1x_tc = '0') then
								next_state <= WAIT_B5;
							else
								next_state <= WRITE_B5;
							end if;
							
			when WRITE_B5 => next_state <= WAIT_B6;
			
			when WAIT_B6 =>	if (cnt1x_tc = '0') then
								next_state <= WAIT_B6;
							else
								next_state <= WRITE_B6;
							end if;
							
			when WRITE_B6 => next_state <= WAIT_B7;
			
			when WAIT_B7 =>	if (cnt1x_tc = '0') then
								next_state <= WAIT_B7;
							else
								next_state <= WRITE_B7;
							end if;
							
			when WRITE_B7 => next_state <= WAIT_STOP_BIT;
			
			when WAIT_STOP_BIT =>	if (cnt1x_tc = '0') then
										next_state <= WAIT_STOP_BIT;
									else
										next_state <= WRITE_STOP_BIT;
									end if;
							
			when WRITE_STOP_BIT =>	if (stop_bit = '1') then
										next_state <= DONE;
									else 
										next_state <= DONE_ERR;
									end if;
									
			when DONE => next_state <= CLK_RECOVER;
			
			when DONE_ERR => next_state <= CLK_RECOVER;
			
			when others => next_state <= RESET;
		end case;
	end process;
	
	state_update: process (reset_n, clock)
	begin
		if (reset_n = '0') then
			present_state <= RESET;
		elsif (clock'event and clock = '1') then
			present_state <= next_state;
		end if;
	end process;
	
	output_gen: process (present_state)
	begin 
		--default values
		sr_sh <= '0';
		sr_ld <= '0';
		sr_clr <= '1';
		cnt8x_en <= '0';
		cnt8x_clr <= '1';
		cnt1x_en <= '0';
		cnt1x_clr <= '1';
		reg_ld <= '0';
		reg_clr <= '1';
		data_available <= '0';
		frame_error <= '0';
		
		case present_state is
			when RESET =>	sr_ld <= '1';
							cnt8x_clr <= '0';
							cnt1x_clr <= '0';
							reg_clr <= '0';
							cnt8x_en <= '1';
			
			when CLK_RECOVER =>	cnt8x_en <= '1';
								
			when SAMPLE => 	sr_sh <= '1';
							cnt8x_clr <= '0';
							cnt8x_en <= '1';
			
			when CHECK_START =>	cnt8x_en <= '1';
								cnt1x_clr <= '0';
								cnt1x_en <= '1';
								
			when WAIT_B0 =>	cnt1x_en <= '1';
							
			when WRITE_B0 =>	sr_sh <= '1';
								cnt1x_clr <= '0';
								cnt1x_en <= '1';
							
			when WAIT_B1 =>	cnt1x_en <= '1';
							
			when WRITE_B1 =>	sr_sh <= '1';
								cnt1x_clr <= '0';
								cnt1x_en <= '1';
			
			when WAIT_B2 =>	cnt1x_en <= '1';
							
			when WRITE_B2 =>	sr_sh <= '1';
								cnt1x_clr <= '0';
								cnt1x_en <= '1';
			
			when WAIT_B3 =>	cnt1x_en <= '1';
							
			when WRITE_B3 =>	sr_sh <= '1';
								cnt1x_clr <= '0';
								cnt1x_en <= '1';
			
			when WAIT_B4 =>	cnt1x_en <= '1';
							
			when WRITE_B4 =>	sr_sh <= '1';
								cnt1x_clr <= '0';
								cnt1x_en <= '1';
			
			when WAIT_B5 =>	cnt1x_en <= '1';
							
			when WRITE_B5 =>	sr_sh <= '1';
								cnt1x_clr <= '0';
								cnt1x_en <= '1';
			
			when WAIT_B6 =>	cnt1x_en <= '1';
							
			when WRITE_B6 =>	sr_sh <= '1';
								cnt1x_clr <= '0';
								cnt1x_en <= '1';
			
			when WAIT_B7 =>	cnt1x_en <= '1';
							
			when WRITE_B7 =>	sr_sh <= '1';
								cnt1x_clr <= '0';
								cnt1x_en <= '1';
			
			when WAIT_STOP_BIT => cnt1x_en <= '1';
							
			when WRITE_STOP_BIT =>	sr_sh <= '1';
									cnt1x_clr <= '0';
									cnt1x_en <= '1';
									
			when DONE => 	reg_ld <= '1';
							data_available <= '1';
							sr_ld <= '1';
							cnt8x_clr <= '0';
							cnt8x_en <= '1';
			
			when DONE_ERR =>	reg_ld <= '1';
								data_available <= '1';
								frame_error <= '1';
								sr_ld <= '1';
								cnt8x_clr <= '0';
								cnt8x_en <= '1';
		end case;
	end process;
end behavior;