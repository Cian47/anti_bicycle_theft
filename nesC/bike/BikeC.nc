#include <math.h>
#include "Lea4a.h"
#include "DataMsg.h"

#define P_LAT 51.556147 //Center Coordinates, red LED will light up
#define P_LON  9.948392 //if going more than defined distance away in either direction
#define DIST 0.1  //in kilometres

module BikeC {
  uses interface Boot;
  uses interface Leds;
  //uses interface SplitControl as GpsControl;
  //uses interface GpsMsg;
  
  
  uses interface SplitControl as RadioControl;
  //uses interface StdControl as DisseminationControl;
  //uses interface DisseminationValue<EasyDisseminationMsg> as Value;
  //uses interface DisseminationUpdate<EasyDisseminationMsg> as Update;
  
  //COLLECT
  uses interface Receive;
  uses interface Send;
  uses interface StdControl as RoutingControl;
  uses interface RootControl;
  uses interface Timer<TMilli>;
  
  
  //localtime:
  uses interface LocalTime<TMicro> as LocalTimeMicro;
  
}
implementation {
    uint8_t stolen=0x00;
    EasyDisseminationMsg pkt;
    message_t packet;
    bool sendBusy = FALSE;
    uint8_t gps_started = 0;
    //uint32_t lats[3000];
    //uint32_t lons[3000];
    
    int secret()
    {
        return TOS_NODE_ID*7+9;
    }
	
	event void Boot.booted() {
	    call RadioControl.start();
		//call GpsControl.start();
	}
	
	/*event void GpsControl.startDone(error_t error) {
	    gps_started=2;
		call GpsMsg.Listen(TRUE);
	}
	event void GpsControl.stopDone(error_t error) {}*/
	
	
	void sendMessage() {
    EasyCollectionMsg* msg =
      (EasyCollectionMsg*)call Send.getPayload(&packet, sizeof(EasyCollectionMsg));
    msg->nodeid[0] = 0xABCD;
    msg->time[0] = (uint32_t)((call LocalTimeMicro.get())/1000000);
    msg->lat[1] = 0xFEBBBBFA;
    
    if (call Send.send(&packet, sizeof(EasyCollectionMsg)) != SUCCESS) 
      call Leds.led0On();
    else 
      sendBusy = TRUE;
  }
  event void Timer.fired() {
    call Leds.led2Toggle();
    if (!sendBusy)
      sendMessage();
  }
	
	/* DUMP GPS HERE */
	void sendMessage2() 
	{
        EasyCollectionMsg* msg = (EasyCollectionMsg*)call Send.getPayload(&packet, sizeof(EasyCollectionMsg));
        msg->nodeid[0] = 0xABCD;//secret();
        msg->time[0] = (uint32_t)((call LocalTimeMicro.get())/1000000);
        msg->lat[1] = 0xFEBBBBFA;

        if (call Send.send(&packet, sizeof(EasyCollectionMsg)) != SUCCESS) 
            call Leds.led0On();
        else 
            sendBusy = TRUE;
    }
    
	/*event void GpsMsg.newMessage(gps_msg_t *msg, error_t error) {
			double lat = (double) msg->deg[0] + (((double) msg->minhi[0] + ((double) msg->minlo[0] / 100000.0)) / 60.0);
			double lon = (double) msg->deg[1] + (((double) msg->minhi[1] + ((double) msg->minlo[1] / 100000.0)) / 60.0);
			
			double latdist = DIST * (360.0/40075.0);
			double londist = DIST * (360.0/(cos(P_LAT)*40075.0)); // 100 Meter in Lat/Lon
			
			if(error == SUCCESS) call Leds.led2Toggle(); //Blink Yellow for GPS fix
			
			if(lat > P_LAT+latdist || lat < P_LAT-latdist || lon < P_LON-londist || lon > P_LON+londist) {
				call Leds.led0On();
				call Leds.led1Off();   //Red Light
			} else {
				call Leds.led1On();
				call Leds.led0Off();   //Green Light
			}
			call GpsMsg.Listen(TRUE);
	}*/
	
  
  event void Send.sendDone(message_t* m, error_t err) {
    //if (err != SUCCESS) 
    //  call Leds.led0On();
    sendBusy = FALSE;
  }
  
  event message_t* 
  Receive.receive(message_t* msg, void* payload, uint8_t len) {
    //call Leds.led1Toggle();    
    return msg;
  }
	
	event void RadioControl.startDone(error_t err) {
    if (err != SUCCESS) 
      call RadioControl.start();
    else {
      //call DisseminationControl.start();
	call Timer.startPeriodic(3000);
      //counter = 0;
      //if ( TOS_NODE_ID  == 8 ) 
      //  call Timer.startPeriodic(2000);
      //if (TOS_NODE_ID == 8) 
	  //  call RootControl.setRoot();
    }
  }

  event void RadioControl.stopDone(error_t err) {}

/*
  event void Value.changed() {
    uint8_t i;
    const EasyDisseminationMsg* newVal = call Value.get();
    // show new counter in leds
    pkt = *newVal;
    for (i=0;i<MAXBIKES;i++)
    {
        if (pkt.bikes[i]==secret())
        {
        	call Leds.led1On();
        	if (gps_started==0)
        	{
        	    gps_started=2;
        	    //call GpsControl.start();
    	    }
    	    else if (gps_started==2) //startDone for gps
    	    {   
    	        call Leds.led2Toggle();
    	        sendMessage(); //it is stolen AND received a broadcast => DUMP ONE PACKET
	        }
  	    }
        //post ShowCounter();
    }
  }*/
}
