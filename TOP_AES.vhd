------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 06/12/2017
-- Module Name: TOP_AES - Behavioral
-- Description:
--      Implement AES algorithm & UART to send/receive data
--      Block - AES : crypto algorithm
--      Block - UART : use to communicate with user 
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


ENTITY TOP_AES is

PORT( Clk_100 : IN STD_LOGIC;
      Reset   : IN STD_LOGIC;
      RX      : IN STD_LOGIC;
      TX      : OUT STD_LOGIC
      
      -- For attack
      --trigger : OUT STD_LOGIC
    );

END TOP_AES;


architecture Behavioral of TOP_AES is

------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------
COMPONENT Uart IS
  GENERIC(
    clk_freq  : INTEGER   := 50_000_000;                  -- frequency of system clock in Hertz
    baud_rate : INTEGER   := 19_200;                      -- data link baud rate in bits/second
    os_rate   : INTEGER   := 16;                          -- oversampling rate to find center of receive bits (in samples per baud period)
    d_width   : INTEGER   := 8;                           -- data bus width
    parity    : INTEGER   := 1;                           -- 0 for no parity, 1 for parity
    parity_eo : STD_LOGIC := '0');                        -- '0' for even, '1' for odd parity

  PORT(
    clk       : IN STD_LOGIC;                             -- system clock
    reset_n   : IN STD_LOGIC;                             -- asynchronous reset
    tx_ena    : IN STD_LOGIC;                             -- initiate transmission
    tx_data   : IN STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  -- data to transmit
    rx        : IN STD_LOGIC;                             -- receive pin
    rx_busy   : OUT STD_LOGIC;                            -- data reception in progress
    rx_error  : OUT STD_LOGIC;                            -- start, parity, or stop bit error detected
    rx_data   : OUT STD_LOGIC_VECTOR(d_width-1 DOWNTO 0); -- data received
    tx_busy   : OUT STD_LOGIC;                            -- transmission in progress
    tx        : OUT STD_LOGIC);                           -- transmit pin
END COMPONENT;


COMPONENT AES is

PORT( Clk        : IN STD_LOGIC;
      Reset      : IN STD_LOGIC;
      Plaintext  : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      CipherKey  : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      Ciphertext : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      EndOfAES   : OUT STD_LOGIC
    );

END COMPONENT;


COMPONENT clk_wiz_0 is

PORT ( clk_in1  : IN STD_ULOGIC;
       clk_out1_ce: IN STD_ULOGIC;
       clk_out1 : OUT STD_ULOGIC;
       resetn   : in std_ULOGIC
      );

END COMPONENT;


COMPONENT ClockEnableControler is

GENERIC( DIVIDER 	: INTEGER := 1);

PORT( Clock:	IN STD_LOGIC;
		  Reset:	IN STD_LOGIC;
		  ClockEnableCTRL	: OUT STD_LOGIC
    );

END COMPONENT;



------------------------------------------------------------------------
-- Type Declarations
------------------------------------------------------------------------
TYPE State_Machine is (INIT, WAIT_KEY, WAIT_AES, WAIT_TX, TRANSMIT, NEXT_TX);


------------------------------------------------------------------------
-- Constant Declarations
------------------------------------------------------------------------
constant DATA_BYTE_LENGTH_RX   : INTEGER := 32;
constant DATA_BYTE_LENGTH_TX   : INTEGER := 16;

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------

-- Control UART
signal tx_ena                  : STD_LOGIC := '0';                                 -- initiate transmission
signal tx_data                 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others=>'0');    -- data to transmit
signal rx_busy                 : STD_LOGIC := '0';                                 -- data reception in progress
signal rx_error                : STD_LOGIC := '0';                                 -- start, parity, or stop bit error detected
signal rx_data                 : STD_LOGIC_VECTOR(7 DOWNTO 0) := (others=>'0');    -- data received
signal tx_busy                 : STD_LOGIC := '0';                                 -- transmission in progress
signal reset_cntr              : INTEGER range 0 to 200000 := 0;                   -- this counter counts the amount of time paused in the UART reset state
signal uart_reset              : STD_LOGIC := '0';

