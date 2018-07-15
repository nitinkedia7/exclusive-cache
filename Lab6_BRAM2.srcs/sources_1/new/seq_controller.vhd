library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity controller is
    port (
        clk : in std_logic;
        start : in std_logic;
        state_port : out integer;
        stop: out std_logic;
        hit_l1 : out std_logic_vector(15 downto 0);
        hit_l2 : out std_logic_vector(15 downto 0);
        miss_l1 : out std_logic_vector(15 downto 0);
        miss_l2 : out std_logic_vector(15 downto 0);
        q1: out std_logic;
        d1 : out std_logic;
        q2: out std_logic;
        d2 : out std_logic;        
        addr : out std_logic_vector(15 downto 0);
        state_l : out integer;
        ind : out std_logic_vector(9 downto 0)
     );
end controller;


architecture rtl of controller is

component L1 is
  Port (
    clk : in std_logic;
    query : in std_logic;
    addr : in std_logic_vector(15 downto 0);
    carry_out : out std_logic_vector(16 downto 0);
    done : out std_logic;
    hit_miss : out std_logic;
    state_l1 : out integer
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

signal state_sig : integer;
signal tr_enable : std_logic := '0';
signal tr_in : std_logic_vector(15 downto 0);
signal tr_out : std_logic_vector(15 downto 0);
signal value : std_logic_vector(15 downto 0) := (others => '0');
signal index : std_logic_vector(9 downto 0) := (others => '0');
signal temp, done: std_logic := '0';
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
signal r_SM_Main : integer := 5;

begin
L1_inst : L1 port map(clk, query1, addr1, carry, done1, hit1, state_sig);
L2_inst : L2 port map(clk, query2, addr2, carry, done2, hit2);
TR_i: component traceram_wrapper
     port map (
      BRAM_PORTA_0_addr(9 downto 0) => index,
      BRAM_PORTA_0_clk => clk,
      BRAM_PORTA_0_din(15 downto 0) => tr_in,
      BRAM_PORTA_0_dout(15 downto 0) => tr_out,
      BRAM_PORTA_0_we(0) => tr_enable
);
process(start, done)
begin
    if (rising_edge(start)) then
        temp <= '1';
    end if;
    if (done = '1') then
        temp <= '0';
    end if;
end process;

process (Clk)
begin
if rising_edge(Clk) then
  case r_SM_Main is
    when 5 =>
        if (temp = '1') then
            r_SM_Main <= 15;
        else
            r_SM_Main <= 5;
        end if;
        done <= '0';
    when 15 =>
        tr_in <= value;
        r_SM_Main <= 16;
    when 16 =>
        tr_enable <= '1';
        r_SM_Main <= 17;
    when 17 =>
        tr_enable <= '0';
        if (index = "1111111111") then
            index <= "0000000000";
            r_SM_Main <= 0;
        else
            r_SM_Main <= 15;
            index <= index + 1;
            value <= value + 15;
        end if;
    when 0 =>
       if (index = "1111111111") then
            r_SM_Main <= 4;
            done <= '1';
       else
           query1 <= '1';
           addr <= tr_out;
           addr1 <= tr_out;
           r_SM_Main <= 1;
       end if;
    when 1 =>
        if (done1 = '1') then
            if (hit1 = '1') then
                hit_count1 <= hit_count1 + 1;
                r_SM_Main <= 6;
            else
                miss_count1 <= miss_count1 + 1;
                r_SM_Main <= 2;
            end if;
            query1 <= '0';
        else
            r_SM_Main <= 1;
        end if;
     when 2 =>
         query2 <= '1';
         addr2 <= tr_out;
         r_SM_Main <= 3;
     when 3 =>
        if (done2 = '1') then
            if (hit2 = '1') then
                hit_count2 <= hit_count2 + 1;
            else
                miss_count2 <= miss_count2 + 1;
            end if;
            r_SM_Main <= 6;
            query2 <= '0';
        else
            r_SM_Main <= 3;
        end if;
     when 6 =>
        index <= index + 1;
        r_SM_Main <= 26;
     when 26 =>
        r_SM_Main <= 36;
     when 36 =>
           r_SM_Main <= 0;    
     when 4 =>
        done <= '1';
        r_SM_Main <= 5;
     when others =>
        r_SM_Main <= 5;
    end case;
end if;
end process;
hit_l1 <= hit_count1;
hit_l2 <= hit_count2;
miss_l1 <= miss_count1;
miss_l2 <= miss_count2;
stop <= done;
q1 <= query1;
q2 <= query2;
d1 <= done1;
d2 <= done2;
state_port <= r_SM_Main;
ind <= index;
state_l <= state_sig;
end rtl;
