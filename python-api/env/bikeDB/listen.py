import subprocess
import time
import bikeDB
import datetime
#p = subprocess.Popen(["java net.tinyos.tools.Listen -comm serial@/dev/ttyUSB1:iris &"], stdout=subprocess.PIPE, shell=True)
p = subprocess.Popen(["java net.tinyos.tools.Listen &"], stdout=subprocess.PIPE, shell=True)

def unsecret(secret):
    return (secret-9)/7

bDB = bikeDB.BikeDB()

COORDS_PER_PACKET=2
LENGTH_OF_PACKET=(2+4+4+4)*2 #in nibbles
while True:
	pkt=p.stdout.readline().strip(" \n\r\t").lower()  #reads until \n
	#00 00 08 00 1A 22 22 71 00 01 00 05 00 1A 24 EE 00 BF FF AA FF BB 00 00 00 00 03 12 AF BC 00 00 00 00 00 97 CD 2F 00 00 00 00
	pkt=pkt.replace(" ","")
	print(pkt)
	if (pkt[30:32]=="ee"): #dissemination ID
	    nodeid=pkt[32:36]
	    print "sent by:",unsecret(int(nodeid,16)),"(%s)"%nodeid
	    runtime=int(pkt[36:44],16)/1000.0
	    print "runtime:",runtime
	    offset=44
	    for i in range(0,COORDS_PER_PACKET):
	        t=int(pkt[offset+i*8:offset+i*8+8],16)/1000.0
	        lat=int(pkt[offset+i*8+COORDS_PER_PACKET*8:offset+i*8+COORDS_PER_PACKET*8+8],16)/1000000.0
	        lon=int(pkt[offset+i*8+COORDS_PER_PACKET*8+COORDS_PER_PACKET*8:offset+i*8+COORDS_PER_PACKET*8+COORDS_PER_PACKET*8+8],16)/1000000.0
	        
	        print "time:",t
	        print "lat:",lat
	        print "lon:",lon
	        timestamp=datetime.datetime.fromtimestamp(time.time()-int(runtime-t)).isoformat()
	        print "timestamp:",timestamp
	        print "insert:","%d"%int(nodeid,16),
		print lat,lon,timestamp
	        if (lat<99 and lon<99 and lat!=0.0 and lon!=0.0):
	            bDB.insertPosition("%d"%int(nodeid,16),str(lat),str(lon),timestamp)
	        #lat = pkt[
