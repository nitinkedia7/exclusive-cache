--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
--Date        : Sun Apr  1 21:43:36 2018
--Host        : nk7u running 64-bit Ubuntu 17.10
--Command     : generate_target L2_block.bd
--Design      : L2_block
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity L2_block is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 6 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 47 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 47 downto 0 );
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of L2_block : entity is "L2_block,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=L2_block,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of L2_block : entity is "L2_block.hwdef";
end L2_block;

architecture STRUCTURE of L2_block is
  component L2_block_blk_mem_gen_0_0 is
  port (
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 6 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 47 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 47 downto 0 )
  );
  end component L2_block_blk_mem_gen_0_0;
  signal BRAM_PORTA_0_1_ADDR : STD_LOGIC_VECTOR ( 6 downto 0 );
  signal BRAM_PORTA_0_1_CLK : STD_LOGIC;
  signal BRAM_PORTA_0_1_DIN : STD_LOGIC_VECTOR ( 47 downto 0 );
  signal BRAM_PORTA_0_1_DOUT : STD_LOGIC_VECTOR ( 47 downto 0 );
  signal BRAM_PORTA_0_1_WE : STD_LOGIC_VECTOR ( 0 to 0 );
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of BRAM_PORTA_0_clk : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTA_0 CLK";
  attribute X_INTERFACE_INFO of BRAM_PORTA_0_addr : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTA_0 ADDR";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of BRAM_PORTA_0_addr : signal is "XIL_INTERFACENAME BRAM_PORTA_0, MASTER_TYPE OTHER, MEM_ECC NONE, MEM_SIZE 8192, MEM_WIDTH 32, READ_WRITE_MODE READ_WRITE";
  attribute X_INTERFACE_INFO of BRAM_PORTA_0_din : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTA_0 DIN";
  attribute X_INTERFACE_INFO of BRAM_PORTA_0_dout : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTA_0 DOUT";
  attribute X_INTERFACE_INFO of BRAM_PORTA_0_we : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTA_0 WE";
begin
  BRAM_PORTA_0_1_ADDR(6 downto 0) <= BRAM_PORTA_0_addr(6 downto 0);
  BRAM_PORTA_0_1_CLK <= BRAM_PORTA_0_clk;
  BRAM_PORTA_0_1_DIN(47 downto 0) <= BRAM_PORTA_0_din(47 downto 0);
  BRAM_PORTA_0_1_WE(0) <= BRAM_PORTA_0_we(0);
  BRAM_PORTA_0_dout(47 downto 0) <= BRAM_PORTA_0_1_DOUT(47 downto 0);
blk_mem_gen_0: component L2_block_blk_mem_gen_0_0
     port map (
      addra(6 downto 0) => BRAM_PORTA_0_1_ADDR(6 downto 0),
      clka => BRAM_PORTA_0_1_CLK,
      dina(47 downto 0) => BRAM_PORTA_0_1_DIN(47 downto 0),
      douta(47 downto 0) => BRAM_PORTA_0_1_DOUT(47 downto 0),
      wea(0) => BRAM_PORTA_0_1_WE(0)
    );
end STRUCTURE;
