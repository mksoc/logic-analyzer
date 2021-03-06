LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY complementary_DP_block IS
	PORT ( -- in from board
	       clk,
			 -- in from main_FSM
	       en_cnt_sample, 
			 rst_n_cnt_sample, 
			 clear_at_TC_cnt_sample,
			 en_reg_change_freq, 
			 rst_n_reg_change_freq,
			 en_ff_wr_req_delay, 
			 rst_n_ff_wr_req_delay, 
			 en_ff_mem_r, 
			 rst_n_ff_mem_r : IN STD_LOGIC;
			 -- out to main_FSM
			 sample : BUFFER STD_LOGIC;
			 r_saved,
			 wr_req : OUT STD_LOGIC;
			 -- in from PC_int
			 param : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			 cmd : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			 -- in from SAMPLER
			 C,
			 G : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			 -- out to TRIG_GEN
		    cond_value,
			 comp_value : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			 -- out to MEM_INT
			 C_G_data_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) );
END complementary_DP_block;

ARCHITECTURE complementary_DP_block_structure OF complementary_DP_block IS
	
	COMPONENT ff_rst_N IS
		PORT ( EN_FF, CLK, RST_N : IN STD_LOGIC;
				 D                 : IN STD_LOGIC;
				 Q                 : OUT STD_LOGIC );
	END COMPONENT;
	
	COMPONENT register_rst_N IS
		GENERIC ( N_BITS : INTEGER := 18 );
		PORT ( EN_REG, CLK, RST_N  : IN STD_LOGIC;
		       D                   : IN STD_LOGIC_VECTOR(N_BITS-1 DOWNTO 0);
		       Q                   : OUT STD_LOGIC_VECTOR(N_BITS-1 DOWNTO 0) );
	END COMPONENT;
	
	COMPONENT mux_NbitData_MbitSel IS
	GENERIC ( NbitData : INTEGER := 12;
	          MbitSel : INTEGER := 4 );
	PORT ( dataIn : IN STD_LOGIC_VECTOR ( NbitData*(2**MbitSel)-1 DOWNTO 0 );
          dataOut : OUT STD_LOGIC_VECTOR ( NbitData-1 DOWNTO 0 );
			 sel : IN STD_LOGIC_VECTOR ( MbitSel-1 DOWNTO 0 ) );
	END COMPONENT;
	
	COMPONENT counter_x_bits IS
	GENERIC ( N_BITS : INTEGER := 18 );
	PORT ( EN_CNT, RST_N, CLK  : IN STD_LOGIC;
			 CLR_SYNC            : IN STD_LOGIC;
          CNT                 : OUT STD_LOGIC_VECTOR(N_BITS-1 DOWNTO 0) );
	END COMPONENT;
	
	SIGNAL sel_samp_freq_D : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL cnt,
          TC      	     : STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL inData_mux_vec  : STD_LOGIC_VECTOR(12*(2**4)-1 DOWNTO 0);
	SIGNAL sel_samp_freq_Q : STD_LOGIC_VECTOR(3 DOWNTO 0);
	
BEGIN

	sel_samp_freq_D <= param(3 DOWNTO 0);
	
	cond_value <= param;
	
	comp_value <= C;
	
	C_G_data_out <= C & G;
	
	inData_mux_vec((12*(1))-1 DOWNTO (12*0)) <= "000000000100"; -- 5 * 2^0 - 1
	inData_mux_vec((12*(2))-1 DOWNTO (12*1)) <= "000000001001"; -- 5 * 2^1 - 1
	inData_mux_vec((12*(3))-1 DOWNTO (12*2)) <= "000000010011"; -- 5 * 2^2 - 1
	inData_mux_vec((12*(4))-1 DOWNTO (12*3)) <= "000000100111"; -- 5 * 2^3 - 1
	inData_mux_vec((12*(5))-1 DOWNTO (12*4)) <= "000001001111"; -- 5 * 2^4 - 1
	inData_mux_vec((12*(6))-1 DOWNTO (12*5)) <= "000010011111"; -- 5 * 2^5 - 1
	inData_mux_vec((12*(7))-1 DOWNTO (12*6)) <= "000100111111"; -- 5 * 2^6 - 1
	inData_mux_vec((12*(8))-1 DOWNTO (12*7)) <= "001001111111"; -- 5 * 2^7 - 1
	inData_mux_vec((12*(9))-1 DOWNTO (12*8)) <= "010011111111"; -- 5 * 2^8 - 1
	inData_mux_vec((12*(10))-1 DOWNTO (12*9)) <= "100111111111"; -- 5 * 2^9 - 1
	
	inData_mux_vec((12*16)-1 DOWNTO (12*10)) <= (OTHERS => '1');

	reg_sample : register_rst_N GENERIC MAP (N_BITS => 4)
	                           PORT MAP ( EN_REG => en_reg_change_freq, 
										           CLK => clk, 
												  	  RST_N => rst_n_reg_change_freq, 
												 	  D => sel_samp_freq_D, 
												     Q => sel_samp_freq_Q );

	counter_sample : counter_x_bits GENERIC MAP ( N_BITS => 12 )
	                         PORT MAP ( EN_CNT => en_cnt_sample, 
									            RST_N => rst_n_cnt_sample, 
												   CLK => clk, 
													CLR_SYNC => clear_at_TC_cnt_sample,
												   CNT => cnt );
													
	mux_TC : mux_NbitData_MbitSel GENERIC MAP ( NbitData => 12, 
	                                         MbitSel => 4 )
								      PORT MAP ( dataIn => inData_mux_vec,
									              dataOut => TC,
													  sel => sel_samp_freq_Q );
													  
	cnt_TC_comparison_process : PROCESS (cnt, TC)
	BEGIN
		IF (cnt = TC) THEN
			sample <= '1';
		ELSE
			sample <= '0';
		END IF;
	END PROCESS;
	
	ff_wr_req_delay : ff_rst_N PORT MAP ( EN_FF => en_ff_wr_req_delay, 
										           CLK => clk, 
													  RST_N => rst_n_ff_wr_req_delay, 
												     D => sample, 
													  Q => wr_req );

	ff_r_saved : ff_rst_N PORT MAP ( EN_FF => en_ff_mem_r, 
										      CLK => clk, 
												RST_N => rst_n_ff_mem_r, 
												D => cmd(1), -- R is "11", but en_ff_mem_r is asserted when a R has been detected only, so cmd(0) = cmd(1)
												Q => r_saved );
											
END ARCHITECTURE;