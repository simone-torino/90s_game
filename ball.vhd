LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ball IS
    PORT (
        clk, rstn, en : IN STD_LOGIC;
        x_pixel_ref, y_pixel_ref : BUFFER INTEGER;
        xscan, yscan : IN INTEGER;
        right_limit, left_limit, top_limit, bottom_limit : IN INTEGER;
        y_racket_left, y_racket_right, x_racket_left, x_racket_right : IN INTEGER;
        mode : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        hm_flag : OUT STD_LOGIC; --hard mode flag per muovere la racchetta avversaria
        hm_ball_tracking : OUT INTEGER;
        flag : OUT STD_LOGIC;
        player_dx_gol : OUT STD_LOGIC;
        player_sx_gol : OUT STD_LOGIC
    );
END ball;

ARCHITECTURE behavior OF ball IS
    CONSTANT x_dim : INTEGER := 10;
    CONSTANT y_dim : INTEGER := 10;

    SIGNAL x_left, x_right, y_up, y_down : INTEGER;
    SIGNAL vel_x, vel_y : INTEGER;
    SIGNAL cnt : INTEGER;
    SIGNAL hit_cnt : INTEGER;
    SIGNAL clk_ref : STD_LOGIC;
    SIGNAL freq_subtractor, freq_sub : INTEGER;
    SIGNAL flag_wall : STD_LOGIC;

