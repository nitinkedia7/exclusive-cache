--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
--Date        : Sun Apr  1 17:58:45 2018
--Host        : nk7u running 64-bit Ubuntu 17.10
--Command     : generate_target L1_mru_wrapper.bd
--Design      : L1_mru_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity L1_mru_wrapper is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 4 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 7 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 7 downto 0 );
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
end L1_mru_wrapper;

architecture STRUCTURE of L1_mru_wrapper is
  component L1_mru is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 4 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 7 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 7 downto 0 );
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component L1_mru;
begin
L1_mru_i: component L1_mru
     port map (
      BRAM_PORTA_0_addr(4 downto 0) => BRAM_PORTA_0_addr(4 downto 0),
      BRAM_PORTA_0_clk => BRAM_PORTA_0_clk,
      BRAM_PORTA_0_din(7 downto 0) => BRAM_PORTA_0_din(7 downto 0),
      BRAM_PORTA_0_dout(7 downto 0) => BRAM_PORTA_0_dout(7 downto 0),
      BRAM_PORTA_0_we(0) => BRAM_PORTA_0_we(0)
    );
end STRUCTURE;