-- Control TOP AES
signal state, next_state : State_Machine;

-- Control data byte from/to UART : MSB first, LSB last
signal cpt_RX        : INTEGER range 0 to DATA_BYTE_LENGTH_RX := DATA_BYTE_LENGTH_RX;
signal reset_cpt_RX  : STD_LOGIC := '0';

signal cpt_TX        : INTEGER range 0 to DATA_BYTE_LENGTH_TX := DATA_BYTE_LENGTH_TX;
signal reset_cpt_TX  : STD_LOGIC := '0';

-- Control AES
-- 256 bits : KEY = 128 bits (255 downto 128) + PTI = 128 bits (127 downto 0)
signal PTI_Key      : STD_LOGIC_VECTOR(255 DOWNTO 0);
signal Ciphertext   : STD_LOGIC_VECTOR(127 DOWNTO 0);
signal triggerAES   : STD_LOGIC;
signal synchro_AES  : STD_LOGIC;
signal reset_AES    : STD_LOGIC;

-- Crypto Clock
signal CryptoClock       : STD_LOGIC :='0';
signal CryptoClock_RST   : STD_LOGIC :='0';
signal CryptoClockBUF_CE : STD_LOGIC :='0';

--constant test_key : std_logic_vector(127 downto 0) := X"2B7E151628AED2A6ABF7158809CF4F3C";
--constant test_pti : std_logic_vector(127 downto 0) := X"3243F6A8885A308D313198A2E0370734";
--constant test_cto : std_logic_vector(127 downto 0) := X"3925841D02DC09FBDC118597196A0B32";

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

-------------------
-- Reset control --
-------------------
uart_reset <= not(Reset);


------------------
-- UART control --
------------------
UART1 : Uart generic map(100000000,9600,16,8,0,'0')
       port map (Clk_100, uart_reset, tx_ena,tx_data,RX,rx_busy,rx_error,rx_data,tx_busy, TX);


---------------------------------------
-- TOP AES control : State Register --
---------------------------------------

process (Clk_100, uart_reset)
begin
    if uart_reset = '0' then
        state <= INIT;

    elsif rising_edge(Clk_100) then
        state <= next_state;
      
    end if;
end process;


-----------------------------------
-- TOP AES control : Next State --
-----------------------------------
process (state, tx_busy, cpt_RX, cpt_TX, triggerAES)
begin
  case state is

    when INIT         =>  next_state <= WAIT_KEY;

    when WAIT_KEY     =>  if cpt_RX = 0 then     
                            next_state <= WAIT_AES;
                          else
                            next_state <= WAIT_KEY;                   
                          end if; 

    when WAIT_AES    =>  if triggerAES = '1' then
                            next_state <= WAIT_TX;
                          else
                            next_state <= WAIT_AES;
                          end if;

    when WAIT_TX      =>  if tx_busy = '0' then
                            next_state <= TRANSMIT;
                          else
                            next_state <= WAIT_TX;                   
                          end if;   
                        
    when TRANSMIT     =>  if tx_busy = '1' then
                            next_state <= NEXT_TX;
                          else
                            next_state <= TRANSMIT;                   
                          end if;   
                                                                
    when NEXT_TX      =>  if cpt_TX = 0 then
                            next_state <= INIT;
                          else
                            next_state <= WAIT_TX;                   
                          end if; 
                            
    when others       =>  next_state <= INIT;
  end case;
end process;


------------------------------------
-- UART RX : Next byte to receive --
------------------------------------

reset_cpt_RX <= '0' when state = INIT else '1';

