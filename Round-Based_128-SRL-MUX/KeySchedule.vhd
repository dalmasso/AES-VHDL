------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 06/12/2017
-- Module Name: KeySchedule - Behavioral
-- Description:
--      Create new round key
--      Input data - Keystate : 128bits of Cipherkey
--      Input data - RCON : Round Constant on 8bits
--      Output data - NewKey : 128bits of Keystate
--      Output data - NewKey : 128bits of Roundkey
------------------------------------------------------------------------

-- 288 LUT

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;


ENTITY KeySchedule is

PORT( KeyState : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
	  RCON     : IN STD_LOGIC_VECTOR(7 downto 0);
      NewKey   : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
    );

-- No optimization  
attribute dont_touch : string;
attribute dont_touch of KeySchedule : entity is "true";

END KeySchedule;

ARCHITECTURE Behavioral of KeySchedule is

------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------
COMPONENT SubBytes is

PORT( SubBytes_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      SubBytes_out: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END COMPONENT;


------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
signal SBOX_out   : STD_LOGIC_VECTOR(31 downto 0)  := (others =>'0');
signal NewKey_reg : STD_LOGIC_VECTOR(127 DOWNTO 0) := (others =>'0');

attribute dont_touch of SBOX_out   : signal is "true";
attribute dont_touch of NewKey_reg : signal is "true";

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

-- SBOXs
SubBytes_3 : SubBytes port map ( KeyState(23 downto 16), SBOX_out(31 downto 24) );
SubBytes_2 : SubBytes port map ( KeyState(15 downto 8) , SBOX_out(23 downto 16) );
SubBytes_1 : SubBytes port map ( KeyState(7 downto 0)  , SBOX_out(15 downto 8) );
SubBytes_0 : SubBytes port map ( KeyState(31 downto 24), SBOX_out(7 downto 0) );


-- New CipherKey
NewKey_reg <= (((KeyState(127 downto 120) XOR RCON) & KeyState(119 downto 96)) XOR SBOX_out(31 downto 0)) &
           	  (NewKey_reg(127 downto 96) XOR KeyState(95 downto 64)) &
           	  (NewKey_reg(95 downto 64)  XOR KeyState(63 downto 32)) &
           	  (NewKey_reg(63 downto 32)  XOR KeyState(31 downto 0));

NewKey <= NewKey_reg;

end Behavioral;