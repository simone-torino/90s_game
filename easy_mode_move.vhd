LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY easy_mode_move IS
    PORT (
        clk, rstn : IN STD_LOGIC;
        y_pixel_ref : BUFFER INTEGER
    );
END easy_mode_move;

ARCHITECTURE behavior OF easy_mode_move IS
    CONSTANT y_lim : INTEGER := 480;
    CONSTANT y_dim : INTEGER := 70;

    SIGNAL cnt : INTEGER;
    SIGNAL clk_ref : STD_LOGIC;
    SIGNAL flag : STD_LOGIC;
BEGIN

    create_clock_ref : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0') THEN
            clk_ref <= '0';
            cnt <= 0;
        ELSIF (clk'event AND clk = '1') THEN
            IF (cnt < 100000) THEN
                cnt <= cnt + 1;
            ELSE
                cnt <= 0;
                clk_ref <= NOT(clk_ref);
            END IF;
        END IF;
    END PROCESS;

    opponent_moviment_vertical : PROCESS (clk_ref, rstn)
    BEGIN
        IF (rstn = '0') THEN
            y_pixel_ref <= 0;
            flag <= '1';
        ELSIF (clk_ref'event AND clk_ref = '1') THEN
            IF (flag = '1') THEN
                y_pixel_ref <= y_pixel_ref + 1;
                IF (y_pixel_ref + y_dim = y_lim) THEN
                    flag <= '0';
                END IF;
            END IF;
            IF (flag = '0') THEN
                y_pixel_ref <= y_pixel_ref - 1;
                IF (y_pixel_ref = 0) THEN
                    flag <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;

END behavior;