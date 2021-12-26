library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This block computes an approximation to the RMS of two values, i.e.
-- rms = sqrt(x^2 + y^2).
-- The approximation boils down to (assuming 0 < x < y)
-- choosing the maximum of the following lines:
-- line0 : 128*rms =        128*y
-- line1 : 128*rms = 16*x + 127*y
-- line2 : 128*rms = 32*x + 124*y
-- line3 : 128*rms = 47*x + 119*y
-- line4 : 128*rms = 62*x + 112*y
-- line5 : 128*rms = 76*x + 103*y
-- line6 : 128*rms = 89*x +  92*y
--
-- In general, all lines are of the form 128*rms = a*x + b*y, where
-- the constants a and b satisfy (approximately) a^2+b^2 = 128^2.
--
-- The output is stored in 10.5 fixed point.
-- The latency through the block is 3 clock cycles.

entity rms is
   generic (
      G_RESOLUTION : integer;
      G_SIZE       : integer
   );
   port (
      clk_i : in  std_logic;
      rst_i : in  std_logic;
      x_i   : in  std_logic_vector(G_SIZE-1 downto 0);
      y_i   : in  std_logic_vector(G_SIZE-1 downto 0);
      rms_o : out std_logic_vector(G_SIZE+G_RESOLUTION-1 downto 0)
   );
end rms;

architecture synthesis of rms is

   signal min_s : std_logic_vector(G_SIZE-1 downto 0);   -- The minimum of x and y.
   signal max_s : std_logic_vector(G_SIZE-1 downto 0);   -- The maximum of x and y.

   constant C_NUM_LINES : integer := 6;
   constant C_KEY_SIZE  : integer := G_SIZE+G_RESOLUTION;

   -- In the structure below, the values for b where chosen as 128-i^2.
   -- And the values for a were chosen as sqrt(128^2-b^2).
   -- For this reason, the index starts at i=1.
   type t_integer_vector is array(natural range <>) of integer;
   constant a : t_integer_vector(1 to C_NUM_LINES) := ( 16,  32,  47,  62,  76, 89);
   constant b : t_integer_vector(1 to C_NUM_LINES) := (127, 124, 119, 112, 103, 92);

   -- The lines_s are calculated as the value a*x + b*y.
   type t_value_vector is array(natural range <>) of std_logic_vector(C_KEY_SIZE-1 downto 0);
   signal lines_s : t_value_vector(1 to C_NUM_LINES);

   -- Stage 1
   signal lines_1 : t_value_vector(1 to C_NUM_LINES);
   signal keys_1  : std_logic_vector(8*C_KEY_SIZE-1 downto 0);

   -- Stage 3
   signal rms_3   : std_logic_vector(C_KEY_SIZE-1 downto 0);

begin

   -- Sort the x and y values, so that x <= y
   i_minmax_xy : entity work.minmax
      generic map (
         G_SIZE => G_SIZE
      )
      port map (
         a_i   => x_i,
         b_i   => y_i,
         min_o => min_s,
         max_o => max_s
      );

   -- Calculate the values associated with each line.
   gen_lines : for i in 1 to C_NUM_LINES generate
      lines_s(i) <= std_logic_vector(
                    to_unsigned(a(i), G_RESOLUTION) * unsigned(min_s) +
                    to_unsigned(b(i), G_RESOLUTION) * unsigned(max_s));
   end generate gen_lines;

   p_stage1 : process (clk_i)
   begin
      if rising_edge(clk_i) then
         lines_1 <= lines_s;
      end if;
   end process p_stage1;

   -- The values are inverted, because we want the maximum value,
   -- but the min_vector_staged block finds the minimum value.
   gen_keys_a : for i in 0 to C_NUM_LINES-1 generate
      keys_1((i+1)*C_KEY_SIZE-1 downto i*C_KEY_SIZE) <= not(lines_1(i+1));
   end generate gen_keys_a;
   gen_keys_b : for i in C_NUM_LINES to 7 generate
      keys_1((i+1)*C_KEY_SIZE-1 downto i*C_KEY_SIZE) <= not(max_s & "0000000");
   end generate gen_keys_b;


-- The latency through min_vector_staged is 2 clock cycles.
-- when G_NUM_POINTS is 8
   i_min_vector_staged : entity work.min_vector_staged
      generic map (
         G_BITS_PER_KEY   => C_KEY_SIZE,
         G_BITS_PER_VALUE => 0,  -- not used here
         G_NUM_POINTS     => 8   -- must be a power of 2
      )
      port map (
         clk_i       => clk_i,
         rst_i       => rst_i,
         keys_i      => keys_1,
         values_i    => (others => '0'),
         min_key_o   => rms_3,
         min_value_o => open
      ); -- i_min_vector_staged

   rms_o <= not(rms_3);

end architecture synthesis;

