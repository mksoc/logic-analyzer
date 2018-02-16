library ieee;
use ieee.std_logic_1164.all;

entity T_FF is
  port(
        CLK: in std_logic;
        nRESET: in std_logic;
        T: in std_logic;
        Q: buffer std_logic
      );
end T_FF;

architecture beh of T_FF is
begin
 process (nRESET ,clk)
 begin
       if (nRESET = '0') then
          q <= '0';
       elsif (clk'event and clk = '1') then
		 if( T = '1' ) then
          q <= not(q);
       end if;
		 end if;
 end process;
 end beh;
 