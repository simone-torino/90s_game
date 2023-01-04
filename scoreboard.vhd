LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY scoreboard IS
    PORT (
        rstn : IN STD_LOGIC;
        player_dx_gol, player_sx_gol : IN STD_LOGIC;
        game_end : OUT STD_LOGIC;
        seg_dx : OUT STD_LOGIC_VECTOR (0 TO 6);
        seg_sx : OUT STD_LOGIC_VECTOR (0 TO 6)
    );
END scoreboard;

ARCHITECTURE behavioral OF scoreboard IS

    SIGNAL score_dx, score_sx : INTEGER;
    SIGNAL game_end_dx, game_end_sx : STD_LOGIC;

BEGIN

    update_score_dx : PROCESS (rstn, player_dx_gol)
    BEGIN
        IF (rstn = '0') THEN
            score_dx <= 0;
            game_end_dx <= '0';
        ELSIF (player_dx_gol'event AND player_dx_gol = '1') THEN
            IF (score_dx < 5) THEN
                score_dx <= score_dx + 1;
            ELSE
                score_dx <= 0;
                game_end_dx <= '1';
            END IF;
        END IF;
    END PROCESS;

    update_score_sx : PROCESS (rstn, player_sx_gol)
    BEGIN
        IF (rstn = '0') THEN
            score_sx <= 0;
            game_end_sx <= '0';
        ELSIF (player_sx_gol'event AND player_sx_gol = '1') THEN
            IF (score_sx < 5) THEN
                score_sx <= score_sx + 1;
            ELSE
                score_sx <= 0;
                game_end_sx <= '1';
            END IF;
        END IF;
    END PROCESS;

    game_end <= game_end_sx OR game_end_dx;

    display_dx_decoder : PROCESS (score_dx)
    BEGIN
        CASE score_dx IS
            WHEN 0 => -- output '0'
                seg_dx <= "0000001";
            WHEN 1 => -- output '1'
                seg_dx <= "1001111";
            WHEN 2 => -- output '2'
                seg_dx <= "0010010";
            WHEN 3 => -- output '3'
                seg_dx <= "0000110";
            WHEN 4 => -- output '4'
                seg_dx <= "1001100";
            WHEN 5 => -- output '5'
                seg_dx <= "0100100";
            WHEN 6 => -- output '6'
                seg_dx <= "0100000";
            WHEN 7 => -- output '7'
                seg_dx <= "0001111";
            WHEN 8 => -- output '8'
                seg_dx <= "0000000";
            WHEN 9 => -- output '9'
                seg_dx <= "0000100";
            WHEN OTHERS => -- default output
                seg_dx <= "1111110";
        END CASE;
    END PROCESS;

    display_sx_decoder : PROCESS (score_sx)
    BEGIN
        CASE score_sx IS
            WHEN 0 => -- output '0'
                seg_sx <= "0000001";
            WHEN 1 => -- output '1'
                seg_sx <= "1001111";
            WHEN 2 => -- output '2'
                seg_sx <= "0010010";
            WHEN 3 => -- output '3'
                seg_sx <= "0000110";
            WHEN 4 => -- output '4'
                seg_sx <= "1001100";
            WHEN 5 => -- output '5'
                seg_sx <= "0100100";
            WHEN 6 => -- output '6'
                seg_sx <= "0100000";
            WHEN 7 => -- output '7'
                seg_sx <= "0001111";
            WHEN 8 => -- output '8'
                seg_sx <= "0000000";
            WHEN 9 => -- output '9'
                seg_sx <= "0000100";
            WHEN OTHERS => -- default output
                seg_sx <= "1111110";
        END CASE;
    END PROCESS;

    --    -- Drive the seven segment display based on the current score
    --    seg_dx <= "0000001" WHEN score_dx = "0000" ELSE
    --        seg_dx <= "1001111" WHEN score_dx = "0001" ELSE
    --        seg_dx <= "0010010" WHEN score_dx = "0010" ELSE
    --        seg_dx <= "0000110" WHEN score_dx = "0011" ELSE
    --        seg_dx <= "1001100" WHEN score_dx = "0100" ELSE
    --        seg_dx <= "0100100" WHEN score_dx = "0101" ELSE
    --        seg_dx <= "0100000" WHEN score_dx = "0110" ELSE
    --        seg_dx <= "0001111" WHEN score_dx = "0111" ELSE
    --        seg_dx <= "0000000" WHEN score_dx = "1000" ELSE
    --        seg_dx <= "0001100" WHEN score_dx = "1001" ELSE
    --        seg_dx <= "1111110" WHEN OTHERS;
    --
    --    seg_sx <= "0000001" WHEN score_sx = "0000" ELSE
    --        seg_sx <= "1001111" WHEN score_sx = "0001" ELSE
    --        seg_sx <= "0010010" WHEN score_sx = "0010" ELSE
    --        seg_sx <= "0000110" WHEN score_sx = "0011" ELSE
    --        seg_sx <= "1001100" WHEN score_sx = "0100" ELSE
    --        seg_sx <= "0100100" WHEN score_sx = "0101" ELSE
    --        seg_sx <= "0100000" WHEN score_sx = "0110" ELSE
    --        seg_sx <= "0001111" WHEN score_sx = "0111" ELSE
    --        seg_sx <= "0000000" WHEN score_sx = "1000" ELSE
    --        seg_sx <= "0001100" WHEN score_sx = "1001" ELSE
    --        seg_sx <= "1111110" WHEN OTHERS;

END behavioral;