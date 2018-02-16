LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY main_FSM IS
	   GENERIC ( n_bit_err : INTEGER := 2 );
		PORT ( -- in from board
		       clk, 
				 rst_n : IN STD_LOGIC; 
				 -- out to board
				 coded_error : OUT STD_LOGIC_VECTOR(n_bit_err-1 DOWNTO 0);
				 main_status_bin0,
				 main_status_bin1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
				 -- in from memory interface
				 rd_rdy_MEM, 
				 rd_done_MEM,
				 allow_trig_MEM : IN STD_LOGIC; 
		       -- out to memory interface
				 trigger_acq_MEM, 
				 wr_req_MEM, 
				 rd_req_MEM, 
				 rst_n_MEM: OUT STD_LOGIC; 
				 -- in from PC interface
				 cmd_PC : IN STD_LOGIC_VECTOR (1 DOWNTO 0); -- F => "00", T => "01", S => "10", R => "11" 
				 rd_req_PC, 
				 command_val_PC : IN STD_LOGIC;
				 -- out to PC interface
				 data_in_val_PC, 
				 end_of_buf_PC,
				 rst_n_PC : OUT STD_LOGIC;
				 -- in from trigger generator
				 start_rq_TRIG : IN STD_LOGIC;
				 -- out to trigger generator
				 en_mem_TRIG, 
				 en_look4trig_TRIG,
				 rst_n_TRIG : OUT STD_LOGIC;
				 -- out to sampler
				 sample_out_SAMP,
				 rst_n_SAMP : OUT STD_LOGIC;
				 -- in from comp_DP_block
				 wr_req_in,
				 sample_in,
				 r_saved : IN STD_LOGIC;	
				 -- out to comp_DP_block
				 en_cnt_sample, 
				 rst_n_cnt_sample, 
				 clear_at_TC_cnt_sample,
				 en_reg_change_freq, 
				 rst_n_reg_change_freq,
				 en_ff_wr_req_delay, 
				 rst_n_ff_wr_req_delay, 
				 en_ff_mem_r, 
				 rst_n_ff_mem_r : OUT STD_LOGIC ); 
END main_FSM;

ARCHITECTURE main_FSM_behaviour OF main_FSM IS

	TYPE main_FSM_STATE_TYPE IS ( Reset, Wait4Cmd_begin, Err_NoTrigSet, SetFreq_begin, SetTrig,
											Wait4Cmd_trig_set, SetFreq_trig_set, Wait4Trig, MemRst_T,
											MemRst_S, SetFreq_wait_rd, Wait_rd, WaitEndWrite, WaitMem_wr_half,
										   Save_R, WaitPC_int, TakeData_TX, GiveData_TX, Done_state );
								
	SIGNAL PS, NS : main_FSM_STATE_TYPE;

