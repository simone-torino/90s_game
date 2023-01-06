LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY text_management IS
    PORT (
        clock25 : IN STD_LOGIC;
        pixel_en : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        hpos, vpos : IN INTEGER;
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

    SIGNAL x_text1, y_text1, x_text2, y_text2, x_text3, y_text3 : INTEGER; --top left corner of the text
    SIGNAL text_to_display1 : STRING (1 TO 9);
    SIGNAL text_to_display2, text_to_display3 : STRING (1 TO 19);
    SIGNAL textLength1, textLength2, textLength3 : INTEGER;
    SIGNAL pixel_on_txt1, pixel_on_txt2, pixel_on_txt3 : STD_LOGIC;

BEGIN

textElement1: Pixel_On_Text
generic map (
    textLength => 38
)
port map(
    clk => clock25,
    displayText => "Pixel_On_Text -- test 1!@#$ at (50,50)",
    x => 100, y => 100,
    --position => (50, 50), -- text position (top left)
    horzCoord => hpos,
    vertCoord => vpos,
    pixel => pixel_on -- result
);
    -- PROCESS (pixel_en)
    -- BEGIN
    --     --        x_text1 = 0;
    --     --        Y_text1 = 0;
    --     --        text_to_display1 = " ";
    --     --        textLength1 = 1;
    --     --        x_text2 = 0;
    --     --        Y_text2 = 0;
    --     --        text_to_display2 = " ";
    --     --        textLength2 = 1;
    --     --        x_text3 = 0;
    --     --        Y_text3 = 0;
    --     --        text_to_display3 = " ";
    --     --        textLength3 = 1;
    --     CASE pixel_en IS
    --         WHEN "0001" => --idle
    --             x_text1 <= 100;
    --             Y_text1 <= 100;
    --             text_to_display1 <= "PONG GAME";
    --             textLength1 <= 9;
    --             x_text2 <= 100;
    --             Y_text2 <= 150;
    --             text_to_display2 <= "press KEY0 to start";
    --             textLength2 <= 19;
    --             -- WHEN "0010" => --num_players_selection
    --             --     x_text1 = ;
    --             --     Y_text1 = ;
    --             --     text_to_display1 = "Single player: press KEY0";
    --             --     textLength1 = ;
    --             --     x_text2 = ;
    --             --     Y_text2 = ;
    --             --     text_to_display2 = "Multiplayer: press KEY1";
    --             --     textLength2 = ;
    --             -- WHEN "0011" => --game_mode_selection
    --             --     x_text1 = ;
    --             --     Y_text1 = ;
    --             --     text_to_display1 = "Easy mode: press KEY0";
    --             --     textLength1 = ;
    --             --     x_text2 = ;
    --             --     Y_text2 = ;
    --             --     text_to_display2 = "Intermediate mode: press KEY1";
    --             --     textLength2 = ;
    --             --     x_text3 = ;
    --             --     Y_text3 = ;
    --             --     text_to_display3 = "Hard mode: press KEY2";
    --             --     textLength3 = ;
    --             -- WHEN "0100" => --start_game
    --             --     x_text1 = ;
    --             --     Y_text1 = ;
    --             --     text_to_display1 = "Press KEY0 to play, good luck!";
    --             --     textLength1 = ;
    --             --     x_text2 = ;
    --             --     Y_text2 = ;
    --             --     text_to_display2 = "press KEY1 to return to main page";
    --             --     textLength2 = ;
    --             -- WHEN "0101" => --current_game
    --             --     x_text1 = ;
    --             --     Y_text1 = ;
    --             --     text_to_display1 = "press reset button to go back to start";
    --             --     textLength1 = ;
    --             -- WHEN "0110" => --win
    --             --     x_text1 = ;
    --             --     Y_text1 = ;
    --             --     text_to_display1 = "WINNER WINNER CHICKEN DINNER!";
    --             --     textLength1 = ;
    --             --     x_text2 = ;
    --             --     Y_text2 = ;
    --             --     text_to_display2 = "Press any key to go back to the main menu";
    --             --     textLength2 = ;
    --         WHEN OTHERS =>
    --             x_text1 <= 100;
    --             Y_text1 <= 100;
    --             text_to_display1 <= "PONG GAME";
    --             textLength1 <= 9;
    --             x_text2 <= 100;
    --             Y_text2 <= 150;
    --             text_to_display2 <= "press KEY0 to start";
    --             textLength2 <= 19;
    --     END CASE;

    -- END PROCESS;
    -- text1 : Pixel_On_Text
    -- GENERIC MAP(
    --     textLength => 9
    -- )
    -- PORT MAP(
    --     clk => clock25,
    --     displayText => text_to_display1,
    --     x => x_text1,
    --     y => y_text1, -- text position (top left)
    --     horzCoord => hpos,
    --     vertCoord => vpos,
    --     pixel => pixel_on_txt1 -- result
    -- );

    -- text2 : Pixel_On_Text
    -- GENERIC MAP(
    --     textLength => 19
    -- )
    -- PORT MAP(
    --     clk => clock25,
    --     displayText => text_to_display2,
    --     x => x_text2,
    --     y => y_text2, -- text position (top left)
    --     horzCoord => hpos,
    --     vertCoord => vpos,
    --     pixel => pixel_on_txt2 -- result
    -- );

    -- --    text3 : Pixel_On_Text
    -- --    GENERIC MAP(
    -- --        textLength => textLength3
    -- --    )
    -- --    PORT MAP(
    -- --        clk => clock25,
    -- --        displayText => text_to_display3,
    -- --        x => x_text3,
    -- --        y => y_text3, -- text position (top left)
    -- --        horzCoord => hpos,
    -- --        vertCoord => vpos,
    -- --        pixel => pixel_on_txt3 -- result
    -- --    );

    -- pixel_on <= pixel_on_txt1 OR pixel_on_txt2 OR pixel_on_txt3;

END behavior;