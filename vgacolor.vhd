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

	COMPONENT Decoder IS
		PORT (
			row_add : IN INTEGER; --row pixel coordinate
			column_add : IN INTEGER; --column pixel coordinate
			address : OUT STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0'));
	END COMPONENT;

	COMPONENT fontrom IS
		PORT (
			aclr : IN STD_LOGIC := '0';
			address : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
			clock : IN STD_LOGIC := '1';
			rden : IN STD_LOGIC := '1';
			q : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
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

	SIGNAL adx : STD_LOGIC_VECTOR(10 DOWNTO 0);
	SIGNAL text_out : STD_LOGIC_VECTOR (7 DOWNTO 0);

	SIGNAL buffer_r : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL buffer_b : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL buffer_g : STD_LOGIC_VECTOR (7 DOWNTO 0);

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

	characterdecoder : Decoder PORT MAP(vpos, hpos, adx);

	rom : fontrom PORT MAP(SW(9), adx, clock25, '1', text_out);

	PROCESS (vpos, hpos)
	BEGIN
		IF (vpos >= 0 AND hpos >= 0 AND
			vpos < 480 AND hpos < 640) THEN --qui penso ci vadano i limiti dello schermo ma non sono sicurissimo
			buffer_r <= text_out;
			buffer_b <= text_out;
			buffer_g <= text_out;
		ELSE
			buffer_r <= (OTHERS => '0');
			buffer_b <= (OTHERS => '0');
			buffer_g <= (OTHERS => '0');
		END IF;
	END PROCESS;
	VGA_R <= buffer_r;
	VGA_G <= buffer_b;
	VGA_B <= buffer_g;

END behavior;