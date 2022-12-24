LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY racket IS
    PORT (
        clk, rstn : IN STD_LOGIC;
        x_pixel_ref : IN INTEGER;
        y_pixel_ref : BUFFER INTEGER;
        xscan, yscan : IN INTEGER;
        button_up, button_down : IN STD_LOGIC;
        red, green, blue : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END racket;

ARCHITECTURE behavior OF racket IS
    CONSTANT x_dim : INTEGER := 10;
    CONSTANT y_dim : INTEGER := 56;
    CONSTANT y_min : INTEGER := 65;
    CONSTANT y_MAX : INTEGER := 445;

    SIGNAL x_left, x_right : INTEGER;
    SIGNAL y_up, y_down : INTEGER;
    SIGNAL cnt : INTEGER;
    SIGNAL clk_ref : STD_LOGIC;

BEGIN
    -- value to draw racket
    x_left <= x_pixel_ref;
    x_right <= x_pixel_ref + x_dim;
    y_up <= y_pixel_ref;
    y_down <= y_pixel_ref + y_dim;

    draw_racket : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0') THEN
            red <= (OTHERS => '0');
            green <= (OTHERS => '0');
            blue <= (OTHERS => '0');
        ELSIF (clk'event AND clk = '1') THEN
            IF (xscan >= x_left AND xscan <= x_right AND yscan >= y_up AND yscan <= y_down) THEN
                red <= (OTHERS => '1');
                green <= (OTHERS => '1');
                blue <= (OTHERS => '1');
            ELSE
                red <= (OTHERS => '0');
                green <= (OTHERS => '0');
                blue <= (OTHERS => '0');
            END IF;
        END IF;
    END PROCESS;

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

    racket_moviment_vertical : PROCESS (clk_ref, rstn)
    BEGIN
        IF (rstn = '0') THEN
            y_pixel_ref <= 65 + 190 - (y_dim/2);
        ELSIF (clk_ref'event AND clk_ref = '1') THEN
            IF (button_up = '1') THEN
                IF (y_pixel_ref > y_min) THEN
                    y_pixel_ref <= y_pixel_ref - 1;
                END IF;
            END IF;
            IF (button_down = '1') THEN
                IF (y_pixel_ref + y_dim < y_MAX) THEN
                    y_pixel_ref <= y_pixel_ref + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

END behavior;