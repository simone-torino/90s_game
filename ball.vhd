LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ball IS
    PORT (
        clk, rstn : IN STD_LOGIC;
        x_pixel_ref, y_pixel_ref : BUFFER INTEGER;
        xscan, yscan : IN INTEGER;
        right_limit, left_limit, top_limit, bottom_limit : IN INTEGER;
        y_racket_left, y_racket_right, x_racket_left, x_racket_right : IN INTEGER;
        flag : OUT STD_LOGIC
    );
END ball;

ARCHITECTURE behavior OF ball IS
    CONSTANT x_dim : INTEGER := 10;
    CONSTANT y_dim : INTEGER := 10;

    SIGNAL x_left, x_right, y_up, y_down : INTEGER;
    SIGNAL vel_x, vel_y : INTEGER;
    SIGNAL cnt : INTEGER;
    SIGNAL clk_ref : STD_LOGIC;

BEGIN

    x_left <= x_pixel_ref;
    x_right <= x_pixel_ref + x_dim;
    y_up <= y_pixel_ref;
    y_down <= y_pixel_ref + y_dim;

    draw_ball : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0') THEN
            flag <= '0';
        ELSIF (clk'event AND clk = '1') THEN
            IF (xscan >= x_left AND xscan <= x_right AND yscan >= y_up AND yscan <= y_down) THEN
                flag <= '1';
            ELSE
                flag <= '0';
            END IF;
        END IF;
    END PROCESS;

    create_clock_ref : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0') THEN
            clk_ref <= '0';
            cnt <= 0;
        ELSIF (clk'event AND clk = '1') THEN
            IF (cnt < 208333) THEN --cambiare questo valore per avere movimenti più fluidi
                cnt <= cnt + 1;
            ELSE
                cnt <= 0;
                clk_ref <= NOT(clk_ref);
            END IF;
        END IF;
    END PROCESS;

    ball_moviment : PROCESS (clk_ref, rstn)
    BEGIN
        IF (rstn = '0') THEN
            y_pixel_ref <= 100; --top_limit + ((bottom_limit - top_limit)/2);
            x_pixel_ref <= 100; --left_limit + ((right_limit - left_limit)/2);
            vel_x <= 2;
            vel_y <= 2;
        ELSIF (clk_ref'event AND clk_ref = '1') THEN
            y_pixel_ref <= y_pixel_ref + vel_y;
            x_pixel_ref <= x_pixel_ref + vel_x;
            -- collisioni muro sopra e sotto
            IF (y_pixel_ref + y_dim > bottom_limit) THEN
                vel_y <= - 2;
            ELSIF (y_pixel_ref < top_limit) THEN
                vel_y <= 2;
            END IF;

            --collisione racchetta sx
            IF (x_pixel_ref < x_racket_left + 10 AND y_pixel_ref > y_racket_left - 9 AND y_pixel_ref < y_racket_left + 56) THEN
                vel_x <= 2;
                --collisione racchetta dx 
            ELSIF (x_pixel_ref > x_racket_right - 10 AND y_pixel_ref > y_racket_right - 9 AND y_pixel_ref < y_racket_right + 56) THEN
                vel_x <= - 2;
            END IF;

            -- collisione muro dx e sx
            IF (x_pixel_ref + x_dim > right_limit) THEN
                vel_x <= - 2;
            ELSIF (x_pixel_ref < left_limit) THEN
                vel_x <= 2;
            END IF;
        END IF;
    END PROCESS;

END behavior;