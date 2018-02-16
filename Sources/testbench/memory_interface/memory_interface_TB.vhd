LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY memory_interface_TB IS
END memory_interface_TB;

ARCHITECTURE str OF memory_interface_TB IS

--components
	COMPONENT boardSignals_gen IS
	PORT ( clk_50MHz, 
	       rst_n : OUT STD_LOGIC );
	END COMPONENT;
	
	COMPONENT WRreq_RDreq_gen IS
	GENERIC ( WR_begTime : TIME := 50 ns;
             RD_beg_Time : TIME := 1 us );
	PORT ( clk : IN STD_LOGIC;
          WR_req,
          RD_req : OUT STD_LOGIC );
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
				 OE_N : BUFFER STD_LOGIC );
	END COMPONENT;
	
	COMPONENT SRAM IS
		GENERIC ( D_BITS    : INTEGER := 16;
					 ADDR_BITS : INTEGER := 18 );
		PORT ( DATA_IN_OUT                  : INOUT STD_LOGIC_VECTOR(D_BITS-1 DOWNTO 0);
				 ADDR                         : IN STD_LOGIC_VECTOR(ADDR_BITS-1 DOWNTO 0);
				 CE_N, OE_N, WE_N, UB_N, LB_N : IN STD_LOGIC);
	END COMPONENT;
	
--signals
	SIGNAL clk,
	       clk_delayed,
          rst_n,	
	       ce_n, 
			 we_n, 
			 oe_n, 
			 ub_n,
			 lb_n,
			 mem_rdy4trig,
			 trigger,
			 trigger_mask_N,
			 wr_req,
			 wr_req_mask_N,
			 rd_req,
			 rd_req_tmp,
			 rd_rst,
			 rd_rdy,
			 rd_done,
			 allow_trig,
			 en_cnt : std_logic;
   SIGNAL addr : std_logic_vector (2 downto 0);
	SIGNAL data_in, 
			 data_out,
		   	data_in_out : std_logic_vector(15 downto 0);
			 
BEGIN

--clock and reset gen process
boardSim : boardSignals_gen 
PORT MAP ( 
	clk_50MHz => clk, 
	rst_n => rst_n );

--data_in gen process
en_cnt <= '1';

data_in_genProcess : PROCESS (en_cnt, wr_req)
		variable tmp : integer := 0;
	begin
		IF( en_cnt = '1' ) THEN
			if (wr_req'event and wr_req = '1') then
				tmp := tmp + 1;
				data_in <= std_logic_vector(to_unsigned(tmp, data_in'length));
			end if;
		ELSE
			data_in <= (OTHERS => '1');
		END IF;
	end PROCESS;
	
--wr_req and rd_req gen process
wr_req_rd_req_gen : WRreq_RDreq_gen
GENERIC MAP
	( WR_begTime => 50 ns,
     RD_beg_Time => 3 us )
PORT MAP 
	( clk => clk,
     WR_req => wr_req,
     RD_req => rd_req );


--trigger gen process
trigger_mask_N <= '0', '1' AFTER 2 us;

trig_genProcess : PROCESS (trigger_mask_N, data_in)
	BEGIN
		IF (trigger_mask_N = '1' AND data_in = "0000000000011010") THEN
			trigger <= '1';
		ELSE
			trigger <= '0';
		END IF;
	END PROCESS;


--SRAM
SRAM_simulation : SRAM
	GENERIC MAP
		( D_BITS => 16,
		  ADDR_BITS => 3 )
	PORT MAP
		( DATA_IN_OUT => data_in_out,
		  ADDR => addr,
		  CE_N => ce_n, 
		  OE_N => oe_n, 
		  WE_N => we_n, 
		  UB_N => ub_n, 
		  LB_N => lb_n );

--DUT
mem_int : memory_interface 
	GENERIC MAP ( nbit_addr => 3 )
	PORT MAP (CLK => clk,
					 RST_N => rst_n, 
					 TRIGGER => trigger, 
					 WR_REQ => wr_req,
					 RD_REQ => rd_req,
					 RD_RDY => rd_rdy,
					 RD_DONE => rd_done, 
					 ALLOW_TRIG => allow_trig,
					 DATA_IN => data_in,
					 DATA_OUT => data_out,
					 DATA_IN_OUT => data_in_out,
					 ADDR => addr,
					 CE_N => ce_n,
					 WE_N => we_n, 
					 UB_N => ub_n, 
					 LB_N => lb_n,
					 OE_N => oe_n );

END ARCHITECTURE;