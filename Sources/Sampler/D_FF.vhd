library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- FF CON RESET ATTIVO BASSO E CAMPIONAMENTO SU FRONTE DI SALITA 
entity D_FF is
   port
   (
      CLK : in std_logic;
      CLRN : in std_logic;
      ENA : in std_logic;      
      D : in std_logic;
      Q : out std_logic
   );
end  D_FF;
 
architecture Behavioral of D_FF is
begin
 P0 :  process (CLK,CLRN) 
BEGIN

IF (CLRN ='0') THEN
Q<= '0'; --uscita del registro

ELSIF ((CLK'EVENT ) AND (CLK = '1')) THEN

IF (ENA='1') THEN --viene abilitata l'uscita
Q<= D;
END IF;
END IF;
   end process P0;
end Behavioral;