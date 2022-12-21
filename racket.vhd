LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY racket IS
    PORT (
        clk, rstn : IN STD_LOGIC;
        x_pixel_ref, y_pixel_ref : IN INTEGER;
        xscan, yscan : IN INTEGER;
        red, green, blue : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END racket;

ARCHITECTURE behavior OF racket IS
    CONSTANT x_dim : INTEGER := 15;
    CONSTANT y_dim : INTEGER := 70;
    CONSTANT x_MAX : INTEGER := 640;
    CONSTANT y_MAX : INTEGER := 480;

    SIGNAL x_left, x_right, y_up, y_down : INTEGER;

BEGIN

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
                blue <= (OTHERS => '0');
            ELSE
                red <= (OTHERS => '0');
                green <= (OTHERS => '0');
                blue <= (OTHERS => '0');
            END IF;
        END IF;
    END PROCESS;

END behavior;