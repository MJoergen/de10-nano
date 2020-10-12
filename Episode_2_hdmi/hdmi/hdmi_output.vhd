library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hdmi_output is
   port (
      clk_i        : in  std_logic;
      pixel_x_i    : in  std_logic_vector(9 downto 0);
      pixel_y_i    : in  std_logic_vector(9 downto 0);
      hdmi_tx_de_o : out std_logic;
      hdmi_tx_d_o  : out std_logic_vector(23 downto 0);
      hdmi_tx_hs_o : out std_logic;
      hdmi_tx_vs_o : out std_logic
   );
end entity hdmi_output;

architecture synthesis of hdmi_output is

   -- The following constants define a resolution of 640x480 @ 60 Hz.
   -- Requires a clock of 25.175 MHz.
   -- See page 17 in "VESA MONITOR TIMING STANDARD"
   -- http://caxapa.ru/thumbs/361638/DMTv1r11.pdf

   -- Define visible screen size
   constant H_PIXELS        : integer := 640;
   constant V_PIXELS        : integer := 480;

   -- Define VGA timing constants
   constant HS_START        : integer := 656;
   constant HS_TIME         : integer := 96;
   constant VS_START        : integer := 490;
   constant VS_TIME         : integer := 2;

begin

   -----------------------------------
   -- Generate output
   -----------------------------------

   p_hdmi_tx : process (clk_i)
   begin
      if rising_edge(clk_i) then
         -- Generate horizontal sync signal
         if unsigned(pixel_x_i) >= HS_START and
            unsigned(pixel_x_i) < HS_START+HS_TIME then

            hdmi_tx_hs_o <= '0';
         else
            hdmi_tx_hs_o <= '1';
         end if;

         -- Generate vertical sync signal
         if unsigned(pixel_y_i) >= VS_START and
            unsigned(pixel_y_i) < VS_START+VS_TIME then

            hdmi_tx_vs_o <= '0';
         else
            hdmi_tx_vs_o <= '1';
         end if;

         -- Default is black
         hdmi_tx_d_o  <= (others => '0');
         hdmi_tx_de_o <= '0';

         -- Only show color when inside visible screen area
         if unsigned(pixel_x_i) >= 0 and
            unsigned(pixel_x_i) < H_PIXELS and
            unsigned(pixel_y_i) < V_PIXELS then

            hdmi_tx_d_o  <= pixel_x_i & pixel_y_i & pixel_y_i(3 downto 0);
            hdmi_tx_de_o <= '1';
         end if;
      end if;
   end process p_hdmi_tx;

end architecture synthesis;

