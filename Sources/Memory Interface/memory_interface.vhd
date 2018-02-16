LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY memory_interface IS
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
			 hex : out std_logic_vector(3 downto 0));
END memory_interface;


ARCHITECTURE memory_interface_structure OF memory_interface IS

	SIGNAL limit, en_cnt_mem, en_reg_mem, writing, rst_N_cnt_mem, rst_N_reg_mem : STD_LOGIC;
	signal hex_mem : std_logic_vector(3 downto 0);

	COMPONENT memory_interface_CU IS
		PORT ( CLK, RST_N, limit, TRIGGER, WR_REQ, RD_REQ : IN STD_LOGIC;
				 EN_CNT_MEM, EN_REG_MEM, RD_RDY, RD_DONE      : OUT STD_LOGIC;
				 CE_N, OE_N, WE_N, UB_N, LB_N                 : OUT STD_LOGIC;
				 RST_N_CNT_MEM, RST_N_REG_MEM                 : OUT STD_LOGIC;
				 WRITING, ALLOW_TRIG                          : OUT STD_LOGIC;
				 hex : out std_logic_vector(3 downto 0) );
	END COMPONENT;

	COMPONENT memory_interface_DP IS
		GENERIC ( nbit_addr : INTEGER := 18 );
		PORT ( DATA_IN                            : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
				 DATA_OUT                           : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				 DATA_IN_OUT                        : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				 ADDR                               : OUT STD_LOGIC_VECTOR(nbit_addr-1 DOWNTO 0);
				 CLK, EN_CNT_MEM, EN_REG_MEM        : IN STD_LOGIC;
				 RST_N_CNT_MEM, RST_N_REG_MEM       : IN STD_LOGIC;
				 WRITING, OE_N                      : IN STD_LOGIC;
				 limit                            : OUT STD_LOGIC );
	END COMPONENT;

BEGIN

	Control_Unit : memory_interface_CU PORT MAP ( CLK => clk, RST_N => rst_N, limit => limit,
																 TRIGGER => trigger, WR_REQ => wr_req, RD_REQ => rd_req,
																 EN_CNT_MEM => en_cnt_mem, 
																 EN_REG_MEM => en_reg_mem, 
																 RD_RDY => rd_rdy, RD_DONE => rd_done,
																 CE_N => ce_N, OE_N => oe_N, WE_N => we_N, 
																 UB_N => ub_N, LB_N => lb_N, RST_N_CNT_MEM => rst_N_cnt_mem, 
																 RST_N_REG_MEM => rst_N_reg_mem, WRITING => writing, 
																 ALLOW_TRIG => allow_trig, hex => hex_mem );
																 
	Data_Path : memory_interface_DP GENERIC MAP ( nbit_addr => nbit_addr )
											  PORT MAP ( DATA_IN => data_in, DATA_OUT => data_out, DATA_IN_OUT => data_in_out,
															 ADDR => addr, CLK => clk, EN_CNT_MEM => en_cnt_mem,
															 EN_REG_MEM => en_reg_mem, RST_N_CNT_MEM => rst_N_cnt_mem, 
															 RST_N_REG_MEM => rst_N_reg_mem, WRITING => writing,
															 OE_N => OE_N, limit => limit );
															 
	hex <= hex_mem;

END ARCHITECTURE;