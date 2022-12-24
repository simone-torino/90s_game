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

--	COMPONENT cube IS
--		PORT (
--			clk, rstn : IN STD_LOGIC;
--			x_pixel_ref, y_pixel_ref : BUFFER INTEGER;
--			xscan, yscan : IN INTEGER;
--			button_up, button_down, button_right, button_left : IN STD_LOGIC;
--			red, green, blue : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
--		);
--	END COMPONENT;

	COMPONENT field IS
		PORT (
			clk, rstn : IN STD_LOGIC;
			xscan, yscan : IN INTEGER;
			red, green, blue : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT racket IS
		PORT (
			clk, rstn : IN STD_LOGIC;
			x_pixel_ref : IN INTEGER;
			y_pixel_ref : BUFFER INTEGER;
			xscan, yscan : IN INTEGER;
			button_up, button_down : IN STD_LOGIC;
			red, green, blue : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
		);
	END COMPONENT;

	--	COMPONENT move_cube IS
	--		PORT (
	--			clk, rstn : IN STD_LOGIC;
	--			button_up, button_down, button_right, button_left : IN STD_LOGIC;
	--			x_pixel_ref, y_pixel_ref : BUFFER INTEGER
	--		);
	--	END COMPONENT;

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

--	SIGNAL r_cube, g_cube, b_cube : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL r_field, g_field, b_field : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL r_racket_sx, g_racket_sx, b_racket_sx : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL r_racket_dx, g_racket_dx, b_racket_dx : STD_LOGIC_VECTOR(7 DOWNTO 0);

	SIGNAL choose_output : INTEGER;

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

--	cube_portmap : cube PORT MAP(
--		clk => clock25, rstn => RSTn,
--		x_pixel_ref => x_pixel_ref, y_pixel_ref => y_pixel_ref,
--		xscan => hpos, yscan => vpos,
--		button_up => NOT(KEY(2)), button_down => NOT(KEY(1)),
--		button_right => NOT(KEY(0)), button_left => NOT(KEY(3)),
--		red => r_cube, green => g_cube, blue => b_cube);

	--	cube_moviment : move_cube PORT MAP(
	--		clk => clock25, rstn => RSTn,
	--		button_up => NOT(KEY(2)), button_down => NOT(KEY(1)),
	--		button_right => NOT(KEY(0)), button_left => NOT(KEY(3)),
	--		x_pixel_ref => x_pixel_ref, y_pixel_ref => y_pixel_ref);

	field_portmap : field PORT MAP(
		clk => clock25, rstn => RSTn,
		xscan => hpos, yscan => vpos,
		red => r_field, green => g_field, blue => b_field);

	--	draw_figures : figures PORT MAP(
	--		clk => clock25, rstn => RSTn,
	--		x_pixel_ref => x_pixel_ref, y_pixel_ref => y_pixel_ref,
	--		xscan => hpos, yscan => vpos,
	--		button_up => NOT(KEY(2)), button_down => NOT(KEY(1)),
	--		button_right => NOT(KEY(0)), button_left => NOT(KEY(3)),
	--		red => VGA_R, green => VGA_G, blue => VGA_B
	--	);

	racket_sx_portmap : racket PORT MAP(
		clk => clock25, rstn => RSTn,
		x_pixel_ref => 37, y_pixel_ref => y_pixel_ref,
		xscan => hpos, yscan => vpos,
		button_up => NOT(KEY(3)), button_down => NOT(KEY(2)),
		red => r_racket_sx, green => g_racket_sx, blue => b_racket_sx);

	racket_dx_portmap : racket PORT MAP(
		clk => clock25, rstn => RSTn,
		x_pixel_ref => 593, y_pixel_ref => y_pixel_ref,
		xscan => hpos, yscan => vpos,
		button_up => NOT(KEY(1)), button_down => NOT(KEY(0)),
		red => r_racket_dx, green => g_racket_dx, blue => b_racket_dx);

	display_all : PROCESS (clock25, RSTn)
	BEGIN
		IF (rstn = '0') THEN
			VGA_R <= (OTHERS => '0');
			VGA_G <= (OTHERS => '0');
			VGA_B <= (OTHERS => '0');
			choose_output <= 0;
		ELSIF (clock25'event AND clock25 = '1') THEN
			CASE choose_output IS
--				WHEN 0 => --display cube
--					VGA_R <= r_cube;
--					VGA_G <= g_cube;
--					VGA_B <= b_cube;
--					choose_output <= 1;
				WHEN 0 => --display field
					VGA_R <= r_field;
					VGA_G <= g_field;
					VGA_B <= b_field;
					choose_output <= 1;
				WHEN 1 => --display racket sx
					VGA_R <= r_racket_sx;
					VGA_G <= g_racket_sx;
					VGA_B <= b_racket_sx;
					choose_output <= 2;
				WHEN 2 => --display racket dx
					VGA_R <= r_racket_dx;
					VGA_G <= g_racket_dx;
					VGA_B <= b_racket_dx;
					choose_output <= 0;
				WHEN OTHERS =>
					VGA_R <= (OTHERS => '0');
					VGA_G <= (OTHERS => '0');
					VGA_B <= (OTHERS => '0');
					choose_output <= 0;
			END CASE;
		END IF;
	END PROCESS;

END behavior;