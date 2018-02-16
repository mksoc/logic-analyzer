library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity D_LATCH is
    Port ( D  : in  STD_LOGIC;
           ENA : in  STD_LOGIC;
           CLRN : in  STD_LOGIC;
           Q  : out STD_LOGIC);
end D_LATCH;

architecture Behavioral of D_LATCH is

begin

process (CLRN,ENA, D)
begin
if (CLRN = '1') then
		Q<='0';
    elsif (ENA = '1') then
        Q <= D;
    end if;
end process;

end Behavioral;