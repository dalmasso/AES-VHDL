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
signal MyRC     : STD_LOGIC_VECTOR(79 downto 0)  := (others => '0'); 

-- No optimization
attribute dont_touch of MyRC     : signal is "true";

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin


-------------------------
-- 128-bit Key storage --
-------------------------
process(Clk)
begin

  if rising_edge(Clk) then
    if Reset ='0' then
      Key_out <= CipherKey;
    
    elsif LastRound = '0' then
      Key_out <= Key_in;

    end if;
  end if;
end process;


--------------------------
-- 128-bit Data storage --
--------------------------
process(Clk)
begin

  if rising_edge(Clk) then
    if Reset ='0' then
      Data_out <= Plaintext XOR CipherKey;

    elsif LastRound = '0' then
      Data_out <= Data_in;

    end if;
  end if;
end process;


---------------------------------------
-- 8-bit RCON storage                --
-- x"36", x"1B", x"80", x"40", x"20" --
-- x"10", x"08", x"04", x"02", x"01" --
---------------------------------------
process(Clk)
begin

  if rising_edge(Clk) then
    if Reset ='0' then
      MyRC <= x"36" & x"1B" & x"80" & x"40" & x"20" &
              x"10" & x"08" & x"04" & x"02" & x"01";

    elsif LastRound = '0' then
      MyRC <= MyRC(7 downto 0) & MyRC(79 downto 8);
    
    end if;
  end if;
end process;

RCON_out <= MyRC(7 downto 0);

end Behavioral;