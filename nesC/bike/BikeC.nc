#include <math.h>
#include "Lea4a.h"

#define P_LAT 51.556147 //Center Coordinates, red LED will light up
#define P_LON  9.948392 //if going more than defined distance away in either direction
#define DIST 0.1  //in kilometres

module Lea4aTestC {
  uses interface Boot;
  uses interface Leds;
  uses interface SplitControl as GpsControl;
  uses interface GpsMsg;
}
implementation {
	
	event void Boot.booted() {
		call GpsControl.start();
	}
	
	event void GpsControl.startDone(error_t error) {
		call GpsMsg.Listen(TRUE);
	}
	event void GpsControl.stopDone(error_t error) {}
	
	event void GpsMsg.newMessage(gps_msg_t *msg, error_t error) {
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
	}
}
