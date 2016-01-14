
/**
* @modified_by Kevin Freeman
* @modified_by Martin Schwarzmaier
*/

#include "DataMsg.h"

configuration BikeAppC 
{}
implementation 
{
    components BikeC, MainC, LedsC, ActiveMessageC;
    components CollectionC as Collector;
    components new CollectionSenderC(0xee);
    components new TimerMilliC();
    components Lea4aGpsC as Gps;
    BikeC.GpsControl -> Gps.SplitControl;
    BikeC.GpsMsg -> Gps.GpsMsg;

    BikeC.Boot -> MainC;
    BikeC.RadioControl -> ActiveMessageC;
    BikeC.RoutingControl -> Collector;
    BikeC.Leds -> LedsC;
    BikeC.Timer -> TimerMilliC;
    BikeC.Send -> CollectionSenderC;
    BikeC.RootControl -> Collector;
    BikeC.Receive -> Collector.Receive[0xee];


    components CounterMicro32C;
    components new CounterToLocalTimeC(TMicro) as CounterToLocalTimeMicroC;
    CounterToLocalTimeMicroC.Counter -> CounterMicro32C;
    BikeC.LocalTimeMicro -> CounterToLocalTimeMicroC;


    components DisseminationC;
    BikeC.DisseminationControl -> DisseminationC;

    components new DisseminatorC(EasyDisseminationMsg, 0x1234) as Diss16C;
    BikeC.Value -> Diss16C;
    BikeC.Update -> Diss16C;
}
