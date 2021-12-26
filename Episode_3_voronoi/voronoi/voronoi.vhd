library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This is the main Voronoi module.
-- This is heavily pipelined in order to meet the timing requirements.

entity voronoi is
   generic (
      G_PIXEL_X_COUNT : integer;
      G_PIXEL_Y_COUNT : integer;
      G_H_PIXELS      : integer;
      G_V_PIXELS      : integer;
      G_HS_START      : integer;
      G_HS_TIME       : integer;
      G_VS_START      : integer;
      G_VS_TIME       : integer;
      G_RESOLUTION    : integer
   );
   port (
      clk_i   : in  std_logic;
      rst_i   : in  std_logic;

      move_i  : in  std_logic;   -- True, if the Voronoi points are to move

      col_o   : out std_logic_vector(23 downto 0);
      de_o    : out std_logic;
      hs_o    : out std_logic;
      vs_o    : out std_logic
   );
end voronoi;

architecture synthesis of voronoi is

   constant C_PIX_SIZE       : integer := 11;
   constant C_VEL_SIZE       : integer := 1;
   constant C_VEL_RESOLUTION : integer := 3;
   constant C_NUM_POINTS     : integer := 32;
   constant C_BITS_PER_POINT : integer := C_PIX_SIZE+G_RESOLUTION;
   constant C_COLOR_DEPTH    : integer := 4;

   type t_init is record
      startx : std_logic_vector(C_PIX_SIZE-1 downto 0);
      starty : std_logic_vector(C_PIX_SIZE-1 downto 0);
      velx   : std_logic_vector(C_VEL_SIZE+C_VEL_RESOLUTION-1 downto 0);
      vely   : std_logic_vector(C_VEL_SIZE+C_VEL_RESOLUTION-1 downto 0);
   end record t_init;

   function init(i : integer) return t_init is
      variable res_v : t_init;
   begin
      -- Make sure the point is not too close to the border
      res_v.startx := std_logic_vector(to_unsigned(10 + ((i*23)    mod (G_H_PIXELS-20)), C_PIX_SIZE));
      res_v.starty := std_logic_vector(to_unsigned(10 + ((i*i*37)  mod (G_V_PIXELS-20)), C_PIX_SIZE));
      -- Make sure the initial velocity is not zero.
      res_v.velx   := std_logic_vector(to_unsigned( 1 + ((i*i*7)   mod 15),              C_VEL_SIZE+C_VEL_RESOLUTION));
      res_v.vely   := std_logic_vector(to_unsigned( 1 + ((i*i*i*4) mod 15),              C_VEL_SIZE+C_VEL_RESOLUTION));

      return res_v;
   end function init;

   -- From the HDMI sync controller
   signal pix_x     : std_logic_vector(C_PIX_SIZE-1 downto 0) := (others => '0');
   signal pix_y     : std_logic_vector(C_PIX_SIZE-1 downto 0) := (others => '0');
   signal de        : std_logic;
   signal hs        : std_logic;
   signal vs        : std_logic;

   -- Control the movement of the Voronoi points.
   signal move_s    : std_logic;

   -- Position of Voronoi points.
   signal vx_r      : std_logic_vector(C_NUM_POINTS*C_PIX_SIZE-1 downto 0) := (others => '0');
   signal vy_r      : std_logic_vector(C_NUM_POINTS*C_PIX_SIZE-1 downto 0) := (others => '0');

   -- Stage 1
   signal pix_x_1   : std_logic_vector(C_PIX_SIZE-1 downto 0) := (others => '0');
   signal pix_y_1   : std_logic_vector(C_PIX_SIZE-1 downto 0) := (others => '0');
   signal de_1      : std_logic;
   signal hs_1      : std_logic;
   signal vs_1      : std_logic;

   -- Stage 2
   signal pix_x_2   : std_logic_vector(C_PIX_SIZE-1 downto 0) := (others => '0');
   signal pix_y_2   : std_logic_vector(C_PIX_SIZE-1 downto 0) := (others => '0');
   signal de_2      : std_logic;
   signal hs_2      : std_logic;
   signal vs_2      : std_logic;

   -- Stage 3
   signal pix_x_3   : std_logic_vector(C_PIX_SIZE-1 downto 0) := (others => '0');
   signal pix_y_3   : std_logic_vector(C_PIX_SIZE-1 downto 0) := (others => '0');
   signal de_3      : std_logic;
   signal hs_3      : std_logic;
   signal vs_3      : std_logic;

   -- Stage 4
   signal dist_4    : std_logic_vector(C_NUM_POINTS*C_BITS_PER_POINT-1 downto 0);
   signal pix_x_4   : std_logic_vector(C_PIX_SIZE-1 downto 0) := (others => '0');
   signal pix_y_4   : std_logic_vector(C_PIX_SIZE-1 downto 0) := (others => '0');
   signal colors_4  : std_logic_vector(C_NUM_POINTS*C_COLOR_DEPTH-1 downto 0);
   signal de_4      : std_logic;
   signal hs_4      : std_logic;
   signal vs_4      : std_logic;

   -- Stage 5
   signal pix_x_5   : std_logic_vector(C_PIX_SIZE-1 downto 0) := (others => '0');
   signal pix_y_5   : std_logic_vector(C_PIX_SIZE-1 downto 0) := (others => '0');
   signal de_5      : std_logic;
   signal hs_5      : std_logic;
   signal vs_5      : std_logic;

   -- Stage 6
   signal pix_x_6   : std_logic_vector(C_PIX_SIZE-1 downto 0) := (others => '0');
   signal pix_y_6   : std_logic_vector(C_PIX_SIZE-1 downto 0) := (others => '0');
   signal de_6      : std_logic;
   signal hs_6      : std_logic;
   signal vs_6      : std_logic;

   -- Stage 7
   signal mindist_7 : std_logic_vector(C_BITS_PER_POINT-1 downto 0);
   signal colour_7  : std_logic_vector(C_COLOR_DEPTH-1 downto 0);
   signal pix_x_7   : std_logic_vector(C_PIX_SIZE-1 downto 0) := (others => '0');
   signal pix_y_7   : std_logic_vector(C_PIX_SIZE-1 downto 0) := (others => '0');
   signal col_7     : std_logic_vector(23 downto 0);
   signal de_7      : std_logic;
   signal hs_7      : std_logic;
   signal vs_7      : std_logic;

   -- Stage 8
   signal col_8     : std_logic_vector(23 downto 0);
   signal de_8      : std_logic;
   signal hs_8      : std_logic;
   signal vs_8      : std_logic;

