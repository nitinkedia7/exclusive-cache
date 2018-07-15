library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity controller is
    generic (
     g_CLKS_PER_BIT : integer := 10417
    );
    port (
        clk : in std_logic;
        i_RX_Serial : in  std_logic;        -- serial input recieved from pc
        serialout :   out std_logic         -- serial output sent to pc
        --start : in std_logic;
--        state_port : out integer;
--        stop: out std_logic;
--        hit_l1 : out std_logic_vector(15 downto 0);
--        hit_l2 : out std_logic_vector(15 downto 0);
--        miss_l1 : out std_logic_vector(15 downto 0);
--        miss_l2 : out std_logic_vector(15 downto 0);
--        q1: out std_logic;
--        q2: out std_logic;
--        addr : out std_logic_vector(15 downto 0)
     );
end controller;
use work.all;
architecture rtl of controller is

component L1 is
  Port (
    clk : in std_logic;
    query : in std_logic;
    addr : in std_logic_vector(15 downto 0);
    carry_out : out std_logic_vector(16 downto 0);
    done : out std_logic;
    hit_miss : out std_logic   
   );
end component;

component L2 is
  Port (
    clk : in std_logic;
    query : in std_logic;
    addr : in std_logic_vector(15 downto 0);
    carry_in : in std_logic_vector(16 downto 0);
    done : out std_logic;
    hit_miss : out std_logic   
   );
end component;

component uart_tx is
    generic (
      g_CLKS_PER_BIT : integer := 10417   -- Clk_Frequency/BaudRate
      );
    port (
      i_clk       : in  std_logic;
      i_tx_dv     : in  std_logic;
      i_tx_byte   : in  std_logic_vector(7 downto 0);
      o_tx_serial : out std_logic;
      o_tx_done   : out std_logic
      );
  end component uart_tx;
type trace_type is array (0 to 1023) of std_logic_vector (15 downto 0) ;
signal traceram : trace_type := (others => (others => '0'));
attribute ram_style: string;
attribute ram_style of traceram : signal is "block"; 

signal temp, done: std_logic;
signal value : std_logic_vector(15 downto 0):= (others => '0');
signal index : integer := 0;
signal index2 : integer := 0;
signal X : std_logic:= '0';
signal query1 : std_logic:= '0';
signal query2 : std_logic:= '0';
signal addr1 : std_logic_vector(15 downto 0):= x"0000";
signal addr2 : std_logic_vector(15 downto 0):= x"0000";
signal carry : std_logic_vector(16 downto 0);
signal hit1 : std_logic;
signal hit2 : std_logic;
signal done1 : std_logic;
signal done2 : std_logic;
signal hit_count1 : std_logic_vector(15 downto 0) := (others => '0');
signal hit_count2 : std_logic_vector(15 downto 0) := (others => '0');
signal miss_count1 : std_logic_vector(15 downto 0) := (others => '0');
signal miss_count2 : std_logic_vector(15 downto 0) := (others => '0');

signal state, next_state : integer := 5;

signal addr: std_logic_vector(15 downto 0);
signal start: std_logic := '0';
signal stop : std_logic := '0';
-- Rx 
type t_SM_Main is (s_Idle, s_RX_Start_Bit, s_RX_Data_Bits,
                     s_RX_Stop_Bit, s_Cleanup);
signal r_SM_Main : t_SM_Main := s_Idle;       -- State of FSM

signal r_RX_Data_R : std_logic := '0';        -- Both store input data from pc
signal r_RX_Data   : std_logic := '0';

signal r_Clk_Count : integer range 0 to g_CLKS_PER_BIT := 0; -- counter to sync 100 Mhz and 9600
signal r_Bit_Index : integer range 0 to 7 := 0;  -- 8 Bits Total -- index of bit to be edited.
signal r_RX_Byte   : std_logic_vector(7 downto 0) := (others => '0'); -- set of 8 bits obtained in the end
signal r_RX_DV     : std_logic := '0'; -- signal that the 8 bits have been recieved
signal o_RX_DV     : std_logic; -- signal that the 8 bits have been recieved
signal o_RX_Byte   : std_logic_vector(7 downto 0); -- set of 8 bits obtained in the end
-- *****************************************************

-- Tx
signal pcout: std_logic_vector(7 downto 0) := "00000000";
signal printer: integer range 0 to 16:= 0;
signal waiter: integer range 0 to 100*g_CLKS_PER_BIT:= 0;
signal o_tx_done: std_logic:= '0'; -- signal tht the 8 bit data has been sent
signal i_tx_dv: std_logic:= '0'; -- signal to start sending 8 bit data

