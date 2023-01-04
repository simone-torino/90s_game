LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY text_management IS
    PORT (
        clock25 : IN STD_LOGIC;
        pixel_en : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        hpos, vpos : IN INTEGER;
        pixel_on_txt1, pixel_on_txt2, pixel_on_txt3 : OUT STD_LOGIC
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
			displayText : IN STRING (1 TO textLength) := (OTHERS => NUL);
			-- top left corner of the text
			x: IN integer;
			y: IN integer;
			-- current pixel postion
			horzCoord : IN INTEGER;
			vertCoord : IN INTEGER;

			pixel : OUT STD_LOGIC := '0'
		);
	END COMPONENT;

    SIGNAL x_text1, y_text1, x_text2, y_text2, x_text3, y_text3 : INTEGER; --top left corner of the text
	SIGNAL text_to_display1, text_to_display2, text_to_display3 : STRING;
	SIGNAL textLength1, textLength2, textLength3 : INTEGER;

BEGIN
    PROCESS (pixel_en)
    BEGIN
    x_text1 = ;
    Y_text1 = ;
    text_to_display1 = " ";
    textLength1 = ; 
    x_text2 = ;
    Y_text2 = ;
    text_to_display2 = " ";
    textLength3 = ;
    x_text3 = ;
    Y_text3 = ;
    text_to_display3 = " ";
    textLength3 = ;
        CASE pixel_en IS
            WHEN "0001" => --idle
                x_text1 = ;
                Y_text1 = ;
                text_to_display1 = "PONG GAME";
                textLength1 = ; 
                x_text2 = ;
                Y_text2 = ;
                text_to_display2 = "press KEY0 to start";
                textLength2 = ;
            WHEN "0010" => --num_players_selection
                x_text1 = ;
                Y_text1 = ;
                text_to_display1 = "Single player: press KEY0";
                textLength1 = ;
                x_text2 = ;
                Y_text2 = ;
                text_to_display2 = "Multiplayer: press KEY1";
                textLength2 = ; 
            WHEN "0011" => --game_mode_selection
                x_text1 = ;
                Y_text1 = ;
                text_to_display1 = "Easy mode: press KEY0";
                textLength1 = ; 
                x_text2 = ;
                Y_text2 = ;
                text_to_display2 = "Intermediate mode: press KEY1" ;
                textLength2 = ;
                x_text3 = ;
                Y_text3 = ;
                text_to_display3 = "Hard mode: press KEY2" ;
                textLength3 = ;
            WHEN "0100" => --start_game
                x_text1 = ;
                Y_text1 = ;
                text_to_display1 = "Press KEY0 to play, good luck!";
                textLength1 = ; 
                x_text2 = ;
                Y_text2 = ;
                text_to_display2 = "press KEY1 to return to main page";
                textLength2 = ;
            WHEN "0101" => --current_game
                x_text1 = ;
                Y_text1 = ;
                text_to_display1 = "press reset button to go back to start";
                textLength1 = ; 
            WHEN "0110" => --win
                x_text1 = ;
                Y_text1 = ;
                text_to_display1 = "WINNER WINNER CHICKEN DINNER!";
                textLength1 = ; 
                x_text2 = ;
                Y_text2 = ;
                text_to_display2 = "Press any key to go back to the main menu" ;
                textLength2 = ;
            WHEN OTHERS => 
            END CASE;
            
    END PROCESS;


    text1 : Pixel_On_Text
		GENERIC MAP(
			textLength => textLength1
		)
		PORT MAP(
			clk => clock25,
			displayText => text_to_display1,
			x => x_text1, 
			y => y_text1, -- text position (top left)
			horzCoord => hpos,
			vertCoord => vpos,
			pixel => pixel_on_txt1 -- result
		);

	text2 : Pixel_On_Text
		GENERIC MAP(
			textLength => textLength2
		)
		PORT MAP(
			clk => clock25,
			displayText => text_to_display2,
			x => x_text2, 
			y => y_text2, -- text position (top left)
			horzCoord => hpos,
			vertCoord => vpos,
			pixel => pixel_on_txt2 -- result
		);

	text3 : Pixel_On_Text
		GENERIC MAP(
			textLength => textLength3
		)
		PORT MAP(
			clk => clock25,
			displayText => text_to_display3,
			x => x_text3, 
			y => y_text3, -- text position (top left)
			horzCoord => hpos,
			vertCoord => vpos,
			pixel => pixel_on_txt3 -- result
		);

END behavior;