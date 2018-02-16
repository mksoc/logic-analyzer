LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY main_DP IS
   GENERIC ( nbit_addr_MEM : INTEGER := 18 );
	PORT ( -- in from board
	       clk : IN STD_LOGIC;
	       ext_in : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			 -- out to board
			 mem_rdy4trig : OUT STD_LOGIC;
		    -- in from main_FSM
				 -- to MEM_int
				 trigger_acq_MEM, 
				 wr_req_MEM, 
				 rd_req_MEM, 
				 rst_n_MEM: IN STD_LOGIC; 
				 -- to PC_int
				 data_in_val_PC, 
				 end_of_buf_PC,
				 rst_n_PC : IN STD_LOGIC;
				 -- to TRIG_gen
				 en_mem_TRIG, 
				 en_look4trig_TRIG,
				 rst_n_TRIG : IN STD_LOGIC;
				 -- to SAMP
				 sample_out_SAMP,
				 rst_n_SAMP : IN STD_LOGIC;
				 -- to comp_DP_block
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
				 -- from MEM
				 rd_rdy_MEM, 
				 rd_done_MEM,
				 allow_trig_MEM : OUT STD_LOGIC;
				 -- from PC_int
				 cmd_PC : BUFFER STD_LOGIC_VECTOR (1 DOWNTO 0); -- F => "00", T => "01", S => "10", R => "11" 
				 rd_req_PC, 
				 command_val_PC : OUT STD_LOGIC;
				 -- from TRIG_gen
				 start_rq_TRIG : OUT STD_LOGIC;
				 -- from comp_DP_block
				 r_saved,
				 wr_req_out,
				 sample_out : OUT STD_LOGIC;	
			 -- inout from/to SRAM
			 data_in_out : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 -- out to SRAM
			 ADDR : OUT STD_LOGIC_VECTOR(nbit_addr_MEM-1 DOWNTO 0);
			 CE_N, 
			 WE_N, 
			 UB_N, 
			 LB_N, 
			 OE_N : OUT STD_LOGIC;
			 -- in from PC
			 rx : IN STD_LOGIC;
			 -- out to PC
			 tx : OUT STD_LOGIC;
			 
			 --debug
			 campione : out std_logic_vector(7 downto 0);
			 -- debug
		     hex : out std_logic_vector(3 downto 0)	);
END main_DP;

ARCHITECTURE main_DP_structure OF main_DP IS
	
	COMPONENT complementary_DP_block IS
		PORT ( -- in from board
				 clk : IN STD_LOGIC;
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
			    wr_req	: OUT STD_LOGIC;
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
	END COMPONENT;
	
	COMPONENT memory_interface IS
	   GENERIC ( nbit_addr : INTEGER := 18 );
		PORT ( -- in from board
				 CLK : IN STD_LOGIC;  
				 -- in from main_FSM
				 RST_N, 
				 TRIGGER, 
				 WR_REQ, 
				 RD_REQ : IN STD_LOGIC;
				 -- out to main_FSM
				 RD_RDY, 
				 RD_DONE,  
				 ALLOW_TRIG : OUT STD_LOGIC;
				 -- in from comp_DP_block
				 DATA_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
				 -- out to PC_int
				 DATA_OUT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				 -- inout from/to SRAM
				 DATA_IN_OUT : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				 -- out to SRAM
				 ADDR : OUT STD_LOGIC_VECTOR(nbit_addr-1 DOWNTO 0);
				 CE_N, 
				 WE_N, 
				 UB_N, 
				 LB_N : OUT STD_LOGIC;
				 OE_N : BUFFER STD_LOGIC;
				hex : out std_logic_vector(3 downto 0) );
	END COMPONENT;
	
	COMPONENT pc_interface is
	PORT ( -- in from board
	       clock : in std_logic;
		    -- in from main_FSM
		    reset_n,
			 data_in_val,
		    end_of_buffer: in std_logic;
			 -- out to main_FSM
			 read_req: out std_logic;
		    command_val: out std_logic;
			 -- out to main_FSM/comp_DP_block
			 command: out std_logic_vector(1 downto 0);
          -- out to comp_DP_block
		    param: out std_logic_vector(7 downto 0);
		    -- in from MEM_int
		    data_in: in std_logic_vector(15 downto 0);
			 -- in from PC
		    rx: in std_logic;
			 -- out to PC
			 tx: out std_logic );
	END COMPONENT;
	
	COMPONENT FULL_SAMPLER IS 
		PORT( -- in from board
		      EXT_IN : IN STD_LOGIC_VECTOR (7 DOWNTO 0); 
		      CLK : IN STD_LOGIC;
				-- in from main_FSM
		      SAMPLE : IN STD_LOGIC;
	      	nRESET: IN STD_LOGIC;
				-- out to comp_DP_block
	       	OUT_CAMPIONE : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); 
		      GLITCH : OUT STD_LOGIC_VECTOR (7 DOWNTO 0) );
	END COMPONENT;
	
	COMPONENT TRIGGER IS 
		PORT ( -- in from board
		       CLK : IN  STD_LOGIC;
				 -- in from main_FSM
				 nRST,
				 EN_MEM,
				 EN_LOOK4TRIG  : IN  STD_LOGIC ;
				 -- out to main_FSM
				 START_RQ    : OUT STD_LOGIC;
				 -- in from comp_DP_block
				 COMP_VALUE  : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
				 COND_VALUE  : IN  STD_LOGIC_VECTOR (7 DOWNTO 0) );
	END COMPONENT;
	
	SIGNAL C, G, comp_value, cond_value, param : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL data_in_mem, data_out_mem : STD_LOGIC_VECTOR(15 DOWNTO 0);
	signal hex_mem :	std_logic_vector(3 downto 0);
	
