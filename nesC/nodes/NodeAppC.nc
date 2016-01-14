/**
* @author Kevin Freeman
* @author Martin Schwarzmaier
*/

#include "DataMsg.h"

configuration NodeAppC 
{
}
implementation 
{
    components MainC;
    components EasyCollectionC;
    components EasyDisseminationC;
    
    components NodeC;
    components LedsC;
    components ActiveMessageC;
    components DisseminationC;
    components new DisseminatorC(EasyDisseminationMsg, 0x1234) as Diss16C;
    components new TimerMilliC() as DissTimer;
    components CollectionC as Collector;
    components new CollectionSenderC(0xee);
    components new TimerMilliC() as CollTimer;
    components CounterMicro32C;
    components new CounterToLocalTimeC(TMicro) as CounterToLocalTimeMicroC;

    EasyDisseminationC.Boot -> MainC;
    
    NodeC.Boot -> MainC;
    
    EasyDisseminationC.RadioControl -> ActiveMessageC;
    EasyDisseminationC.DisseminationControl -> DisseminationC;
    EasyDisseminationC.Value -> Diss16C;
    EasyDisseminationC.Update -> Diss16C;
    EasyDisseminationC.Leds -> LedsC;
    EasyDisseminationC.Timer -> DissTimer;

    EasyCollectionC.Boot -> MainC;
    EasyCollectionC.RadioControl -> ActiveMessageC;
    EasyCollectionC.RoutingControl -> Collector;
    EasyCollectionC.Leds -> LedsC;
    EasyCollectionC.Timer -> CollTimer;
    EasyCollectionC.Send -> CollectionSenderC;
    EasyCollectionC.RootControl -> Collector;
    EasyCollectionC.Receive -> Collector.Receive[0xee];

    CounterToLocalTimeMicroC.Counter -> CounterMicro32C;
    EasyCollectionC.LocalTimeMicro -> CounterToLocalTimeMicroC;

    
}
