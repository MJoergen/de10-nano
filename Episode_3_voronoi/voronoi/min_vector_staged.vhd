library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This block finds the minimum key in a vector, together with
-- an arbitrary associated value.
-- The latency through the block is several clock cycles,
-- calculated as ceil(log_4(G_NUM_POINTS)). E.g. for 32 points
-- the latency is 3 clock cycles.

entity min_vector_staged is
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
end min_vector_staged;

architecture synthesis of min_vector_staged is

   signal min_keys   : std_logic_vector(4*G_BITS_PER_KEY-1 downto 0);
   signal min_values : std_logic_vector(4*G_BITS_PER_VALUE-1 downto 0);

begin

   gen_recursion : if G_NUM_POINTS > 4 generate
      -- Divide the input vector into 4 smaller vectors and recusively find the
      -- minimum of each smaller vector.
      gen_stage1 : for i in 0 to 3 generate
         i_min_vector_staged : entity work.min_vector_staged
            generic map (
               G_BITS_PER_KEY   => G_BITS_PER_KEY,
               G_BITS_PER_VALUE => G_BITS_PER_VALUE,
               G_NUM_POINTS     => G_NUM_POINTS/4
            )
            port map (
               clk_i       => clk_i,
               rst_i       => rst_i,
               keys_i      => keys_i((i+1)*G_BITS_PER_KEY*G_NUM_POINTS/4-1 downto i*G_BITS_PER_KEY*G_NUM_POINTS/4),
               values_i    => values_i((i+1)*G_BITS_PER_VALUE*G_NUM_POINTS/4-1 downto i*G_BITS_PER_VALUE*G_NUM_POINTS/4),
               min_key_o   => min_keys((i+1)*G_BITS_PER_KEY-1 downto i*G_BITS_PER_KEY),
               min_value_o => min_values((i+1)*G_BITS_PER_VALUE-1 downto i*G_BITS_PER_VALUE)
            ); -- i_min_vector_staged
      end generate gen_stage1;

      -- Finally, find the overall minimum.
      i_stage2 : entity work.min_vector
         generic map (
            G_BITS_PER_KEY   => G_BITS_PER_KEY,
            G_BITS_PER_VALUE => G_BITS_PER_VALUE,
            G_NUM_POINTS     => 4
         )
         port map (
            clk_i       => clk_i,
            rst_i       => rst_i,
            keys_i      => min_keys,
            values_i    => min_values,
            min_key_o   => min_key_o,
            min_value_o => min_value_o
         ); -- i_stage2
   end generate gen_recursion;

   gen_no_recursion : if G_NUM_POINTS <= 4 generate
      i_stage1 : entity work.min_vector
         generic map (
            G_BITS_PER_KEY   => G_BITS_PER_KEY,
            G_BITS_PER_VALUE => G_BITS_PER_VALUE,
            G_NUM_POINTS     => G_NUM_POINTS
         )
         port map (
            clk_i       => clk_i,
            rst_i       => rst_i,
            keys_i      => keys_i,
            values_i    => values_i,
            min_key_o   => min_key_o,
            min_value_o => min_value_o
         ); -- i_stage1
   end generate gen_no_recursion;

end architecture synthesis;

