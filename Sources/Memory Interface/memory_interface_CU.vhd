LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY memory_interface_CU IS
		PORT ( CLK, RST_N, limit, TRIGGER, WR_REQ, RD_REQ : IN STD_LOGIC;
				 EN_CNT_MEM, EN_REG_MEM                       : OUT STD_LOGIC; 
				 RST_N_CNT_MEM, RST_N_REG_MEM                 : OUT STD_LOGIC; -- counter's and register's reset_N				 
				 RD_RDY, RD_DONE, ALLOW_TRIG                  : OUT STD_LOGIC; -- RD_RDY = Ready to Read, RD_DONE = Read Done
				 WRITING                                      : OUT STD_LOGIC; -- asserted when when we are in a writing state. The signal is used to control the fake three state INOUT memory data buffer
				 CE_N, OE_N, WE_N, UB_N, LB_N                 : OUT STD_LOGIC;
				 hex : out std_logic_vector(3 downto 0) ); -- signal to the SRAM
END memory_interface_CU;

ARCHITECTURE memory_interface_CU_behaviour OF memory_interface_CU IS

	TYPE memory_interface_STATE_TYPE IS ( Reset, Idle, WR_half_preparing, Up_addr_WR_half_preparing, Wait_WR_half_preparing, 
	                                      WR_free, Up_addr_WR_free, Wait_WR_free, WR_half, Up_addr_WR_half, Wait_WR_half, adj_bef_RD,
								                 Wait_RD, RD_one_time, RD_done_state );
								
	SIGNAL PS, NS : memory_interface_STATE_TYPE;

