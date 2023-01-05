LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY game IS
    PORT (
        clk, rstn : IN STD_LOGIC;
        KEY : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        hpos, vpos : IN INTEGER;
        HEX0 : OUT STD_LOGIC_VECTOR(0 TO 6);
        HEX5 : OUT STD_LOGIC_VECTOR(0 TO 6);
        end_game : OUT STD_LOGIC;
        pixel_on, pixel_on_racket_left, pixel_on_racket_right : OUT STD_LOGIC
    );
END game;

ARCHITECTURE behavior OF game IS

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
            en_one_player : IN STD_LOGIC;
            en_difficulty : IN INTEGER;
            hm_ball_tracking : IN INTEGER;
            hm_flag : IN STD_LOGIC;
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
            hm_flag : OUT STD_LOGIC; --hard mode flag per muovere la racchetta avversaria
            hm_ball_tracking : OUT INTEGER;
            flag : OUT STD_LOGIC;
            player_dx_gol : OUT STD_LOGIC;
            player_sx_gol : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT scoreboard IS
        PORT (
            rstn : IN STD_LOGIC;
            player_dx_gol, player_sx_gol : IN STD_LOGIC;
            game_end : OUT STD_LOGIC;
            seg_dx : OUT STD_LOGIC_VECTOR (0 TO 6);
            seg_sx : OUT STD_LOGIC_VECTOR (0 TO 6)
        );
    END COMPONENT;

    SIGNAL y_ref_right_racket, y_ref_left_racket : INTEGER;
    SIGNAL x_ref_right_racket, x_ref_left_racket : INTEGER;

    SIGNAL x_pixel_ref, y_pixel_ref : INTEGER;

    SIGNAL r_field, g_field, b_field : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL r_racket_sx, g_racket_sx, b_racket_sx : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL r_racket_dx, g_racket_dx, b_racket_dx : STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL pixel_on_field, pixel_on_ball : STD_LOGIC;

    SIGNAL right_limit, left_limit, top_limit, bottom_limit : INTEGER;

    SIGNAL player_dx_gol, player_sx_gol : STD_LOGIC;

    SIGNAL hm_ball_tracking : INTEGER;
    SIGNAL hm_flag : STD_LOGIC;
    SIGNAL en_one_player : STD_LOGIC;
    SIGNAL en_difficulty : INTEGER;

BEGIN

    field_portmap : field PORT MAP(
        clk => clk, rstn => rstn,
        xscan => hpos, yscan => vpos,
        right_limit => right_limit, left_limit => left_limit, top_limit => top_limit, bottom_limit => bottom_limit,
        flag => pixel_on_field
    );

    racket_left_portmap : racket PORT MAP(
        clk => clk, rstn => rstn,
        x_pixel_ref => x_ref_left_racket, y_pixel_ref => y_ref_left_racket,
        xscan => hpos, yscan => vpos,
        button_up => NOT(KEY(3)), button_down => NOT(KEY(2)),
        top_limit => top_limit, bottom_limit => bottom_limit, lateral_limit => left_limit + 2,
        en_one_player => '1', en_difficulty => 2, --da modificare en_one_player in seguito
        hm_ball_tracking => hm_ball_tracking, hm_flag => hm_flag,
        flag => pixel_on_racket_left
    );

    racket_right_portmap : racket PORT MAP(
        clk => clk, rstn => rstn,
        x_pixel_ref => x_ref_right_racket, y_pixel_ref => y_ref_right_racket,
        xscan => hpos, yscan => vpos,
        button_up => NOT(KEY(1)), button_down => NOT(KEY(0)),
        top_limit => top_limit, bottom_limit => bottom_limit, lateral_limit => right_limit - 10 - 2,
        en_one_player => '0', en_difficulty => en_difficulty,
        hm_ball_tracking => hm_ball_tracking, hm_flag => hm_flag,
        flag => pixel_on_racket_right
    );

    ball_portmap : ball PORT MAP(
        clk => clk, rstn => rstn,
        x_pixel_ref => x_pixel_ref, y_pixel_ref => y_pixel_ref,
        xscan => hpos, yscan => vpos,
        right_limit => right_limit, left_limit => left_limit, top_limit => top_limit, bottom_limit => bottom_limit,
        y_racket_left => y_ref_left_racket, y_racket_right => y_ref_right_racket,
        x_racket_left => x_ref_left_racket, x_racket_right => x_ref_right_racket,
        hm_flag => hm_flag, hm_ball_tracking => hm_ball_tracking,
        flag => pixel_on_ball,
        player_dx_gol => player_dx_gol, player_sx_gol => player_sx_gol
    );

    scoreboard_portmap : scoreboard PORT MAP(
        rstn => rstn,
        player_dx_gol => player_dx_gol, player_sx_gol => player_sx_gol,
        game_end => end_game,
        seg_dx => HEX0, seg_sx => HEX5
    );

    pixel_on <= pixel_on_field OR pixel_on_ball;

END behavior;