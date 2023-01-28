LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY display_7_seg IS
      PORT (
            input : IN INTEGER;
            output : OUT STD_LOGIC_VECTOR(0 TO 6));
END display_7_seg;

ARCHITECTURE STRUCTURE OF display_7_seg IS
BEGIN
      PROCESS (input)
      BEGIN
            CASE input IS
                  WHEN 0 => output <= "0000001"; -- "0"
                  WHEN 1 => output <= "1001111"; -- "1"
                  WHEN 2 => output <= "0010010"; -- "2"
                  WHEN 3 => output <= "0000110"; -- "3"
                  WHEN 4 => output <= "1001100"; -- "4"
                  WHEN 5 => output <= "0100100"; -- "5"
                  WHEN 6 => output <= "0100000"; -- "6"
                  WHEN 7 => output <= "0001111"; -- "7"
                  WHEN 8 => output <= "0000000"; -- "8"
                  WHEN 9 => output <= "0000100"; -- "9"
                  WHEN OTHERS => output <= "1111110"; --default "-"
            END CASE;
      END PROCESS;

END STRUCTURE;