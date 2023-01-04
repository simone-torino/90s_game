LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY menu IS
    PORT (
        clk : IN STD_LOGIC; -- clock signal
        rstn : IN STD_LOGIC; -- rstn signal
        KEY0 : IN STD_LOGIC; -- input button for selecting number of players
        KEY1 : IN STD_LOGIC; -- input button for selecting game mode
        KEY2 : IN STD_LOGIC; -- input button for starting the game
        game_end : IN STD_LOGIC; --flag that ends the game
        pixel_en : OUT STD_LOGIC; -- output signal for text display
        num_players : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- output signal for number of players
        game_mode : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)); -- output signal for game mode
END menu;

-- Architecture body
ARCHITECTURE rtl OF menu IS
    TYPE state_type IS (idle, num_players_selection, game_mode_selection, start_game, current_game, win);
    SIGNAL current_state, next_state : state_type;
BEGIN
    -- state machine
    PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0') THEN
            current_state <= idle;
        ELSIF (clk'event AND clk = '1') THEN
            current_state <= next_state;
        END IF;
    END PROCESS;

    -- state transitions
    PROCESS (current_state, KEY0, KEY1, KEY2)
    BEGIN
        CASE current_state IS
            WHEN idle => --front page
                IF (KEY0 = '1') THEN --start button
                    next_state <= num_players_selection;
                ELSE
                    next_state <= idle;
                END IF;
            WHEN num_players_selection =>
                IF (KEY0 = '1') THEN
                    num_players <= "00";
                    next_state <= game_mode_selection;
                ELSIF (KEY1 = '1') THEN
                    num_players <= "01";
                    next_state <= game_mode_selection;
                ELSE
                    next_state <= num_players_selection;
                END IF;
            WHEN game_mode_selection =>
                IF (KEY0 = '1') THEN
                    game_mode <= "000";
                    next_state <= start_game;
                ELSIF (KEY1 = '1') THEN
                    game_mode <= "001";
                    next_state <= start_game;
                ELSIF (KEY2 = '1') THEN
                    game_mode <= "010";
                    next_state <= start_game;
                ELSE
                    next_state <= game_mode_selection;
                END IF;
            WHEN start_game =>
                IF (KEY0 = '1') THEN --start the game
                    next_state <= current_game;
                ELSIF (KEY1 = '1') THEN --back button
                    next_state <= idle;
            WHEN current_game =>
                IF (game_end = '1') THEN
                    next_state <= win;
            WHEN win =>
                IF (KEY0 = '1' OR KEY1 = '1' OR KEY2 = '1') THEN
                    next_state <= idle;
            WHEN OTHERS =>
                next_state <= idle;
        END CASE;
    END PROCESS;

    CC2: PROCESS (current_state)
	BEGIN
		CASE current_state IS
			WHEN idle =>
                pixel_en <= "0001";
			WHEN num_players_selection =>
                pixel_en <= "0010";
            WHEN game_mode_selection =>
                pixel_en <= "0011";
            WHEN start_game =>
                pixel_en <= "0100";
            WHEN current_game =>
                pixel_en <= "0101";
            WHEN win =>
                pixel_en <= "0110";
			WHEN OTHERS => 
            END CASE;
			
	END PROCESS;

END rtl;