#include <Timer.h>
#include "DataMsg.h"
#include "Lea4a.h"
#include "DataMsg.h"

#define MAXPOSITIONS 100

/**
* @modified_by Kevin Freeman
* @modified_by Martin Schwarzmaier
*/

module BikeC 
{
    uses interface Boot;
    uses interface SplitControl as RadioControl;
    uses interface StdControl as RoutingControl;
    uses interface Send;
    uses interface Leds;
    uses interface Timer<TMilli>;
    uses interface RootControl;
    uses interface Receive;

    uses interface SplitControl as GpsControl;
    uses interface GpsMsg;

    //localtime:
    uses interface LocalTime<TMicro> as LocalTimeMicro;

    //diss
    uses interface StdControl as DisseminationControl;
    uses interface DisseminationValue<EasyDisseminationMsg> as Value;
    uses interface DisseminationUpdate<EasyDisseminationMsg> as Update;


}
implementation 
{
    message_t packet;
    bool sendBusy = FALSE;
    uint8_t stolen=0x00;
    EasyDisseminationMsg pkt;
    uint8_t gps_started = 0;
    uint32_t lons[MAXPOSITIONS];
    uint32_t lats[MAXPOSITIONS];
    uint32_t times[MAXPOSITIONS];
    int current_writing_pos=0;
    uint32_t gps_signals_received=0;
    int current_reading_pos=0;


    int secret()
    {
        return TOS_NODE_ID*7+9;
    }

    event void Boot.booted() {
        call RadioControl.start();
    }

    event void RadioControl.startDone(error_t err) {
        if (err != SUCCESS)
            call RadioControl.start();
        else {
            call RoutingControl.start();
            call DisseminationControl.start();
        // if (TOS_NODE_ID == 1) 
        //  call RootControl.setRoot();
        //else
        //call Timer.startPeriodic(5000);
        }
    }

    event void RadioControl.stopDone(error_t err) 
    {}

    void sendMessage() 
    {
        uint8_t i;
        uint8_t j=0;
        EasyCollectionMsg* msg =
        (EasyCollectionMsg*)call Send.getPayload(&packet, sizeof(EasyCollectionMsg));
        msg->nodeid = secret();
        msg->current_time=(uint32_t)((call LocalTimeMicro.get())/1000);

        /* clean up the msg*/
        for (i=0;i<COORDS_PER_PACKET;i++)
        {
            msg->time[i]=0;
            msg->lat[i]=0;
            msg->lon[i]=0;
        }

        atomic
        {
            for (i=current_reading_pos;i!=current_writing_pos;i++)
            {
                msg->time[j] = times[i];
                msg->lat[j] = lats[i];
                msg->lon[j] = lons[i];
                times[i]=0;
                lats[i]=0;
                lons[i]=0;
                current_reading_pos++; //we read the value
                if (current_reading_pos==MAXPOSITIONS)
                    current_reading_pos=0;

                j++;
                if (j==COORDS_PER_PACKET)
                    break;
            }      
        }

        if (call Send.send(&packet, sizeof(EasyCollectionMsg)) != SUCCESS) 
            call Leds.led0On();
        else 
            sendBusy = TRUE;
    }
    event void Timer.fired() 
    {
        call Leds.led2Toggle();
        gps_started=2;
    }

    event void Send.sendDone(message_t* m, error_t err) 
    {
        if (err != SUCCESS) 
            call Leds.led0On();
        sendBusy = FALSE;
    }

    event message_t* 
    Receive.receive(message_t* msg, void* payload, uint8_t len) 
    {
                //call Leds.led1Toggle();    
        return msg;
    }

    event void GpsMsg.newMessage(gps_msg_t *msg, error_t error) 
    {
        gps_signals_received++;
        if (gps_started==2 && gps_signals_received%100==0)//now we save coords
        {
            double lat = (double) msg->deg[0] + (((double) msg->minhi[0] + ((double) msg->minlo[0] / 100000.0)) / 60.0);
            double lon = (double) msg->deg[1] + (((double) msg->minhi[1] + ((double) msg->minlo[1] / 100000.0)) / 60.0);
            atomic
            {
                lats[current_writing_pos]=(uint32_t)(lat*1000000);
                lons[current_writing_pos]=(uint32_t)(lon*1000000);
                times[current_writing_pos]=(uint32_t)((call LocalTimeMicro.get())/1000); //3digits ms
                current_writing_pos++;
                if (current_writing_pos==MAXPOSITIONS)
                    current_writing_pos=0;
                call Leds.led0Toggle();
            }       
       }

        if(error == SUCCESS) call Leds.led2Toggle(); //Blink Yellow for GPS fix
        
        //gps_started=2; //made timer dependent
            call GpsMsg.Listen(TRUE);
        }

        event void GpsControl.startDone(error_t error) 
        {
            call GpsMsg.Listen(TRUE);
      }
      event void GpsControl.stopDone(error_t error) 
      {}

      event void Value.changed() 
      {
        uint8_t i;
        const EasyDisseminationMsg* newVal = call Value.get();
        bool found=FALSE;
        pkt = *newVal;
        for (i=0;i<MAXBIKES;i++)
        {
            if (pkt.bikes[i]==secret())
            {  
                stolen=0x01;
                found=TRUE;
                call Leds.led1On();
                if (gps_started==0)
                {
                    gps_started=1;
                    call Timer.startOneShot(90000); //wait X/1000 secs
                    call GpsControl.start();
                }
                else if (gps_started==2) //startDone for gps
                {   
                    call Leds.led2Toggle();
                    //it is stolen AND received a broadcast 
                    //=> DUMP ONE PACKET
                    sendMessage(); 
                }
            }
        }
        if (found==FALSE)
        {
            call Leds.led1Off();
            stolen=0x00;
            if (gps_started>1)
            {
                call GpsControl.stop();
                gps_started=0;
            }
        }
    }

}


