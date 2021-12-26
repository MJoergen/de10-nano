library ieee;
use ieee.std_logic_1164.all;

-- This is a simple testbench to simulate the design.

entity tb is
end entity tb;

architecture simulation of tb is

   signal clk          : std_logic;
   signal rst          : std_logic;
   signal hdmi_tx_d    : std_logic_vector(23 downto 0);
   signal hdmi_tx_de   : std_logic;
   signal hdmi_tx_hs   : std_logic;
   signal hdmi_tx_vs   : std_logic;

   constant CLK_PERIOD : time := 10 ns; -- Just select an arbitrary frequency of 100 MHz.

begin

    p_clk : process
    begin
       clk <= '1', '0' after CLK_PERIOD/2;
       wait for CLK_PERIOD;
    end process p_clk;

    p_rst : process
    begin
       rst <= '1';
       wait for 100 ns;
       wait until clk = '1';
       rst <= '0';
       wait;
    end process p_rst;


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
         clk_i   => clk,
         rst_i   => rst,
         move_i  => '1',
         col_o   => hdmi_tx_d,
         de_o    => hdmi_tx_de,
         hs_o    => hdmi_tx_hs,
         vs_o    => hdmi_tx_vs
      ); -- i_voronoi

end architecture simulation;

