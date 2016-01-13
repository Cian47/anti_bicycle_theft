import subprocess
import time
#p = subprocess.Popen(["java net.tinyos.tools.Listen -comm serial@/dev/ttyUSB1:iris &"], stdout=subprocess.PIPE, shell=True)
p = subprocess.Popen(["java net.tinyos.tools.Listen &"], stdout=subprocess.PIPE, shell=True)

def unsecret(secret):
    return (secret-9)/7

COORDS_PER_PACKET=2
LENGTH_OF_PACKET=(2+4+4+4)*2 #in nibbles
while True:
	pkt=p.stdout.readline().strip(" \n\r\t").lower()  #reads until \n
	#00 00 08 00 1A 22 22 71 00 01 00 05 00 1A 24 EE 00 BF FF AA FF BB 00 00 00 00 03 12 AF BC 00 00 00 00 00 97 CD 2F 00 00 00 00
	pkt=pkt.replace(" ","")
	if (pkt[30:32]=="ee"): #dissemination ID
	    nodeid=pkt[32:36]
	    print "sent by:",unsecret(int(nodeid,16)),"(%s)"%nodeid
	    for i in range(0,COORDS_PER_PACKET):
	        time=int(pkt[36+i*8:36+i*8+8],16)/1000.0
	        lat=int(pkt[36+i*8+COORDS_PER_PACKET*8:36+i*8+COORDS_PER_PACKET*8+8],16)/1000000.0
	        lon=int(pkt[36+i*8+COORDS_PER_PACKET*8+COORDS_PER_PACKET*8:36+i*8+COORDS_PER_PACKET*8+COORDS_PER_PACKET*8+8],16)/1000000.0
	        
	        print "time:",time
	        print "lat:",lat
	        print "lon:",lon
	        #lat = pkt[
	print(pkt)
