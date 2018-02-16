library ieee;
use ieee.std_logic_1164.all; 

entity MUX2TO1 is 
port(
		A : in STD_LOGIC;
		B : in STD_LOGIC;
		S : IN STD_LOGIC;
		U : OUT STD_LOGIC
);
END MUX2TO1;

ARCHITECTURE BEH OF MUX2TO1 IS 
BEGIN 
p0 : PROCESS (S,A,B)
BEGIN 
IF S = '1'  THEN 
U<=A;
ELSE 
U<=B;
END IF ;
END PROCESS P0;
END BEH ; 