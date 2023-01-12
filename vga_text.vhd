LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pong_text IS
    PORT (
        clk, rstn : IN STD_LOGIC;
        pixel_x, pixel_y : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dig0, dig1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        ball : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        text_on : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        text_rgb : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END pong_text;