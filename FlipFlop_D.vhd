LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY FlipFlop_D IS
    PORT (
        D, Clk, Ld, Clr, Rstn : IN STD_LOGIC;
        Q : OUT STD_LOGIC
    );
END FlipFlop_D;

ARCHITECTURE behavior OF FlipFlop_D IS

BEGIN

    PROCESS (Rstn, Clk)
    BEGIN
        IF (Rstn = '0') THEN --Asynchronous reset
            Q <= '1';
        ELSIF (Clk'EVENT AND Clk = '1') THEN
            IF (Clr = '1') THEN --Synchronous reset
                Q <= '0';
            ELSIF (Ld = '1') THEN --Load signal
                Q <= D;
            END IF;
        END IF;
    END PROCESS;

END behavior;