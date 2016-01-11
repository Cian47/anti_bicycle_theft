#include <Timer.h>
#include "DataMsg.h"

module EasyCollectionC {
  uses interface Boot;
  uses interface SplitControl as RadioControl;
  uses interface StdControl as RoutingControl;
  uses interface Send;
  uses interface Leds;
  uses interface Timer<TMilli>;
  uses interface RootControl;
  uses interface Receive;
  
  //localtime:
  uses interface LocalTime<TMicro> as LocalTimeMicro;
}
implementation {
  message_t packet;
  bool sendBusy = FALSE;


  event void Boot.booted() {
    call RadioControl.start();
  }
  
  event void RadioControl.startDone(error_t err) {
    if (err != SUCCESS)
      call RadioControl.start();
    else {
      call RoutingControl.start();
      if (TOS_NODE_ID == 8) 
	call RootControl.setRoot();
      else
	call Timer.startPeriodic(10000);
    }
  }

  event void RadioControl.stopDone(error_t err) {}

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
  
  event void Send.sendDone(message_t* m, error_t err) {
    if (err != SUCCESS) 
      call Leds.led0On();
    sendBusy = FALSE;
  }
  
  event message_t* 
  Receive.receive(message_t* msg, void* payload, uint8_t len) {
    call Leds.led1Toggle();    
    return msg;
  }
}

