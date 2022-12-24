LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY field IS
    PORT (
        clk, rstn : IN STD_LOGIC;
        xscan, yscan : IN INTEGER;
        red, green, blue : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END field;

ARCHITECTURE behavior OF field IS
    CONSTANT offset : INTEGER := 30;
    CONSTANT offset_top : INTEGER := 60;
    CONSTANT thickness : INTEGER := 5;
    CONSTANT y_max : INTEGER := 480;
    CONSTANT x_max : INTEGER := 640;

BEGIN
    draw_field : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0') THEN
            red <= (OTHERS => '0');
            green <= (OTHERS => '0');
            blue <= (OTHERS => '0');
        ELSIF (clk'event AND clk = '1') THEN
            IF (xscan >= offset AND xscan <= x_max - offset AND yscan >= offset_top AND yscan <= y_max - offset) THEN
                --           IF (((xscan >= offset AND xscan <= offset + thickness) OR (xscan >= x_max - offset - thickness AND xscan <= x_max - offset)) OR
                --                ((yscan >= offset_top AND yscan <= offset_top + thickness) OR (yscan >= y_max - offset - thickness AND yscan <= y_max - offset))) THEN
                red <= (OTHERS => '1');
                green <= (OTHERS => '1');
                blue <= (OTHERS => '1');
                IF (xscan >= offset + thickness AND xscan <= x_max - offset - thickness AND yscan >= offset_top + thickness AND yscan <= y_max - offset - thickness) THEN
                    red <= (OTHERS => '0');
                    green <= (OTHERS => '0');
                    blue <= (OTHERS => '0');
                END IF;
            ELSE
                red <= (OTHERS => '0');
                green <= (OTHERS => '0');
                blue <= (OTHERS => '0');
            END IF;
        END IF;
    END PROCESS;

END behavior;