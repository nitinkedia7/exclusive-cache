library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity L1 is
 Port (
    clk : in std_logic;
    query : in std_logic;
    addr : in std_logic_vector(15 downto 0);
    carry_out : out std_logic_vector(16 downto 0);
    done : out std_logic;
    hit_miss : out std_logic
    );
end L1;

architecture Behavioral of L1 is
--component declaration
component L1_Block_wrapper is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 4 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
end component;
component L1_lru_wrapper is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 4 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
end component;
component L1_mru_wrapper is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 4 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 7 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 7 downto 0 );
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
end component;

--signal declaration
signal state : integer := 0;
signal next_state : integer := 0;

signal set : std_logic_vector (4 downto 0) := (others => '0');
signal tag : std_logic_vector(7 downto 0) := "10000000";
signal block_in : std_logic_vector (31 downto 0) := (others => '0');
signal block_out : std_logic_vector (31 downto 0) := (others => '0');
signal lru_in : std_logic_vector (31 downto 0) := (others => '0');
signal lru_out : std_logic_vector (31 downto 0) := (others => '0');
signal mru_in : std_logic_vector (7 downto 0) := (others => '0');
signal mru_out : std_logic_vector (7 downto 0) := (others => '0');  
signal all_block : std_logic_vector (31 downto 0) := (others => '0');
signal all_lru : std_logic_vector (31 downto 0) := (others => '0');
signal all_mru : std_logic_vector (7 downto 0) := (others => '0');
signal mru_value : std_logic_vector(7 downto 0) := (others => '0');
signal block_enable : std_logic := '0';
signal lru_enable : std_logic := '0';
signal mru_enable : std_logic := '0';

begin
--component instantination
L1_Block_i: component L1_Block_wrapper
     port map (
      BRAM_PORTA_0_addr(4 downto 0) => set,
      BRAM_PORTA_0_clk => clk,
      BRAM_PORTA_0_din(31 downto 0) => block_in,
      BRAM_PORTA_0_dout(31 downto 0) => block_out,
      BRAM_PORTA_0_we(0) => block_enable
);
L1_lru_i: component L1_lru_wrapper
     port map (
      BRAM_PORTA_0_addr(4 downto 0) => set,
      BRAM_PORTA_0_clk => clk,
      BRAM_PORTA_0_din(31 downto 0) => lru_in,
      BRAM_PORTA_0_dout(31 downto 0) => lru_out,
      BRAM_PORTA_0_we(0) => lru_enable
    );
L1_mru_i: component L1_mru_wrapper
         port map (
          BRAM_PORTA_0_addr(4 downto 0) => set,
          BRAM_PORTA_0_clk => clk,
          BRAM_PORTA_0_din(7 downto 0) => mru_in,
          BRAM_PORTA_0_dout(7 downto 0) => mru_out,
          BRAM_PORTA_0_we(0) => mru_enable
        );
