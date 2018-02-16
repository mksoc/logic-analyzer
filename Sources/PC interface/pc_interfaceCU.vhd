--file pc_interfaceCU.vhd

library ieee;
use ieee.std_logic_1164.all;

entity pc_interfaceCU is
	port (clock, reset_n: in std_logic;
		  --input control signals
		  data_in_val: in std_logic;
		  command_ctrl: in std_logic_vector(1 downto 0);
		  end_of_buffer, uart_data_rdy, uart_frame_error, tx_rdy, 
			ascii_ok, ascii_fail: in std_logic; --status from DP
		  --output control signals
		  mux_in_sel: out std_logic_vector(2 downto 0);
		  mux_char_sel: out std_logic_vector(1 downto 0);
		  reg_sample_clr_n, reg_sample_ld, reg_glitch_clr_n, reg_glitch_ld, reg_char_clr_n, reg_char_ld, sendLF, sendCR,
			uart_reset_n, tx_start, ascii_reset_n, ascii_data_val: out std_logic; --controls to DP
		  read_req: out std_logic);
end pc_interfaceCU;

architecture behavior of pc_interfaceCU is
	--state definition
	type state_type is (RESET, IDLE, DECODE, RESULT, FAIL, OK_DONE, TX_STATUS, WAIT_DATA, STORE_DATA, 
							SEL_CH0, TX_CH0, SEL_CH1, TX_CH1, SEL_CH2, TX_CH2, SEL_CH3, TX_CH3, SEL_CH4, TX_CH4, 
							SEL_CH5, TX_CH5, SEL_CH6, TX_CH6, SEL_CH7, TX_CH7, SEL_CR, TX_CR, SEL_LF, TX_LF);
	signal present_state, next_state: state_type;
	