BEGIN

	sampler_DP : FULL_SAMPLER PORT MAP ( EXT_IN => ext_in,
	                                     CLK => clk,
												    SAMPLE => sample_out_SAMP,
												    nRESET => rst_n_SAMP,
													 OUT_CAMPIONE => C,
													 GLITCH => G );
													 
	memory_interface_DP : memory_interface GENERIC MAP ( nbit_addr => nbit_addr_MEM )
	PORT MAP 
	        ( CLK => clk,  
				 RST_N => rst_n_MEM, 
				 TRIGGER => trigger_acq_MEM, 
				 WR_REQ => wr_req_MEM, 
				 RD_REQ => rd_req_MEM,
				 RD_RDY => rd_rdy_MEM, 
				 RD_DONE => rd_done_MEM,
				 ALLOW_TRIG => allow_trig_MEM,
				 DATA_IN => data_in_mem,
				 DATA_OUT => data_out_mem,
				 DATA_IN_OUT => data_in_out,
				 ADDR => ADDR,
				 CE_N => CE_N,
				 WE_N => WE_N,
				 UB_N => UB_N,
				 LB_N => LB_N,
				 OE_N => OE_N,
				 hex => hex_mem );
											
	pc_interface_DP : pc_interface PORT MAP 
		  ( clock => clk,
		    reset_n => rst_n_PC,
			 data_in_val => data_in_val_PC,
		    end_of_buffer => end_of_buf_PC,
			 read_req => rd_req_PC,
		    command_val => command_val_PC,
			 command => cmd_PC,
		    param => param,
		    data_in => data_out_mem,
		    rx => rx,
			 tx => tx );
	
	trigger_gen_DP : trigger PORT MAP 
	        ( CLK => clk,
				 nRST => rst_n_TRIG,
				 EN_MEM => en_mem_TRIG,
				 EN_LOOK4TRIG => en_look4trig_TRIG,
				 START_RQ => start_rq_TRIG,
				 COMP_VALUE => comp_value,
				 COND_VALUE => cond_value );
	
	complementary_DP_block_DP : complementary_DP_block PORT MAP 
			  ( clk => clk,
				 en_cnt_sample => en_cnt_sample, 
				 rst_n_cnt_sample => rst_n_cnt_sample, 
				 clear_at_TC_cnt_sample => clear_at_TC_cnt_sample,
				 en_reg_change_freq => en_reg_change_freq, 
				 rst_n_reg_change_freq => rst_n_reg_change_freq,
				 en_ff_wr_req_delay => en_ff_wr_req_delay, 
				 rst_n_ff_wr_req_delay => rst_n_ff_wr_req_delay, 
				 en_ff_mem_r => en_ff_mem_r, 
				 rst_n_ff_mem_r => rst_n_ff_mem_r,
				 sample => sample_out,
				 r_saved => r_saved,
				 wr_req => wr_req_out,
				 param => param,
				 cmd => cmd_PC,
				 C => C,
				 G => G,
				 cond_value => cond_value,
				 comp_value => comp_value,
				 C_G_data_out => data_in_mem );
				 
				 hex <= hex_mem;
				 
				 --debug
				 campione <= C;
				 -- debug
END ARCHITECTURE;