process (reset_cpt_RX, rx_busy)
begin
    if reset_cpt_RX = '0' then
      cpt_RX <= DATA_BYTE_LENGTH_RX;
        
    elsif falling_edge(rx_busy) then

      if cpt_RX > 0 then
        cpt_RX <= cpt_RX - 1;

      else
        cpt_RX <= cpt_RX;

      end if;
    end if;
end process;


process(uart_reset, rx_busy)
begin

  if uart_reset = '0' then
    PTI_Key <= (others => '0');
  
  elsif falling_edge(rx_busy) then
    PTI_Key <= PTI_Key(247 downto 0) & rx_data; -- Left Shift
    
  end if;
end process;


---------------------------------
-- UART TX : Next byte to send --
---------------------------------
reset_cpt_TX <= '0' when state = INIT else '1';

process (reset_cpt_TX, tx_busy)
begin
    if reset_cpt_TX = '0' then
      cpt_TX <= DATA_BYTE_LENGTH_TX;
        
    elsif rising_edge(tx_busy) then

      if cpt_TX > 0 then
        cpt_TX <= cpt_TX - 1;

      else
        cpt_TX <= cpt_TX;

      end if;
    end if;
end process;


process(Clk_100, uart_reset)
begin
  
  if uart_reset = '0' then
    tx_data <= (others => '0');
  
  elsif rising_edge(Clk_100) then

    case cpt_TX is
      when 16      =>  tx_data <= CipherText(127 downto 120);
      when 15      =>  tx_data <= CipherText(119 downto 112);
      when 14      =>  tx_data <= CipherText(111 downto 104);
      when 13      =>  tx_data <= CipherText(103 downto 96);
      when 12      =>  tx_data <= CipherText(95 downto 88);
      when 11      =>  tx_data <= CipherText(87 downto 80);
      when 10      =>  tx_data <= CipherText(79 downto 72);
      when 9       =>  tx_data <= CipherText(71 downto 64);
      when 8       =>  tx_data <= CipherText(63 downto 56);
      when 7       =>  tx_data <= CipherText(55 downto 48);
      when 6       =>  tx_data <= CipherText(47 downto 40);
      when 5       =>  tx_data <= CipherText(39 downto 32);
      when 4       =>  tx_data <= CipherText(31 downto 24);
      when 3       =>  tx_data <= CipherText(23 downto 16);
      when 2       =>  tx_data <= CipherText(15 downto 8);
      when 1       =>  tx_data <= CipherText(7 downto 0);
      when others  =>  tx_data <= (others => '0');
    end case;
    
  end if;
end process;

tx_ena <= '1' when state = TRANSMIT else '0';


------------------
-- AES control --
------------------

-- Synchro Reset AES
process(Clk_100)
begin

  if rising_edge(Clk_100) then

    if state = INIT or state = WAIT_KEY then
      synchro_AES <= '0';
    else
      synchro_AES <= '1';
  
    end if;  
  end if;
end process;


process(CryptoClock)
begin

  if rising_edge(CryptoClock) then
    reset_AES <= synchro_AES;

  end if;
end process;



CryptoClock_RST <= '1';
CLK_SYS : clk_wiz_0 port map (Clk_100, CryptoClockBUF_CE, CryptoClock, CryptoClock_RST);

CLOCKCTRL: ClockEnableControler generic map (1)
port map(Clk_100, CryptoClock_RST, CryptoClockBUF_CE);


CRYPTO : AES port map (CryptoClock, reset_AES, PTI_Key(127 downto 0), PTI_Key(255 downto 128), CipherText, triggerAES);


------------------------
-- Trigger for attack --
------------------------
--process(Clk_100, reset_AES)
--begin
--    if reset_AES = '0' then
--      trigger <= '0';
    
--    elsif rising_edge(Clk_100) then
  
--      if state = WAIT_AES and triggerAES = '0' then
--        trigger <= '1';
--      else
--        trigger <= '0';
--      end if;
    
--    end if;
--end process;

end Behavioral;