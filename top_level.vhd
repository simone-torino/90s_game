LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY top_level IS

    PORT (
        CLOCK_50 : IN STD_LOGIC;
        KEY : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        VGA_R, VGA_B, VGA_G : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        VGA_CLK, VGA_SYNC_N, VGA_BLANK_N : OUT STD_LOGIC;
        VGA_VS, VGA_HS : OUT STD_LOGIC;
        HEX0 : OUT STD_LOGIC_VECTOR(0 TO 6);
        HEX5 : OUT STD_LOGIC_VECTOR(0 TO 6);
        SW : IN STD_LOGIC_VECTOR(9 DOWNTO 9)
    );
END top_level;

ARCHITECTURE behavior OF top_level IS

    COMPONENT vga_management IS
        PORT (
            clk, rstn : IN STD_LOGIC;
            hs, vs : OUT STD_LOGIC;
            hpos, vpos : BUFFER INTEGER
        );
    END COMPONENT;

    COMPONENT FlipFlop_D IS
        PORT (
            D, Clk, Ld, Clr, Rstn : IN STD_LOGIC;
            Q : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT mypll IS
        PORT (
            refclk : IN STD_LOGIC := '0'; --  refclk.clk
            rst : IN STD_LOGIC := '0'; --   reset.reset
            outclk_0 : OUT STD_LOGIC; -- outclk0.clk
            outclk_1 : OUT STD_LOGIC; -- outclk1.clk
            locked : OUT STD_LOGIC --  locked.export
        );
    END COMPONENT;

    COMPONENT vgacolor IS
        PORT (
            clk, rstn : IN STD_LOGIC;
            pixel_on, pixel_on_racket_left, pixel_on_racket_right : IN STD_LOGIC;
            red, blue, green : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT game IS
        PORT (
            clk, rstn : IN STD_LOGIC;
            KEY : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            hpos, vpos : IN INTEGER;
            HEX0 : OUT STD_LOGIC_VECTOR(0 TO 6);
            HEX5 : OUT STD_LOGIC_VECTOR(0 TO 6);
            end_game : OUT STD_LOGIC;
            pixel_on, pixel_on_racket_left, pixel_on_racket_right : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL RSTn : STD_LOGIC;
    SIGNAL hpos, vpos : INTEGER;
    SIGNAL hsync, vsync : STD_LOGIC;
    SIGNAL clock25 : STD_LOGIC;
    SIGNAL locked : STD_LOGIC;

    SIGNAL pixel_on, pixel_on_racket_left, pixel_on_racket_right : STD_LOGIC;

    SIGNAL end_game : STD_LOGIC;

BEGIN

    VGA_SYNC_N <= '1';
    VGA_BLANK_N <= '1';
    RSTn <= NOT(SW(9)) AND LOCKED;

    vga_signals : vga_management PORT MAP(
        clk => clock25, rstn => RSTn,
        hs => hsync, vs => vsync,
        hpos => hpos, vpos => vpos
    );

    ff1 : FlipFlop_D PORT MAP(hsync, clock25, '1', '0', RSTn, VGA_HS);

    ff2 : FlipFlop_D PORT MAP(vsync, clock25, '1', '0', RSTn, VGA_VS);

    phaselockedloop : mypll PORT MAP(refclk => CLOCK_50, rst => SW(9), outclk_0 => clock25, outclk_1 => VGA_CLK, locked => locked);

    game_component : game PORT MAP(
        clk => clock25, rstn => RSTn,
        KEY => KEY,
        hpos => hpos, vpos => vpos,
        HEX0 => HEX0, HEX5 => HEX5,
        end_game => end_game,
        pixel_on => pixel_on, pixel_on_racket_left => pixel_on_racket_left, pixel_on_racket_right => pixel_on_racket_right
    );

    display_colors : vgacolor PORT MAP(
        clk => clock25, rstn => RSTn,
        pixel_on => pixel_on, pixel_on_racket_left => pixel_on_racket_left, pixel_on_racket_right => pixel_on_racket_right,
        red => VGA_R, blue => VGA_B, green => VGA_G
    );

END behavior;