begin

   -----------------------------------------------------------------
   -- Instantiate the HDMI pixel counters
   -----------------------------------------------------------------

   i_hdmi_sync : entity work.hdmi_sync
      generic map (
         G_PIX_SIZE      => C_PIX_SIZE,
         G_PIXEL_X_COUNT => G_PIXEL_X_COUNT,
         G_PIXEL_Y_COUNT => G_PIXEL_Y_COUNT,
         G_H_PIXELS      => G_H_PIXELS,
         G_V_PIXELS      => G_V_PIXELS,
         G_HS_START      => G_HS_START,
         G_HS_TIME       => G_HS_TIME,
         G_VS_START      => G_VS_START,
         G_VS_TIME       => G_VS_TIME
      )
      port map (
         clk_i     => clk_i,
         rst_i     => rst_i,
         pixel_x_o => pix_x,
         pixel_y_o => pix_y,
         de_o      => de,
         hs_o      => hs,
         vs_o      => vs
      ); -- i_hdmi_counters


   -----------------------------------------------------------------
   -- Signal update of Voronoi point coordinates
   -- when current pixel is outside screen area.
   -----------------------------------------------------------------

   move_s <= move_i when unsigned(pix_x) = G_H_PIXELS and unsigned(pix_y) = G_V_PIXELS else '0';


   gen_voronoi_points : for i in 0 to C_NUM_POINTS-1 generate

      -- This block moves around each Voronoi center.
      i_move : entity work.move
         generic map (
            G_HPIXELS    => G_H_PIXELS,
            G_VPIXELS    => G_V_PIXELS,
            G_RESOLUTION => C_VEL_RESOLUTION,
            G_PIX_SIZE   => C_PIX_SIZE,
            G_VEL_SIZE   => C_VEL_SIZE
         )
         port map (
            clk_i    => clk_i,
            rst_i    => rst_i,
            startx_i => init(i).startx,
            starty_i => init(i).starty,
            velx_i   => init(i).velx,
            vely_i   => init(i).vely,
            move_i   => move_s,
            x_o      => vx_r((i+1)*C_PIX_SIZE-1 downto i*C_PIX_SIZE),
            y_o      => vy_r((i+1)*C_PIX_SIZE-1 downto i*C_PIX_SIZE)
         ); -- i_move
   end generate gen_voronoi_points;


   -----------------------------------------------------------------
   -- Stage 1, 2, 3, and 4 : Calculate distance to each Voronoi point
   -----------------------------------------------------------------

   gen_dist : for i in 0 to C_NUM_POINTS-1 generate

      -- This is a small combinatorial block that computes the distance
      -- from the current pixel to the Voronoi center.
      i_dist : entity work.dist
         generic map (
            G_RESOLUTION => G_RESOLUTION,
            G_SIZE       => C_PIX_SIZE
         )
         port map (
            clk_i  => clk_i,
            rst_i  => rst_i,
            x1_i   => vx_r((i+1)*C_PIX_SIZE-1 downto i*C_PIX_SIZE),
            y1_i   => vy_r((i+1)*C_PIX_SIZE-1 downto i*C_PIX_SIZE),
            x2_i   => pix_x,
            y2_i   => pix_y,
            dist_o => dist_4((i+1)*C_BITS_PER_POINT-1 downto i*C_BITS_PER_POINT)
         ); -- i_dist
   end generate gen_dist;

   p_stage1 : process (clk_i)
   begin
      if rising_edge(clk_i) then
         pix_x_1 <= pix_x;
         pix_y_1 <= pix_y;
         de_1    <= de;
         hs_1    <= hs;
         vs_1    <= vs;
      end if;
   end process p_stage1;

   p_stage2 : process (clk_i)
   begin
      if rising_edge(clk_i) then
         pix_x_2 <= pix_x_1;
         pix_y_2 <= pix_y_1;
         de_2    <= de_1;
         hs_2    <= hs_1;
         vs_2    <= vs_1;
      end if;
   end process p_stage2;

   p_stage3 : process (clk_i)
   begin
      if rising_edge(clk_i) then
         pix_x_3 <= pix_x_2;
         pix_y_3 <= pix_y_2;
         de_3    <= de_2;
         hs_3    <= hs_2;
         vs_3    <= vs_2;
      end if;
   end process p_stage3;

   p_stage4 : process (clk_i)
   begin
      if rising_edge(clk_i) then
         pix_x_4 <= pix_x_3;
         pix_y_4 <= pix_y_3;
         de_4    <= de_3;
         hs_4    <= hs_3;
         vs_4    <= vs_3;
      end if;
   end process p_stage4;


   -----------------------------------------------------------------
   -- Stage 5, 6, and 7 : Determine which Voronoi point is the nearest
   -----------------------------------------------------------------

   gen_colors : for i in 0 to C_NUM_POINTS-1 generate
      colors_4((i+1)*C_COLOR_DEPTH-1 downto i*C_COLOR_DEPTH) <=
         std_logic_vector(to_unsigned(i mod (2**C_COLOR_DEPTH-1), C_COLOR_DEPTH));
   end generate gen_colors;

   i_min_vector_staged : entity work.min_vector_staged
      generic map (
         G_BITS_PER_KEY   => C_BITS_PER_POINT,
         G_BITS_PER_VALUE => C_COLOR_DEPTH,
         G_NUM_POINTS     => C_NUM_POINTS
      )
      port map (
         clk_i       => clk_i,
         rst_i       => rst_i,
         keys_i      => dist_4,
         values_i    => colors_4,
         min_key_o   => mindist_7,
         min_value_o => colour_7
      ); -- i_min_vector

   p_stage5 : process (clk_i)
   begin
      if rising_edge(clk_i) then
         pix_x_5 <= pix_x_4;
         pix_y_5 <= pix_y_4;
         de_5    <= de_4;
         hs_5    <= hs_4;
         vs_5    <= vs_4;
      end if;
   end process p_stage5;

   p_stage6 : process (clk_i)
   begin
      if rising_edge(clk_i) then
         pix_x_6 <= pix_x_5;
         pix_y_6 <= pix_y_5;
         de_6    <= de_5;
         hs_6    <= hs_5;
         vs_6    <= vs_5;
      end if;
   end process p_stage6;

   p_stage7 : process (clk_i)
   begin
      if rising_edge(clk_i) then
         pix_x_7 <= pix_x_6;
         pix_y_7 <= pix_y_6;
         de_7    <= de_6;
         hs_7    <= hs_6;
         vs_7    <= vs_6;
      end if;
   end process p_stage7;


   -----------------------------------------------------------------
   -- Stage 8 : Generate pixel colour
   -----------------------------------------------------------------

   p_stage8 : process (clk_i)
      variable brightness_v : std_logic_vector(7 downto 0);
   begin
      if rising_edge(clk_i) then
         brightness_v := not mindist_7(G_RESOLUTION+7 downto G_RESOLUTION+0);
         case colour_7 is
            when "0000" => col_8 <= brightness_v & brightness_v & brightness_v;
            when "0001" => col_8 <= brightness_v & brightness_v &   "01000000";
            when "0010" => col_8 <= brightness_v &   "01000000" & brightness_v;
            when "0011" => col_8 <= brightness_v &   "01000000" &   "01000000";
            when "0100" => col_8 <=   "01000000" & brightness_v & brightness_v;
            when "0101" => col_8 <=   "01000000" & brightness_v &   "01000000";
            when "0110" => col_8 <=   "01000000" &   "01000000" & brightness_v;
            when "0111" => col_8 <=   "01000000" &   "01000000" &   "01000000";
            when "1000" => col_8 <= brightness_v & brightness_v & brightness_v;
            when "1001" => col_8 <= brightness_v & brightness_v &   "00000000";
            when "1010" => col_8 <= brightness_v &   "00000000" & brightness_v;
            when "1011" => col_8 <= brightness_v &   "00000000" &   "00000000";
            when "1100" => col_8 <=   "00000000" & brightness_v & brightness_v;
            when "1101" => col_8 <=   "00000000" & brightness_v &   "00000000";
            when "1110" => col_8 <=   "00000000" &   "00000000" & brightness_v;
            when "1111" => col_8 <=   "00000000" &   "00000000" &   "00000000";
            when others => col_8 <= (others => '0');
         end case;

         -- Make sure colour is black outside the visible area.
         if unsigned(pix_x_7) >= G_H_PIXELS or unsigned(pix_y_7) >= G_V_PIXELS then
            col_8 <= (others => '0'); -- Black colour.
         end if;

         de_8 <= de_7;
         hs_8 <= hs_7;
         vs_8 <= vs_7;
      end if;
   end process p_stage8;


   --------------------------------------------------
   -- Drive output signals
   --------------------------------------------------

   col_o <= col_8;
   de_o  <= de_8;
   hs_o  <= hs_8;
   vs_o  <= vs_8;

end architecture synthesis;