-- *****************************************************


begin
L1_inst : L1 port map(clk, query1, addr1, carry, done1, hit1);
L2_inst : L2 port map(clk, query2, addr2, carry, done2,hit2);
outstream: entity work.UART_TX port map(Clk, i_tx_dv, pcout, serialout, o_tx_done);
--q1 <= query1;
--q2 <= query2; 

p_SAMPLE : process (Clk)
begin
if rising_edge(Clk) then
  r_RX_Data_R <= i_RX_Serial;
  r_RX_Data   <= r_RX_Data_R;
end if;
end process p_SAMPLE;

o_RX_Byte <= r_RX_Byte;
o_RX_DV   <= r_RX_DV;
p_UART_RX: process (Clk)
begin
if rising_edge(Clk) then
         
  case r_SM_Main is
    when s_Idle =>
      r_RX_DV     <= '0';
      r_Clk_Count <= 0;
      r_Bit_Index <= 0;

      if r_RX_Data = '0' then       -- Start bit detected
        r_SM_Main <= s_RX_Start_Bit;
      else
        r_SM_Main <= s_Idle;
      end if;

       
    -- Check middle of start bit to make sure it's still low
    when s_RX_Start_Bit =>
      if r_Clk_Count = (g_CLKS_PER_BIT-1)/2 then
        if r_RX_Data = '0' then
          r_Clk_Count <= 0;  -- reset counter since we found the middle
          r_SM_Main   <= s_RX_Data_Bits;
        else
          r_SM_Main   <= s_Idle;
        end if;
      else
        r_Clk_Count <= r_Clk_Count + 1;
        r_SM_Main   <= s_RX_Start_Bit;
      end if;

       
    -- Wait g_CLKS_PER_BIT-1 clock cycles to sample serial data
    when s_RX_Data_Bits =>
      if r_Clk_Count < g_CLKS_PER_BIT-1 then    
        r_Clk_Count <= r_Clk_Count + 1;
        r_SM_Main   <= s_RX_Data_Bits;
      else
        r_Clk_Count            <= 0;
        r_RX_Byte(r_Bit_Index) <= r_RX_Data;
         
        -- Check if we have sent out all bits
        if r_Bit_Index < 7 then
          r_Bit_Index <= r_Bit_Index + 1;
          r_SM_Main   <= s_RX_Data_Bits;
        else
          r_Bit_Index <= 0;
          r_SM_Main   <= s_RX_Stop_Bit;
          
        end if;
      end if;


    -- Receive Stop bit.  Stop bit = 1
    when s_RX_Stop_Bit =>
      -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
      if r_Clk_Count < g_CLKS_PER_BIT-1 then
        r_Clk_Count <= r_Clk_Count + 1;
        r_SM_Main   <= s_RX_Stop_Bit;
      else
        r_RX_DV     <= '1';
        r_Clk_Count <= 0;
        r_SM_Main   <= s_Cleanup;
      end if;
      
    when s_Cleanup =>    
        r_RX_DV   <= '0';
        r_SM_Main <= s_Idle;
        if (index2 = 1023 and X = '1') then
            start <= '1';
        elsif (X = '1') then
            index2 <= index2 + 1;
        end if;
        if( X = '0') then
            X <= '1';
            traceram(index2)(7 downto 0) <= r_RX_Byte;
        elsif( X = '1') then
            X <= '0';
            traceram(index2)(15 downto 8) <= r_RX_Byte;
        end if;   
    
    when others => 
        r_SM_Main <= s_Idle;
    end case;
end if;
end process;

--process(clk)
--begin
--    if (rising_edge(clk)) then
--        state <= next_state;
--    end if;
--end process;   

process(start, done)
begin
    if (rising_edge(start)) then
        temp <= '1';
    end if;
    if (done = '1') then
        temp <= '0';
    end if;
end process;

process(clk)
begin
--next_state <= state;
if rising_edge(clk) then
case state is
    when 5 =>
        if (temp = '1') then 
            state <= 0;
        else
            state <= 5;
        end if;
        done <= '0';
    when 0 => 
       if (index = 1024) then
            state <= 4;
            done <= '1';
       else
           query1 <= '1';
