#include "DataMsg.h"

configuration NodeAppC {
}
implementation {
    components MainC;
    components EasyCollectionC;
    components EasyDisseminationC;
    
    components NodeC;
    EasyDisseminationC.Boot -> MainC;
    
    components LedsC;
    NodeC.Boot -> MainC;
    NodeC.Leds -> LedsC;
    
    components ActiveMessageC;
    //NodeC.RadioControl -> ActiveMessageC;
    

    EasyDisseminationC.RadioControl -> ActiveMessageC;


    components DisseminationC;
    EasyDisseminationC.DisseminationControl -> DisseminationC;

    components new DisseminatorC(EasyDisseminationMsg, 0x1234) as Diss16C;
    EasyDisseminationC.Value -> Diss16C;
    EasyDisseminationC.Update -> Diss16C;
    EasyDisseminationC.Leds -> LedsC;

    components new TimerMilliC() as DissTimer;
    EasyDisseminationC.Timer -> DissTimer;

    components CollectionC as Collector;
    components new CollectionSenderC(0xee);

    components new TimerMilliC() as CollTimer;
    EasyCollectionC.Boot -> MainC;
    EasyCollectionC.RadioControl -> ActiveMessageC;
    EasyCollectionC.RoutingControl -> Collector;
    EasyCollectionC.Leds -> LedsC;
    EasyCollectionC.Timer -> CollTimer;
    EasyCollectionC.Send -> CollectionSenderC;
    EasyCollectionC.RootControl -> Collector;
    EasyCollectionC.Receive -> Collector.Receive[0xee];



    components CounterMicro32C;
    components new CounterToLocalTimeC(TMicro) as CounterToLocalTimeMicroC;
    CounterToLocalTimeMicroC.Counter -> CounterMicro32C;
    EasyCollectionC.LocalTimeMicro -> CounterToLocalTimeMicroC;

    
}