BEGIN

    x_left <= x_pixel_ref;
    x_right <= x_pixel_ref + x_dim;
    y_up <= y_pixel_ref;
    y_down <= y_pixel_ref + y_dim;
    hm_ball_tracking <= y_pixel_ref + (y_dim/2);

    freq_sub <= freq_subtractor;

    draw_ball : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0') THEN
            flag <= '0';
        ELSIF (clk'event AND clk = '1') THEN
            IF (en = '1') THEN
                IF (xscan >= x_left AND xscan <= x_right AND yscan >= y_up AND yscan <= y_down) THEN
                    flag <= '1';
                ELSE
                    flag <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    create_clock_ref : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0') THEN
            clk_ref <= '0';
            cnt <= 0;
        ELSIF (clk'event AND clk = '1') THEN
            IF (en = '1') THEN
                IF (cnt < 104166 - freq_sub) THEN --cambiare questo valore per avere movimenti più fluidi
                    cnt <= cnt + 1;
                ELSE
                    cnt <= 0;
                    clk_ref <= NOT(clk_ref);
                END IF;
            END IF;
        END IF;
    END PROCESS;

    ball_moviment : PROCESS (clk_ref, rstn)
    BEGIN
        IF (rstn = '0') THEN
            y_pixel_ref <= top_limit + ((bottom_limit - top_limit)/2);
            x_pixel_ref <= left_limit + ((right_limit - left_limit)/2);
            vel_x <= 1;
            vel_y <= 0;
            hit_cnt <= 0;
            player_sx_gol <= '0';
            player_dx_gol <= '0';
            hm_flag <= '0';
            freq_subtractor <= 0;
        ELSIF (clk_ref'event AND clk_ref = '1') THEN
            IF (en = '1') THEN
                y_pixel_ref <= y_pixel_ref + vel_y;
                x_pixel_ref <= x_pixel_ref + vel_x;

                -- collisioni muro sopra e sotto
                IF (y_pixel_ref + y_dim >= bottom_limit) THEN
                    vel_y <= - 1;
                ELSIF (y_pixel_ref <= top_limit) THEN
                    vel_y <= 1;
                END IF;

                --collisione racchetta sx
                IF (mode = "00") THEN
                    IF (x_pixel_ref <= x_racket_left + 10 AND y_pixel_ref >= top_limit AND y_pixel_ref <= bottom_limit) THEN
                        hit_cnt <= hit_cnt + 1;
                        vel_x <= 1;
                        flag_wall <= '1';
                    ELSE
                        flag_wall <= '0';
                    END IF;
                ELSE
                    IF (x_pixel_ref <= x_racket_left + 10 AND y_pixel_ref >= y_racket_left - 9 AND y_pixel_ref <= y_racket_left + 56) THEN
                        hit_cnt <= hit_cnt + 1;
                        vel_x <= 1;
                        hm_flag <= '0'; --una volta presa la palla, si ferma (se in hard mode)
                        IF (y_pixel_ref >= y_racket_left - 9 AND y_pixel_ref <= y_racket_left + 14) THEN --parte superiore
                            vel_y <= - 1;
                        ELSIF (y_pixel_ref >= y_racket_left + 15 AND y_pixel_ref <= y_racket_left + 32) THEN --parte centrale
                            vel_y <= 0;
                        ELSIF (y_pixel_ref >= y_racket_left + 33 AND y_pixel_ref <= y_racket_left + 56) THEN --parte inferiore
                            vel_y <= 1;
                        END IF;
                    END IF;
                END IF;

                --collisione racchetta dx 
                IF (x_pixel_ref >= x_racket_right - 10 AND y_pixel_ref >= y_racket_right - 9 AND y_pixel_ref <= y_racket_right + 56) THEN
                    hit_cnt <= hit_cnt + 1;
                    vel_x <= - 1;
                    hm_flag <= '1'; --dal momento in cui il player prende la palla, in hard mode l'avversario si muove verso la direzione

                    IF (mode = "00") THEN
                        IF (y_pixel_ref >= y_racket_left - 9 AND y_pixel_ref <= y_racket_left + 22) THEN --Upper part
                            vel_y <= - 1;
                        ELSIF (y_pixel_ref >= y_racket_left + 23 AND y_pixel_ref <= y_racket_left + 56) THEN --Lower part
                            vel_y <= 1;
                        END IF;
                    ELSIF (mode = "01" OR mode = "10") THEN
                        IF (y_pixel_ref >= y_racket_right - 9 AND y_pixel_ref <= y_racket_right + 14) THEN --parte superiore
                            vel_y <= - 1;
                        ELSIF (y_pixel_ref >= y_racket_right + 15 AND y_pixel_ref <= y_racket_right + 32) THEN --parte centrale
                            vel_y <= 0;
                        ELSIF (y_pixel_ref >= y_racket_right + 33 AND y_pixel_ref <= y_racket_right + 56) THEN --parte inferiore
                            vel_y <= 1;
                        END IF;
                    END IF;
                END IF;

                -- collisione muro dx e sx (GOAL)
                IF (x_pixel_ref + x_dim >= right_limit) THEN
                    hit_cnt <= 0;
                    vel_y <= 0;
                    vel_x <= 1; --palla verso chi ha subito gol
                    player_sx_gol <= '1';
                    freq_subtractor <= 0;
                    y_pixel_ref <= top_limit + ((bottom_limit - top_limit)/2);
                    x_pixel_ref <= left_limit + ((right_limit - left_limit)/2);
                ELSIF (x_pixel_ref <= left_limit) THEN
                    hit_cnt <= 0;
                    vel_y <= 0;
                    vel_x <= - 1;
                    player_dx_gol <= '1';
                    freq_subtractor <= 0;
                    y_pixel_ref <= top_limit + ((bottom_limit - top_limit)/2);
                    x_pixel_ref <= left_limit + ((right_limit - left_limit)/2);
                ELSIF (flag_wall = '1') THEN
                    player_dx_gol <= '1';
                ELSE
                    player_sx_gol <= '0';
                    player_dx_gol <= '0';
                END IF;

                IF (hit_cnt = 5) THEN --dopo 5 scambi aumenta velocità di 2
                    hit_cnt <= 0;
                    freq_subtractor <= freq_subtractor + 5000;
                END IF;
            END IF;
        END IF;
    END PROCESS;

END behavior;