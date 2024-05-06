------------------------------------------------------------------------
-- Engineer:	Dalmasso Loic
-- Create Date:	22/12/2017
-- Module Name:	SubCells - Behavioral
-- Description:
--		SBOX of AES encryption
--		Input data - SubCells_in : nibble of plaintext on 1 byte (8bits)
--		Output data - SubCells_out : substituted data on 1 byte (8bits)
------------------------------------------------------------------------

-- 40 LUT

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SubBytes is

PORT( SubBytes_in  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	  SubBytes_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);

-- No optimization		
attribute dont_touch : string;
attribute dont_touch of SubBytes : entity is "true";

END SubBytes;

ARCHITECTURE Behavioral of SubBytes is

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

with SubBytes_in select
					-- Row 0
	SubBytes_out <= X"63" when X"00",
					X"7C" when X"01",
					X"77" when X"02",
					X"7B" when X"03",
					X"F2" when X"04",
					X"6B" when X"05",
					X"6F" when X"06",
					X"C5" when X"07",
					X"30" when X"08",
					X"01" when X"09",
					X"67" when X"0A",
					X"2B" when X"0B",
					X"FE" when X"0C",
					X"D7" when X"0D",
					X"AB" when X"0E",
					X"76" when X"0F",

					-- Row 1
					X"CA" when X"10",
					X"82" when X"11",
					X"C9" when X"12",
					X"7D" when X"13",
					X"FA" when X"14",
					X"59" when X"15",
					X"47" when X"16",
					X"F0" when X"17",
					X"AD" when X"18",
					X"D4" when X"19",
					X"A2" when X"1A",
					X"AF" when X"1B",
					X"9C" when X"1C",
					X"A4" when X"1D",
					X"72" when X"1E",
					X"C0" when X"1F",

					-- Row 2
					X"B7" when X"20",
					X"FD" when X"21",
					X"93" when X"22",
					X"26" when X"23",
					X"36" when X"24",
					X"3F" when X"25",
					X"F7" when X"26",
					X"CC" when X"27",
					X"34" when X"28",
					X"A5" when X"29",
					X"E5" when X"2A",
					X"F1" when X"2B",
					X"71" when X"2C",
					X"D8" when X"2D",
					X"31" when X"2E",
					X"15" when X"2F",

					-- Row 3
					X"04" when X"30",
					X"C7" when X"31",
					X"23" when X"32",
					X"C3" when X"33",
					X"18" when X"34",
					X"96" when X"35",
					X"05" when X"36",
					X"9A" when X"37",
					X"07" when X"38",
					X"12" when X"39",
					X"80" when X"3A",
					X"E2" when X"3B",
					X"EB" when X"3C",
					X"27" when X"3D",
					X"B2" when X"3E",
					X"75" when X"3F",

					-- Row 4
					X"09" when X"40",
					X"83" when X"41",
					X"2C" when X"42",
					X"1A" when X"43",
					X"1B" when X"44",
					X"6E" when X"45",
					X"5A" when X"46",
					X"A0" when X"47",
					X"52" when X"48",
					X"3B" when X"49",
					X"D6" when X"4A",
					X"B3" when X"4B",
					X"29" when X"4C",
					X"E3" when X"4D",
					X"2F" when X"4E",
					X"84" when X"4F",

					-- Row 5
					X"53" when X"50",
					X"D1" when X"51",
					X"00" when X"52",
					X"ED" when X"53",
					X"20" when X"54",
					X"FC" when X"55",
					X"B1" when X"56",
					X"5B" when X"57",
					X"6A" when X"58",
					X"CB" when X"59",
					X"BE" when X"5A",
					X"39" when X"5B",
					X"4A" when X"5C",
					X"4C" when X"5D",
					X"58" when X"5E",
					X"CF" when X"5F",

					-- Row 6
					X"D0" when X"60",
					X"EF" when X"61",
					X"AA" when X"62",
					X"FB" when X"63",
					X"43" when X"64",
					X"4D" when X"65",
					X"33" when X"66",
					X"85" when X"67",
					X"45" when X"68",
					X"F9" when X"69",
					X"02" when X"6A",
					X"7F" when X"6B",
					X"50" when X"6C",
					X"3C" when X"6D",
					X"9F" when X"6E",
					X"A8" when X"6F",

					-- Row 7
					X"51" when X"70",
					X"A3" when X"71",
					X"40" when X"72",
					X"8F" when X"73",
					X"92" when X"74",
					X"9D" when X"75",
					X"38" when X"76",
					X"F5" when X"77",
					X"BC" when X"78",
					X"B6" when X"79",
					X"DA" when X"7A",
					X"21" when X"7B",
					X"10" when X"7C",
					X"FF" when X"7D",
					X"F3" when X"7E",
					X"D2" when X"7F",

					-- Row 8
					X"CD" when X"80",
					X"0C" when X"81",
					X"13" when X"82",
					X"EC" when X"83",
					X"5F" when X"84",
					X"97" when X"85",
					X"44" when X"86",
					X"17" when X"87",
					X"C4" when X"88",
					X"A7" when X"89",
					X"7E" when X"8A",
					X"3D" when X"8B",
					X"64" when X"8C",
					X"5D" when X"8D",
					X"19" when X"8E",
					X"73" when X"8F",

					-- Row 9
					X"60" when X"90",
					X"81" when X"91",
					X"4F" when X"92",
					X"DC" when X"93",
					X"22" when X"94",
					X"2A" when X"95",
					X"90" when X"96",
					X"88" when X"97",
					X"46" when X"98",
					X"EE" when X"99",
					X"B8" when X"9A",
					X"14" when X"9B",
					X"DE" when X"9C",
					X"5E" when X"9D",
					X"0B" when X"9E",
					X"DB" when X"9F",

					-- Row 10
					X"E0" when X"A0",
					X"32" when X"A1",
					X"3A" when X"A2",
					X"0A" when X"A3",
					X"49" when X"A4",
					X"06" when X"A5",
					X"24" when X"A6",
					X"5C" when X"A7",
					X"C2" when X"A8",
					X"D3" when X"A9",
					X"AC" when X"AA",
					X"62" when X"AB",
					X"91" when X"AC",
					X"95" when X"AD",
					X"E4" when X"AE",
					X"79" when X"AF",

					-- Row 11
					X"E7" when X"B0",
					X"C8" when X"B1",
					X"37" when X"B2",
					X"6D" when X"B3",
					X"8D" when X"B4",
					X"D5" when X"B5",
					X"4E" when X"B6",
					X"A9" when X"B7",
					X"6C" when X"B8",
					X"56" when X"B9",
					X"F4" when X"BA",
					X"EA" when X"BB",
					X"65" when X"BC",
					X"7A" when X"BD",
					X"AE" when X"BE",
					X"08" when X"BF",

					-- Row 12
					X"BA" when X"C0",
					X"78" when X"C1",
					X"25" when X"C2",
					X"2E" when X"C3",
					X"1C" when X"C4",
					X"A6" when X"C5",
					X"B4" when X"C6",
					X"C6" when X"C7",
					X"E8" when X"C8",
					X"DD" when X"C9",
					X"74" when X"CA",
					X"1F" when X"CB",
					X"4B" when X"CC",
					X"BD" when X"CD",
					X"8B" when X"CE",
					X"8A" when X"CF",

					-- Row 13
					X"70" when X"D0",
					X"3E" when X"D1",
					X"B5" when X"D2",
					X"66" when X"D3",
					X"48" when X"D4",
					X"03" when X"D5",
					X"F6" when X"D6",
					X"0E" when X"D7",
					X"61" when X"D8",
					X"35" when X"D9",
					X"57" when X"DA",
					X"B9" when X"DB",
					X"86" when X"DC",
					X"C1" when X"DD",
					X"1D" when X"DE",
					X"9E" when X"DF",

					-- Row 14
					X"E1" when X"E0",
					X"F8" when X"E1",
					X"98" when X"E2",
					X"11" when X"E3",
					X"69" when X"E4",
					X"D9" when X"E5",
					X"8E" when X"E6",
					X"94" when X"E7",
					X"9B" when X"E8",
					X"1E" when X"E9",
					X"87" when X"EA",
					X"E9" when X"EB",
					X"CE" when X"EC",
					X"55" when X"ED",
					X"28" when X"EE",
					X"DF" when X"EF",

					-- Row 15
					X"8C" when X"F0",
					X"A1" when X"F1",
					X"89" when X"F2",
					X"0D" when X"F3",
					X"BF" when X"F4",
					X"E6" when X"F5",
					X"42" when X"F6",
					X"68" when X"F7",
					X"41" when X"F8",
					X"99" when X"F9",
					X"2D" when X"FA",
					X"0F" when X"FB",
					X"B0" when X"FC",
					X"54" when X"FD",
					X"BB" when X"FE",
					X"16" when X"FF",

					(OTHERS =>'X') when OTHERS;

end Behavioral;