# Exclusive Cache

Design and impementation of a two level (L1 & L2) cache with exclusive cache inclusion policy in VHDL developed in Xilinx Vivado on BASYS 3 FPGA board. The implementation comprises of 2 ASMs (Asynchronous State Machines) each for the L1 and the L2 level. A third ASM serves as a cache controller. Cache block replacement was done using LRU policy.

The implementation was cross-checked by multiple iterations of the following steps:

1. Generate a query-set of 1024 random (also sequential) main memory addresses using a python script rand_gen.py.
2. Sequentially querying these addresses on a freshly programmed FPGA from PC though UART using uart.py script.
3. Match the Hit/Miss data with an identical C++ implementation check.cpp.
4. Simulation in Vivado for sequential memory addresses is also present.

## Important Links
* [Cache exclusion policy wiki](https://en.wikipedia.org/wiki/Cache_inclusion_policy)
* [Problem statement for exact design specifications](https://github.com/nitinkedia7/exclusive-cache/blob/master/AssgnStmt-06.pdf)
* [Leat Recently Used (LRU) policy](http://www.mathcs.emory.edu/~cheung/Courses/355/Syllabus/9-virtual-mem/LRU-replace.html)

## Authors

* **[Nitin Kedia](https://in.linkedin.com/in/nitinkedia7)**
* **[Abhinav Mishra](https://in.linkedin.com/in/abmishra1)**
* **[Jatin Goyal](https://in.linkedin.com/in/jatingoyal412)**
* **[Namit Kumar](https://in.linkedin.com/in/namitkrarya)**
