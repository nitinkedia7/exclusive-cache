library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity L2 is
 Port (
    clk : in std_logic;
    query : in std_logic;
    addr : in std_logic_vector(15 downto 0);
    carry_in : in std_logic_vector(16 downto 0);
    done : out std_logic;
    hit_miss : out std_logic 
    );
end L2;
--component declaration
architecture Behavioral of L2 is
component L2_Block_wrapper is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 6 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 47 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 47 downto 0 );
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
end component;
component L2_lru_wrapper is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 6 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 63 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 63 downto 0 );
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
end component;
component L2_mru_wrapper is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 6 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 7 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 7 downto 0 );
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
end component;
--signal declaration
signal state : integer := 0;
signal next_state : integer := 0;

signal set : std_logic_vector (6 downto 0) := (others => '0');
signal tag : std_logic_vector(5 downto 0) := "100000";
signal block_in : std_logic_vector (47 downto 0) := (others => '0');
signal block_out : std_logic_vector (47 downto 0) := (others => '0');
signal lru_in : std_logic_vector (63 downto 0) := (others => '0');
signal lru_out : std_logic_vector (63 downto 0) := (others => '0');
signal mru_in : std_logic_vector (7 downto 0) := (others => '0');
signal mru_out : std_logic_vector (7 downto 0) := (others => '0');  
signal all_block : std_logic_vector (47 downto 0) := (others => '0');
signal all_lru : std_logic_vector (63 downto 0) := (others => '0');
signal mru_value : std_logic_vector(7 downto 0) := (others => '0');
signal block_enable : std_logic := '0';
signal lru_enable : std_logic := '0';
signal mru_enable : std_logic := '0';

begin
--component instantination
L2_Block_i: component L2_Block_wrapper
     port map (
      BRAM_PORTA_0_addr(6 downto 0) => set,
      BRAM_PORTA_0_clk => clk,
      BRAM_PORTA_0_din(47 downto 0) => block_in,
      BRAM_PORTA_0_dout(47 downto 0) => block_out,
      BRAM_PORTA_0_we(0) => block_enable
);
L2_lru_i: component L2_lru_wrapper
     port map (
      BRAM_PORTA_0_addr(6 downto 0) => set,
      BRAM_PORTA_0_clk => clk,
      BRAM_PORTA_0_din(63 downto 0) => lru_in,
      BRAM_PORTA_0_dout(63 downto 0) => lru_out,
      BRAM_PORTA_0_we(0) => lru_enable
    );
L2_mru_i: component L2_mru_wrapper
         port map (
          BRAM_PORTA_0_addr(6 downto 0) => set,
          BRAM_PORTA_0_clk => clk,
          BRAM_PORTA_0_din(7 downto 0) => mru_in,
          BRAM_PORTA_0_dout(7 downto 0) => mru_out,
          BRAM_PORTA_0_we(0) => mru_enable
        );

