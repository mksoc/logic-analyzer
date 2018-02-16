-- file ascii_decCU.vhd

library ieee;
use ieee.std_logic_1164.all;

entity ascii_decCU is 
	port (clock, reset_n: in std_logic;
		  data_val: in std_logic;
		  freq, trig, start, read, num09, numAF: in std_logic; --status from DP
		  num_sel, msb_ld, msb_clr, lsb_ld, lsb_clr: out std_logic; -- commands to DP
		  command: out std_logic_vector(1 downto 0);
		  ok, fail: out std_logic);
end ascii_decCU;

architecture behavior of ascii_decCU is
	type state_type is (RESET, F1, F2, F3, T1, T2_09, T2_AF, T_WAIT, T3_09, T3_AF, T4, S, R1, R2, FAIL_STATE);
	signal present_state, next_state: state_type;
	
begin 
	next_state_gen: process (present_state, freq, trig, start, read, num09, numAF, data_val)
	begin
		case present_state is
			when RESET =>	if (data_val = '0') then
								next_state <= RESET;
							else
								if (freq = '1') then
									next_state <= F1;
								elsif (trig = '1') then
									next_state <= T1;
								elsif (start = '1') then
									next_state <= S;
								elsif (read = '1') then
									next_state <= R1;
								else 
									next_state <= FAIL_STATE;
								end if;
							end if;
						
			when F1 =>	if (data_val = '0') then
							next_state <= F1;
						else
							if (num09 = '1') then
								next_state <= F2;
							else 
								next_state <= FAIL_STATE;
							end if;
						end if;
						
			when F2 => next_state <= F3;
			
			when F3 => next_state <= RESET;
			
			when T1 =>	if (data_val = '0') then 
							next_state <= T1;
						else 
							if (num09 = '1') then
								next_state <= T2_09;
							elsif (numAF = '1') then	
								next_state <= T2_AF;
							else
								next_state <= FAIL_STATE;
							end if;
						end if;
						
			when T2_09 =>	next_state <= T_WAIT;
							
			when T2_AF =>	next_state <= T_WAIT;
							
			when T_WAIT =>	if (data_val = '0') then
								next_state <= T_WAIT;
							else 
								if (num09 = '1') then
									next_state <= T3_09;
								elsif (numAF <= '1') then
									next_state <= T3_AF;
								else 
									next_state <= FAIL_STATE;
								end if;
							end if; 
							
			when T3_09 => next_state <= T4;
			
			when T3_AF => next_state <= T4;
			
			when T4 => next_state <= RESET;
			
			when S => next_state <= RESET;
			
			when R1 => next_state <= R2;
			
			when R2 => next_state <= RESET;
			
			when FAIL_STATE => next_state <= RESET;
			
			when others => next_state <= RESET;
		end case;
	end process;
	
	state_update: process (clock, reset_n)
	begin
		if (reset_n = '0') then
			present_state <= RESET;
		else
			if (clock'event and clock = '1') then
				present_state <= next_state;
			end if;
		end if;
	end process;
	
	output_gen: process (present_state)
	begin 
		--defaults
		num_sel <= '0';
		msb_clr <= '1';
		msb_ld <= '0';
		lsb_clr <= '1';
		lsb_ld <= '0';
		command <= "00";
		ok <= '0';
		fail <= '0';
		
		case present_state is
			when RESET =>	msb_clr <= '0';
							lsb_clr <= '0';
						
			when F1 => num_sel <= '0';
						
			when F2 =>	num_sel <= '0';
						lsb_ld <= '1';
						command <= "00";
						ok <= '1';
			
			when F3 =>	command <= "00";
						ok <= '1';
			
			when T1 => 
						
			when T2_09 =>	num_sel <= '0';
							msb_ld <= '1';
							
			when T2_AF =>	num_sel <= '1';
							msb_ld <= '1';
							
			when T_WAIT =>
							
			when T3_09 =>	num_sel <= '0';
							lsb_ld <= '1';
							command <= "01";
							ok <= '1';
			
			when T3_AF =>	num_sel <= '1';
							lsb_ld <= '1';
							command <= "01";
							ok <= '1';
			
			when T4 =>	command <= "01";
						ok <= '1';
			
			when S =>	command <= "10";
						ok <= '1';
			
			when R1 =>	command <= "11";
						ok <= '1';
						
			when R2 =>	command <= "11";
						ok <= '1';
			
			when FAIL_STATE => fail <= '1';
		end case;
	end process;
end behavior;