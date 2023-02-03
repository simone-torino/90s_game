LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY scoreboard IS
    PORT (
        rstn : IN STD_LOGIC;
        player_dx_gol, player_sx_gol : IN STD_LOGIC;
        mode : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        game_end : OUT STD_LOGIC;
        seg_5, seg_4 : OUT STD_LOGIC_VECTOR (0 TO 6);
        seg_1, seg_0 : OUT STD_LOGIC_VECTOR (0 TO 6)
    );
END scoreboard;

ARCHITECTURE behavioral OF scoreboard IS

    COMPONENT display_7_seg IS
        PORT (
            input : IN INTEGER;
            output : OUT STD_LOGIC_VECTOR(0 TO 6));
    END COMPONENT;

    SIGNAL score_dx0, score_dx1, score_sx : INTEGER;
    SIGNAL game_end_dx, game_end_sx : STD_LOGIC;

BEGIN

    --The two right hand side displays can show numbers from 00 to 99
    update_score_dx : PROCESS (rstn, player_dx_gol)
    BEGIN
        IF (rstn = '0') THEN
            score_dx0 <= 0;
            score_dx1 <= 0;
            game_end_dx <= '0';
        ELSIF (player_dx_gol'event AND player_dx_gol = '1') THEN
            IF (mode = "00") THEN
                IF (score_dx0 < 9) THEN
                    score_dx0 <= score_dx0 + 1;
                ELSE
                    score_dx0 <= 0;
                    IF (score_dx1 < 9) THEN
                        score_dx1 <= score_dx1 + 1;
                    ELSE
                        score_dx1 <= 0;
                    END IF;
                END IF;
            ELSE
                IF (score_dx0 < 4) THEN
                    score_dx0 <= score_dx0 + 1;
                ELSE
                    score_dx0 <= 5;
                    game_end_dx <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- The screens on the left show only numbers from 00 to 05
    update_score_sx : PROCESS (rstn, player_sx_gol)
    BEGIN
        IF (rstn = '0') THEN
            score_sx <= 0;
            game_end_sx <= '0';
        ELSIF (player_sx_gol'event AND player_sx_gol = '1') THEN
            IF (mode = "00") THEN
                game_end_sx <= '1';
            ELSE
                IF (score_sx < 4) THEN
                    score_sx <= score_sx + 1;
                ELSE
                    score_sx <= 5;
                    game_end_sx <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    --The ending of the game depends on display's values
    game_end <= game_end_sx OR game_end_dx;

    --Leftmost display is kept on for aesthetic reasons
    seg_5 <= "0000001";

    display_dx0_decoder : display_7_seg PORT MAP(score_dx0, seg_0);
    display_dx1_decoder : display_7_seg PORT MAP(score_dx1, seg_1);
    display_sx_decoder : display_7_seg PORT MAP(score_sx, seg_4);

END behavioral;