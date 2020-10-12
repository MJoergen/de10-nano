library ieee;
use ieee.std_logic_1164.all;

entity top is
   port (
      sw_i  : in  std_logic_vector(3 downto 0);
      led_o : out std_logic_vector(3 downto 0)
   );
end entity top;

architecture synthesis of top is

begin

   led_o <= sw_i;

end architecture synthesis;

