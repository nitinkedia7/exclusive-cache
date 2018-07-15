library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity combined_sim is
--  Port ( );
end combined_sim;

architecture TB of combined_sim is
    component controller is
    Port (
        clk : in std_logic;
        start : in std_logic;
        stop: out std_logic;
        state_port : out integer;
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
    end component;

signal clk : std_logic := '0';
signal start : std_logic := '0';
signal stop : std_logic := '0';
signal hit_l1 : std_logic_vector (15 downto 0) := (others => '0');
signal hit_l2 : std_logic_vector (15 downto 0) := (others => '0');
signal miss_l1 : std_logic_vector (15 downto 0) := (others => '0');
signal miss_l2 : std_logic_vector (15 downto 0) := (others => '0');
signal q1 : std_logic := '0';
signal q2 : std_logic := '0';
signal d1 : std_logic;
signal d2 : std_logic;
signal addr : std_logic_vector (15 downto 0) := (others => '0');
signal index : std_logic_vector (9 downto 0) := (others => '0');
signal state, state_l1 : integer;
constant clk_period : time := 1 ns;

begin
    uut: controller port map(
        clk => clk,
        start => start,
        stop => stop,
        state_port => state,
        hit_l1 => hit_l1,
        hit_l2 => hit_l2,
        miss_l1 => miss_l1,
        miss_l2 => miss_l2,
        q1 => q1,
        d1 => d1,
        q2 => q2,
        d2 => d2,
        addr => addr,
        state_l => state_l1,
        ind => index
        );
     clk_process :process
       begin
            clk <= '0';
            wait for clk_period;
            clk <= '1';
            wait for clk_period;
       end process;   
    query_process : process
     begin
        start <= '1';
        wait until stop = '1';
     end process query_process;
end TB;