--           addr <= traceram(index);
           addr1 <= traceram(index); 
           state <= 1;
       end if;
    when 1 =>
        
        if (done1 = '1') then
            if (hit1 = '1') then
                hit_count1 <= hit_count1 + 1;
                state <= 16;
                 index <= index + 1;
            else
                miss_count1 <= miss_count1 + 1;
                state <= 2;
            end if;
            query1 <= '0';
           
        else
            state <= 1;
        end if;
     when 2 =>
         query2 <= '1';
         addr2 <= traceram(index);
         state <= 3;
     when 3 =>
        if (done2 = '1') then
            if (hit2 = '1') then
                hit_count2 <= hit_count2 + 1;
            else
                miss_count2 <= miss_count2 + 1;
            end if;
            state <= 6;
            query2 <= '0';
            index <= index + 1;
        else
            state <= 3;
        end if;
     when 16 =>
        state <= 6;
     when 6 =>
        state <= 26;
     when 26 =>
        state <= 0;
     when 4 =>
        done <= '1';
        case printer is
            when 0 =>
                pcout <= hit_count1(15 downto 8);
--                pcout <= addr1(15 downto 8);
                printer <= 1;
                i_tx_dv <= '1';
            when 1 =>
                if waiter = 100*g_CLKS_PER_BIT then
                    printer <= 2;
                    waiter <= 0;
                else
                    i_tx_dv <= '0';
                    waiter <= waiter + 1; 
                end if;
            when 2 =>
                pcout <= hit_count1(7 downto 0); 
--                pcout <= addr1(7 downto 0);
                printer <= 3;
                i_tx_dv <= '1';
            when 3 =>
                if waiter = 100*g_CLKS_PER_BIT then
                    printer <= 4;
                    waiter <= 0;
                else
                    i_tx_dv <= '0';
                    waiter <= waiter + 1; 
                end if;
            when 4 =>
                pcout <= hit_count2(15 downto 8);
--                pcout <= addr2(15 downto 8);
                printer <= 5;
                i_tx_dv <= '1';
            when 5 =>
                if waiter = 100*g_CLKS_PER_BIT then
                    printer <= 6;
                    waiter <= 0;
                else
                    i_tx_dv <= '0';
                    waiter <= waiter + 1; 
                end if;
            when 6 =>
                pcout <= hit_count2(7 downto 0); 
--                pcout <= addr2(7 downto 0);
                printer <= 7;
                i_tx_dv <= '1';
            when 7 =>
                if waiter = 100*g_CLKS_PER_BIT then
                    printer <= 8;
                    waiter <= 0;
                else
                    i_tx_dv <= '0';
                    waiter <= waiter + 1; 
                end if;
            when 8 =>
                pcout <= miss_count1(15 downto 8);
                printer <= 9;
                i_tx_dv <= '1';
            when 9 =>
                if waiter = 100*g_CLKS_PER_BIT then
                    printer <= 10;
                    waiter <= 0;
                else
                    i_tx_dv <= '0';
                    waiter <= waiter + 1; 
                end if;
            when 10 => 
                pcout <= miss_count1(7 downto 0);
                printer <= 11;
                i_tx_dv <= '1';
            when 11 =>
                if waiter = 100*g_CLKS_PER_BIT then
                    printer <= 12;
                    waiter <= 0;
                else
                    i_tx_dv <= '0';
                    waiter <= waiter + 1; 
                end if;
             when 12 =>
                pcout <= miss_count2(15 downto 8);
                printer <= 13;
                i_tx_dv <= '1';
            when 13 =>
                if waiter = 100*g_CLKS_PER_BIT then
                    printer <= 14;
                    waiter <= 0;
                else
                    i_tx_dv <= '0';
                    waiter <= waiter + 1; 
                end if;
            when 14 => 
                pcout <= miss_count2(7 downto 0);
                printer <= 15;
                i_tx_dv <= '1';
            when 15 =>
                if waiter = 100*g_CLKS_PER_BIT then
                    printer <= 0;
                    state <= 5;
                    waiter <= 0;
                else
                    i_tx_dv <= '0';
                    waiter <= waiter + 1; 
                end if;
            when others => 
                printer <= 0; 
        end case;       
     when others =>
        state <= 5;
    end case; 
    end if;
end process;

--hit_l1 <= hit_count1;
--hit_l2 <= hit_count2;
--miss_l1 <= miss_count1;
--miss_l2 <= miss_count2;
stop <= done;
--state_port <= state; 
end rtl;