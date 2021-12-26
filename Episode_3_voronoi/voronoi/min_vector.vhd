library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This block finds the minimum key in a vector, together with
-- an arbitrary associated value.
-- The latency through the block is 1 clock cycle.

entity min_vector is
   generic (
      G_BITS_PER_KEY   : integer;
      G_BITS_PER_VALUE : integer;
      G_NUM_POINTS     : integer
   );
   port (
      clk_i       : in  std_logic;
      rst_i       : in  std_logic;
      keys_i      : in  std_logic_vector(G_NUM_POINTS*G_BITS_PER_KEY-1 downto 0);
      values_i    : in  std_logic_vector(G_NUM_POINTS*G_BITS_PER_VALUE-1 downto 0);
      min_key_o   : out std_logic_vector(G_BITS_PER_KEY-1 downto 0);
      min_value_o : out std_logic_vector(G_BITS_PER_VALUE-1 downto 0)
   );
end min_vector;

architecture synthesis of min_vector is

begin

   ------------------------------------------------
   -- Determine which value is the smallest
   ------------------------------------------------

   p_min_vector : process (clk_i)
      variable min_key_v   : std_logic_vector(G_BITS_PER_KEY-1 downto 0);
      variable min_value_v : std_logic_vector(G_BITS_PER_VALUE-1 downto 0);
   begin
      if rising_edge(clk_i) then

         -- Start with the first key.
         min_key_v   := keys_i(G_BITS_PER_KEY-1 downto 0);
         min_value_v := values_i(G_BITS_PER_VALUE-1 downto 0);

         -- Compare with all the remaining keys.
         for i in 1 to G_NUM_POINTS-1 loop
            if keys_i((i+1)*G_BITS_PER_KEY-1 downto i*G_BITS_PER_KEY) < min_key_v then
               min_key_v   := keys_i((i+1)*G_BITS_PER_KEY-1 downto i*G_BITS_PER_KEY);
               min_value_v := values_i((i+1)*G_BITS_PER_VALUE-1 downto i*G_BITS_PER_VALUE);
            end if;
         end loop;

         min_key_o <= min_key_v;
         min_value_o <= min_value_v;
      end if;
   end process p_min_vector;

end architecture synthesis;

