-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
-- Date        : Sun Apr  1 21:47:52 2018
-- Host        : nk7u running 64-bit Ubuntu 17.10
-- Command     : write_vhdl -force -mode synth_stub
--               /home/nk7/Lab6_BRAM2/Lab6_BRAM2.srcs/sources_1/bd/L2_block/ip/L2_block_blk_mem_gen_0_0/L2_block_blk_mem_gen_0_0_stub.vhdl
-- Design      : L2_block_blk_mem_gen_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35ticpg236-1L
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity L2_block_blk_mem_gen_0_0 is
  Port ( 
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 6 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 47 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 47 downto 0 )
  );

end L2_block_blk_mem_gen_0_0;

architecture stub of L2_block_blk_mem_gen_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,wea[0:0],addra[6:0],dina[47:0],douta[47:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_4_1,Vivado 2017.4";
begin
end;