BEGIN

	NS_DEFINITION_PROCESS: PROCESS ( PS, rd_rdy_MEM, rd_done_MEM, allow_trig_MEM, 
	                                 cmd_PC, rd_req_PC, command_val_PC,
												start_rq_TRIG, sample_in, r_saved )
	BEGIN
		CASE PS IS
			
			-- reset state
			WHEN Reset => NS <= Wait4Cmd_begin;
			
			WHEN Wait4Cmd_begin => IF (command_val_PC = '1') THEN
										    CASE cmd_PC IS
												WHEN "00" => NS <= SetFreq_begin;
												WHEN "01" => NS <= SetTrig;
												WHEN OTHERS => NS <= Err_NoTrigSet;
											 END CASE;
							           ELSE
										    NS <= Wait4Cmd_begin;
										  END IF;
			
			WHEN SetFreq_begin => NS <= Wait4Cmd_begin;
			
			WHEN Err_NoTrigSet => IF (command_val_PC = '1') THEN
										   CASE cmd_PC IS
											  WHEN "00" => NS <= SetFreq_begin;
											  WHEN "01" => NS <= SetTrig;
											  WHEN OTHERS => NS <= Err_NoTrigSet;
											END CASE;
							          ELSE
										   NS <= Err_NoTrigSet;
										 END IF;
			
			WHEN SetTrig => NS <= Wait4Cmd_trig_set;
			
			WHEN Wait4Cmd_trig_set =>  IF (command_val_PC = '1') THEN
										      CASE cmd_PC IS
												  WHEN "00" => NS <= SetFreq_trig_set;
												  WHEN "01" => NS <= SetTrig;
												  WHEN "10" => IF (allow_trig_MEM = '1') THEN
												                 NS <= Wait4Trig;
																	ELSE
																	  NS <= WaitMem_wr_half;
																	END IF;
												  WHEN "11" => NS <= Save_R;
												  WHEN OTHERS => NS <= Reset;
												END CASE;
							               ELSE
										        NS <= Wait4Cmd_trig_set;
										      END IF;
			
			WHEN Save_R => IF (allow_trig_MEM = '1') THEN
								  NS <= Wait4Trig;
								ELSE
								  NS <= WaitMem_wr_half;
								END IF;
			
			WHEN SetFreq_trig_set => NS <= Wait4Cmd_trig_set;
			
			WHEN Wait4Trig => IF (start_rq_TRIG = '1') THEN
								     NS <= WaitEndWrite;
								   ELSE
								     IF (command_val_PC = '1') THEN
									    CASE cmd_PC IS
										   WHEN "00" => NS <= SetFreq_trig_set;
											WHEN "01" => NS <= MemRst_T;
											WHEN OTHERS => NS <= Wait4Trig;
									    END CASE;
									  ELSE
									    NS <= Wait4Trig;
								     END IF;
									END IF;
			
			WHEN MemRst_T => NS <= Wait4Cmd_trig_set;
			
			WHEN MemRst_S => IF (allow_trig_MEM = '1') THEN
								    NS <= Wait4Trig;
								  ELSE
								    NS <= WaitMem_wr_half;
								  END IF;
			
			WHEN SetFreq_wait_rd => NS <= Wait_rd;
			
			WHEN Wait_rd => IF (r_saved = '1') THEN
			                  IF (rd_req_PC = '1') THEN
									  NS <= TakeData_TX;
									ELSE
									  NS <= WaitPC_int;
									END IF;
		                   ELSE
								   IF (command_val_PC = '1') THEN
								     CASE cmd_PC IS
									    WHEN "00" => NS <= SetFreq_wait_rd;
								       WHEN "01" => NS <= MemRst_T;
									    WHEN "10" => NS <= MemRst_S;
									    WHEN "11" => IF (rd_req_PC = '1') THEN
									                   NS <= TakeData_TX;
									                 ELSE
									                   NS <= WaitPC_int;
									                 END IF;
									    WHEN OTHERS => NS <= Reset;
										END CASE;
							      ELSE
								     NS <= Wait_rd;
								   END IF;
								 END IF; 
			
			WHEN WaitEndWrite => IF (rd_rdy_MEM = '1') THEN
			                       NS <= Wait_rd;
										ELSE
										  NS <= WaitEndWrite;
										END IF;
			
			WHEN WaitMem_wr_half => IF (allow_trig_MEM = '1') THEN
								           NS <= Wait4Trig;
								         ELSE
								           NS <= WaitMem_wr_half;
								         END IF;
			
			WHEN WaitPC_int => IF (rd_req_PC = '1') THEN
										  IF (rd_done_MEM = '1') THEN
											 NS <= Done_state;
										  ELSE
										    NS <= TakeData_TX;
										  END IF;
										ELSE
										  NS <= WaitPC_int;
									 END IF;
			
			WHEN TakeData_TX => NS <= GiveData_TX;
			
			WHEN GiveData_TX => NS <= WaitPC_int;
			
			WHEN Done_state => NS <= Wait4Cmd_trig_set;
			
			WHEN OTHERS => NS <= Reset;
			
		END CASE;
	END PROCESS;
	
	
	PS_UPDATING_PROCESS: PROCESS ( clk, rst_N )
	BEGIN
		IF ( rst_n = '0' ) THEN -- async reset
			PS <= Reset;
		ELSE
			IF ( clk'EVENT AND clk = '1' ) THEN
				PS <= NS;
			END IF;
		END IF;
	END PROCESS;
	
	
	OUTPUT_DEFINITION_PROCESS: PROCESS ( PS )
	BEGIN
	
		-- default outputs (asserted)
		en_cnt_sample <= '1';
		en_ff_wr_req_delay <= '1';
		
		-- default outputs (not asserted)
		coded_error <= (OTHERS => '0');
		trigger_acq_MEM <= '0'; 
	   rd_req_MEM <= '0'; 
		data_in_val_PC <= '0';  
		end_of_buf_PC <= '0'; 
		en_mem_TRIG <= '0'; 
		en_look4trig_TRIG <= '0'; 
		rst_n_cnt_sample <= '1';  
		en_reg_change_freq <= '0';  
		rst_n_reg_change_freq <= '1';
		rst_n_ff_wr_req_delay <= '1';  
		en_ff_mem_r <= '0';  
		rst_n_ff_mem_r <= '1'; 
		rst_n_MEM <= '1';
		rst_n_PC <= '1';
		rst_n_TRIG <= '1';
		rst_n_SAMP <= '1';
		
		CASE PS IS
			
			WHEN Reset => rst_n_MEM <= '0';
		                 rst_n_PC <= '0';
		                 rst_n_TRIG <= '0';
		                 rst_n_SAMP <= '0';
							  rst_n_ff_mem_r <= '0'; 
							  rst_n_ff_wr_req_delay <= '0';
							  rst_n_reg_change_freq <= '0'; 
							  rst_n_cnt_sample <= '0'; 
							  
							  main_status_bin0 <= "0000";
							  main_status_bin1 <= "0100";
			
			WHEN Wait4Cmd_begin => end_of_buf_PC <= '1';
			
			                       main_status_bin0 <= "0000";
							           main_status_bin1 <= "0011";
			
			WHEN SetFreq_begin => en_reg_change_freq <= '1'; 
			                      rst_n_MEM <= '0';
										 rst_n_cnt_sample <= '0'; 
										 
										 main_status_bin0 <= "0000";
							          main_status_bin1 <= "0000";
			                      
			
			WHEN Err_NoTrigSet => coded_error <= "01";
			                      end_of_buf_PC <= '1'; 
			                      
										 main_status_bin0 <= "0001";
							          main_status_bin1 <= "0000";
			
			WHEN SetTrig => en_mem_TRIG <= '1';
				             main_status_bin0 <= "0010";
							    main_status_bin1 <= "0000";
			
			WHEN Wait4Cmd_trig_set => end_of_buf_PC <= '1';
								           main_status_bin0 <= "0011";
							              main_status_bin1 <= "0000";
			
			WHEN Save_R => en_ff_mem_r <= '1';
			             
							   main_status_bin0 <= "0100";
							   main_status_bin1 <= "0000";
			
			WHEN SetFreq_trig_set => en_reg_change_freq <= '1'; 
			                         rst_n_MEM <= '0';
										    rst_n_cnt_sample <= '0'; 
											 
											 main_status_bin0 <= "0101";
							             main_status_bin1 <= "0000";
			
			WHEN Wait4Trig => en_look4trig_TRIG <= '1';
			
			                  main_status_bin0 <= "0110";
							      main_status_bin1 <= "0000";
			
			WHEN MemRst_T => rst_n_MEM <= '0';
			                 rst_n_cnt_sample <= '0'; 
								  en_mem_TRIG <= '1';
								  
								  main_status_bin0 <= "0111";
							     main_status_bin1 <= "0000";
			
			WHEN MemRst_S => rst_n_MEM <= '0';
			                 rst_n_cnt_sample <= '0'; 
								  
								  main_status_bin0 <= "1000";
							     main_status_bin1 <= "0000";
			
			WHEN SetFreq_wait_rd => en_reg_change_freq <= '1'; 
			
											main_status_bin0 <= "1001";
							            main_status_bin1 <= "0000";
			
			WHEN Wait_rd => en_ff_wr_req_delay <= '0';
			                rst_n_ff_wr_req_delay <= '0';  
								 en_cnt_sample <= '0'; 
			             
							    main_status_bin0 <= "1010";
							    main_status_bin1 <= "0000";
			
			WHEN WaitEndWrite => trigger_acq_MEM <= '1'; 
			                     en_ff_wr_req_delay <= '1';
										
										main_status_bin0 <= "1011";
							         main_status_bin1 <= "0000";
			
			WHEN WaitMem_wr_half => main_status_bin0 <= "1100";
							            main_status_bin1 <= "0000";
			
			WHEN WaitPC_int => en_ff_wr_req_delay <= '0';
			                   en_cnt_sample <= '0'; 
			
			                   main_status_bin0 <= "1101";
							       main_status_bin1 <= "0000";
			
			WHEN TakeData_TX => rd_req_MEM <= '1';
									  en_ff_wr_req_delay <= '0';
									  en_cnt_sample <= '0'; 
									  
									  main_status_bin0 <= "1110";
							        main_status_bin1 <= "0000";
									 
			WHEN GiveData_TX => data_in_val_PC <= '1';  
			                    en_ff_wr_req_delay <= '0';
									  en_cnt_sample <= '0'; 
			
				                 main_status_bin0 <= "1111";
							        main_status_bin1 <= "0000";
			
			WHEN Done_state => end_of_buf_PC <= '1'; 
									 rst_n_ff_mem_r <= '0';
									  
									 main_status_bin0 <= "0000";
							       main_status_bin1 <= "0001";
				
         -- redundant but necessary for Quartus				
			WHEN OTHERS => en_cnt_sample <= '1';
		                  en_ff_wr_req_delay <= '1';
								
								main_status_bin0 <= "0000";
							   main_status_bin1 <= "0010";
		    
		END CASE;
	END PROCESS;
	
	wr_req_MEM <= wr_req_in;
	
	sample_out_SAMP <= sample_in;
	
	clear_at_TC_cnt_sample <= sample_in;
	
END ARCHITECTURE;