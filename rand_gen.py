from random import randrange

PATH = '/home/nk7/Lab6_BRAM_final/data_rand.txt'
PATH2 = '/home/nk7/Lab6_BRAM_final/data_seq.txt'

m = int(input())
if (m == 0):
    with open(PATH, "w"):
        pass
    for i in range(1024):
    	addr = randrange(0, 65535) # 65535
    	with open(PATH,"a") as myfile:
    		myfile.write(str(addr)+"\n")
else:
    with open(PATH2, "w"):
        pass
    a = 0
    for i in range(1024):
        with open(PATH2,"a") as myfile:
            myfile.write(str(a)+"\n")
            a += m