begin 
	next_state_gen: process (present_state, data_in_val, end_of_buffer, uart_data_rdy, uart_frame_error, tx_rdy, 
			ascii_ok, ascii_fail, command_ctrl)
	begin
		case present_state is
			when RESET =>	next_state <= IDLE;
			
			when IDLE =>	if (uart_data_rdy = '0') then
								next_state <= IDLE;
							else
								if (uart_frame_error = '1') then
									next_state <= FAIL;
								else 
									next_state <= DECODE;
								end if;
							end if;
								
			when DECODE =>	next_state <= RESULT;
							
			when RESULT =>	if (ascii_fail = '1') then
								next_state <= FAIL;
							elsif (ascii_ok = '1') then
								if (command_ctrl = "11") then
									next_state <= WAIT_DATA;
								else 
									next_state <= OK_DONE;
								end if;
							else
								next_state <= IDLE;
							end if;
							
			when FAIL =>	if (tx_rdy = '0') then
								next_state <= FAIL;
							else
								next_state <= TX_STATUS;
							end if;		
			
			when OK_DONE =>	if (tx_rdy = '0') then
								next_state <= OK_DONE;
							else 
								next_state <= TX_STATUS;
							end if;
			
			when TX_STATUS =>	if (uart_data_rdy = '0') then
									next_state <= IDLE;
								else
									if (uart_frame_error = '1') then
										next_state <= FAIL;
									else 
										next_state <= DECODE;
									end if;
								end if;

			when WAIT_DATA =>	if (end_of_buffer = '0') then			
									if (data_in_val = '0') then
										next_state <= WAIT_DATA;
									else 
										next_state <= STORE_DATA;
									end if;
								else
									next_state <= OK_DONE;
								end if;
								
							
			when STORE_DATA =>	next_state <= SEL_CH0;
			
			when SEL_CH0 =>	if (tx_rdy = '0') then
								next_state <= SEL_CH0;
							else 
								next_state <= TX_CH0;
							end if;
							
			when TX_CH0 =>	next_state <= SEL_CH1;
			
			when SEL_CH1 =>	if (tx_rdy = '0') then
								next_state <= SEL_CH1;
							else 
								next_state <= TX_CH1;
							end if;
							
			when TX_CH1 =>	next_state <= SEL_CH2;
			
			when SEL_CH2 =>	if (tx_rdy = '0') then
								next_state <= SEL_CH2;
							else 
								next_state <= TX_CH2;
							end if;
							
			when TX_CH2 =>	next_state <= SEL_CH3;
			
			when SEL_CH3 =>	if (tx_rdy = '0') then
								next_state <= SEL_CH3;
							else 
								next_state <= TX_CH3;
							end if;
							
			when TX_CH3 =>	next_state <= SEL_CH4;
			
			when SEL_CH4 =>	if (tx_rdy = '0') then
								next_state <= SEL_CH4;
							else 
								next_state <= TX_CH4;
							end if;
							
			when TX_CH4 =>	next_state <= SEL_CH5;
			
			when SEL_CH5 =>	if (tx_rdy = '0') then
								next_state <= SEL_CH5;
							else 
								next_state <= TX_CH5;
							end if;
							
			when TX_CH5 =>	next_state <= SEL_CH6;
			
			when SEL_CH6 =>	if (tx_rdy = '0') then
								next_state <= SEL_CH6;
							else 
								next_state <= TX_CH6;
							end if;
							
			when TX_CH6 =>	next_state <= SEL_CH7;
			
			when SEL_CH7 =>	if (tx_rdy = '0') then
								next_state <= SEL_CH7;
							else 
								next_state <= TX_CH7;
							end if;
							
			when TX_CH7 =>	next_state <= SEL_CR;
			
			when SEL_CR =>	if (tx_rdy = '0') then
								next_state <= SEL_CR;
							else 
								next_state <= TX_CR;
							end if;
							
			when TX_CR =>	next_state <= SEL_LF;
			
			when SEL_LF =>	if (tx_rdy = '0') then
								next_state <= SEL_LF;
							else 
								next_state <= TX_LF;
							end if;
							
			when TX_LF =>	next_state <= WAIT_DATA; --start over
			
			when others =>	next_state <= RESET;
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
		reg_sample_clr_n <= '1';
		reg_sample_ld <= '0';
		reg_glitch_clr_n <= '1';
		reg_glitch_ld <= '0';
		reg_char_clr_n <= '1';
		reg_char_ld <= '0';
		mux_in_sel <= "000";
		sendLF <= '0';
		sendCR <= '0';
		mux_char_sel <= "00";
		uart_reset_n <= '1';
		tx_start <= '0';
		ascii_reset_n <= '1';
		ascii_data_val <= '0';
		read_req <= '0';
		
		case present_state is 
			when RESET =>	reg_sample_clr_n <= '0';
							reg_sample_clr_n <= '0';
							reg_char_clr_n <= '0';
							uart_reset_n <= '0';
							ascii_reset_n <= '0';
			
			when IDLE =>	
							
			when DECODE =>	ascii_data_val <= '1';

			when RESULT => 
							
			when FAIL =>	mux_char_sel <= "10";
							reg_char_ld <= '1';
			
			when OK_DONE =>	mux_char_sel <= "01";
							reg_char_ld <= '1';
			
			when TX_STATUS =>	tx_start <= '1';

			when WAIT_DATA =>	read_req <= '1';
							
			when STORE_DATA =>	reg_sample_ld <= '1';
								reg_glitch_ld <= '1';
			
			when SEL_CH0 =>	mux_char_sel <= "00";
							mux_in_sel <= "000";
							reg_char_ld <= '1';
							
			when TX_CH0 =>	tx_start <= '1';
			
			when SEL_CH1 =>	mux_char_sel <= "00";
							mux_in_sel <= "001";
							reg_char_ld <= '1';
							
			when TX_CH1 =>	tx_start <= '1';
			
			when SEL_CH2 =>	mux_char_sel <= "00";
							mux_in_sel <= "010";
							reg_char_ld <= '1';
							
			when TX_CH2 =>	tx_start <= '1';
			
			when SEL_CH3 =>	mux_char_sel <= "00";
							mux_in_sel <= "011";
							reg_char_ld <= '1';
							
			when TX_CH3 =>	tx_start <= '1';
			
			when SEL_CH4 =>	mux_char_sel <= "00";
							mux_in_sel <= "100";
							reg_char_ld <= '1';
							
			when TX_CH4 =>	tx_start <= '1';
			
			when SEL_CH5 =>	mux_char_sel <= "00";
							mux_in_sel <= "101";
							reg_char_ld <= '1';
							
			when TX_CH5 =>	tx_start <= '1';
			
			when SEL_CH6 =>	mux_char_sel <= "00";
							mux_in_sel <= "110";
							reg_char_ld <= '1';
							
			when TX_CH6 =>	tx_start <= '1';
			
			when SEL_CH7 =>	mux_char_sel <= "00";
							mux_in_sel <= "111";
							reg_char_ld <= '1';
							
			when TX_CH7 =>	tx_start <= '1';
			
			when SEL_CR =>	mux_char_sel <= "00";
							sendCR <= '1';
							reg_char_ld <= '1';
							
			when TX_CR =>	tx_start <= '1';
			
			when SEL_LF =>	mux_char_sel <= "00";
							sendLF <= '1';
							reg_char_ld <= '1';
							
			when TX_LF =>	tx_start <= '1';
		end case;
	end process;
end behavior;