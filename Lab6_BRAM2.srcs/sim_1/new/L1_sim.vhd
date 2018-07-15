library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity L1_simulation is
--  Port ( );
end L1_simulation;

architecture Behavioral of L1_simulation is
    component L1 is
    Port (
        clk : in std_logic;
        query : in std_logic;
        addr : in std_logic_vector(15 downto 0);
        carry_out : out std_logic_vector(16 downto 0);
	    done : out std_logic;
        hit_miss : out std_logic;
        state_out: out integer;
        set_out : out std_logic_vector(4 downto 0)   
    );
    end component;

signal clk : std_logic := '0';
signal query : std_logic := '0';
signal addr : std_logic_vector (15 downto 0) := (others => '0');
signal carry_out : std_logic_vector (16 downto 0);
signal done : std_logic;
signal hit_miss : std_logic;
signal state : integer;
signal set : std_logic_vector(4 downto 0);

constant clk_period : time := 1 ns;

begin
    inst_DUT: L1 port map(
        clk => clk,
        query => query,
        addr => addr,
        carry_out => carry_out,
        done => done,
        hit_miss => hit_miss,
        state_out => state,
        set_out => set
        );
     clk_process :process
           begin
                clk <= '0';
                wait for clk_period;
                clk <= '1';
                wait for clk_period;
           end process;   
    query_process : process
           variable i: integer;
           begin
           i := 1;
           query <= '0';
           addr <= (others => '0');
           wait for clk_period*2;
           for i in 1 to 64 loop    
            query <= '0';
            wait for clk_period*2;
            query <= '1';
            wait until done = '1';
            wait for clk_period*2;
            addr <= addr + '1'; 
           end loop;
--           addr <= (others => '0');
--           for i in 1 to 64 loop    
--            query <= '0';
--            wait for clk_period*2;
--            query <= '1';
--            wait for clk_period*2;
--            addr <= addr + '1'; 
--           end loop;
           end process query_process;
end Behavioral;