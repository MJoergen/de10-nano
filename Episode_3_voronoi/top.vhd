library ieee;
use ieee.std_logic_1164.all;

entity top is
   port (
      fpga_clk1_50_i : in  std_logic;        -- 50 Mhz clock input
      key_i          : in  std_logic_vector(1 downto 0);
      hdmi_tx_clk_o  : out std_logic;
      hdmi_tx_de_o   : out std_logic;
      hdmi_tx_d_o    : out std_logic_vector(23 downto 0);
      hdmi_tx_hs_o   : out std_logic;
      hdmi_tx_vs_o   : out std_logic
   );
end entity top;

architecture synthesis of top is

   signal fpga_clk1_rst  : std_logic;
   signal move           : std_logic;

   signal hdmi_clk       : std_logic;
   signal hdmi_rst_n     : std_logic;
   signal hdmi_rst       : std_logic;

begin

   fpga_clk1_rst <= not key_i(0);
   move          <= key_i(1);

   -- Generate 74.25 MHz clock
   i_pll_hdmi_video : entity work.pll_hdmi_video
      port map (
         refclk   => fpga_clk1_50_i,
         rst      => fpga_clk1_rst,
         outclk_0 => hdmi_clk,
         locked   => hdmi_rst_n
      );

   hdmi_rst <= not hdmi_rst_n;

   -- These parameters are for 1280x720p @ 60 Hz
   -- See page 19 of CEA-861-D
   i_voronoi : entity work.voronoi
      generic map (
         G_PIXEL_X_COUNT => 1650,
         G_PIXEL_Y_COUNT => 750,
         G_H_PIXELS      => 1280,
         G_V_PIXELS      => 720,
         G_HS_START      => 1280 + 110,
         G_HS_TIME       => 40,
         G_VS_START      => 720 + 5,
         G_VS_TIME       => 5,
         G_RESOLUTION    => 7
      )
      port map (
         clk_i   => hdmi_clk,
         rst_i   => hdmi_rst,
         move_i  => move,
         col_o   => hdmi_tx_d_o,
         de_o    => hdmi_tx_de_o,
         hs_o    => hdmi_tx_hs_o,
         vs_o    => hdmi_tx_vs_o
      ); -- i_voronoi

   -- Connect output clock
   hdmi_tx_clk_o <= hdmi_clk;

end architecture synthesis;

