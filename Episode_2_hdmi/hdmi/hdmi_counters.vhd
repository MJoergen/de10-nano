library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hdmi_counters is
   port (
      clk_i     : in  std_logic;
      pixel_x_o : out std_logic_vector(9 downto 0);
      pixel_y_o : out std_logic_vector(9 downto 0)
   );
end entity hdmi_counters;

architecture synthesis of hdmi_counters is

   -- The following constants define a resolution of 640x480 @ 60 Hz.
   -- Requires a clock of 25.175 MHz.
   -- See page 17 in "VESA MONITOR TIMING STANDARD"
   -- http://caxapa.ru/thumbs/361638/DMTv1r11.pdf

   constant C_PIXEL_X_COUNT : integer := 800;
   constant C_PIXEL_Y_COUNT : integer := 525;

   signal pixel_x           : std_logic_vector(9 downto 0);
   signal pixel_y           : std_logic_vector(9 downto 0);

begin

   -------------------------------------
   -- Generate horizontal pixel counter
   -------------------------------------

   p_pixel_x : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if unsigned(pixel_x) = C_PIXEL_X_COUNT-1 then
            pixel_x <= (others => '0');
         else
            pixel_x <= std_logic_vector(unsigned(pixel_x) + 1);
         end if;
      end if;
   end process p_pixel_x;


   -----------------------------------
   -- Generate vertical pixel counter
   -----------------------------------

   p_pixel_y : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if unsigned(pixel_x) = C_PIXEL_X_COUNT-1 then
            if unsigned(pixel_y) = C_PIXEL_Y_COUNT-1 then
               pixel_y <= (others => '0');
            else
               pixel_y <= std_logic_vector(unsigned(pixel_y) + 1);
            end if;
         end if;
      end if;
   end process p_pixel_y;


   --------------------------
   -- Connect output signals
   --------------------------

   pixel_x_o <= pixel_x;
   pixel_y_o <= pixel_y;

end architecture synthesis;

