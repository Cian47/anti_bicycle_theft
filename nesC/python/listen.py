import subprocess
import time
#p = subprocess.Popen(["java net.tinyos.tools.Listen -comm serial@/dev/ttyUSB1:iris &"], stdout=subprocess.PIPE, shell=True)
p = subprocess.Popen(["java net.tinyos.tools.Listen &"], stdout=subprocess.PIPE, shell=True)

while True:
	pkt=p.stdout.readline().strip(" \n\r\t")  #reads until \n
	print(pkt)
