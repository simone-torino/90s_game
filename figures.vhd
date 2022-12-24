LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY figures IS
    PORT (
        clk, rstn : IN STD_LOGIC;
        x_pixel_ref, y_pixel_ref : IN INTEGER;
        xscan, yscan : IN INTEGER;
        button_up, button_down, button_left, button_right : IN STD_LOGIC;
        red, green, blue : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END figures;

ARCHITECTURE behavior OF figures IS
    COMPONENT field IS
        PORT (
            clk, rstn : IN STD_LOGIC;
            xscan, yscan : IN INTEGER;
            out_field : OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT cube IS
        PORT (
            clk, rstn : IN STD_LOGIC;
            x_pixel_ref, y_pixel_ref : IN INTEGER;
            xscan, yscan : IN INTEGER;
            out_cube : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT move_cube IS
        PORT (
            clk, rstn : IN STD_LOGIC;
            button_up, button_down, button_right, button_left : IN STD_LOGIC;
            x_pixel_ref, y_pixel_ref : BUFFER INTEGER
        );
    END COMPONENT;

    SIGNAL out_field, out_cube : STD_LOGIC_VECTOR (23 DOWNTO 0);
BEGIN

    draw_field : field PORT MAP(
        clk => clk, rstn => rstn,
        xscan => xscan, yscan => yscan,
        out_field => out_field
    );

    draw_cube : cube PORT MAP(
        clk => clk, rstn => rstn,
        x_pixel_ref => x_pixel_ref, y_pixel_ref => y_pixel_ref,
        xscan => xscan, yscan => yscan,
        out_cube => out_cube
    );

    moviment_cube : move_cube PORT MAP(
        clk => clk, rstn => rstn,
        button_up => button_up, button_down => button_down, button_right => button_right, button_left => button_left,
        x_pixel_ref => x_pixel_ref, y_pixel_ref => y_pixel_ref
    );

    PROCESS (rstn, clk)
    BEGIN
        IF (rstn = '0') THEN
            flag <= '0';
        ELSIF (clk'event AND clk = '1') THEN
            flag <= NOT(flag);
        END IF;
    END PROCESS;

    PROCESS (flag)
    BEGIN
        IF (flag = '0') THEN
            red <= out_field(23 DOWNTO 16);
            green <= out_field (15 DOWNTO 8);
            blue <= out_field (7 DOWNTO 0);
        ELSIF (flag = '1') THEN
            red <= out_cube(23 DOWNTO 16);
            green <= out_cube (15 DOWNTO 8);
            blue <= out_cube (7 DOWNTO 0);
        END IF;
    END PROCESS;

END behavior;