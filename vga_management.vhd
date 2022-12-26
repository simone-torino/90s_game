LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY vga_management IS
    PORT (
        clk, rstn : IN STD_LOGIC;
        hs, vs : OUT STD_LOGIC;
        hpos, vpos : BUFFER INTEGER
    );
END vga_management;

ARCHITECTURE behavior OF vga_management IS

    CONSTANT ha : INTEGER := 96;
    CONSTANT hb : INTEGER := 48;
    CONSTANT hc : INTEGER := 640;
    CONSTANT hd : INTEGER := 16;

    CONSTANT va : INTEGER := 2;
    CONSTANT vb : INTEGER := 33;
    CONSTANT vc : INTEGER := 480;
    CONSTANT vd : INTEGER := 10;

BEGIN

    -- horizontal synch signal
    hsynch : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0') THEN
            hs <= '1';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (hpos > (hc + hd - 1) AND hpos <= (hc + hd + ha - 1)) THEN
                hs <= '0';
            ELSE
                hs <= '1';
            END IF;
        END IF;
    END PROCESS;

    -- vertical synch signal
    vsynch : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0') THEN
            vs <= '0';
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (vpos > (vc + vd - 1) AND vpos <= (vc + vd + va - 1)) THEN
                vs <= '0';
            ELSE
                vs <= '1';
            END IF;
        END IF;
    END PROCESS;

    -- horizontal scan
    hscan : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0') THEN
            hpos <= 0;
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (hpos = (ha + hb + hc + hd - 1)) THEN
                hpos <= 0;
            ELSE
                hpos <= hpos + 1;
            END IF;
        END IF;
    END PROCESS;

    -- veritcal scan
    vscan : PROCESS (clk, rstn)
    BEGIN
        IF (rstn = '0') THEN
            vpos <= 0;
        ELSIF (clk'EVENT AND clk = '1') THEN
            IF (vpos >= (va + vb + vc + vd - 1)) THEN
                vpos <= 0;
            ELSIF (hpos = ha + hb + hc + hd - 1) THEN
                vpos <= vpos + 1;
            END IF;
        END IF;
    END PROCESS;

END behavior;