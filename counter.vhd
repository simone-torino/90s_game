LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY counter IS
    PORT (
        clk, rstn, en : IN STD_LOGIC;
        tc : OUT STD_LOGIC
    );
END counter;

ARCHITECTURE behavior OF counter IS

    SIGNAL cnt : INTEGER;

BEGIN
    count : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0') THEN
            tc <= '0';
            cnt <= 0;
        ELSIF (clk'event AND clk = '1') THEN
            IF (en = '1') THEN
                IF (cnt < 25000000) THEN
                    cnt <= cnt + 1;
                    tc <= '0';
                ELSE
                    cnt <= 0;
                    tc <= '1';
                END IF;
            ELSE
                tc <= '0';
                cnt <= 0;
            END IF;
        END IF;
    END PROCESS;

END behavior;