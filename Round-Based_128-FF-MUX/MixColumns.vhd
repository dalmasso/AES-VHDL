------------------------------------------------------------------------
-- Engineer:	Dalmasso Loic
-- Create Date:	06/12/2017
-- Module Name:	MixColumns - Behavioral
-- Description:
--		Galois Field (GF) multiplication with constant matrix
-- 		Input data - MixColumns_in : 128bits of text
--		Output data - MixColumns_out : 128bits shifted bits of text
--		/!\ each column in matrix representation is in row in VHDL code
--
--		Example
--		Range		127 ................................. 0
--		data input :  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15
--
--		   (Constant Matrix)		   (Data Input Matrix)
--		=> 	| 2	 3  1  1 |	  			| 0	 4  8   12	|				
--			| 1	 2  3  1 |	MixColumns  | 1	 5  9   13	|   Output
--			| 1	 1  2  3 |	    * 		| 2	 6  10  14	|  	  =
--			| 3	 1  1  2 |	  			| 3	 7  11  15	|				
------------------------------------------------------------------------

-- 304 LUT

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MixColumns is

PORT( MixColumns_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
	  MixColumns_out: OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
	);

-- No optimization		
attribute dont_touch : string;
attribute dont_touch of MixColumns : entity is "true";

END MixColumns;

ARCHITECTURE Behavioral of MixColumns is

------------------------------------------------------------------------
-- Type Declarations
------------------------------------------------------------------------
TYPE GF_Mult_2_Matrix is array (15 downto 0) of STD_LOGIC_VECTOR(7 downto 0); -- Use to save multiplication by 2
TYPE GF_Mult_3_Matrix is array (15 downto 0) of STD_LOGIC_VECTOR(7 downto 0); -- Use to save multiplication by 3


------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
signal GF_Mult_2 : GF_Mult_2_Matrix;	-- Use to perform multiplication by 2
signal GF_Mult_3 : GF_Mult_3_Matrix;	-- Use to perform multiplication by 3

-- No optimization  
attribute dont_touch of GF_Mult_2 : signal is "true";
attribute dont_touch of GF_Mult_3 : signal is "true";

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin


---------------------------------------
-- GF multiplication by 2 :			 --
-- If MSB = 0 => Left Shift 		 --
-- If MSB = 1 => Left Shift xor 0x1B --
---------------------------------------
GF_Mutl_2_Process : process(MixColumns_in)
begin
	-- GF_Mult_2(15) = MixColumns_in(127 downto 120)
	-- GF_Mult_2(0) = MixColumns_in(7 downto 0)
	for i in 15 downto 0 loop

		if MixColumns_in((8*i)+7) = '0' then
			GF_Mult_2(i) <= MixColumns_in((8*i)+6 downto (8*i)) & '0';

		else
			GF_Mult_2(i) <= (MixColumns_in((8*i)+6 downto (8*i)) & '0') XOR X"1B";

		end if;

	end loop;

end process;



----------------------------------
-- GF multiplication by 3 :		--
-- GF_Mult_2 xor MixColumns_in	--
----------------------------------
GF_Mutl_3_Process : process(MixColumns_in, GF_Mult_2)
begin
	-- GF_Mult_3(15) = MixColumns_in(127 downto 120)
	-- GF_Mult_3(0) = MixColumns_in(7 downto 0)
	for i in 15 downto 0 loop

		GF_Mult_3(i) <= GF_Mult_2(i) xor MixColumns_in((8*i)+7 downto (8*i));

	end loop;

end process;


----------------------------
-- MixColumns calculation --
----------------------------

-- Output : Column 1 Row 1		-- Input : (C1R1 * C1R1) xor (C2R1 * C1R2) xor (C3R1 * C1R3) xor (C4R1 * C1R4)
MixColumns_out(127 downto 120) 	<= GF_Mult_2(15) XOR GF_Mult_3(14) XOR 	MixColumns_in(111 downto 104) XOR MixColumns_in(103 downto 96);

-- Output : Column 1 Row 2		-- Input : (C1R2 * C1R1) xor (C2R2 * C1R2) xor (C3R2 * C1R3) xor (C4R2 * C1R4)
MixColumns_out(119 downto 112) 	<= MixColumns_in(127 downto 120) XOR GF_Mult_2(14) XOR GF_Mult_3(13) XOR MixColumns_in(103 downto 96);

-- Output : Column 1 Row 3		-- Input : (C1R3 * C1R1) xor (C2R3 * C1R2) xor (C3R3 * C1R3) xor (C4R3 * C1R4)
MixColumns_out(111 downto 104) 	<= MixColumns_in(127 downto 120) XOR MixColumns_in(119 downto 112) XOR GF_Mult_2(13) XOR GF_Mult_3(12);

