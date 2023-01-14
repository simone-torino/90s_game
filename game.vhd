LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

--component used to combine all components necessary to play
ENTITY game IS
    PORT (
        clk, rstn, en : IN STD_LOGIC;
        button : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        hpos, vpos : IN INTEGER;
        choose_mode : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        score_dx1, score_dx0 : OUT STD_LOGIC_VECTOR(0 TO 6);
        score_sx5, score_sx4 : OUT STD_LOGIC_VECTOR(0 TO 6);
        end_game : OUT STD_LOGIC;
        pixel_on, pixel_on_racket_left, pixel_on_racket_right : OUT STD_LOGIC
    );
END game;

ARCHITECTURE behavior OF game IS

    --drow the playground
    COMPONENT field IS
        PORT (
            clk, rstn, en : IN STD_LOGIC;
            xscan, yscan : IN INTEGER;
            right_limit, left_limit, top_limit, bottom_limit : BUFFER INTEGER;
            flag : OUT STD_LOGIC
        );
    END COMPONENT;

    --drow and move the rackets according to the game mode
    COMPONENT racket IS
        PORT (
            clk, rstn, en : IN STD_LOGIC;
            x_pixel_ref : BUFFER INTEGER;
            y_pixel_ref : BUFFER INTEGER;
            xscan, yscan : IN INTEGER;
            button_up, button_down : IN STD_LOGIC;
            top_limit, bottom_limit, lateral_limit : IN INTEGER;
            en_mode : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            hm_ball_tracking : IN INTEGER;
            hm_flag : IN STD_LOGIC;
            flag : OUT STD_LOGIC
        );
    END COMPONENT;

    --drow and manage the ball moviments 
    COMPONENT ball IS
        PORT (
            clk, rstn, en : IN STD_LOGIC;
            x_pixel_ref, y_pixel_ref : BUFFER INTEGER;
            xscan, yscan : IN INTEGER;
            right_limit, left_limit, top_limit, bottom_limit : IN INTEGER;
            y_racket_left, y_racket_right, x_racket_left, x_racket_right : IN INTEGER;
            mode : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
            hm_flag : OUT STD_LOGIC; --hard mode flag per muovere la racchetta avversaria
            hm_ball_tracking : OUT INTEGER;
            flag : OUT STD_LOGIC;
            player_dx_gol : OUT STD_LOGIC;
            player_sx_gol : OUT STD_LOGIC
        );
    END COMPONENT;

    --manage the score on the 7 segments display
    COMPONENT scoreboard IS
        PORT (
            rstn : IN STD_LOGIC;
            player_dx_gol, player_sx_gol : IN STD_LOGIC;
            mode : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
            game_end : OUT STD_LOGIC;
            seg_5, seg_4 : OUT STD_LOGIC_VECTOR (0 TO 6);
            seg_1, seg_0 : OUT STD_LOGIC_VECTOR (0 TO 6)
        );
    END COMPONENT;

    --reference signals for the top-left pixel of right and left racket
    SIGNAL y_ref_right_racket, y_ref_left_racket : INTEGER;
    SIGNAL x_ref_right_racket, x_ref_left_racket : INTEGER;

    --reference signals por the top-left pixel of the ball
    SIGNAL x_pixel_ref_ball, y_pixel_ref_ball : INTEGER;

    --flag referring to pixel to turn on to display field and ball on the screen  
    SIGNAL pixel_on_field, pixel_on_ball : STD_LOGIC;

    --field limits
    SIGNAL right_limit, left_limit, top_limit, bottom_limit : INTEGER;

    --signal to manage points
    SIGNAL player_dx_gol, player_sx_gol : STD_LOGIC;

    --signal to track ball and to active racket moviment for cpu mode
    SIGNAL hm_ball_tracking : INTEGER;
    SIGNAL hm_flag : STD_LOGIC;

    --signals for expressions in the portmap
    SIGNAL s_button3 : STD_LOGIC;
    SIGNAL s_button2 : STD_LOGIC;
    SIGNAL s_button1 : STD_LOGIC;
    SIGNAL s_button0 : STD_LOGIC;
    SIGNAL s_limit_sx : INTEGER;
    SIGNAL s_limit_dx : INTEGER;

BEGIN

    s_button3 <= NOT(button(3));
    s_button2 <= NOT(button(2));
    s_button1 <= NOT(button(1));
    s_button0 <= NOT(button(0));

    s_limit_sx <= left_limit + 2;
    s_limit_dx <= right_limit - 10 - 2;

    --components port map

    field_portmap : field PORT MAP(
        clk => clk, rstn => rstn, en => en,
        xscan => hpos, yscan => vpos,
        right_limit => right_limit, left_limit => left_limit, top_limit => top_limit, bottom_limit => bottom_limit,
        flag => pixel_on_field
    );

    racket_left_portmap : racket PORT MAP(
        clk => clk, rstn => rstn, en => en,
        x_pixel_ref => x_ref_left_racket, y_pixel_ref => y_ref_left_racket,
        xscan => hpos, yscan => vpos,
        button_up => s_button3, button_down => s_button2,
        top_limit => top_limit, bottom_limit => bottom_limit, lateral_limit => s_limit_sx,
        en_mode => choose_mode,
        hm_ball_tracking => hm_ball_tracking, hm_flag => hm_flag,
        flag => pixel_on_racket_left
    );

    racket_right_portmap : racket PORT MAP(
        clk => clk, rstn => rstn, en => en,
        x_pixel_ref => x_ref_right_racket, y_pixel_ref => y_ref_right_racket,
        xscan => hpos, yscan => vpos,
        button_up => s_button1, button_down => s_button0,
        top_limit => top_limit, bottom_limit => bottom_limit, lateral_limit => s_limit_dx,
        en_mode => "10",
        hm_ball_tracking => hm_ball_tracking, hm_flag => hm_flag,
        flag => pixel_on_racket_right
    );

    ball_portmap : ball PORT MAP(
        clk => clk, rstn => rstn, en => en,
        x_pixel_ref => x_pixel_ref_ball, y_pixel_ref => y_pixel_ref_ball,
        xscan => hpos, yscan => vpos,
        right_limit => right_limit, left_limit => left_limit, top_limit => top_limit, bottom_limit => bottom_limit,
        mode => choose_mode,
        y_racket_left => y_ref_left_racket, y_racket_right => y_ref_right_racket,
        x_racket_left => x_ref_left_racket, x_racket_right => x_ref_right_racket,
        hm_flag => hm_flag, hm_ball_tracking => hm_ball_tracking,
        flag => pixel_on_ball,
        player_dx_gol => player_dx_gol, player_sx_gol => player_sx_gol
    );

    scoreboard_portmap : scoreboard PORT MAP(
        rstn => rstn,
        player_dx_gol => player_dx_gol, player_sx_gol => player_sx_gol,
        mode => choose_mode,
        game_end => end_game,
        seg_5 => score_sx5, seg_4 => score_sx4,
        seg_1 => score_dx1, seg_0 => score_dx0
    );

    --white pixels in game
    pixel_on <= pixel_on_field OR pixel_on_ball;

END behavior;