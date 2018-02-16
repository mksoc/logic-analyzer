library ieee;
use ieee.std_logic_1164.all;
--POSITIVE
entity POSITIVE_EDGE is 
port( 
	D : in std_logic;
	ENA : in std_logic;
	CLRN : in std_logic;
	SLOPE_UP : out std_logic
	);
	end POSITIVE_EDGE ;
	
architecture beh of POSITIVE_EDGE is

--HERE ENA WILL BE THE EXT_IN BECAUSE D = 1
COMPONENT D_LATCH 
    Port ( D : in  STD_LOGIC;
           ENA : in  STD_LOGIC;
           CLRN : in  STD_LOGIC;
           Q  : out STD_LOGIC);
end COMPONENT ;

SIGNAL Q1,NENA:STD_LOGIC;
BEGIN 


nENA<= not(ENA);

D_LATCH_1 : D_LATCH port map (
						D=> D ,
						ENA=> NENA ,
						CLRN => CLRN ,
						Q=>Q1
						);

D_LATCH_2 : D_LATCH port map (
						D=> Q1 ,
						ENA=> ENA ,
						CLRN => CLRN ,
						Q=> SLOPE_UP
						);
						
end beh;

	