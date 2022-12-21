LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY vgacolor IS

	PORT (
		CLOCK_50 : IN STD_LOGIC;
		KEY : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		VGA_R, VGA_B, VGA_G : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		VGA_CLK, VGA_SYNC_N, VGA_BLANK_N : OUT STD_LOGIC;
		VGA_VS, VGA_HS : OUT STD_LOGIC;
		SW : IN STD_LOGIC_VECTOR(9 DOWNTO 9)
	);
END vgacolor;

ARCHITECTURE behavior OF vgacolor IS

	COMPONENT FlipFlop_D IS
		PORT (
			D, Clk, Ld, Clr, Rstn : IN STD_LOGIC;
			Q : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT mypll IS
		PORT (
			refclk : IN STD_LOGIC := '0'; --  refclk.clk
			rst : IN STD_LOGIC := '0'; --   reset.reset
			outclk_0 : OUT STD_LOGIC; -- outclk0.clk
			outclk_1 : OUT STD_LOGIC; -- outclk1.clk
			locked : OUT STD_LOGIC --  locked.export
		);
	END COMPONENT;

	COMPONENT cube IS
		PORT (
			clk, rstn : IN STD_LOGIC;
			x_pixel_ref, y_pixel_ref : IN INTEGER;
			xscan, yscan : IN INTEGER;
			red, green, blue : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT move_cube IS
		PORT (
			clk, rstn : IN STD_LOGIC;
			button_up, button_down, button_right, button_left : IN STD_LOGIC;
			x_pixel_ref, y_pixel_ref : BUFFER INTEGER
		);
	END COMPONENT;

	CONSTANT ha : INTEGER := 96;
	CONSTANT hb : INTEGER := 48;
	CONSTANT hc : INTEGER := 640;
	CONSTANT hd : INTEGER := 16;

	CONSTANT va : INTEGER := 2;
	CONSTANT vb : INTEGER := 33;
	CONSTANT vc : INTEGER := 480;
	CONSTANT vd : INTEGER := 10;

	SIGNAL RSTn : STD_LOGIC;
	SIGNAL hpos, vpos : INTEGER;
	SIGNAL hsync, vsync : STD_LOGIC;
	SIGNAL clock25 : STD_LOGIC := '0';
	SIGNAL locked : STD_LOGIC;

	SIGNAL x_pixel_ref : INTEGER;
	SIGNAL y_pixel_ref : INTEGER;

BEGIN

	--locked <= '1';
	VGA_SYNC_N <= '1';
	VGA_BLANK_N <= '1';
	RSTn <= NOT(SW(9)) AND LOCKED;

	--	clk25 : PROCESS (CLOCK_50)
	--	BEGIN
	--		IF (CLOCK_50'EVENT AND CLOCK_50 = '1') THEN
	--			clock25 <= NOT clock25;
	--		END IF;
	--	END PROCESS;

	hscan : PROCESS (clock25, RSTn)
	BEGIN
		IF (RSTn = '0') THEN
			hpos <= 0;
		ELSIF (clock25'EVENT AND clock25 = '1') THEN
			IF (hpos = (ha + hb + hc + hd - 1)) THEN
				hpos <= 0;
			ELSE
				hpos <= hpos + 1;
			END IF;
		END IF;
	END PROCESS;

	vscan : PROCESS (clock25, RSTn)
	BEGIN
		IF (RSTn = '0') THEN
			vpos <= 0;
		ELSIF (clock25'EVENT AND clock25 = '1') THEN
			IF (vpos >= (va + vb + vc + vd - 1)) THEN
				vpos <= 0;
			ELSIF (hpos = ha + hb + hc + hd - 1) THEN
				vpos <= vpos + 1;
			END IF;
		END IF;
	END PROCESS;
	--sync signal
	hsynch : PROCESS (clock25, RSTn)
	BEGIN
		IF (RSTn = '0') THEN
			hsync <= '1';
		ELSIF (clock25'EVENT AND clock25 = '1') THEN
			IF (hpos > (hc + hd - 1) AND hpos <= (hc + hd + ha - 1)) THEN
				hsync <= '0';
			ELSE
				hsync <= '1';
			END IF;
		END IF;

	END PROCESS;

	--VGA_HS <= hsync;
	--VGA_VS <= vsync;

	ff1 : FlipFlop_D PORT MAP(hsync, clock25, '1', '0', RSTn, VGA_HS);
	vsynch : PROCESS (clock25, RSTn)
	BEGIN
		IF (RSTn = '0') THEN
			vsync <= '0';
		ELSIF (clock25'EVENT AND clock25 = '1') THEN
			IF (vpos > (vc + vd - 1) AND vpos <= (vc + vd + va - 1)) THEN
				vsync <= '0';
			ELSE
				vsync <= '1';
			END IF;
		END IF;

	END PROCESS;

	ff2 : FlipFlop_D PORT MAP(vsync, clock25, '1', '0', RSTn, VGA_VS);

	phaselockedloop : mypll PORT MAP(refclk => CLOCK_50, rst => SW(9), outclk_0 => clock25, outclk_1 => VGA_CLK, locked => locked);

	draw_cube : cube PORT MAP(
		clk => clock25, rstn => RSTn,
		x_pixel_ref => x_pixel_ref, y_pixel_ref => y_pixel_ref,
		xscan => hpos, yscan => vpos,
		red => VGA_R, green => VGA_G, blue => VGA_B);

	cube_moviment : move_cube PORT MAP(
		clk => clock25, rstn => RSTn,
		button_up => NOT(KEY(2)), button_down => NOT(KEY(1)),
		button_right => NOT(KEY(0)), button_left => NOT(KEY(3)),
		x_pixel_ref => x_pixel_ref, y_pixel_ref => y_pixel_ref);

END behavior;