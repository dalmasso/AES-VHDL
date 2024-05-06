------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date:	06/12/2017
-- Module Name:	ShiftRows - Behavioral
-- Description:
--		Move words in columns of data input
-- 		Input data - ShiftRows_in : 128bits of text
--		Output data - ShiftRows_out : 128bits shifted bits of text
--		/!\ each column in matrix representation is in row in VHDL code
--
--		Example
--		Range		127 ................................. 0
--		data input :  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
--
--		=> 	| 0	 4  8   12	|				| 0   4	  8	 12 |
--			| 1	 5  9   13	|	ShiftRows	| 5   9	 13	  1 |  Output
--			| 2	 6  10  14	|	========>	| 10  14  2	  6 |	  =
--			| 3	 7  11  15	|				| 15  3	  7  11 |
------------------------------------------------------------------------

-- 0 LUT

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ShiftRows is

PORT( ShiftRows_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
	  ShiftRows_out: OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
	);

-- No optimization		
attribute dont_touch : string;
attribute dont_touch of ShiftRows : entity is "true";

END ShiftRows;

ARCHITECTURE Behavioral of ShiftRows is

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

-- Output : Column 1 Row 1		-- Input : Column 1 Row 1
ShiftRows_out(127 downto 120) 	<= ShiftRows_in(127 downto 120);
-- Output : Column 1 Row 2		-- Input : Column 2 Row 2
ShiftRows_out(119 downto 112) 	<= ShiftRows_in(87 downto 80);
-- Output : Column 1 Row 3		-- Input : Column 3 Row 3
ShiftRows_out(111 downto 104) 	<= ShiftRows_in(47 downto 40);
-- Output : Column 1 Row 4		-- Input : Column 4 Row 4
ShiftRows_out(103 downto 96)	<= ShiftRows_in(7 downto 0);

-- Output : Column 2 Row 1		-- Input : Column 2 Row 1
ShiftRows_out(95 downto 88)	 	<= ShiftRows_in(95 downto 88);
-- Output : Column 2 Row 2		-- Input : Column 3 Row 2
ShiftRows_out(87 downto 80) 	<= ShiftRows_in(55 downto 48);
-- Output : Column 2 Row 3		-- Input : Column 4 Row 3
ShiftRows_out(79 downto 72) 	<= ShiftRows_in(15 downto 8);
-- Output : Column 2 Row 4		-- Input : Column 1 Row 4
ShiftRows_out(71 downto 64) 	<= ShiftRows_in(103 downto 96);

-- Output : Column 3 Row 1		-- Input : Column 3 Row 1
ShiftRows_out(63 downto 56) 	<= ShiftRows_in(63 downto 56);
-- Output : Column 3 Row 2		-- Input : Column 4 Row 2
ShiftRows_out(55 downto 48) 	<= ShiftRows_in(23 downto 16);
-- Output : Column 3 Row 3		-- Input : Column 1 Row 3
ShiftRows_out(47 downto 40) 	<= ShiftRows_in(111 downto 104);
-- Output : Column 3 Row 4		-- Input : Column 2 Row 4
ShiftRows_out(39 downto 32) 	<= ShiftRows_in(71 downto 64);

-- Output : Column 4 Row 1		-- Input : Column 4 Row 1
ShiftRows_out(31 downto 24) 	<= ShiftRows_in(31 downto 24);
-- Output : Column 4 Row 2		-- Input : Column 1 Row 2
ShiftRows_out(23 downto 16) 	<= ShiftRows_in(119 downto 112);
-- Output : Column 4 Row 3		-- Input : Column 2 Row 3
ShiftRows_out(15 downto 8) 	 	<= ShiftRows_in(79 downto 72);
-- Output : Column 4 Row 4		-- Input : Column 3 Row 4
ShiftRows_out(7 downto 0) 	 	<= ShiftRows_in(39 downto 32);

end Behavioral;