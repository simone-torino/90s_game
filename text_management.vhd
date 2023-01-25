LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY text_management IS
    PORT (
        clk, rstn : IN STD_LOGIC;
        hpos, vpos : IN INTEGER;
        en_welcome_page, en_choose_mod, en_game_over, en_game, en_wait : IN STD_LOGIC;
        choose_mode : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        pixel_on : OUT STD_LOGIC
    );
END text_management;

ARCHITECTURE behavior OF text_management IS

    COMPONENT Pixel_On_Text IS
        GENERIC (
            --Needed for init displayText, the default value 11 is just a random number
            textLength : INTEGER := 11
        );
        PORT (
            clk : IN STD_LOGIC;
            displayText : IN STRING (1 TO textLength);
            --Top left corner of the text
            x : IN INTEGER;
            y : IN INTEGER;
            --Current pixel postion
            horzCoord : IN INTEGER;
            vertCoord : IN INTEGER;
            pixel : OUT STD_LOGIC := '0'
        );
    END COMPONENT;

    SIGNAL pixel_on_pong, pixel_on_start, pixel_on_choose, pixel_on_list, pixel_on_game_over, pixel_on_restart : STD_LOGIC;
    SIGNAL pixel_on_wall, pixel_on_cpu, pixel_on_two_players, pixel_on_loading : STD_LOGIC;

BEGIN

    pong_game : Pixel_On_Text GENERIC MAP(textLength => 9)
    PORT MAP(
        clk => clk,
        displayText => "PONG GAME",
        x => 295, y => 160,
        horzCoord => hpos,
        vertCoord => vpos,
        pixel => pixel_on_pong
    );

    press_key_to_start : Pixel_On_Text GENERIC MAP(textLength => 28)
    PORT MAP(
        clk => clk,
        displayText => "Press KEY0 to start the game",
        x => 240, y => 320,
        horzCoord => hpos,
        vertCoord => vpos,
        pixel => pixel_on_start
    );

    choose_mod : Pixel_On_Text GENERIC MAP(textLength => 21)
    PORT MAP(
        clk => clk,
        displayText => "Choose the game mode:",
        x => 240, y => 160,
        horzCoord => hpos,
        vertCoord => vpos,
        pixel => pixel_on_choose
    );

    list_of_mod : Pixel_On_Text GENERIC MAP(textLength => 62)
    PORT MAP(
        clk => clk,
        displayText => "WALL mode (KEY0)     CPU mode (KEY1)     2 PLAYERS mode (KEY2)",
        x => 90, y => 320,
        horzCoord => hpos,
        vertCoord => vpos,
        pixel => pixel_on_list
    );

    game_over : Pixel_On_Text GENERIC MAP(textLength => 9)
    PORT MAP(
        clk => clk,
        displayText => "GAME OVER",
        x => 295, y => 160,
        horzCoord => hpos,
        vertCoord => vpos,
        pixel => pixel_on_game_over
    );

    restart : Pixel_On_Text GENERIC MAP(textLength => 21)
    PORT MAP(
        clk => clk,
        displayText => "Press KEY0 to restart",
        x => 250, y => 315,
        horzCoord => hpos,
        vertCoord => vpos,
        pixel => pixel_on_restart
    );

    wall_mode : Pixel_On_Text GENERIC MAP(textLength => 9)
    PORT MAP(
        clk => clk,
        displayText => "WALL mode",
        x => 295, y => 30,
        horzCoord => hpos,
        vertCoord => vpos,
        pixel => pixel_on_wall
    );

    cpu_mode : Pixel_On_Text GENERIC MAP(textLength => 8)
    PORT MAP(
        clk => clk,
        displayText => "CPU mode",
        x => 295, y => 30,
        horzCoord => hpos,
        vertCoord => vpos,
        pixel => pixel_on_cpu
    );

    two_players_mode : Pixel_On_Text GENERIC MAP(textLength => 16)
    PORT MAP(
        clk => clk,
        displayText => "TWO PLAYERS mode",
        x => 280, y => 30,
        horzCoord => hpos,
        vertCoord => vpos,
        pixel => pixel_on_two_players
    );

    loading : Pixel_On_Text GENERIC MAP(textLength => 10)
    PORT MAP(
        clk => clk,
        displayText => "Loading...",
        x => 295, y => 160,
        horzCoord => hpos,
        vertCoord => vpos,
        pixel => pixel_on_loading
    );

    enable_text : PROCESS (en_welcome_page, en_choose_mod)
    BEGIN
        IF (en_welcome_page = '1') THEN
            pixel_on <= pixel_on_pong OR pixel_on_start;
        ELSIF (en_choose_mod = '1') THEN
            pixel_on <= pixel_on_choose OR pixel_on_list;
        ELSIF (en_game_over = '1') THEN
            pixel_on <= pixel_on_game_over OR pixel_on_restart;
        ELSIF (en_wait = '1') THEN
            pixel_on <= pixel_on_loading;
        ELSIF (en_game = '1') THEN
            IF (choose_mode = "00") THEN
                pixel_on <= pixel_on_wall;
            ELSIF (choose_mode = "01") THEN
                pixel_on <= pixel_on_cpu;
            ELSIF (choose_mode = "10") THEN
                pixel_on <= pixel_on_two_players;
            END IF;
        END IF;
    END PROCESS;

END behavior;