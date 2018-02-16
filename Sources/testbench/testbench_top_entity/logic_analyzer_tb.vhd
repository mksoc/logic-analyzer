LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY logic_analyzer_tb IS
END ENTITY;

ARCHITECTURE behaviour OF logic_analyzer_tb IS

	CONSTANT n_bit_addr : INTEGER := 3; -- set this variable to decide of how many bits the address is composed

	COMPONENT DE2_board_signals IS
		PORT ( clk_50MHz, 
		       rst_n : OUT STD_LOGIC;
	          leds : IN STD_LOGIC_VECTOR(8 DOWNTO 0) );
	END COMPONENT;

	COMPONENT logic_analyzer IS
		GENERIC ( nbit_addr_MEM : INTEGER := 18 );
		PORT ( -- in from board
				 CLOCK50 : IN STD_LOGIC; -- main clk
				 SW : IN STD_LOGIC_VECTOR(17 DOWNTO 0); -- SW(0) -> async_rst_N
				 GPIO : IN STD_LOGIC_VECTOR(35 DOWNTO 0); -- GPIO_0(7 DOWNTO 0) -> ext_in
				 -- out to board
				 LEDG : OUT STD_LOGIC_VECTOR(8 DOWNTO 0); -- coded error state
				 -- inout from/to SRAM
				 SRAM_DQ : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
				 -- out to SRAM
				 SRAM_ADDR : OUT STD_LOGIC_VECTOR(nbit_addr_MEM-1 DOWNTO 0);
				 SRAM_CE_N,
				 SRAM_WE_N,
				 SRAM_OE_N,
				 SRAM_UB_N,
				 SRAM_LB_N : OUT STD_LOGIC;
				 -- in from PC
				 UART_RXD : IN STD_LOGIC;
				 -- out to PC
				 UART_TXD : OUT STD_LOGIC ); 
	END COMPONENT;
	
	COMPONENT SRAM IS
		GENERIC ( D_BITS    : INTEGER := 16;
					 ADDR_BITS : INTEGER := 18 );
		PORT ( DATA_IN_OUT                  : INOUT STD_LOGIC_VECTOR(D_BITS-1 DOWNTO 0);
				 ADDR                         : IN STD_LOGIC_VECTOR(ADDR_BITS-1 DOWNTO 0);
				 CE_N, OE_N, WE_N, UB_N, LB_N : IN STD_LOGIC);
	END COMPONENT;
	
	COMPONENT PC IS
		GENERIC ( no_communication_time : time := 230 ns; 
	             time_interval_between_two_commands : time := 100 us);
		PORT ( tx_PC : OUT STD_LOGIC;
	          rx_PC : IN STD_LOGIC );
	END COMPONENT;
	
	COMPONENT signals_generator IS
		GENERIC ( n_signals : INTEGER := 8 );
		PORT ( signals_to_be_analyzed : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) );
	END COMPONENT;
	
	component signals_generator_GLITCH_ONBOARD IS
	GENERIC ( n_signals : INTEGER := 2 );
	
	PORT ( clk,nRESET : in std_logic ;
	signals_to_be_analyzed : OUT STD_LOGIC_VECTOR(n_signals-1 downto 0) );
	END COMPONENT;
	
	SIGNAL clk_50MHz, rst_n, tx, rx, ce_n, we_n, oe_n, ub_n, lb_n : STD_LOGIC;
	SIGNAL data_in_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL addr : STD_LOGIC_VECTOR(n_bit_addr-1 DOWNTO 0);
	SIGNAL leds : STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL signals_to_be_analyzed : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL SW_sim : STD_LOGIC_VECTOR(17 DOWNTO 0);
	SIGNAL GPIO_0_sim : STD_LOGIC_VECTOR(35 DOWNTO 0);

BEGIN

	DE2_simulation : DE2_board_signals 
	PORT MAP
		( clk_50MHz => clk_50MHz, 
		  rst_n => rst_n,
	    leds => leds);
		
	signals_simulation : signals_generator
	GENERIC MAP
		( n_signals => 8 )
	PORT MAP
		( signals_to_be_analyzed => signals_to_be_analyzed );
		
	-- signals_simulation_glitch : signals_generator_GLITCH_ONBOARD
	-- GENERIC MAP ( n_signals => 2 )
	-- PORT MAP( clk => clk_50MHz, 
	          -- nRESET => rst_n,
	-- signals_to_be_analyzed => signals_to_be_analyzed(1 downto 0));
	-- signals_to_be_analyzed(7 downto 2) <= (OTHERS => '0');
		
   SRAM_simulation : SRAM
	GENERIC MAP
		( D_BITS => 16,
		  ADDR_BITS => n_bit_addr )
	PORT MAP
		( DATA_IN_OUT => data_in_out,
		  ADDR => addr,
		  CE_N => ce_n, 
		  OE_N => oe_n, 
		  WE_N => we_n, 
		  UB_N => ub_n, 
		  LB_N => lb_n );

	DUT : logic_analyzer 
	GENERIC MAP 
		( nbit_addr_MEM => n_bit_addr )
	PORT MAP 
		( CLOCK50 => clk_50MHz,
		  SW => SW_sim,
		  GPIO => GPIO_0_sim,
		  LEDG => leds,
		  SRAM_DQ => data_in_out,
		  SRAM_ADDR => addr,
		  SRAM_CE_N => ce_n,
		  SRAM_WE_N => we_n,
		  SRAM_OE_N => oe_n,
		  SRAM_UB_N => ub_n,
		  SRAM_LB_N => lb_n,
		  UART_RXD => rx,
		  UART_TXD => tx );
		
	PC_simulation : PC
	GENERIC MAP  
	   ( no_communication_time => 230 ns, 
	     time_interval_between_two_commands => 100 us)
	PORT MAP
		( tx_PC => rx,  -- tx_PC is a "rx" from the board point of view, and vice-versa
		  rx_PC => tx );
	
	-- buiding signal for fit empty vector spaces
	SW_sim(0) <= rst_n;
	GPIO_0_sim <= "0000000000000000000000000000" & signals_to_be_analyzed;

END ARCHITECTURE;