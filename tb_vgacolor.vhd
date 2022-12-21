library ieee;
use ieee.std_logic_1164.all;

entity tb_vgacolor is
end tb_vgacolor;

architecture tb of tb_vgacolor is

    component vgacolor
        port (CLOCK_50    : in std_logic;
              KEY         : in std_logic_vector (0 downto 0);
              VGA_R       : out std_logic_vector (7 downto 0);
              VGA_B       : out std_logic_vector (7 downto 0);
              VGA_G       : out std_logic_vector (7 downto 0);
              VGA_CLK     : out std_logic;
              VGA_SYNC_N  : out std_logic;
              VGA_BLANK_N : out std_logic;
              VGA_VS      : out std_logic;
              VGA_HS      : out std_logic);
    end component;

    signal CLOCK_50    : std_logic;
    signal KEY         : std_logic_vector (0 downto 0);
    signal VGA_R       : std_logic_vector (7 downto 0);
    signal VGA_B       : std_logic_vector (7 downto 0);
    signal VGA_G       : std_logic_vector (7 downto 0);
    signal VGA_CLK     : std_logic;
    signal VGA_SYNC_N  : std_logic;
    signal VGA_BLANK_N : std_logic;
    signal VGA_VS      : std_logic;
    signal VGA_HS      : std_logic;

    constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : vgacolor
    port map (CLOCK_50    => CLOCK_50,
              KEY         => KEY,
              VGA_R       => VGA_R,
              VGA_B       => VGA_B,
              VGA_G       => VGA_G,
              VGA_CLK     => VGA_CLK,
              VGA_SYNC_N  => VGA_SYNC_N,
              VGA_BLANK_N => VGA_BLANK_N,
              VGA_VS      => VGA_VS,
              VGA_HS      => VGA_HS);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that CLOCK_50 is really your main clock signal
    CLOCK_50 <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        KEY <= (others => '0');
        wait for 10 ns;

        KEY <= (others => '1');
        wait;
    end process;

end tb;