NEXT_STATE_DECODE : PROCESS (clk)
 variable equal_b0: STD_LOGIC_VECTOR(7 downto 0);
 variable equal_b1: STD_LOGIC_VECTOR(7 downto 0);
 variable equal_b2: STD_LOGIC_VECTOR(7 downto 0);
 variable equal_b3: STD_LOGIC_VECTOR(7 downto 0);
 variable is_b0: STD_LOGIC;
 variable is_b1: STD_LOGIC;
 variable is_b2: STD_LOGIC;
 variable is_b3: STD_LOGIC;
 variable hit : std_logic;
 variable lru: std_logic_vector(1 downto 0);
 variable lru_value  : std_logic_vector(7 downto 0);
  BEGIN
    IF (rising_edge(clk)) THEN
    CASE (state) IS

      WHEN 0 =>       -- Initialize
        if (query = '1') then
            state <= 1;               
        end if;
        hit_miss <= '0';
        done <= '0';
      WHEN 1 => -- assign set
        tag <= '1' & addr(15 downto 9);             --add valid bit
        set <= addr(8 downto 4);
        state <= 12;
      WHEN 12 =>        --buffer state for clock sycronization
        state <= 2;  
      WHEN 2 =>        --buffer state for clock sycronization
        state <= 17;
      WHEN 17 =>        --state responsible for extraction of set array, lru array,mru of set
        all_block <= block_out;
        all_lru <= lru_out;
        mru_value <= mru_out + 1;
        state <= 7;
      WHEN 7 =>          
        equal_b0 := all_block(7 downto 0) xnor tag;                 --compare blocks with tag
        equal_b1 := all_block(15 downto 8) xnor tag;
        equal_b2 := all_block(23 downto 16) xnor tag;
        equal_b3 := all_block(31 downto 24) xnor tag;
        is_b0 := equal_b0(7) and equal_b0(6) and equal_b0(5) and equal_b0(4) and equal_b0(3) and equal_b0(2) and equal_b0(1) and equal_b0(0);       --find all true or not
        is_b1 := equal_b1(7) and equal_b1(6) and equal_b1(5) and equal_b1(4) and equal_b1(3) and equal_b1(2) and equal_b1(1) and equal_b1(0);
        is_b2 := equal_b2(7) and equal_b2(6) and equal_b2(5) and equal_b2(4) and equal_b2(3) and equal_b2(2) and equal_b2(1) and equal_b2(0);
        is_b3 := equal_b3(7) and equal_b3(6) and equal_b3(5) and equal_b3(4) and equal_b3(3) and equal_b3(2) and equal_b3(1) and equal_b3(0);   
        hit := is_b0 or is_b1 or is_b2 or is_b3;            --take or to calculate hit
        hit_miss <= hit;
        if (hit = '1') then                                 --if hit find block and change its lru value and go writing state
            if (is_b0 = '1') then              
                all_lru(7 downto 0) <= mru_value;
            elsif (is_b1 = '1') then              
                all_lru(15 downto 8) <= mru_value;
            elsif (is_b2 = '1') then              
                all_lru(23 downto 16) <= mru_value;
            elsif (is_b3 = '1') then              
                all_lru(31 downto 24) <= mru_value;
            end if;
            state <= 3;
        else
            state <= 4;                                 --if miss go to finding lru state
        end if;
      WHEN 3 => -- complete hit
        lru_enable <= '1';                              --enable writing permission
        mru_enable <= '1';
        mru_in <= mru_value;
        lru_in <= all_lru;
        state <= 10;
      WHEN 10 =>
        lru_enable <= '0';                              --disable writing permission                  
        mru_enable <= '0';
        state <= 6;
      WHEN 4 =>
        state <= 8;                                     --buffer state
      WHEN 8 =>
        if (all_lru(15 downto 8) < all_lru(7 downto 0)) then        --find block with least lru value
            lru := "01";
            lru_value := all_lru(15 downto 8);
        else
            lru := "00";
            lru_value := all_lru(7 downto 0);
        end if;
        if (all_lru(23 downto 16) < lru_value) then
            lru := "10";
            lru_value := all_lru(23 downto 16);
        end if;
        if (all_lru(31 downto 24) < lru_value) then
            lru := "11";
            lru_value := all_lru(31 downto 24);
        end if;
              
        if (lru = "00") then                                        --replace the lru block with the current query and change its lru value as well as mru value of set 
            carry_out <= all_block(7 downto 0) & addr(8 downto 0);      --save the block which is getting replaced
            all_block(7 downto 0) <= '1' & tag(6 downto 0);
            all_lru(7 downto 0) <= mru_value;                 
        elsif (lru = "01") then
            carry_out <= all_block(15 downto 8) & addr(8 downto 0);
            all_block(15 downto 8) <= '1' & tag(6 downto 0);
            all_lru(15 downto 8) <= mru_value;             
        elsif (lru = "10") then
            carry_out <= all_block(23 downto 16) & addr(8 downto 0);
            all_block(23 downto 16) <= '1' & tag(6 downto 0);
            all_lru(23 downto 16) <= mru_value;             
        elsif (lru = "11") then
            carry_out <= all_block(31 downto 24) & addr(8 downto 0);
            all_block(31 downto 24) <= '1' & tag(6 downto 0);
            all_lru(31 downto 24) <= mru_value;             
        end if;
        state <= 9;
     WHEN 9 =>
        block_in <= all_block;                  --give writing permissions
        lru_in <= all_lru;
        mru_in <= mru_value;
        mru_enable <= '1';
        block_enable <= '1';
        lru_enable <= '1';
        state <= 5;
      WHEN 5 => -- finish miss
        block_enable <= '0';                --disable writing permissions
        lru_enable <= '0';
        mru_enable <= '0';
        state <= 6;
      WHEN 6 =>                             --change done signal to 1 as query is completed
        done <= '1';
        state <= 16;
      WHEN 16 =>                            --buffer states for clock sychronization
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
