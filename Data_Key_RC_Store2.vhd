------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 09/03/2018
-- Module Name: Data_Key_RC_Store - Behavioral
-- Description:
--      Save all data / key / RCON
--      Input data - Clk : clock for KeySchedule
--      Input data - Reset : reset block
--      Input data - Cipherkey : 128bits of Cipherkey
--      Input data - Key_in : 128bits of Keystate
--      Input data - Plaintext : 128bits of Plaintext
--      Input data - Data_in : 128bits of Intermediate plaintext
--      Output data - Key_out : 128bits of Keystate
--      Output data - Data_out : 128bits of Intermediate plaintext
--      Output data - RCON_out : 8bit RCON
------------------------------------------------------------------------

-- 257 LUT
-- 344 FF

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Data_Key_RC_Store is

PORT( Clk      : IN STD_LOGIC;
      Reset    : IN STD_LOGIC;

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
signal FirstAdd : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
signal MyRC     : STD_LOGIC_VECTOR(7 downto 0)  := (others => '0'); 

-- No optimization
attribute dont_touch of FirstAdd : signal is "true";
attribute dont_touch of MyRC     : signal is "true";

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

-----------------------
-- First AddRoundKey --
-- PTI XOR CipherKey --
-----------------------
FirstAdd <= Plaintext XOR CipherKey;


-------------------------
-- 128-bit Key storage --
-------------------------
process(Clk)
begin

  if rising_edge(Clk) then

    if Reset = '0' then
      Key_out <= CipherKey;
    else
      Key_out <= Key_in;

    end if;
  end if;
end process;

-------------------------
-- 127-bit Data storage --
-------------------------
process(Clk)
begin

  if rising_edge(Clk) then
    
    if Reset = '0' then
      Data_out <= FirstAdd;
    else
      Data_out <= Data_in;
    end if;

  end if;
end process;


---------------------------------------
-- 8-bit RCON storage                --
-- x"FF" (trigger end of AES)        --
-- x"36", x"1B", x"80", x"40", x"20" --
-- x"10", x"08", x"04", x"02", x"01" --
---------------------------------------
process(Clk)
begin

  if rising_edge(Clk) then

    if Reset = '0' then
        MyRC <= x"01";
    elsif MyRC = x"01" then
        MyRC <= x"02";
    elsif MyRC = x"02" then
        MyRC <= x"04";
    elsif MyRC = x"04" then
        MyRC <= x"08";
    elsif MyRC = x"08" then
        MyRC <= x"10";
    elsif MyRC = x"10" then
        MyRC <= x"20";
    elsif MyRC = x"20" then
        MyRC <= x"40";
    elsif MyRC = x"40" then
        MyRC <= x"80";
    elsif MyRC = x"80" then
        MyRC <= x"1B";
    elsif MyRC = x"1B" then
        MyRC <= x"36";
    elsif MyRC = x"36" then
        MyRC <= x"FF";
    else
        MyRC <= x"01";
    end if;
  end if;
end process;

RCON_out <= MyRC;

end Behavioral;
