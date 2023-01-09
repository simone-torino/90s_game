LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY vgacolor IS

	PORT (
		clk, rstn : IN STD_LOGIC;
		pixel_on, pixel_on_racket_left, pixel_on_racket_right, pixel_on_menu : IN STD_LOGIC;
		red, blue, green : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END vgacolor;

ARCHITECTURE behavior OF vgacolor IS

BEGIN

	display_all : PROCESS (clk, rstn)
	BEGIN
		IF (rstn = '0') THEN
			red <= (OTHERS => '0');
			green <= (OTHERS => '0');
			blue <= (OTHERS => '0');
		ELSIF (clk'event AND clk = '1') THEN
			IF (pixel_on_racket_left = '1') THEN
				red <= (OTHERS => '1');
				green <= (OTHERS => '0');
				blue <= (OTHERS => '0');
			ELSIF (pixel_on_racket_right = '1') THEN
				red <= (OTHERS => '0');
				green <= (OTHERS => '1');
				blue <= (OTHERS => '1');
			ELSIF (pixel_on = '1' OR pixel_on_menu = '1') THEN
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