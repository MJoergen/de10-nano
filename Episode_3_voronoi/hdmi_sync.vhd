library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hdmi_sync is
   generic (
      G_PIX_SIZE      : integer;
      G_PIXEL_X_COUNT : integer;
      G_PIXEL_Y_COUNT : integer;
      G_H_PIXELS      : integer;
      G_V_PIXELS      : integer;
      G_HS_START      : integer;
      G_HS_TIME       : integer;
      G_VS_START      : integer;
      G_VS_TIME       : integer
   );
   port (
      clk_i     : in  std_logic;
      rst_i     : in  std_logic;
      pixel_x_o : out std_logic_vector(G_PIX_SIZE-1 downto 0);
      pixel_y_o : out std_logic_vector(G_PIX_SIZE-1 downto 0);
      hs_o      : out std_logic;
      vs_o      : out std_logic;
      de_o      : out std_logic
   );
end entity hdmi_sync;

architecture synthesis of hdmi_sync is

   -- The following constants define a resolution of 1280x1024 @ 60 Hz.
   -- Requires a clock of 108 MHz.
   -- See http://caxapa.ru/thumbs/361638/DMTv1r11.pdf

   signal pixel_x           : std_logic_vector(G_PIX_SIZE-1 downto 0) := (others => '0');
   signal pixel_y           : std_logic_vector(G_PIX_SIZE-1 downto 0) := (others => '0');

begin

   -------------------------------------
   -- Generate horizontal pixel counter
   -------------------------------------

   p_pixel_x : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if unsigned(pixel_x) = G_PIXEL_X_COUNT-1 then
            pixel_x <= (others => '0');
         else
            pixel_x <= std_logic_vector(unsigned(pixel_x) + 1);
         end if;

         if rst_i = '1' then
            pixel_x <= (others => '0');
         end if;
      end if;
   end process p_pixel_x;


   -----------------------------------
   -- Generate vertical pixel counter
   -----------------------------------

   p_pixel_y : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if unsigned(pixel_x) = G_PIXEL_X_COUNT-1 then
            if unsigned(pixel_y) = G_PIXEL_Y_COUNT-1 then
               pixel_y <= (others => '0');
            else
               pixel_y <= std_logic_vector(unsigned(pixel_y) + 1);
            end if;
         end if;

         if rst_i = '1' then
            pixel_y <= (others => '0');
         end if;
      end if;
   end process p_pixel_y;


   p_hdmi_tx : process (clk_i)
   begin
      if rising_edge(clk_i) then
         -- Generate horizontal sync signal
         if unsigned(pixel_x) >= G_HS_START and
            unsigned(pixel_x) < G_HS_START+G_HS_TIME then

            hs_o <= '0';
         else
            hs_o <= '1';
         end if;

         -- Generate vertical sync signal
         if unsigned(pixel_y) >= G_VS_START and
            unsigned(pixel_y) < G_VS_START+G_VS_TIME then

            vs_o <= '0';
         else
            vs_o <= '1';
         end if;

         -- Default is black
         de_o <= '0';

         -- Only show color when inside visible screen area
         if unsigned(pixel_x) < G_H_PIXELS and
            unsigned(pixel_y) < G_V_PIXELS then

            de_o <= '1';
         end if;

         if rst_i = '1' then
            hs_o <= '1';
            vs_o <= '1';
            de_o <= '0';
         end if;
      end if;
   end process p_hdmi_tx;

   --------------------------
   -- Connect output signals
   --------------------------

   pixel_x_o <= pixel_x;
   pixel_y_o <= pixel_y;

end architecture synthesis;

