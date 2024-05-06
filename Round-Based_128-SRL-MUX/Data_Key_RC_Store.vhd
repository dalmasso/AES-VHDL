------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 09/03/2018
-- Module Name: Data_Key_RC_Store - Behavioral
-- Description:
--      Save all data / key / RCON
--      Input data - Clk : clock for KeySchedule
--      Input data - Reset : reset block
--      Input data - LastRound : Trigger for the last round
--      Input data - Cipherkey : 128bits of Cipherkey
--      Input data - Key_in : 128bits of Keystate
--      Input data - Plaintext : 128bits of Plaintext
--      Input data - Data_in : 128bits of Intermediate plaintext
--      Output data - Key_out : 128bits of Keystate
--      Output data - Data_out : 128bits of Intermediate plaintext
--      Output data - RCON_out : 8bit RCON
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

ENTITY Data_Key_RC_Store is

PORT( Clk      : IN STD_LOGIC;
      Reset    : IN STD_LOGIC;
      LastRound: IN STD_LOGIC;

      CipherKey: IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      Key_in   : IN STD_LOGIC_VECTOR(127 DOWNTO 0);

      Plaintext: IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      Data_in  : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
  
      Key_out  : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      Data_out : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      RCON_out : OUT STD_LOGIC_VECTOR(7 downto 0)    
    );

-- No optimization 
attribute dont_touch : string;
attribute dont_touch of Data_Key_RC_Store : entity is "true";

END Data_Key_RC_Store;


ARCHITECTURE Behavioral of Data_Key_RC_Store is

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
signal FirstAdd    : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
signal MyKey       : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
signal MyPTI       : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
signal MyRCin      : STD_LOGIC_VECTOR(79 downto 0)  := (others => '0');
signal MyRCout     : STD_LOGIC_VECTOR(79 downto 0)  := (others => '0');
signal MyRCloop    : STD_LOGIC_VECTOR(79 downto 0)  := (others => '0');
signal InvLastRound: STD_LOGIC := '0';

-- No optimization
attribute dont_touch of FirstAdd     : signal is "true";
attribute dont_touch of MyKey        : signal is "true";
attribute dont_touch of MyPTI        : signal is "true";
attribute dont_touch of MyRCin       : signal is "true";
attribute dont_touch of MyRCout      : signal is "true";
attribute dont_touch of MyRCloop     : signal is "true";
attribute dont_touch of InvLastRound : signal is "true";

------------------------------------------------------------------------
-- Constant Declarations
------------------------------------------------------------------------
constant RCON_INIT: STD_LOGIC_VECTOR(79 downto 0) := x"361B8040201008040201";


------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

-----------------------
-- First AddRoundKey --
-- PTI XOR CipherKey --
-----------------------
FirstAdd <= Plaintext XOR CipherKey;


-- Inv LastRound
InvLastRound <= not LastRound;

-------------------------
-- 128-bit Key storage --
-------------------------
KEYSTORE: for i in 127 downto 0 generate
  MUXKEY: MUXF7 port map (MyKey(i), CipherKey(i), Key_in(i), Reset);

  KEYST : SRL16E generic map (INIT => X"0000")
                 port map (Key_out(i), '0', '0', '0', '0', InvLastRound, Clk, MyKey(i));
end generate;


-------------------------
-- 128-bit Data storage --
-------------------------
DATASTORE: for i in 127 downto 0 generate
  MUXDAT: MUXF7 port map (MyPTI(i), FirstAdd(i), Data_in(i), Reset);

  DATAST : SRL16E generic map (INIT => X"0000")
                  port map (Data_out(i), '0', '0', '0', '0', InvLastRound, Clk, MyPTI(i));

end generate;

---------------------------------------
-- 8-bit RCON storage                --
-- x"36", x"1B", x"80", x"40", x"20" --
-- x"10", x"08", x"04", x"02", x"01" --
---------------------------------------
RCSTORE: for i in 79 downto 0 generate
  MUXRC: MUXF7 port map (MyRCin(i), RCON_INIT(i), MyRCloop(i), Reset);

  RCST : SRL16E generic map (INIT => X"0000")
                  port map (MyRCout(i), '0', '0', '0', '0', '1', Clk, MyRCin(i));
end generate;

MyRCloop <= MyRCout(7 downto 0) & MyRCout(79 downto 8) when LastRound = '0' else MyRCout;

RCON_out <= MyRCout(7 downto 0);

end Behavioral;