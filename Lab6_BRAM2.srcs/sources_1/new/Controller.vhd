--library declaration
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity controller is
    generic (
     g_CLKS_PER_BIT : integer := 10417
    );
    port (
        clk : in std_logic;
        i_RX_Serial : in  std_logic;        -- serial input recieved from pc
        sel : in std_logic_vector(1 downto 0);
        res :out std_logic_vector (15 downto 0);
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
architecture rtl of controller is
--component declaration
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
component traceram_wrapper is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 9 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 15 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 15 downto 0 );
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
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


-- signal declarations
signal tr_enable : std_logic := '0';
signal tr_in : std_logic_vector(15 downto 0);
signal tr_out : std_logic_vector(15 downto 0);
signal index : std_logic_vector(10 downto 0) := (others => '0');
signal temp, done: std_logic;
signal X : std_logic := '0';
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

signal addr: std_logic_vector(15 downto 0);
signal start: std_logic := '0';
signal stop : std_logic := '0';
-- Rx 
type t_SM_Main is (s_Idle, s_RX_Start_Bit, s_RX_Data_Bits,
                     s_RX_Stop_Bit, s_Cleanup, save, save2, s_0, s_1, s_2, s_3, s_4, s_5, s_6, s_10, s_11, s_15, s_9, s_26, s_36);
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

--component inst
L1_inst : L1 port map(clk, query1, addr1, carry, done1, hit1);          --L1 cache
L2_inst : L2 port map(clk, query2, addr2, carry, done2, hit2);          --L2 cache
outstream: entity work.UART_TX port map(Clk, i_tx_dv, pcout, serialout, o_tx_done);         --Uart for pc communication
TR_i: component traceram_wrapper                                        --Trace ram in which queries are saved
     port map (
      BRAM_PORTA_0_addr(9 downto 0) => index(9 downto 0),
      BRAM_PORTA_0_clk => clk,
      BRAM_PORTA_0_din(15 downto 0) => tr_in,
      BRAM_PORTA_0_dout(15 downto 0) => tr_out,
      BRAM_PORTA_0_we(0) => tr_enable
);

p_SAMPLE : process (Clk)
--process responsible mapping uart ports
begin
if rising_edge(Clk) then
  r_RX_Data_R <= i_RX_Serial;                  
  r_RX_Data   <= r_RX_Data_R;
end if;
end process p_SAMPLE;

o_RX_Byte <= r_RX_Byte;
o_RX_DV   <= r_RX_DV;

