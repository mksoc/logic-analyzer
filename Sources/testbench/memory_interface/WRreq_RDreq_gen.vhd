LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY WRreq_RDreq_gen IS
	GENERIC ( WR_begTime : TIME := 50 ns;
              RD_beg_Time : TIME := 1 us );
	PORT ( clk : IN STD_LOGIC;
           WR_req,
           RD_req : OUT STD_LOGIC );
END ENTITY;

ARCHITECTURE behaviour OF WRreq_RDreq_gen IS

	SIGNAL WR_mask,
	       RD_mask : STD_LOGIC;
	
BEGIN

	WR_mask <= '1', '0' AFTER WR_begTime;
	RD_mask <= '1', '0' AFTER RD_beg_Time;
	
	WR_req_gen_process : PROCESS(clk, WR_mask)
	variable tmp : integer := 0;
	BEGIN 
		IF (WR_mask = '0') THEN
			IF (CLK'event AND CLK = '1') THEN
				tmp := tmp + 1;
				IF(tmp = 5) THEN
					tmp := 0;
					WR_req <= '1';
				ELSE
					WR_req <= '0';
				END IF;
			END IF;
		ELSE
			WR_req <= '0';
		END IF;
	END PROCESS;
	
	RD_req_gen_process : PROCESS(clk, RD_mask)
	variable tmp : integer := 0;
	BEGIN 
		IF (RD_mask = '0') THEN
			IF (CLK'event AND CLK = '1') THEN
				tmp := tmp + 1;
				IF(tmp = 2) THEN
					tmp := 0;
					RD_req <= '1';
				ELSE
					RD_req <= '0';
				END IF;
			END IF;
		ELSE
			RD_req <= '0';
		END IF;
	END PROCESS;
	
END ARCHITECTURE;