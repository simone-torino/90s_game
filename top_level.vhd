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
        HEX0, HEX1 : OUT STD_LOGIC_VECTOR(0 TO 6);
        HEX5, HEX4 : OUT STD_LOGIC_VECTOR(0 TO 6);
        SW : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
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
            pixel_on, pixel_on_racket_left, pixel_on_racket_right, pixel_on_menu : IN STD_LOGIC;
            red, blue, green : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT counter IS
        PORT (
            clk, rstn, en : IN STD_LOGIC;
            tc : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT game IS
        PORT (
            clk, rstn, en : IN STD_LOGIC;
            button : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            hpos, vpos : IN INTEGER;
            choose_mode : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
            score_dx1, score_dx0 : OUT STD_LOGIC_VECTOR(0 TO 6);
            score_sx5, score_sx4 : OUT STD_LOGIC_VECTOR(0 TO 6);
            end_game : OUT STD_LOGIC;
            pixel_on, pixel_on_racket_left, pixel_on_racket_right : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT text_management IS
        PORT (
            clk, rstn : IN STD_LOGIC;
            hpos, vpos : IN INTEGER;
            en_welcome_page, en_choose_mod, en_game_over, en_game : IN STD_LOGIC;
            choose_mode : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
            pixel_on : OUT STD_LOGIC
        );
    END COMPONENT;

    -- signals declaration
    SIGNAL RESETn, rstn : STD_LOGIC;
    SIGNAL hpos, vpos : INTEGER;
    SIGNAL hsync, vsync : STD_LOGIC;
    SIGNAL clock25 : STD_LOGIC;
    SIGNAL locked : STD_LOGIC;

    SIGNAL pixel_on_game, pixel_on_text, pixel_on_racket_left, pixel_on_racket_right : STD_LOGIC;

    SIGNAL en_game, en_welcome_page, en_game_over, en_choose_mod, en_cnt, end_game, tc : STD_LOGIC;
    SIGNAL mode : STD_LOGIC_VECTOR (1 DOWNTO 0);

    --FSM state declaration
    TYPE state_type IS (idle, main_menu, wait_mode, mode_selection, wall_mode, cpu_mode, two_players_mode, wait_game_over, game_over, wait_idle);
    SIGNAL state : state_type;

BEGIN
    --VGA signal that must be active
    VGA_SYNC_N <= '1';
    VGA_BLANK_N <= '1';

    --system reset
    RESETn <= NOT(SW(0)) AND LOCKED;

    --FSM state transition management
    STATE_TRANSITION : PROCESS (clock25, RESETn)
    BEGIN
        IF (RESETn = '0') THEN
            state <= idle;
        ELSIF (clock25'event AND clock25 = '1') THEN
            CASE state IS
                WHEN idle =>
                    state <= main_menu;
                WHEN main_menu =>
                    IF (KEY(0) = '0') THEN
                        state <= wait_mode;
                    ELSE
                        state <= main_menu;
                    END IF;
                WHEN wait_mode =>
                    IF (tc = '1') THEN
                        state <= mode_selection;
                    ELSE
                        state <= wait_mode;
                    END IF;
                WHEN mode_selection =>
                    IF (KEY(0) = '0') THEN
                        state <= wall_mode;
                    ELSIF (KEY(1) = '0') THEN
                        state <= cpu_mode;
                    ELSIF (KEY(2) = '0') THEN
                        state <= two_players_mode;
                    ELSE
                        state <= mode_selection;
                    END IF;
                WHEN wall_mode =>
                    IF (end_game = '1') THEN
                        state <= game_over;
                    ELSE
                        state <= wall_mode;
                    END IF;
                WHEN cpu_mode =>
                    IF (end_game = '1') THEN
                        state <= game_over;
                    ELSE
                        state <= cpu_mode;
                    END IF;
                WHEN two_players_mode =>
                    IF (end_game = '1') THEN
                        state <= game_over;
                    ELSE
                        state <= two_players_mode;
                    END IF;
                WHEN wait_game_over =>
                    IF (tc = '1') THEN
                        state <= game_over;
                    ELSE
                        state <= wait_game_over;
                    END IF;
                WHEN game_over =>
                    IF (KEY(0) = '0') THEN
                        state <= idle;
                    ELSE
                        state <= game_over;
                    END IF;
                WHEN wait_idle =>
                    IF (tc = '1') THEN
                        state <= idle;
                    ELSE
                        state <= wait_idle;
                    END IF;
                WHEN OTHERS =>
                    state <= idle;
            END CASE;
        END IF;
    END PROCESS;

    --signal management in the FSM states
    SIGNAL_PROCESS : PROCESS (state)
    BEGIN
        en_game <= '0';
        en_welcome_page <= '0';
        en_game_over <= '0';
        en_choose_mod <= '0';
        en_cnt <= '0';
        rstn <= '1';
        mode <= "00";
        CASE state IS
            WHEN idle => rstn <= '0';
            WHEN main_menu => en_welcome_page <= '1';
            WHEN wait_mode => en_cnt <= '1';
            WHEN mode_selection => en_choose_mod <= '1';
            WHEN wall_mode => en_game <= '1';
                mode <= "00";
            WHEN cpu_mode => en_game <= '1';
                mode <= "01";
            WHEN two_players_mode => en_game <= '1';
                mode <= "10";
            WHEN wait_game_over => en_cnt <= '1';
            WHEN game_over => en_game_over <= '1';
            WHEN wait_idle => en_cnt <= '1';
            WHEN OTHERS => rstn <= '1';
        END CASE;
    END PROCESS;

    --components port map
    vga_signals : vga_management PORT MAP(
        clk => clock25, rstn => RSTn,
        hs => hsync, vs => vsync,
        hpos => hpos, vpos => vpos
    );

    ff1 : FlipFlop_D PORT MAP(hsync, clock25, '1', '0', RSTn, VGA_HS);

    ff2 : FlipFlop_D PORT MAP(vsync, clock25, '1', '0', RSTn, VGA_VS);

    phaselockedloop : mypll PORT MAP(refclk => CLOCK_50, rst => SW(0), outclk_0 => clock25, outclk_1 => VGA_CLK, locked => locked);

    game_component : game PORT MAP(
        clk => clock25, rstn => RSTn,
        en => en_game,
        button => KEY,
        hpos => hpos, vpos => vpos,
        choose_mode => mode,
        score_dx1 => HEX1, score_dx0 => HEX0,
        score_sx5 => HEX5, score_sx4 => HEX4,
        end_game => end_game,
        pixel_on => pixel_on_game, pixel_on_racket_left => pixel_on_racket_left, pixel_on_racket_right => pixel_on_racket_right
    );

    display_colors : vgacolor PORT MAP(
        clk => clock25, rstn => RSTn,
        pixel_on => pixel_on_game, pixel_on_racket_left => pixel_on_racket_left,
        pixel_on_racket_right => pixel_on_racket_right, pixel_on_menu => pixel_on_text,
        red => VGA_R, blue => VGA_B, green => VGA_G
    );

    menu : text_management PORT MAP(
        clk => clock25, rstn => RSTn,
        hpos => hpos, vpos => vpos,
        en_welcome_page => en_welcome_page, en_choose_mod => en_choose_mod, en_game_over => en_game_over,
        en_game => en_game, choose_mode => mode,
        pixel_on => pixel_on_text
    );

    cnt : counter PORT MAP(
        clk => clock25, rstn => RSTn, en => en_cnt,
        tc => tc
    );

END behavior;