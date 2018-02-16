library ieee;
use ieee.std_logic_1164.all;

ENTITY POSITIVE_EDGE_DETECTOR IS 
PORT (
EXT_IN : IN STD_LOGIC; 
CLK : IN STD_LOGIC ;
ALTERNATE : IN STD_LOGIC;
nRESET: IN STD_LOGIC;
RISING : BUFFER STD_LOGIC
);
END POSITIVE_EDGE_DETECTOR;

ARCHITECTURE BEH OF POSITIVE_EDGE_DETECTOR IS 

component POSITIVE_EDGE 
port( 
	D : in std_logic;
	ENA : in std_logic;
	CLRN : in std_logic;
	SLOPE_UP : out std_logic
	);
	end component ;
	
	
SIGNAL  RESET_0,RESET_1,UP_0,UP_1 : STD_LOGIC;
	
BEGIN 

RESET_0 <= NOT(nRESET) or ALTERNATE;

RESET_1 <= NOT(nRESET) or not(ALTERNATE);

P_DETECT_1 : POSITIVE_EDGE port map(  
	D => '1' ,
	ENA => EXT_IN,
	CLRN => RESET_0 ,
	SLOPE_UP => UP_0 
	);

P_DETECT_2 : POSITIVE_EDGE port map(  
	D => '1' ,
	ENA => EXT_IN,
	CLRN => RESET_1 ,
	SLOPE_UP => UP_1
	);

RISING <= UP_0 or UP_1;


END BEH ;