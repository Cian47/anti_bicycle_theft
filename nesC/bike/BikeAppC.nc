#include "DataMsg.h"

configuration BikeAppC {
}
implementation {
    components MainC;
    components LedsC;
    components BikeC as App;
    components Lea4aGpsC as Gps;

    App.Boot -> MainC;
    App.Leds -> LedsC;
    App.GpsControl -> Gps.SplitControl;
    App.GpsMsg -> Gps.GpsMsg;

    components ActiveMessageC;
    App.RadioControl -> ActiveMessageC;

    components DisseminationC;
    App.DisseminationControl -> DisseminationC;

    components new DisseminatorC(EasyDisseminationMsg, 0x1234) as Diss16C;
    App.Value -> Diss16C;
    App.Update -> Diss16C;

    //components new TimerMilliC() as DissTimer;
    //App.Timer -> DissTimer;
    
    components CollectionC as Collector;
    components new CollectionSenderC(0xee);

    components new TimerMilliC() as CollTimer;
    
    ///*unneeded?*/ EasyCollectionC.RadioControl -> ActiveMessageC;
    //EasyCollectionC.RoutingControl -> Collector;
    //EasyCollectionC.Leds -> LedsC;
    //EasyCollectionC.Timer -> CollTimer;
    App.Send -> CollectionSenderC;
    //EasyCollectionC.RootControl -> Collector;
    App.Receive -> Collector.Receive[0xee];

    components CounterMicro32C;
    components new CounterToLocalTimeC(TMicro) as CounterToLocalTimeMicroC;
    CounterToLocalTimeMicroC.Counter -> CounterMicro32C;
    App.LocalTimeMicro -> CounterToLocalTimeMicroC;
}
