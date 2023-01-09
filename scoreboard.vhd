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

    SIGNAL score_dx0, score_dx1, score_sx : INTEGER;
    SIGNAL game_end_dx, game_end_sx : STD_LOGIC;

BEGIN

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

    game_end <= game_end_sx OR game_end_dx;
    seg_5 <= "0000001";

    display_dx0_decoder : PROCESS (score_dx0)
    BEGIN
        CASE score_dx0 IS
            WHEN 0 => -- output '0'
                seg_0 <= "0000001";
            WHEN 1 => -- output '1'
                seg_0 <= "1001111";
            WHEN 2 => -- output '2'
                seg_0 <= "0010010";
            WHEN 3 => -- output '3'
                seg_0 <= "0000110";
            WHEN 4 => -- output '4'
                seg_0 <= "1001100";
            WHEN 5 => -- output '5'
                seg_0 <= "0100100";
            WHEN 6 => -- output '6'
                seg_0 <= "0100000";
            WHEN 7 => -- output '7'
                seg_0 <= "0001111";
            WHEN 8 => -- output '8'
                seg_0 <= "0000000";
            WHEN 9 => -- output '9'
                seg_0 <= "0000100";
            WHEN OTHERS => -- default output
                seg_0 <= "1111110";
        END CASE;
    END PROCESS;

    display_dx1_decoder : PROCESS (score_dx1)
    BEGIN
        CASE score_dx1 IS
            WHEN 0 => -- output '0'
                seg_1 <= "0000001";
            WHEN 1 => -- output '1'
                seg_1 <= "1001111";
            WHEN 2 => -- output '2'
                seg_1 <= "0010010";
            WHEN 3 => -- output '3'
                seg_1 <= "0000110";
            WHEN 4 => -- output '4'
                seg_1 <= "1001100";
            WHEN 5 => -- output '5'
                seg_1 <= "0100100";
            WHEN 6 => -- output '6'
                seg_1 <= "0100000";
            WHEN 7 => -- output '7'
                seg_1 <= "0001111";
            WHEN 8 => -- output '8'
                seg_1 <= "0000000";
            WHEN 9 => -- output '9'
                seg_1 <= "0000100";
            WHEN OTHERS => -- default output
                seg_1 <= "1111110";
        END CASE;
    END PROCESS;

    display_sx_decoder : PROCESS (score_sx)
    BEGIN
        CASE score_sx IS
            WHEN 0 => -- output '0'
                seg_4 <= "0000001";
            WHEN 1 => -- output '1'
                seg_4 <= "1001111";
            WHEN 2 => -- output '2'
                seg_4 <= "0010010";
            WHEN 3 => -- output '3'
                seg_4 <= "0000110";
            WHEN 4 => -- output '4'
                seg_4 <= "1001100";
            WHEN 5 => -- output '5'
                seg_4 <= "0100100";
            WHEN 6 => -- output '6'
                seg_4 <= "0100000";
            WHEN 7 => -- output '7'
                seg_4 <= "0001111";
            WHEN 8 => -- output '8'
                seg_4 <= "0000000";
            WHEN 9 => -- output '9'
                seg_4 <= "0000100";
            WHEN OTHERS => -- default output
                seg_4 <= "1111110";
        END CASE;
    END PROCESS;

END behavioral;