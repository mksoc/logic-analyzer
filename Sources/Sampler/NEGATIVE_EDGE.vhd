library ieee;
use ieee.std_logic_1164.all;
--negative

entity NEGATIVE_EDGE is 
port( 
	D : in std_logic;
	ENA : in std_logic;
	CLRN : in std_logic;
	SLOPE_DOWN : out std_logic
	);
	end NEGATIVE_EDGE ;
	
architecture beh of NEGATIVE_EDGE is

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
						ENA=> ENA ,
						CLRN => CLRN ,
						Q=>Q1
						);

D_LATCH_2 : D_LATCH port map (
						D=> Q1 ,
						ENA=> NENA ,
						CLRN => CLRN ,
						Q=> SLOPE_DOWN
						);

end beh;

	