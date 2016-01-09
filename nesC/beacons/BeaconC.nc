#include <Timer.h>

module BeaconC {
  uses interface Boot;
  uses interface Leds;
}

implementation {

  event void Boot.booted() {
      call Leds.led0On();
      call Leds.led2On();
  }
  
  
  /* listen for broadcast of bike, answer if necessary ?
  event message_t* 
  Receive.receive(message_t* msg, void* payload, uint8_t len) {
    call Leds.led2Toggle();    
    return msg;
  }*/

}
