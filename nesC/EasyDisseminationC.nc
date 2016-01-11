#include <Timer.h>
#include "DataMsg.h"

module EasyDisseminationC {
  uses interface Boot;
  uses interface SplitControl as RadioControl;
  uses interface StdControl as DisseminationControl;
  uses interface DisseminationValue<EasyDisseminationMsg> as Value;
  uses interface DisseminationUpdate<EasyDisseminationMsg> as Update;
  uses interface Leds;
  uses interface Timer<TMilli>;
}

implementation {

  
  EasyDisseminationMsg pkt;
  
  //uint16_t bikes[]={-1,-1,-1,-1,-1,-1,-1,-1,-1,-1};

  /*task void ShowCounter() {
    if (bikes & 0x1) 
      call Leds.led0On();
    else 
      call Leds.led0Off();
    if (counter & 0x2) 
      call Leds.led1On();
    else 
      call Leds.led1Off();
    if (counter & 0x4) 
      call Leds.led2On();
    else
      call Leds.led2Off();
  }*/

  event void Boot.booted() {
    call RadioControl.start();
  }

  event void RadioControl.startDone(error_t err) {
    if (err != SUCCESS) 
      call RadioControl.start();
    else {
      call DisseminationControl.start();
      //counter = 0;
      if ( TOS_NODE_ID  == 8 ) 
        call Timer.startPeriodic(2000);
    }
  }

  event void RadioControl.stopDone(error_t err) {}

  event void Timer.fired() {
  //LOAD BIKES; PUSH
    pkt.bikes[0]=0xACCF;
    pkt.bikes[2]=0x0815;
    pkt.bikes[3]=0x0404;
    //pkt->bikes[1]=0xFEAA;
    //pkt->bikes[2]=0x1010;
    // show counter in leds
    //post ShowCounter();
    // disseminate counter value
    call Update.change(&pkt);
  }

  event void Value.changed() {
    const EasyDisseminationMsg* newVal = call Value.get();
    // show new counter in leds
    pkt = *newVal;
    if (pkt.bikes[0]==0xABCF)
    	call Leds.led1Toggle();
    //post ShowCounter();
  }
}
