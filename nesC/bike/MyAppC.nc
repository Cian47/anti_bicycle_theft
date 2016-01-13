#include "DataMsg.h"

configuration MyAppC {}
implementation {
  components MyC, MainC, LedsC, ActiveMessageC;
  components CollectionC as Collector;
  components new CollectionSenderC(0xee);
  components new TimerMilliC();
  components Lea4aGpsC as Gps;
  MyC.GpsControl -> Gps.SplitControl;
  MyC.GpsMsg -> Gps.GpsMsg;

  MyC.Boot -> MainC;
  MyC.RadioControl -> ActiveMessageC;
  MyC.RoutingControl -> Collector;
  MyC.Leds -> LedsC;
  MyC.Timer -> TimerMilliC;
  MyC.Send -> CollectionSenderC;
  MyC.RootControl -> Collector;
  MyC.Receive -> Collector.Receive[0xee];
  
  
    components CounterMicro32C;
    components new CounterToLocalTimeC(TMicro) as CounterToLocalTimeMicroC;
    CounterToLocalTimeMicroC.Counter -> CounterMicro32C;
    MyC.LocalTimeMicro -> CounterToLocalTimeMicroC;
    
    
    components DisseminationC;
    MyC.DisseminationControl -> DisseminationC;

    components new DisseminatorC(EasyDisseminationMsg, 0x1234) as Diss16C;
    MyC.Value -> Diss16C;
    MyC.Update -> Diss16C;
}
