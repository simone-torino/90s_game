LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_top_level IS
END tb_top_level;

ARCHITECTURE behavior OF tb_top_level IS
    -- component instantiation
    COMPONENT top_level
        PORT (
            CLOCK_50 : IN STD_LOGIC;
            KEY : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            VGA_R, VGA_B, VGA_G : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            VGA_CLK, VGA_SYNC_N, VGA_BLANK_N : OUT STD_LOGIC;
            VGA_VS, VGA_HS : OUT STD_LOGIC;
            HEX0, HEX1 : OUT STD_LOGIC_VECTOR(0 TO 6);
            HEX5, HEX4 : OUT STD_LOGIC_VECTOR(0 TO 6);
            SW : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            stop_game_simulation : IN STD_LOGIC
        );
    END COMPONENT;

    -- signals declaration
    SIGNAL CLOCK_50 : STD_LOGIC;
    SIGNAL KEY : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL VGA_R, VGA_B, VGA_G : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL VGA_CLK, VGA_SYNC_N, VGA_BLANK_N : STD_LOGIC;
    SIGNAL VGA_VS, VGA_HS : STD_LOGIC;
    SIGNAL HEX0, HEX1 : STD_LOGIC_VECTOR(0 TO 6);
    SIGNAL HEX5, HEX4 : STD_LOGIC_VECTOR(0 TO 6);
    SIGNAL SW : STD_LOGIC_VECTOR(0 DOWNTO 0);
    SIGNAL stop_game_simulation : STD_LOGIC;

BEGIN
    -- component instantiation
    uut : top_level PORT MAP(
        CLOCK_50 => CLOCK_50,
        KEY => KEY,
        VGA_R => VGA_R,
        VGA_B => VGA_B,
        VGA_G => VGA_G,
        VGA_CLK => VGA_CLK,
        VGA_SYNC_N => VGA_SYNC_N,
        VGA_BLANK_N => VGA_BLANK_N,
        VGA_VS => VGA_VS,
        VGA_HS => VGA_HS,
        HEX0 => HEX0,
        HEX1 => HEX1,
        HEX5 => HEX5,
        HEX4 => HEX4,
        SW => SW,
        stop_game_simulation => stop_game_simulation
    );

    -- clock process
    CLOCK_PROC : PROCESS
    BEGIN
        CLOCK_50 <= '0';
        WAIT FOR 20 ns;
        CLOCK_50 <= '1';
        WAIT FOR 20 ns;
    END PROCESS;

    -- stimulus process
    STIM_PROC : PROCESS
    BEGIN
        SW <= "1"; --idle
        KEY <= "1111";
        stop_game_simulation <= '0';
        WAIT FOR 200 us;
        SW <= "0"; --main_menu
        WAIT FOR 200 us;
        KEY <= "1110"; --wait_mode
        WAIT FOR 100 us;
        KEY <= "1111"; --wait_mode
        WAIT FOR 250 us; --mode_selection
        KEY <= "1101"; --cpu_mode
        WAIT FOR 150 us;
        stop_game_simulation <= '1'; --wait_game_over
        KEY <= "1111";
        WAIT FOR 50 us;
        stop_game_simulation <= '0'; --wait_game_over
        WAIT FOR 320 us; --game_over
        key <= "1110"; --wait_idle
        WAIT FOR 100 us;
        KEY <= "1111"; --wait_idle
        WAIT;

    END PROCESS;
END behavior;