-- Output : Column 1 Row 4		-- Input : (C1R4 * C1R1) xor (C2R4 * C1R2) xor (C3R4 * C1R3) xor (C4R4 * C1R4)
MixColumns_out(103 downto 96)	<= GF_Mult_3(15) XOR MixColumns_in(119 downto 112) XOR MixColumns_in(111 downto 104) XOR GF_Mult_2(12);


-- Output : Column 2 Row 1		-- Input : (C1R1 * C2R1) xor (C2R1 * C2R2) xor (C3R1 * C2R3) xor (C4R1 * C2R4)
MixColumns_out(95 downto 88) 	<= GF_Mult_2(11) XOR GF_Mult_3(10) XOR MixColumns_in(79 downto 72) XOR MixColumns_in(71 downto 64);

-- Output : Column 2 Row 2		-- Input : (C1R2 * C2R1) xor (C2R2 * C2R2) xor (C3R2 * C2R3) xor (C4R2 * C2R4)
MixColumns_out(87 downto 80) 	<= MixColumns_in(95 downto 88) XOR GF_Mult_2(10) XOR GF_Mult_3(9) XOR MixColumns_in(71 downto 64);

-- Output : Column 2 Row 3		-- Input : (C1R3 * C2R1) xor (C2R3 * C2R2) xor (C3R3 * C2R3) xor (C4R3 * C2R4)
MixColumns_out(79 downto 72) 	<= MixColumns_in(95 downto 88) XOR MixColumns_in(87 downto 80) XOR GF_Mult_2(9) XOR GF_Mult_3(8);

-- Output : Column 2 Row 4		-- Input : (C1R4 * C2R1) xor (C2R4 * C2R2) xor (C3R4 * C2R3) xor (C4R4 * C2R4)
MixColumns_out(71 downto 64) 	<= GF_Mult_3(11) XOR MixColumns_in(87 downto 80) XOR MixColumns_in(79 downto 72) XOR GF_Mult_2(8);


-- Output : Column 3 Row 1		-- Input : (C1R1 * C3R1) xor (C2R1 * C3R2) xor (C3R1 * C3R3) xor (C4R1 * C3R4)
MixColumns_out(63 downto 56) 	<= GF_Mult_2(7) XOR GF_Mult_3(6) XOR MixColumns_in(47 downto 40) XOR MixColumns_in(39 downto 32);

-- Output : Column 3 Row 2		-- Input : (C1R2 * C3R1) xor (C2R2 * C3R2) xor (C3R2 * C3R3) xor (C4R2 * C3R4)
MixColumns_out(55 downto 48) 	<= MixColumns_in(63 downto 56) XOR GF_Mult_2(6) XOR GF_Mult_3(5) XOR MixColumns_in(39 downto 32);

-- Output : Column 3 Row 3		-- Input : (C1R3 * C3R1) xor (C2R3 * C3R2) xor (C3R3 * C3R3) xor (C4R3 * C3R4)
MixColumns_out(47 downto 40) 	<= MixColumns_in(63 downto 56) XOR MixColumns_in(55 downto 48) XOR GF_Mult_2(5) XOR GF_Mult_3(4);

-- Output : Column 3 Row 4		-- Input : (C1R4 * C3R1) xor (C2R4 * C3R2) xor (C3R4 * C3R3) xor (C4R4 * C3R4)
MixColumns_out(39 downto 32) 	<= GF_Mult_3(7) XOR MixColumns_in(55 downto 48) XOR MixColumns_in(47 downto 40) XOR GF_Mult_2(4);


-- Output : Column 4 Row 1		-- Input : (C1R1 * C4R1) xor (C2R1 * C4R2) xor (C3R1 * C4R3) xor (C4R1 * C4R4)
MixColumns_out(31 downto 24) 	<= GF_Mult_2(3) XOR GF_Mult_3(2) XOR MixColumns_in(15 downto 8) XOR MixColumns_in(7 downto 0);

-- Output : Column 4 Row 2		-- Input : (C1R2 * C4R1) xor (C2R2 * C4R2) xor (C3R2 * C4R3) xor (C4R2 * C4R4)
MixColumns_out(23 downto 16) 	<= MixColumns_in(31 downto 24) XOR GF_Mult_2(2) XOR GF_Mult_3(1) XOR MixColumns_in(7 downto 0);

-- Output : Column 4 Row 3		-- Input : (C1R3 * C4R1) xor (C2R3 * C4R2) xor (C3R3 * C4R3) xor (C4R3 * C4R4)
MixColumns_out(15 downto 8) 	<= MixColumns_in(31 downto 24) XOR MixColumns_in(23 downto 16) XOR GF_Mult_2(1) XOR GF_Mult_3(0);

-- Output : Column 4 Row 4		-- Input : (C1R4 * C4R1) xor (C2R4 * C4R2) xor (C3R4 * C4R3) xor (C4R4 * C4R4)
MixColumns_out(7 downto 0) 	 	<= GF_Mult_3(3) XOR MixColumns_in(23 downto 16) XOR MixColumns_in(15 downto 8) XOR GF_Mult_2(0);

end Behavioral;