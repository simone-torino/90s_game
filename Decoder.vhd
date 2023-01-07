LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.Std_Logic_Arith.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY Decoder IS
    PORT (
        row_add : IN INTEGER; --row pixel coordinate
        column_add : IN INTEGER; --column pixel coordinate
        address : OUT STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0')); -- gli indirizzi fino a 2048 sono scritti su 11 bit
END Decoder;

ARCHITECTURE behavior OF Decoder IS
    SIGNAL int_address : INTEGER RANGE 0 TO 2048; --dimensione della rom
    SIGNAL horizontal : INTEGER RANGE 0 TO 640 := 0;
    SIGNAL vertical : INTEGER RANGE 0 TO 480 := 0;

BEGIN
    PROCESS (row_add, column_add, horizontal, vertical)
    BEGIN
        horizontal <= column_add;
        vertical <= row_add;
        -- scrivere posizione della lettera nella condizione 
        -- lo spazio dovrebbe essere sufficiente a contenere la lettera
        IF (horizontal >= 20 AND horizontal <= 100 AND vertical >= 20 AND vertical <= 180) THEN
            -- qui scrivere l'indirizzo della lettera nella rom
            -- gli indirizzi corrispondono al codice ascii in esadecimale
            int_address <= 16#41#; --forse c'è da mettere uno zero alla fine es 0x430
            
        END IF;
    END PROCESS;
    address <= conv_std_logic_vector(int_address, 11); --converto indirizzo in std_logic_vector su 11 bit
END behavior;

-- HEX  CHAR
-- 41	A
-- 42	B
-- 43	C
-- 44	D
-- 45	E
-- 46	F
-- 47	G
-- 48	H
-- 49	I
-- 4A	J
-- 4B	K
-- 4C	L
-- 4D	M
-- 4E	N
-- 4F	O
-- 50	P
-- 51	Q
-- 52	R
-- 53	S
-- 54	T
-- 55	U
-- 56	V
-- 57	W
-- 58	X
-- 59	Y
-- 5A	Z
