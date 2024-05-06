------------------------------------------------------------------------
-- Engineer:	Dalmasso Loic
-- Create Date:	25/12/2017
-- Module Name:	Round - Behavioral
-- Description:
--		Implement one round of AES encryption algorithm
--		Input data - LastRound : Trigger for the last round
--		Input data - Plaintext : 128 bits of plaintext
-- 		Input data - RoundKey  : 128 bits of round key
--		Output data - Ciphertext : 128 bits of ciphertext
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Round is

PORT( LastRound  : IN STD_LOGIC;
	  Plaintext  : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
	  RoundKey	 : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
	  Ciphertext : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
	);

-- No optimization  
attribute dont_touch : string;
attribute dont_touch of Round : entity is "true";

END Round;

ARCHITECTURE Behavioral of Round is

------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------
COMPONENT SubBytes is

PORT( SubBytes_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	  SubBytes_out: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;


COMPONENT ShiftRows is

PORT( ShiftRows_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
	  ShiftRows_out: OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
	);

END COMPONENT;


COMPONENT MixColumns is

PORT( MixColumns_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
	  MixColumns_out: OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
	);

END COMPONENT;

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
signal SubBytes_output 		: STD_LOGIC_VECTOR(127 DOWNTO 0) := (others => '0');	-- SBOX result
signal ShiftRows_output		: STD_LOGIC_VECTOR(127 DOWNTO 0) := (others => '0');	-- ShiftRows result
signal MixColumns_output	: STD_LOGIC_VECTOR(127 DOWNTO 0) := (others => '0');	-- MixColumns result
signal Ciphertext_input		: STD_LOGIC_VECTOR(127 DOWNTO 0) := (others => '0');	-- Ciphertext input


-- No optimization  
attribute dont_touch of SubBytes_output   : signal is "true";
attribute dont_touch of ShiftRows_output  : signal is "true";
attribute dont_touch of MixColumns_output : signal is "true";

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

--------------------------
-- 16 SBOXes generation --
--------------------------
SBOXS: for i in 15 downto 0 generate
	SBOX : SubBytes port map ( Plaintext((8*i)+7 downto (8*i)), SubBytes_output((8*i)+7 downto (8*i)) );
end generate;


---------------
-- ShiftRows --
---------------
SHIFTR : ShiftRows port map ( SubBytes_output, ShiftRows_output );


----------------
-- MixColumns --
----------------
MIXCOL : MixColumns port map ( ShiftRows_output, MixColumns_output );


-----------------
-- AddRoundKey --
-----------------
Ciphertext_input <= ShiftRows_output when LastRound = '1' else MixColumns_output;	-- MixColumns for all round, except for last round			
Ciphertext <= Ciphertext_input XOR RoundKey;

end Behavioral;