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

	COMPONENT vga_management IS
		PORT (
			clk, rstn : IN STD_LOGIC;
			hs, vs : OUT STD_LOGIC;
			hpos, vpos : BUFFER INTEGER
		);
	END COMPONENT;

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

	COMPONENT field IS
		PORT (
			clk, rstn : IN STD_LOGIC;
			xscan, yscan : IN INTEGER;
			right_limit, left_limit, top_limit, bottom_limit : BUFFER INTEGER;
			flag : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT racket IS
		PORT (
			clk, rstn : IN STD_LOGIC;
			x_pixel_ref : BUFFER INTEGER;
			y_pixel_ref : BUFFER INTEGER;
			xscan, yscan : IN INTEGER;
			button_up, button_down : IN STD_LOGIC;
			top_limit, bottom_limit, lateral_limit : IN INTEGER;
			flag : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT ball IS
		PORT (
			clk, rstn : IN STD_LOGIC;
			x_pixel_ref, y_pixel_ref : BUFFER INTEGER;
			xscan, yscan : IN INTEGER;
			right_limit, left_limit, top_limit, bottom_limit : IN INTEGER;
			y_racket_left, y_racket_right, x_racket_left, x_racket_right : IN INTEGER;
			flag : OUT STD_LOGIC
		);
	END COMPONENT;

	SIGNAL RSTn : STD_LOGIC;
	SIGNAL hpos, vpos : INTEGER;
	SIGNAL hsync, vsync : STD_LOGIC;
	SIGNAL clock25 : STD_LOGIC := '0';
	SIGNAL locked : STD_LOGIC;

	SIGNAL y_ref_right_racket, y_ref_left_racket : INTEGER;
	SIGNAL x_ref_right_racket, x_ref_left_racket : INTEGER;
	
	SIGNAL x_pixel_ref, y_pixel_ref : INTEGER;

	SIGNAL r_field, g_field, b_field : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL r_racket_sx, g_racket_sx, b_racket_sx : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL r_racket_dx, g_racket_dx, b_racket_dx : STD_LOGIC_VECTOR(7 DOWNTO 0);

	SIGNAL pixel_on, pixel_on_field, pixel_on_racket_left, pixel_on_racket_right, pixel_on_ball : STD_LOGIC;

	SIGNAL right_limit, left_limit, top_limit, bottom_limit : INTEGER;

BEGIN

	VGA_SYNC_N <= '1';
	VGA_BLANK_N <= '1';
	RSTn <= NOT(SW(9)) AND LOCKED;

	vga_signals : vga_management PORT MAP(
		clk => clock25, rstn => RSTn,
		hs => hsync, vs => vsync,
		hpos => hpos, vpos => vpos
	);

	ff1 : FlipFlop_D PORT MAP(hsync, clock25, '1', '0', RSTn, VGA_HS);

	ff2 : FlipFlop_D PORT MAP(vsync, clock25, '1', '0', RSTn, VGA_VS);

	phaselockedloop : mypll PORT MAP(refclk => CLOCK_50, rst => SW(9), outclk_0 => clock25, outclk_1 => VGA_CLK, locked => locked);

	field_portmap : field PORT MAP(
		clk => clock25, rstn => RSTn,
		xscan => hpos, yscan => vpos,
		right_limit => right_limit, left_limit => left_limit, top_limit => top_limit, bottom_limit => bottom_limit,
		flag => pixel_on_field
		--		red => r_field, green => g_field, blue => b_field
	);

	--	draw_figures : figures PORT MAP(
	--		clk => clock25, rstn => RSTn,
	--		x_pixel_ref => x_pixel_ref, y_pixel_ref => y_pixel_ref,
	--		xscan => hpos, yscan => vpos,
	--		button_up => NOT(KEY(2)), button_down => NOT(KEY(1)),
	--		button_right => NOT(KEY(0)), button_left => NOT(KEY(3)),
	--		red => VGA_R, green => VGA_G, blue => VGA_B
	--	);

	racket_left_portmap : racket PORT MAP(
		clk => clock25, rstn => RSTn,
		x_pixel_ref => x_ref_left_racket, y_pixel_ref => y_ref_left_racket,
		xscan => hpos, yscan => vpos,
		button_up => NOT(KEY(3)), button_down => NOT(KEY(2)),
		top_limit => top_limit, bottom_limit => bottom_limit, lateral_limit => left_limit + 2,
		flag => pixel_on_racket_left
	);

	racket_right_portmap : racket PORT MAP(
		clk => clock25, rstn => RSTn,
		x_pixel_ref => x_ref_right_racket, y_pixel_ref => y_ref_right_racket,
		xscan => hpos, yscan => vpos,
		button_up => NOT(KEY(1)), button_down => NOT(KEY(0)),
		top_limit => top_limit, bottom_limit => bottom_limit, lateral_limit => right_limit - 10 - 2,
		flag => pixel_on_racket_right
	);

	ball_portmap : ball PORT MAP(
		clk => clock25, rstn => RSTn,
		x_pixel_ref => x_pixel_ref, y_pixel_ref => y_pixel_ref,
		xscan => hpos, yscan => vpos,
		right_limit => right_limit, left_limit => left_limit, top_limit => top_limit, bottom_limit => bottom_limit,
		y_racket_left => y_ref_left_racket, y_racket_right => y_ref_right_racket, 
		x_racket_left => x_ref_left_racket, x_racket_right => x_ref_right_racket,
		flag => pixel_on_ball
	);

	pixel_on <= pixel_on_field OR pixel_on_racket_left OR pixel_on_racket_right OR pixel_on_ball;

	display_all : PROCESS (clock25, RSTn)
	BEGIN
		IF (rstn = '0') THEN
			VGA_R <= (OTHERS => '0');
			VGA_G <= (OTHERS => '0');
			VGA_B <= (OTHERS => '0');
		ELSIF (clock25'event AND clock25 = '1') THEN
			IF (pixel_on = '1') THEN
				VGA_R <= (OTHERS => '1');
				VGA_G <= (OTHERS => '1');
				VGA_B <= (OTHERS => '1');
			ELSE
				VGA_R <= (OTHERS => '0');
				VGA_G <= (OTHERS => '0');
				VGA_B <= (OTHERS => '0');
			END IF;
		END IF;
	END PROCESS;

END behavior;