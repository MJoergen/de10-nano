library ieee;
use ieee.std_logic_1164.all;

entity top is
   port (
      fpga_clk1_50_i : in  std_logic;        -- 50 Mhz clock input
      hdmi_tx_clk_o  : out std_logic;        -- 25 MHz clock output
      hdmi_tx_de_o   : out std_logic;
      hdmi_tx_d_o    : out std_logic_vector(23 downto 0);
      hdmi_tx_hs_o   : out std_logic;
      hdmi_tx_vs_o   : out std_logic
   );
end entity top;

architecture synthesis of top is

   signal hdmi_clk : std_logic;              -- 25 MHz HDMI clock

begin

   -- A simple clock divider (from 50 MHz to 25 MHz)
   p_clk : process (fpga_clk1_50_i)
   begin
      if rising_edge(fpga_clk1_50_i) then
         hdmi_clk <= not hdmi_clk;
      end if;
   end process p_clk;

   -- Instantiate the HDMI controller
   i_hdmi : entity work.hdmi
      port map (
         clk_i        => hdmi_clk,
         hdmi_tx_de_o => hdmi_tx_de_o,
         hdmi_tx_d_o  => hdmi_tx_d_o,
         hdmi_tx_hs_o => hdmi_tx_hs_o,
         hdmi_tx_vs_o => hdmi_tx_vs_o
      ); -- i_hdmi

   -- Connect output clock
   hdmi_tx_clk_o <= hdmi_clk;

end architecture synthesis;