p_UART_RX: process (clk)
begin 
if rising_edge(clk) then       
  case r_SM_Main is
    when s_Idle =>                      --s_Idle state denotes ideal position at the start when input is to be taken
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
        if( X = '0') then           --8 bits data recieved 8 more to come so change x to 1 denoting more to come 
            X <= '1';
            tr_in(7 downto 0) <= r_RX_Byte;
            r_SM_Main <= s_Idle;
        elsif( X = '1') then
            X <= '0';               --all 16 bit recieved now move to sate that will save it the traceram blockram
            tr_in(15 downto 8) <= r_RX_Byte;
            r_SM_Main <= save;
        end if;
    when save =>
        tr_enable <= '1';                                   --write enabled for trace ram
        r_SM_Main <= save2;
    when save2 =>
        tr_enable <= '0';                                   --write permission disabeled
        if (index = "01111111111") then                     --till number of queries reaches 1024 repeat else move to query state
            index <= (others => '0');
            r_SM_Main <= s_5;
        else
            r_SM_Main <= s_Idle;
            index <= index + 1;
        end if;
    when s_5 =>                                            --default state of query 
        r_SM_Main <= s_15;
        done <= '0';                                        --initialize done to 0 done 1 when query has been completed
    when s_15 =>
        r_SM_Main <= s_0;                                   --buffer state for sychronizing clock
    when s_0 => 
       if (index = "10000000000") then                      -- if number of queries exceed 1024 go to printing state
            r_SM_Main <= s_4;   
            done <= '1';
       else                                                 --else extract the query value from traceram and start query in cache L1
           query1 <= '1';
           addr <= tr_out;
           addr1 <= tr_out; 
           r_SM_Main <= s_1;
       end if;
    when s_1 =>
        if (done1 = '1') then                             --till L1 cache query is complete wait 
            if (hit1 = '1') then                          --if hit increase hit in L1 and prepare for next query
                hit_count1 <= hit_count1 + 1;
                r_SM_Main <= s_6;
            else                                          --if miss increase miss in L1 and go to query state of L2
                miss_count1 <= miss_count1 + 1;
                r_SM_Main <= s_2;
            end if;
            query1 <= '0';                                  --when done becomes 1 query in L1 completed 
        else
            r_SM_Main <= s_1;
        end if;
     when s_2 =>                                           --activate query in L2 and send in value of query
         query2 <= '1';
         addr2 <= tr_out;
         r_SM_Main <= s_3;
     when s_3 =>
        if (done2 = '1') then                               --till L2 cache query is complete wait
            if (hit2 = '1') then                            -- if hit increase hit in L2 and prepare for next query
                hit_count2 <= hit_count2 + 1;
            else                                            --if miss increase miss in L2 and prepare for next query
                miss_count2 <= miss_count2 + 1;
            end if;
            query2 <= '0';                                  --turn query in L2 off
            r_SM_Main <= s_6;
        else
            r_SM_Main <= s_3;
        end if;
     when s_6 =>
        index <= index + 1;                                 --increase index value for next query
        r_SM_Main <= s_26;
     when s_26 =>                                           --buffer states for clock sychronization
       r_SM_Main <= s_36;
     when s_36 =>
          r_SM_Main <= s_0;
     when s_4 =>
        case printer is
            when 0 =>                                       --send last 8 bit of hit in L1 and activate print 
                pcout <= hit_count1(15 downto 8);
                printer <= 1;
                i_tx_dv <= '1';
            when 1 =>                                       --wait for completion of 8 bits and preapre for next 8 bit sending of hit in L1
                if waiter = 100*g_CLKS_PER_BIT then
                    printer <= 2;
                    waiter <= 0;
                else
                    i_tx_dv <= '0';
                    waiter <= waiter + 1; 
                end if;
            when 2 => 
                pcout <= hit_count1(7 downto 0);                -- send first 8 bits of hit in L1
                printer <= 3;
                i_tx_dv <= '1';
            when 3 =>
                if waiter = 100*g_CLKS_PER_BIT then          --wait for completion of 8 bits and preapre for  sending 8 bits of hit in L2
                    printer <= 4;
                    waiter <= 0;
                else
                    i_tx_dv <= '0';
                    waiter <= waiter + 1; 
                end if;
            when 4 =>
                pcout <= hit_count2(15 downto 8);                --send last 8 bit of hit in L2 and activate print 
                printer <= 5;
                i_tx_dv <= '1';
            when 5 =>
                if waiter = 100*g_CLKS_PER_BIT then              --wait for completion of 8 bits and preapre for next 8 bit sending of hit in L2
                    printer <= 6;
                    waiter <= 0;
                else
                    i_tx_dv <= '0';
                    waiter <= waiter + 1; 
                end if;
            when 6 => 
                pcout <= hit_count2(7 downto 0);                -- send first 8 bits of hit in L2
                printer <= 7;
                i_tx_dv <= '1';
            when 7 =>
                if waiter = 100*g_CLKS_PER_BIT then          --wait for completion of 8 bits and then send to next state
                    printer <= 8;
                    waiter <= 0;
                else
                    i_tx_dv <= '0';
                    waiter <= waiter + 1; 
                end if;
            when 8 =>
                pcout <= miss_count1(15 downto 8);                -- send first 8 bits of miss in L1
                printer <= 9;
                i_tx_dv <= '1';
            when 9 =>                                       --wait for completion of 8 bits and preapre for next 8 bit sending of miss in L1
                if waiter = 100*g_CLKS_PER_BIT then
                    printer <= 10;
                    waiter <= 0;
                else
                    i_tx_dv <= '0';
                    waiter <= waiter + 1; 
                end if;
            when 10 => 
                pcout <= miss_count1(7 downto 0);                -- send first 8 bits of miss in L1
                printer <= 11;
                i_tx_dv <= '1';
            when 11 =>
                if waiter = 100*g_CLKS_PER_BIT then         --wait for completion of 8 bits and preapre for  sending 8 bits of miss in L2
                    printer <= 12;
                    waiter <= 0;
                else
                    i_tx_dv <= '0';
                    waiter <= waiter + 1; 
                end if;
             when 12 =>
                pcout <= miss_count2(15 downto 8);                -- send last 8 bits of miss in L2
                printer <= 13;
                i_tx_dv <= '1';
            when 13 =>                                      --wait for completion of 8 bits and preapre for next 8 bit sending of miss in L2
                if waiter = 100*g_CLKS_PER_BIT then
                    printer <= 14;
                    waiter <= 0;
                else
                    i_tx_dv <= '0';
                    waiter <= waiter + 1; 
                end if;
            when 14 => 
                pcout <= miss_count2(7 downto 0);                -- send first 8 bits of miss in L2
                printer <= 15;
                i_tx_dv <= '1';
            when 15 =>
                if waiter = 100*g_CLKS_PER_BIT then
                    printer <= 0;
                    r_SM_Main <= s_Idle;
                    waiter <= 0;
                else
                    i_tx_dv <= '0';
                    waiter <= waiter + 1; 
                end if;
            when others => 
                printer <= 0; 
        end case;     
     when others =>
        r_SM_Main <= s_Idle;
    end case;
end if;
end process;

process(clk)                                                    --this process is responsible displaying hit or miss in L1 or L2 depending on user input
begin
    if (index = "10000000000") then
        case sel is 
            when "00" =>                                        --hit in L1
                res <= hit_count1;
            when "01" =>                                       --miss in L1
                res <= hit_count2;
            when "10" =>                                       --hit in L2
                res <= miss_count1;
            when "11" =>                                       --miss in L2
                res <= miss_count2;
            when others =>
                res <= (others => '0');
        end case;
    end if;
end process;
stop <= done;
end rtl;