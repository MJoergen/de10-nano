library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This block computes the distance between two points.
-- The latency through the block is 4 clock cycles.
entity dist is
   generic (
      G_RESOLUTION : integer;
      G_SIZE       : integer
   );
   port (
      clk_i  : in  std_logic;
      rst_i  : in  std_logic;
      x1_i   : in  std_logic_vector(G_SIZE-1 downto 0);
      y1_i   : in  std_logic_vector(G_SIZE-1 downto 0);
      x2_i   : in  std_logic_vector(G_SIZE-1 downto 0);
      y2_i   : in  std_logic_vector(G_SIZE-1 downto 0);
      dist_o : out std_logic_vector(G_SIZE+G_RESOLUTION-1 downto 0)
   );
end dist;

architecture synthesis of dist is

   signal xmin_s  : std_logic_vector(G_SIZE-1 downto 0);
   signal xmax_s  : std_logic_vector(G_SIZE-1 downto 0);
   signal ymin_s  : std_logic_vector(G_SIZE-1 downto 0);
   signal ymax_s  : std_logic_vector(G_SIZE-1 downto 0);

   -- These contain the horizontal and vertical displacements.
   signal xdist_s : std_logic_vector(G_SIZE-1 downto 0);
   signal ydist_s : std_logic_vector(G_SIZE-1 downto 0);

   -- Stage 1
   signal xdist_1 : std_logic_vector(G_SIZE-1 downto 0);
   signal ydist_1 : std_logic_vector(G_SIZE-1 downto 0);
   signal dist_1  : std_logic_vector(G_SIZE+G_RESOLUTION-1 downto 0) := (others => '0');

   -- Stage 4
   signal dist_4  : std_logic_vector(G_SIZE+G_RESOLUTION-1 downto 0);

begin

   -- Sort the x coordinates.
   i_minmax_x : entity work.minmax
      generic map (
         G_SIZE => G_SIZE
      )
      port map (
         a_i   => x1_i,
         b_i   => x2_i,
         min_o => xmin_s,
         max_o => xmax_s
      );

   -- Sort the y coordinates.
   i_minmax_y : entity work.minmax
      generic map (
         G_SIZE => G_SIZE
      )
      port map (
         a_i   => y1_i,
         b_i   => y2_i,
         min_o => ymin_s,
         max_o => ymax_s
      );

   -- Calculate the x and y displacements.
   xdist_s <= std_logic_vector(unsigned(xmax_s) - unsigned(xmin_s));
   ydist_s <= std_logic_vector(unsigned(ymax_s) - unsigned(ymin_s));

   p_stage1 : process(clk_i)
   begin
      if rising_edge(clk_i) then
         xdist_1 <= xdist_s;
         ydist_1 <= ydist_s;
      end if;
   end process p_stage1;

   -- Calculate the distance.
   i_rms : entity work.rms
      generic map (
         G_RESOLUTION => G_RESOLUTION,
         G_SIZE       => G_SIZE
      )
      port map (
         clk_i => clk_i,
         rst_i => rst_i,
         x_i   => xdist_1,
         y_i   => ydist_1,
         rms_o => dist_4
      ); -- i_rms

   dist_o <= dist_4;

end architecture synthesis;

