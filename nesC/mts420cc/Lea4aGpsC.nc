/*
 * Copyright (c) 2015 Andreas Zdziarstek
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
 * - Neither the name of the copyright holders nor the names of
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
 */

#include "Adg715.h" 

configuration Lea4aGpsC {
	provides {
		interface GpsMsg;
		interface SplitControl;
	}
}
implementation {
	components Lea4aGpsP;
	components Adg715C;
	components Atm128Uart1C as UART1;
	components MeasureClockC;

	GpsMsg = Lea4aGpsP;
	SplitControl = Lea4aGpsP;
	Lea4aGpsP.Uart1Ctrl -> UART1.StdControl;
	Lea4aGpsP.AdgRes -> Adg715C.Resource[unique(UQ_ADG715)];
	Lea4aGpsP.CommChannels -> Adg715C.CommChannels;
	Lea4aGpsP.PowerChannels -> Adg715C.PowerChannels;
	Lea4aGpsP.Atm128Calibrate -> MeasureClockC.Atm128Calibrate;
	Lea4aGpsP.Uart1 -> UART1.UartStream;
}