NEXT_STATE_DECODE : PROCESS (clk)
 variable equal_b0: STD_LOGIC_VECTOR(5 downto 0);
 variable equal_b1: STD_LOGIC_VECTOR(5 downto 0);
 variable equal_b2: STD_LOGIC_VECTOR(5 downto 0);
 variable equal_b3: STD_LOGIC_VECTOR(5 downto 0);
 variable equal_b4: STD_LOGIC_VECTOR(5 downto 0);
 variable equal_b5: STD_LOGIC_VECTOR(5 downto 0);
 variable equal_b6: STD_LOGIC_VECTOR(5 downto 0);
 variable equal_b7: STD_LOGIC_VECTOR(5 downto 0);
 variable is_b0: STD_LOGIC;
 variable is_b1: STD_LOGIC;
 variable is_b2: STD_LOGIC;
 variable is_b3: STD_LOGIC;
 variable is_b4: STD_LOGIC;
 variable is_b5: STD_LOGIC;
 variable is_b6: STD_LOGIC;
 variable is_b7: STD_LOGIC;
 variable hit : std_logic;
 variable lru: std_logic_vector(2 downto 0);
 variable lru_value  : std_logic_vector(7 downto 0);
  BEGIN
  IF (rising_edge(clk)) THEN
    CASE (state) IS
      WHEN 0 =>       -- Initialize
        if (query = '1') then
            state <= 1;               
        end if;
        done <= '0';
        hit_miss <= '0';
      WHEN 1 => -- assign set
        tag <= '1' & addr(15 downto 11);             --add valid bit
        set <= addr(10 downto 4);
        state <= 12;
      WHEN 12 =>                     --buffer state for clock sycronization
        state <= 2;  
      WHEN 2 =>                    --buffer state for clock sycronization 
        state <= 17;
      WHEN 17 =>       --state responsible for extraction of set array, lru array,mru of set
        all_block <= block_out;
        all_lru <= lru_out;
        mru_value <= mru_out + 1;
        state <= 7;
      WHEN 7 =>          
        equal_b0 := all_block(5 downto 0) xnor tag;                 --compare blocks with tag
        equal_b1 := all_block(11 downto 6) xnor tag;
        equal_b2 := all_block(17 downto 12) xnor tag;
        equal_b3 := all_block(23 downto 18) xnor tag;
        equal_b4 := all_block(29 downto 24) xnor tag;
        equal_b5 := all_block(35 downto 30) xnor tag;
        equal_b6 := all_block(41 downto 36) xnor tag;
        equal_b7 := all_block(47 downto 42) xnor tag;
        is_b0 := equal_b0(5) and equal_b0(4) and equal_b0(3) and equal_b0(2) and equal_b0(1) and equal_b0(0);      --find all true or not
        is_b1 := equal_b1(5) and equal_b1(4) and equal_b1(3) and equal_b1(2) and equal_b1(1) and equal_b1(0);
        is_b2 := equal_b2(5) and equal_b2(4) and equal_b2(3) and equal_b2(2) and equal_b2(1) and equal_b2(0);
        is_b3 := equal_b3(5) and equal_b3(4) and equal_b3(3) and equal_b3(2) and equal_b3(1) and equal_b3(0);   
        is_b4 := equal_b4(5) and equal_b4(4) and equal_b4(3) and equal_b4(2) and equal_b4(1) and equal_b4(0);
        is_b5 := equal_b5(5) and equal_b5(4) and equal_b5(3) and equal_b5(2) and equal_b5(1) and equal_b5(0);
        is_b6 := equal_b6(5) and equal_b6(4) and equal_b6(3) and equal_b6(2) and equal_b6(1) and equal_b6(0);
        is_b7 := equal_b7(5) and equal_b7(4) and equal_b7(3) and equal_b7(2) and equal_b7(1) and equal_b7(0);
        hit := is_b0 or is_b1 or is_b2 or is_b3 or is_b4 or is_b5 or is_b6 or is_b7;
        hit_miss <= hit;            --take or to calculate hit
        if (hit = '1') then
            if (is_b0 = '1') then                                --if hit find block replace it with carry in from L1 and change its lru value and go writing state
                all_block(5 downto 0) <= carry_in(16 downto 11);              
                all_lru(7 downto 0) <= mru_value;
            elsif (is_b1 = '1') then              
                all_block(11 downto 6) <= carry_in(16 downto 11);
                all_lru(15 downto 8) <= mru_value;
            elsif (is_b2 = '1') then              
                all_block(17 downto 12) <= carry_in(16 downto 11);
                all_lru(23 downto 16) <= mru_value;
            elsif (is_b3 = '1') then              
                all_block(23 downto 18) <= carry_in(16 downto 11);
                all_lru(31 downto 24) <= mru_value;
            elsif (is_b4 = '1') then              
                all_block(29 downto 24) <= carry_in(16 downto 11);
                all_lru(39 downto 32) <= mru_value;
            elsif (is_b5 = '1') then              
                all_block(35 downto 30) <= carry_in(16 downto 11);
                all_lru(47 downto 40) <= mru_value;
            elsif (is_b6 = '1') then              
                all_block(41 downto 36) <= carry_in(16 downto 11);
                all_lru(55 downto 48) <= mru_value;
            elsif (is_b7 = '1') then              
                all_block(47 downto 42) <= carry_in(16 downto 11);
                all_lru(63 downto 56) <= mru_value;
            end if; 
            state <= 3;
        else
            state <= 4;                                 --if miss go to finding lru state
        end if;
      WHEN 3 => -- complete hit
        lru_enable <= '1';                             --enable writing permission
        mru_enable <= '1';
        block_enable <= '1';
        block_in <= all_block;
        mru_in <= mru_value;
        lru_in <= all_lru;
        state <= 10;
      WHEN 10 =>
        block_enable <= '0';                             --disable writing permission      
        lru_enable <= '0';
        mru_enable <= '0';
        state <= 6;
      WHEN 4 =>
        state <= 8;                                     --buffer state
      WHEN 8 =>
        if (all_lru(15 downto 8) < all_lru(7 downto 0)) then            --find block with least lru value
            lru := "001";
            lru_value := all_lru(15 downto 8);
        else
            lru := "000";
            lru_value := all_lru(7 downto 0);
        end if;
        if (all_lru(23 downto 16) < lru_value) then
            lru := "010";
            lru_value := all_lru(23 downto 16);
        end if;
        if (all_lru(31 downto 24) < lru_value) then
            lru := "011";
            lru_value := all_lru(31 downto 24);
        end if;
        if (all_lru(39 downto 32) < lru_value) then
            lru := "100";
            lru_value := all_lru(39 downto 32);
        end if;
        if (all_lru(47 downto 40) < lru_value) then
            lru := "101";
            lru_value := all_lru(47 downto 40);
        end if;
        if (all_lru(55 downto 48) < lru_value) then
            lru := "110";
            lru_value := all_lru(55 downto 48);
        end if;
        if (all_lru(63 downto 56) < lru_value) then
            lru := "111";
            lru_value := all_lru(63 downto 56);
        end if;
              
        if (lru = "000") then                                       --replace the lru block with the current query and change its lru value as well as mru value of set 
            all_block(5 downto 0) <= carry_in(16 downto 11);      --save the block which is getting replaced
            all_lru(7 downto 0) <= mru_value;                 
        elsif (lru = "001") then
            all_block(11 downto 6) <= carry_in(16 downto 11);
            all_lru(15 downto 8) <= mru_value;             
        elsif (lru = "010") then
            all_block(17 downto 12) <= carry_in(16 downto 11);
            all_lru(23 downto 16) <= mru_value;             
        elsif (lru = "011") then
            all_block(23 downto 18) <= carry_in(16 downto 11);
            all_lru(31 downto 24) <= mru_value;             
        elsif (lru = "100") then
            all_block(29 downto 24) <= carry_in(16 downto 11);
            all_lru(39 downto 32) <= mru_value;             
        elsif (lru = "101") then
            all_block(35 downto 30) <= carry_in(16 downto 11);
            all_lru(47 downto 40) <= mru_value;             
        elsif (lru = "110") then
            all_block(41 downto 36) <= carry_in(16 downto 11);
            all_lru(55 downto 48) <= mru_value;
        elsif (lru = "111") then
            all_block(47 downto 42) <= carry_in(16 downto 11);
            all_lru(63 downto 56) <= mru_value;       
        end if;
        state <= 9;
     WHEN 9 =>
        block_in <= all_block;                            --give writing permissions
        lru_in <= all_lru;
        mru_in <= mru_value;
        mru_enable <= '1';
        block_enable <= '1';
        lru_enable <= '1';
        state <= 5;
      WHEN 5 => -- finish miss
        block_enable <= '0';               --disable writing permissions
        mru_enable <= '0';
        lru_enable <= '0';
        state <= 6;
      WHEN 6 =>                            --change done signal to 1 as query is completed
        done <= '1';
        state <= 16;
      WHEN 16 =>                           --buffer states for clock sychronization
        done <= '0';
        state <= 26;
      WHEN 26 =>
        state <= 0;    
      WHEN OTHERS => 
        state <= 0; --Stay in the same state & wait for debug
    END CASE; 
  END IF;
  END PROCESS;

end Behavioral;
