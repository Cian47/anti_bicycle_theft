/**
* src: http://tinyos.stanford.edu/tinyos-wiki/index.php/Network_Protocols#Collection
* @modified_by Kevin Freeman
* @modified_by Martin Schwarzmaier
* Base_Station TOS_NODE_ID = 8
*/

#include <Timer.h>
#include "DataMsg.h"

module EasyDisseminationC 
{
    uses interface Boot;
    uses interface SplitControl as RadioControl;
    uses interface StdControl as DisseminationControl;
    uses interface DisseminationValue<EasyDisseminationMsg> as Value;
    uses interface DisseminationUpdate<EasyDisseminationMsg> as Update;
    uses interface Leds;
    uses interface Timer<TMilli>;
}

implementation 
{
    EasyDisseminationMsg pkt;

    event void Boot.booted() {
        call RadioControl.start();
    }

    event void RadioControl.startDone(error_t err) 
    {
        if (err != SUCCESS) 
            call RadioControl.start();
        else 
        {
            call DisseminationControl.start();
            if ( TOS_NODE_ID  == 8 ) 
                call Timer.startPeriodic(2000);
        }
    }

    event void RadioControl.stopDone(error_t err) {}

    event void Timer.fired() {
        //LOAD BIKES; PUSH /just an example, this is implemented at the base station
        pkt.bikes[0]=0xACCF;
        pkt.bikes[2]=0x0815;
        pkt.bikes[3]=0x0404;
        call Update.change(&pkt);
    }

    event void Value.changed() {
        const EasyDisseminationMsg* newVal = call Value.get();
        pkt = *newVal;
        //again, only an example
        if (pkt.bikes[0]==0xABCF)
            call Leds.led1Toggle();
    }
}
