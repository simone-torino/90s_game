LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY field IS
    PORT (
        clk, rstn, en : IN STD_LOGIC;
        xscan, yscan : IN INTEGER;
        right_limit, left_limit, top_limit, bottom_limit : BUFFER INTEGER;
        flag : OUT STD_LOGIC
    );
END field;

ARCHITECTURE behavior OF field IS
    CONSTANT offset : INTEGER := 30; --Distance from display edge
    CONSTANT offset_top : INTEGER := 60; --Distance from the top is higher to let space for text
    CONSTANT thickness : INTEGER := 5; --Thickness of the field edges
    CONSTANT y_max : INTEGER := 480;
    CONSTANT x_max : INTEGER := 640;

BEGIN
    --Field is drawn by overlapping a black rectangle over a slightly larger white rectangle
    draw_field : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0') THEN
            flag <= '0';
        ELSIF (clk'event AND clk = '1') THEN
            IF (en = '1') THEN
                --White rectangle dimensions define the outer edge
                IF (xscan >= offset AND xscan <= x_max - offset AND yscan >= offset_top AND yscan <= y_max - offset) THEN
                    flag <= '1';
                    --Black rectangle dimensions define the inner edge
                    IF (xscan >= left_limit AND xscan <= right_limit AND yscan >= top_limit AND yscan <= bottom_limit) THEN
                        flag <= '0';
                        --Mid vertical line divides the field in half.
                        IF (xscan >= left_limit + ((right_limit - left_limit)/2) - 1 AND xscan <= left_limit + ((right_limit - left_limit)/2) + 1 AND yscan >= top_limit AND yscan <= bottom_limit) THEN
                            flag <= '1';
                        END IF;
                    END IF;
                ELSE
                    flag <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    right_limit <= x_max - offset - thickness;
    left_limit <= offset + thickness;
    top_limit <= offset_top + thickness;
    bottom_limit <= y_max - offset - thickness;

END behavior;