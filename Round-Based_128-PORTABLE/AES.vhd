------------------------------------------------------------------------
-- Engineer:  Dalmasso Loic
-- Create Date: 25/12/2017
-- Module Name: AES - Behavioral
-- Description:
--      Implement one round of AES encryption algorithm
--      Input data - Clk : clock of AES
--      Input data - Reset : reset of AES
--      Input data - Plaintext : 128 bits of plaintext
--      Input data - Cipherkey : 128 bits of cipherkey
--      Output data - Ciphertext : 128 bits of ciphertext
--      Output data - EndOfAES : siganl to identify end of AES algorithm
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY AES is

PORT( Clk        : IN STD_LOGIC;
      Reset      : IN STD_LOGIC;
      Plaintext  : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      CipherKey  : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      Ciphertext : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      EndOfAES   : OUT STD_LOGIC
    );

-- No optimization  
attribute dont_touch : string;
attribute dont_touch of AES : entity is "true";

END AES;

ARCHITECTURE Behavioral of AES is

------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------
COMPONENT Round is

PORT( LastRound  : IN STD_LOGIC;
      Plaintext  : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      RoundKey   : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      Ciphertext : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
  );

END COMPONENT;


COMPONENT KeySchedule is

PORT( KeyState : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      RCON     : IN STD_LOGIC_VECTOR(7 downto 0);
      NewKey   : OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
    );

END COMPONENT;


COMPONENT MixColumns is

PORT( MixColumns_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      MixColumns_out: OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
  );

END COMPONENT;


COMPONENT ShiftRows is

PORT( ShiftRows_in : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      ShiftRows_out: OUT STD_LOGIC_VECTOR(127 DOWNTO 0)
  );
END COMPONENT;


COMPONENT SubBytes is

PORT( SubBytes_in  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      SubBytes_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );

END COMPONENT;


COMPONENT Data_Key_RC_Store is

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

END COMPONENT;

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
signal Keystate  : STD_LOGIC_VECTOR(127 DOWNTO 0) := (others => '0');
signal NewKey    : STD_LOGIC_VECTOR(127 DOWNTO 0) := (others => '0');

signal RCON      : STD_LOGIC_VECTOR(7 DOWNTO 0)   := (others => '0');

signal NewPlain  : STD_LOGIC_VECTOR(127 DOWNTO 0) := (others => '0');
signal NewCipher : STD_LOGIC_VECTOR(127 DOWNTO 0) := (others => '0');
signal LastRound : STD_LOGIC := '0';

-- No optimization  
attribute dont_touch of Keystate : signal is "true";
attribute dont_touch of NewKey   : signal is "true";
attribute dont_touch of RCON     : signal is "true";
attribute dont_touch of NewPlain : signal is "true";
attribute dont_touch of NewCipher: signal is "true";
attribute dont_touch of LastRound: signal is "true";

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

-----------------
-- KeySchedule --
-----------------
KEYSCH : KeySchedule port map (NewKey, RCON, Keystate);

-----------
-- Round --
-----------
ROUNDS : Round port map (LastRound, NewPlain, Keystate, NewCipher);

-------------
-- Storage --
-------------
STORE : Data_Key_RC_Store port map (Clk, Reset, LastRound, CipherKey, Keystate, Plaintext, NewCipher, NewKey, NewPlain, RCON);


-------------------------
-- Final round trigger --
-------------------------
LastRound <= '1' when RCON = x"36" else '0'; -- 10th round

---------------------------
-- Send final ciphertext --
---------------------------
Ciphertext <= NewCipher;
EndOfAES <= LastRound;

end Behavioral;