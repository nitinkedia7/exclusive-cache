import serial
import time

path = '/home/nk7/Lab6_BRAM_final/data_rand.txt'
port = "/dev/ttyUSB1"
baud = 9600
byte = serial.EIGHTBITS
par = serial.PARITY_NONE
sto = serial.STOPBITS_ONE
ser = serial.Serial(port, baudrate=baud, bytesize=byte, parity=par, stopbits=sto, timeout=2)

ser.close()
ser.open()

if ser.isOpen():
	print(ser.name + ' is open... ')

query_list = []
with open(path) as f:
	query_list = f.readlines()
	query_list = [(int)(x.strip()) for x in query_list]
temp1 = 0
temp2 = 0
for query in query_list:
	temp1 = (int)(query/256)
	temp2 = query%256
	ser.write(bytes([temp2]))
	time.sleep(0.002)
	ser.write(bytes([temp1]))
	time.sleep(0.002)

# time.sleep(2)
st = ser.read(2)
hit1 = int.from_bytes(st, byteorder='big')
print("hits in L1: " + str(hit1))
st = ser.read(2)
hit2 = int.from_bytes(st, byteorder='big')
print("hits in L2: " + str(hit2))
st = ser.read(2)
miss1 = int.from_bytes(st, byteorder='big')
print("misses in L1: " + str(miss1))
st = ser.read(2)
miss2 = int.from_bytes(st, byteorder='big')
print("misses in L2: " + str(miss2))
ser.close()

print("L1 hit ratio:", str(hit1/1024))
if (miss1 != 0):
	print("L2 hit ratio:", str(hit2/miss1))
exit(1)
