--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
--Date        : Sun Apr  1 21:43:35 2018
--Host        : nk7u running 64-bit Ubuntu 17.10
--Command     : generate_target L2_lru_wrapper.bd
--Design      : L2_lru_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity L2_lru_wrapper is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 6 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 63 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 63 downto 0 );
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
end L2_lru_wrapper;

architecture STRUCTURE of L2_lru_wrapper is
  component L2_lru is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 6 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 63 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 63 downto 0 );
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component L2_lru;
begin
L2_lru_i: component L2_lru
     port map (
      BRAM_PORTA_0_addr(6 downto 0) => BRAM_PORTA_0_addr(6 downto 0),
      BRAM_PORTA_0_clk => BRAM_PORTA_0_clk,
      BRAM_PORTA_0_din(63 downto 0) => BRAM_PORTA_0_din(63 downto 0),
      BRAM_PORTA_0_dout(63 downto 0) => BRAM_PORTA_0_dout(63 downto 0),
      BRAM_PORTA_0_we(0) => BRAM_PORTA_0_we(0)
    );
end STRUCTURE;
