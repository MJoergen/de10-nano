library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hdmi is
   port (
      clk_i        : in  std_logic;
      hdmi_tx_de_o : out std_logic;
      hdmi_tx_d_o  : out std_logic_vector(23 downto 0);
      hdmi_tx_hs_o : out std_logic;
      hdmi_tx_vs_o : out std_logic
   );
end entity hdmi;

architecture synthesis of hdmi is

   signal pixel_x  : std_logic_vector(9 downto 0);
   signal pixel_y  : std_logic_vector(9 downto 0);

begin

   i_hdmi_counters : entity work.hdmi_counters
      port map (
         clk_i     => clk_i,
         pixel_x_o => pixel_x,
         pixel_y_o => pixel_y
      ); -- i_hdmi_counters

   i_hdmi_output : entity work.hdmi_output
      port map (
         clk_i        => clk_i,
         pixel_x_i    => pixel_x,
         pixel_y_i    => pixel_y,
         hdmi_tx_de_o => hdmi_tx_de_o,
         hdmi_tx_d_o  => hdmi_tx_d_o,
         hdmi_tx_hs_o => hdmi_tx_hs_o,
         hdmi_tx_vs_o => hdmi_tx_vs_o
      ); -- i_hdmi_output

end architecture synthesis;

