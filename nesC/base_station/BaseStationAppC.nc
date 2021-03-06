// $Id: BaseStationAppC.nc,v 1.7 2010-06-29 22:07:13 scipio Exp $

/*									tab:4
* Copyright (c) 2000-2003 The Regents of the University  of California.  
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
*
* - Redistributions of source code must retain the above copyright
*   notice, this list of conditions and the following disclaimer.
* - Redistributions in binary form must reproduce the above copyright
*   notice, this list of conditions and the following disclaimer in the
*   documentation and/or other materials provided with the
*   distribution.
* - Neither the name of the University of California nor the names of
*   its contributors may be used to endorse or promote products derived
*   from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
* FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
* THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
* HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
* STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
* OF THE POSSIBILITY OF SUCH DAMAGE.
*
* Copyright (c) 2002-2003 Intel Corporation
* All rights reserved.
*
* This file is distributed under the terms in the attached INTEL-LICENSE     
* file. If you do not find these files, copies can be found by writing to
* Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
* 94704.  Attention:  Intel License Inquiry.
*/

/**
* The TinyOS 2.x base station that forwards packets between the UART
* and radio.It replaces the GenericBase of TinyOS 1.0 and the
* TOSBase of TinyOS 1.1.
*
* <p>On the serial link, BaseStation sends and receives simple active
* messages (not particular radio packets): on the radio link, it
* sends radio active messages, whose format depends on the network
* stack being used. BaseStation will copy its compiled-in group ID to
* messages moving from the serial link to the radio, and will filter
* out incoming radio messages that do not contain that group ID.</p>
*
* <p>BaseStation includes queues in both directions, with a guarantee
* that once a message enters a queue, it will eventually leave on the
* other interface. The queues allow the BaseStation to handle load
* spikes.</p>
*
* <p>BaseStation acknowledges a message arriving over the serial link
* only if that message was successfully enqueued for delivery to the
* radio link.</p>
*
* <p>The LEDS are programmed to toggle as follows:</p>
* <ul>
* <li><b>RED Toggle:</b>: Message bridged from serial to radio</li>
* <li><b>GREEN Toggle:</b> Message bridged from radio to serial</li>
* <li><b>YELLOW/BLUE Toggle:</b> Dropped message due to queue overflow in either direction</li>
* </ul>
*
* @author Phil Buonadonna
* @author Gilman Tolle
* @author David Gay
* @author Philip Levis
* @date August 10 2005
* @modified_by Kevin Freeman
* @modified_by Martin Schwarzmaier
*/

configuration BaseStationAppC 
{
}
implementation 
{
    components MainC, BaseStationC, LedsC;
    components ActiveMessageC as Radio, SerialActiveMessageC as Serial;
    components EasyCollectionC;
    components EasyDisseminationC;
    components CounterMicro32C;
    components new CounterToLocalTimeC(TMicro) as CounterToLocalTimeMicroC;
    components ActiveMessageC;
    components DisseminationC;
    components new DisseminatorC(EasyDisseminationMsg, 0x1234) as Diss16C;
    components new TimerMilliC() as DissTimer;
    components CollectionC as Collector;
    components new CollectionSenderC(0xee);
    components new TimerMilliC() as CollTimer;

    MainC.Boot <- BaseStationC;

    BaseStationC.RadioControl -> Radio;
    BaseStationC.SerialControl -> Serial;

    BaseStationC.UartSend -> Serial;
    BaseStationC.UartReceive -> Serial.Receive;
    BaseStationC.UartPacket -> Serial;
    BaseStationC.UartAMPacket -> Serial;

    BaseStationC.RadioSend -> Radio;
    BaseStationC.RadioReceive -> Radio.Receive;
    BaseStationC.RadioSnoop -> Radio.Snoop;
    BaseStationC.RadioPacket -> Radio;
    BaseStationC.RadioAMPacket -> Radio;

    BaseStationC.Leds -> LedsC;

    BaseStationC.DisseminationControl -> DisseminationC;

    BaseStationC.Value -> Diss16C;
    BaseStationC.Update -> Diss16C;

    BaseStationC.Timer -> DissTimer;


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
