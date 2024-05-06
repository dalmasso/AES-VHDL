----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.12.2017 17:53:20
-- Design Name: 
-- Module Name: testbench_AES - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity testbench_AES is
--  Port ( );
end testbench_AES;

architecture Behavioral of testbench_AES is

COMPONENT AES is

PORT( Clk           : IN STD_LOGIC;
	  Reset		    : IN STD_LOGIC;
      Plaintext     : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
	  CipherKey	    : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
	  Ciphertext    : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
	  EndOfAES      : OUT STD_LOGIC
	);

END COMPONENT;

signal clk, reset 	: STD_LOGIC := '0';
signal myplain 		: STD_LOGIC_VECTOR(127 DOWNTO 0) := (others => '0');
signal mykey 		: STD_LOGIC_VECTOR(127 DOWNTO 0) := (others => '0');
signal cipher 	    : STD_LOGIC_VECTOR(127 DOWNTO 0) := (others => '0');
signal endofAES 	: STD_LOGIC := '0';

begin

uut : AES port map (clk, reset, myplain, mykey, cipher, endofAES);

clk <= not clk after 5 ns;
reset <= '0', '1' after 203 ns, '0' after 400 ns, '1' after 420 ns;
myplain <= X"3243F6A8885A308D313198A2E0370734";
mykey <= X"2B7E151628AED2A6ABF7158809CF4F3C";

end Behavioral;