BEGIN

	NS_DEFINITION_PROCESS: PROCESS ( PS, limit, trigger, WR_req, RD_req )
	BEGIN
		CASE PS IS
			
			-- reset state
			WHEN Reset => NS <= Idle;
							  
			WHEN Idle => IF ( WR_req = '1' ) THEN 
							    NS <= WR_half_preparing;
							  ELSE 
							    NS <= Idle;
							  END IF;
							  
			-- write at least half of the memory
			WHEN WR_half_preparing => NS <= Up_addr_WR_half_preparing;
			
			-- update address
			WHEN Up_addr_WR_half_preparing =>  NS <= Wait_WR_half_preparing;
			
			-- state in which we wait for the WR_REQ (we are acquiring every T_s (sample time), so we'll write one sample per T_s)c
			WHEN Wait_WR_half_preparing => IF ( WR_req = '1' ) THEN
									           IF ( limit = '1' ) THEN
										           NS <= WR_free;
										        ELSE
										           NS <= WR_half_preparing;
										        END IF;
									        ELSE
									           NS <= Wait_WR_half_preparing;
									        END IF;
											  
			-- free running writing at 		  
			WHEN WR_free => NS <= Up_addr_WR_free;
			
			-- update address
			WHEN Up_addr_WR_free => NS <= Wait_WR_free;
			
			-- wait to write in freerunning every "T_s" seconds (1/T_s is the frequency at which the sampler is acquiring)
			WHEN Wait_WR_free => IF ( WR_req = '1' ) THEN
									      IF ( trigger = '1' ) THEN
										      NS <= WR_half;
										   ELSE
										      NS <= WR_free;
										   END IF;
									   ELSE
									      NS <= Wait_WR_free;
									   END IF;
			
			-- write half of the memory after a trigger event
			WHEN WR_half => NS <= Up_addr_WR_half;
			
			-- update address
			WHEN Up_addr_WR_half => NS <= Wait_WR_half;
			
			-- wait to write every T_s
			WHEN Wait_WR_half => IF ( WR_req = '1' ) THEN
									     IF ( limit = '1' ) THEN
										     NS <= adj_bef_RD;
									 	  ELSE
									 	     NS <= WR_half;
									 	  END IF;
									   ELSE
									      NS <= Wait_WR_half;
									   END IF;
										
			WHEN adj_bef_RD => NS <= Wait_RD;
										
			-- wait for a read command
			WHEN Wait_RD => IF ( RD_req = '1' ) THEN
								    NS <= RD_one_time;
							    ELSE
								    NS <= Wait_RD;
							    END IF;
			
			-- read at max speed
			WHEN RD_one_time => IF ( limit = '1' ) THEN
								        NS <= RD_done_state;
							        ELSE
								        NS <= Wait_RD;
							        END IF;
			
			-- done, ready to begin writing at the next state
			WHEN RD_done_state => IF (WR_req = '1') THEN
			                        NS <= WR_half_preparing;
										 ELSE
											NS <= RD_done_state;
										 END IF;
			
			WHEN OTHERS => NS <= Reset;
			
		END CASE;
	END PROCESS;
	
	PS_UPDATING_PROCESS: PROCESS ( clk, rst_N )
	BEGIN
		IF ( rst_N = '0' ) THEN -- async reset
			PS <= Reset;
		ELSE
			IF ( CLK'EVENT AND CLK = '1' ) THEN
				PS <= NS;
			END IF;
		END IF;
	END PROCESS;
	
	OUTPUT_DEFINITION_PROCESS: PROCESS ( PS )
	BEGIN
		-- default outputs (not asserted). This is valid also for not coded states (WHEN OTHERS =>)
		RST_N_CNT_MEM <= '1';
		RST_N_REG_MEM <= '1';
		EN_CNT_MEM <= '0';
		EN_REG_MEM <= '0';
		RD_RDY <= '0';
		RD_DONE <= '0';
		WRITING <= '0';
		CE_N <= '1';
		OE_N <= '1';
		WE_N <= '1';
		-- UB_N and LB_N are always asserted. We don't need to use this type of control
		UB_N <= '0'; 
		LB_N <= '0';
		ALLOW_TRIG <= '0';
		
		CASE PS IS
			
			WHEN Reset => RST_N_CNT_MEM <= '0';
		              	  RST_N_REG_MEM <= '0';
							  hex <= "0000";
							  
							  
			WHEN Idle => EN_REG_MEM <= '1';
			hex <= "0001";
							  
			WHEN WR_half_preparing => WRITING <= '1';
											  CE_N <= '0';
		                             WE_N <= '0';
											  hex <= "0010";
											  
			WHEN Up_addr_WR_half_preparing => 
			
			WRITING <= '1';
			EN_CNT_MEM <= '1';
			hex <= "0011";
											  
			WHEN Wait_WR_half_preparing => EN_REG_MEM <= '0'; -- redundant but fundamental (otherwise it would begin freerunning writing after the next state)
			                               WRITING <= '1';
													 hex <= "0100";
													 
			WHEN WR_free => EN_REG_MEM <= '1';
								 WRITING <= '1';
								 CE_N <= '0';
		                   WE_N <= '0';
								 ALLOW_TRIG <= '1';
								 hex <= "0101";
								 
			WHEN Up_addr_WR_free => EN_CNT_MEM <= '1';
										   ALLOW_TRIG <= '1';
			                        WRITING <= '1';
											hex <= "0110";
								 
			WHEN Wait_WR_free => WRITING <= '1';
										ALLOW_TRIG <= '1';
										hex <= "0111";
			
			WHEN WR_half => WRITING <= '1';
								 CE_N <= '0';
		                   WE_N <= '0';
								 hex <= "1000";
								 
			WHEN Up_addr_WR_half => EN_CNT_MEM <= '1';
			WRITING <= '1';
			hex <= "1001";
			
			WHEN Wait_WR_half => WRITING <= '1';
			hex <= "1010";
			
			WHEN adj_bef_RD => EN_CNT_MEM <= '1';
									 RD_RDY <= '1';
									 hex <= "1011";
			
			WHEN Wait_RD => CE_N <= '0';
								 OE_N <= '0';
								 RD_RDY <= '1';
								 hex <= "1100";
			
			WHEN RD_one_time => CE_N <= '0';
									  OE_N <= '0';
									  EN_CNT_MEM <= '1';
									  hex <= "1101";
			
			WHEN RD_done_state => RD_DONE <= '1';
			                      EN_REG_MEM <= '1';
										 hex <= "1110";
		
         -- WHEN OTHERS omitted because default outputs have already been defined ( and NS -> Reset )

		END CASE;
	END PROCESS;
	
END ARCHITECTURE;