LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY top_level_tb IS
END top_level_tb;

ARCHITECTURE behavior OF top_level_tb IS
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
            SW : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
        );
    END COMPONENT;

    -- signals for input stimulus
    SIGNAL CLOCK_50 : STD_LOGIC := '0';
    SIGNAL KEY : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL SW : STD_LOGIC_VECTOR(0 DOWNTO 0) := (OTHERS => '0');

    -- signals for output checking
    SIGNAL VGA_R : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL VGA_B : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL VGA_G : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL VGA_CLK : STD_LOGIC;
    SIGNAL VGA_SYNC_N : STD_LOGIC;
    SIGNAL VGA_BLANK_N : STD_LOGIC;
    SIGNAL VGA_VS : STD_LOGIC;
    SIGNAL VGA_HS : STD_LOGIC;
    SIGNAL HEX0 : STD_LOGIC_VECTOR(0 TO 6);
    SIGNAL HEX1 : STD_LOGIC_VECTOR(0 TO 6);
    SIGNAL HEX5 : STD_LOGIC_VECTOR(0 TO 6);
    SIGNAL HEX4 : STD_LOGIC_VECTOR(0 TO 6);

    -- clock generation
    CONSTANT clock_period : TIME := 40 ns;
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
        SW => SW
    );

    -- clock generation process
    CLOCK_50_gen : PROCESS
    BEGIN
        CLOCK_50 <= '0';
        WAIT FOR clock_period/2;
        CLOCK_50 <= '1';
        WAIT FOR clock_period/2;
    END PROCESS;

    -- stimulus process
    stimulus : PROCESS
    BEGIN

        --reset 
        SW <= (OTHERS => '1');
        WAIT FOR clock_period;
        SW <= (OTHERS => '0');

        -- wait for a few clock cycles
        WAIT FOR 5 * clock_period;

        -- Press key0 to begin
        KEY <= "0001";

        -- wait for a few more clock cycles
        WAIT FOR 5 * clock_period;

        -- Wall mode
        KEY <= "0001";

        -- wait for the simulation to finish
        WAIT;
    END PROCESS;

    -- output checking process
    -- output_check : PROCESS
    -- BEGIN
    --     -- wait for a few clock cycles
    --     WAIT FOR 5 * clock_period;

    --     -- check output values
    --     ASSERT VGA_R = "11111111" REPORT "VGA_R output is incorrect" SEVERITY failure;
    --     ASSERT VGA_B = "11111111" REPORT "VGA_B output is incorrect" SEVERITY failure;
    --     ASSERT VGA_G = "11111111" REPORT "VGA_G output is incorrect" SEVERITY failure;
    --     ASSERT VGA_CLK = '1' REPORT "VGA_CLK output is incorrect" SEVERITY failure;
    --     ASSERT VGA_SYNC_N = '0' REPORT "VGA_SYNC_N output is incorrect" SEVERITY failure;
    --     ASSERT VGA_BLANK_N = '1' REPORT "VGA_BLANK_N output is incorrect" SEVERITY failure;
    --     ASSERT VGA_VS = '1' REPORT "VGA_VS output is incorrect" SEVERITY failure;
    --     ASSERT VGA_HS = '1' REPORT "VGA_HS output is incorrect" SEVERITY failure;
    --     ASSERT HEX0 = "1111111" REPORT "HEX0 output is incorrect" SEVERITY failure;
    --     ASSERT HEX1 = "1111111" REPORT "HEX1 output is incorrect" SEVERITY failure;
    --     ASSERT HEX5 = "1111111" REPORT "HEX5 output is incorrect" SEVERITY failure;
    --     ASSERT HEX4 = "1111111" REPORT "HEX4 output is incorrect" SEVERITY failure;

    --     -- wait for the simulation to finish
    --     WAIT;
    -- END PROCESS;

    END;