LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY memory_interface_DP IS
	GENERIC ( nbit_addr : INTEGER := 18 );
	PORT ( DATA_IN                            : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			 DATA_OUT                           : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 DATA_IN_OUT                        : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 ADDR                               : OUT STD_LOGIC_VECTOR(nbit_addr-1 DOWNTO 0);
			 CLK, EN_CNT_MEM, EN_REG_MEM        : IN STD_LOGIC;
			 RST_N_CNT_MEM, RST_N_REG_MEM       : IN STD_LOGIC;
			 WRITING, OE_N                      : IN STD_LOGIC;
			 limit                            : OUT STD_LOGIC );
END memory_interface_DP;

ARCHITECTURE memory_interface_DP_structure OF memory_interface_DP IS

	SIGNAL current_address, limit_address_D, limit_address_Q : STD_LOGIC_VECTOR(nbit_addr-1 DOWNTO 0);
	SIGNAL WRITING_AND_OEN : STD_LOGIC;

	COMPONENT counter_x_bits IS
		GENERIC ( N_BITS : INTEGER := 18 );
		PORT ( EN_CNT, RST_N, CLK, CLR_SYNC  : IN STD_LOGIC;
	          CNT                 : OUT STD_LOGIC_VECTOR(N_BITS-1 DOWNTO 0) );
	END COMPONENT; 
	
	COMPONENT register_rst_N IS
		GENERIC ( N_BITS : INTEGER := 18 );
		PORT ( EN_REG, CLK, RST_N  : IN STD_LOGIC;
		       D                   : IN STD_LOGIC_VECTOR(N_BITS-1 DOWNTO 0);
		       Q                   : OUT STD_LOGIC_VECTOR(N_BITS-1 DOWNTO 0) );
	END COMPONENT;
	
BEGIN

	WRITING_AND_OEN <= WRITING AND OE_N;

	-- inout DATA from SRAM
	DATA_IN_OUT <= DATA_IN WHEN WRITING_AND_OEN = '1' ELSE (OTHERS => 'Z');
	DATA_OUT <= DATA_IN_OUT;
	
	-- counter
	address_counter : counter_x_bits GENERIC MAP ( N_BITS => nbit_addr )
	                                 PORT MAP ( EN_CNT => EN_CNT_MEM, RST_N => RST_N_CNT_MEM, CLK => CLK, CLR_SYNC => '0',
	                                            CNT => current_address );
	-- signal assignment														  
	ADDR <= current_address;
	
	-- adding ( (2^18)/2 = 2^17 ) to current address (with overflow) -> this way we can find the reciprocal of the current address
	limit_address_D(nbit_addr-2 DOWNTO 0) <= current_address(nbit_addr-2 DOWNTO 0);
	limit_address_D(nbit_addr-1) <= NOT(current_address(nbit_addr-1));
	
	-- register
	limit_address_register : register_rst_N GENERIC MAP ( N_BITS => nbit_addr )
                                           PORT MAP ( EN_REG => EN_REG_MEM, CLK => CLK, RST_N => RST_N_REG_MEM, 
	                                                   D => limit_address_D, Q => limit_address_Q );
	
	currAddr_limitAddr_comparison : 
	PROCESS ( current_address, limit_address_Q )
	BEGIN
		IF( current_address = limit_address_Q ) THEN
			limit <= '1';
		ELSE
			limit <= '0';
		END IF;
	END PROCESS;
																		
END ARCHITECTURE;