import subprocess
import time
import bikeDB
import datetime
import thread
import os

maxBikes=10

def unsecret(secret):
    return (secret-9)/7

def send(bDB):
    while True:
        stolen=bDB.getIdsOfStolen()
        cmd="java net.tinyos.tools.Send "
        pkt="00 FF FF 00 04 %02x FE 2A "
        packetlength=2
        stolen_str=""
        for b in stolen:
            stolen_str+="%02x %02x "%(int(b)/256,int(b)%256)
            packetlength+=2
        for i in range(maxBikes-len(stolen)):
            stolen_str+="00 00 "
            packetlength+=2
        if packetlength>2: 
            pkt = pkt % packetlength
            pkt = pkt + stolen_str
            cmd = cmd + pkt.upper()
            print("send: {}".format(pkt))
            print(cmd)
            os.system(cmd)

        time.sleep(3);


def recv(bDB):
    #p = subprocess.Popen(["java net.tinyos.tools.Listen -comm serial@/dev/ttyUSB1:iris &"], stdout=subprocess.PIPE, shell=True)
    p = subprocess.Popen(["java net.tinyos.tools.Listen &"], stdout=subprocess.PIPE, shell=True)  # use this WITH serialForwarder
    COORDS_PER_PACKET=2
    LENGTH_OF_PACKET=(2+4+4+4)*2 #in nibbles
    while True:
        pkt=p.stdout.readline().strip(" \n\r\t").lower()  #reads until \n
        pkt=pkt.replace(" ","")
        print("recv: {}".format(pkt))
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


if __name__ == "__main__":
    bDB = bikeDB.BikeDB()
    thread.start_new_thread(send,(bDB,))
    recv(bDB) # blocking