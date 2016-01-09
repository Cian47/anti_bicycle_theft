#include <Timer.h>

module BikeC {
  uses interface Boot;
  uses interface Leds;
}

implementation {

  event void Boot.booted() {
      call Leds.led0On();
      call Leds.led2On();
  }

}
