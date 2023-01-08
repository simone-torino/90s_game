LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY text_management IS
    PORT (
        clk, rstn : IN STD_LOGIC;
        hpos, vpos : IN INTEGER;
        en_welcome_page, en_choose_mod, en_game_over : IN STD_LOGIC;
        pixel_on : OUT STD_LOGIC
    );
END text_management;

ARCHITECTURE behavior OF text_management IS

    COMPONENT Pixel_On_Text IS
        GENERIC (
            -- needed for init displayText, the default value 11 is just a random number
            textLength : INTEGER := 11
        );
        PORT (
            clk : IN STD_LOGIC;
            displayText : IN STRING (1 TO textLength);
            -- top left corner of the text
            x : IN INTEGER;
            y : IN INTEGER;
            -- current pixel postion
            horzCoord : IN INTEGER;
            vertCoord : IN INTEGER;
            pixel : OUT STD_LOGIC := '0'
        );
    END COMPONENT;

    SIGNAL pixel_on_pong, pixel_on_start, pixel_on_choose, pixel_on_list, pixel_on_game_over, pixel_on_restart : STD_LOGIC;

BEGIN

    pong_game : Pixel_On_Text GENERIC MAP(textLength => 9)
    PORT MAP(
        clk => clk,
        displayText => "PONG GAME",
        x => 316, y => 160,
        horzCoord => hpos,
        vertCoord => vpos,
        pixel => pixel_on_pong
    );

    press_key_to_start : Pixel_On_Text GENERIC MAP(textLength => 28)
    PORT MAP(
        clk => clk,
        displayText => "Press KEY3 to start the game",
        x => 306, y => 320,
        horzCoord => hpos,
        vertCoord => vpos,
        pixel => pixel_on_start
    );

    choose_mod : Pixel_On_Text GENERIC MAP(textLength => 21)
    PORT MAP(
        clk => clk,
        displayText => "Choose the game mode:",
        x => 250, y => 160,
        horzCoord => hpos,
        vertCoord => vpos,
        pixel => pixel_on_choose
    );

    list_of_mod : Pixel_On_Text GENERIC MAP(textLength => 62)
    PORT MAP(
        clk => clk,
        displayText => "WALL mode (KEY0)     CPU mode (KEY1)     2 PLAYERS mode (KEY2)",
        x => 100, y => 320,
        horzCoord => hpos,
        vertCoord => vpos,
        pixel => pixel_on_list
    );

    game_over : Pixel_On_Text GENERIC MAP(textLength => 9)
    PORT MAP(
        clk => clk,
        displayText => "GAME OVER",
        x => 316, y => 160,
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

    enable_text : PROCESS (en_welcome_page, en_choose_mod)
    BEGIN
        IF (en_welcome_page = '1') THEN
            pixel_on <= pixel_on_pong OR pixel_on_start;
        ELSIF (en_choose_mod = '1') THEN
            pixel_on <= pixel_on_choose OR pixel_on_list;
        ELSIF (en_game_over = '1') THEN
            pixel_on <= pixel_on_game_over OR pixel_on_restart;
        END IF;
    END PROCESS;

END behavior;