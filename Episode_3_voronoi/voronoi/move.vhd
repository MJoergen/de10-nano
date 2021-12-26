library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This module controls the movement of a single Voronoi point.
--
-- To achieve smooth motion, the module operates internally
-- with fixed-point 10.3 arithmetic, i.e. 10 integer bits
-- and 3 fractional bits.
-- The velocity is given in 1.3 fixed point two's complement arithmetic.
-- This means in particular the following example values:
-- "0000" -> 0.0
-- "0100" -> 0.5
-- "1000" -> -1.0
-- "1100" -> -0.5


entity move is
   generic (
      G_HPIXELS    : integer;
      G_VPIXELS    : integer;
      G_RESOLUTION : integer;
      G_PIX_SIZE   : integer;
      G_VEL_SIZE   : integer
   );
   port (
      clk_i    : in  std_logic;
      rst_i    : in  std_logic;
      startx_i : in  std_logic_vector(G_PIX_SIZE-1 downto 0);
      starty_i : in  std_logic_vector(G_PIX_SIZE-1 downto 0);
      velx_i   : in  std_logic_vector(G_VEL_SIZE+G_RESOLUTION-1 downto 0);
      vely_i   : in  std_logic_vector(G_VEL_SIZE+G_RESOLUTION-1 downto 0);
      move_i   : in  std_logic;
      x_o      : out std_logic_vector(G_PIX_SIZE-1 downto 0);
      y_o      : out std_logic_vector(G_PIX_SIZE-1 downto 0)
   );
end move;

architecture synthesis of move is

   constant C_FULL_SIZE : integer := G_PIX_SIZE + G_RESOLUTION;
   subtype R_INTEGER is integer range C_FULL_SIZE-1 downto G_RESOLUTION;

   -- This function performs a sign extension from 1.3 to 10.3 fixed point
   -- two's complement values.
   function sign_extend(arg : std_logic_vector(G_VEL_SIZE+G_RESOLUTION-1 downto 0)) return std_logic_vector is
      variable res : std_logic_vector(C_FULL_SIZE-1 downto 0);
   begin
      res := (others => arg(arg'left));
      res(arg'left downto 0) := arg;
      return res;
   end function sign_extend;

   -- Position and movement of first Voronoi point
   signal x_r      : std_logic_vector(C_FULL_SIZE-1 downto 0);
   signal y_r      : std_logic_vector(C_FULL_SIZE-1 downto 0);
   signal velx_r   : std_logic_vector(C_FULL_SIZE-1 downto 0);
   signal vely_r   : std_logic_vector(C_FULL_SIZE-1 downto 0);
   constant C_ZERO : std_logic_vector(C_FULL_SIZE-1 downto 0) := (others => '0');

begin

   p_move : process (clk_i)
   begin
      if rising_edge(clk_i) then
         if move_i = '1' then
            x_r <= std_logic_vector(unsigned(x_r) + unsigned(velx_r));
            y_r <= std_logic_vector(unsigned(y_r) + unsigned(vely_r));

            if unsigned(x_r(R_INTEGER)) > G_HPIXELS-5 and velx_r(velx_r'left) = '0' then
               velx_r <= std_logic_vector(unsigned(C_ZERO)-unsigned(velx_r));
            end if;

            if unsigned(x_r(R_INTEGER)) < 5 and velx_r(velx_r'left) = '1' then
               velx_r <= std_logic_vector(unsigned(C_ZERO)-unsigned(velx_r));
            end if;

            if unsigned(y_r(R_INTEGER)) > G_VPIXELS-5 and vely_r(vely_r'left) = '0' then
               vely_r <= std_logic_vector(unsigned(C_ZERO)-unsigned(vely_r));
            end if;

            if unsigned(y_r(R_INTEGER)) < 5 and vely_r(vely_r'left) = '1' then
               vely_r <= std_logic_vector(unsigned(C_ZERO)-unsigned(vely_r));
            end if;
         end if;

         if rst_i = '1' then
            x_r    <= startx_i & std_logic_vector(to_unsigned(0, G_RESOLUTION));
            y_r    <= starty_i & std_logic_vector(to_unsigned(0, G_RESOLUTION));
            velx_r <= sign_extend(velx_i);
            vely_r <= sign_extend(vely_i);
         end if;
      end if;
   end process p_move;

   -- Remove the three LSB.
   x_o <= x_r(R_INTEGER);
   y_o <= y_r(R_INTEGER);

end architecture synthesis;

