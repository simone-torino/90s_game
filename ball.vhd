LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ball IS
    PORT (
        clk, rstn : IN STD_LOGIC;
        x_pixel_ref, y_pixel_ref : IN INTEGER;
        xscan, yscan : IN INTEGER;
        red, green, blue : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ball;

ARCHITECTURE behavior OF ball IS
    CONSTANT x_dim : INTEGER := 50;
    CONSTANT y_dim : INTEGER := 50;
    CONSTANT x_MAX : INTEGER := 640;
    CONSTANT y_MAX : INTEGER := 480;

    CONSTANT radius : INTEGER := 12;

    SIGNAL x_left, x_right, y_up, y_down : INTEGER;

BEGIN

    x_left <= x_pixel_ref;
    x_right <= x_pixel_ref + x_dim;
    y_up <= y_pixel_ref;
    y_down <= y_pixel_ref + y_dim;

    draw_ball : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0') THEN
            red <= (OTHERS => '0');
            green <= (OTHERS => '0');
            blue <= (OTHERS => '0');
        ELSIF (clk'event AND clk = '1') THEN
        -- 3y-y^2+4x-x^2 > 1000 - r^2
        IF (480*yscan - yscan*yscan + 640*xscan - xscan*xscan > 160000 - radius*radius ) THEN
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

END behavior;