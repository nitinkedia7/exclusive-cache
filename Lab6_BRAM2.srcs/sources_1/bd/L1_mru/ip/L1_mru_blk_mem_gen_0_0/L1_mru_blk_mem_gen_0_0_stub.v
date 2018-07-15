// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
// Date        : Sun Apr  1 18:02:57 2018
// Host        : nk7u running 64-bit Ubuntu 17.10
// Command     : write_verilog -force -mode synth_stub
//               /home/nk7/Lab6_BRAM2/Lab6_BRAM2.srcs/sources_1/bd/L1_mru/ip/L1_mru_blk_mem_gen_0_0/L1_mru_blk_mem_gen_0_0_stub.v
// Design      : L1_mru_blk_mem_gen_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35ticpg236-1L
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_1,Vivado 2017.4" *)
module L1_mru_blk_mem_gen_0_0(clka, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[4:0],dina[7:0],douta[7:0]" */;
  input clka;
  input [0:0]wea;
  input [4:0]addra;
  input [7:0]dina;
  output [7:0]douta;
endmodule
