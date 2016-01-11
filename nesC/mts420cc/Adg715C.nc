/*
 * Copyright (c) 2008 Rincon Research Corporation
 * All rights reserved.
 * 
 * modified 2015 by Andreas Zdziarstek
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the Rincon Research Corporation nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
 * RINCON RESEARCH OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE
 */

/**
 * The ADG715 chip has 8 channels that are controlled through the I2C
 * bus.  This configuration provides 2 ChannelMask interfaces,
 * one for each chip. CommChannels represents the chip switching the
 * communication lines, while PowerChannels the one switching the
 * power lines. This implementation is specific to the MTS420CC
 * sensorboard.
 * 
 * @author Danny Park
 * @author Andreas Zdziarstek
 */
 
#include "Adg715.h" 
 
configuration Adg715C {
	provides {
		interface ChannelMask<uint8_t> as CommChannels;
		interface ChannelMask<uint8_t> as PowerChannels;
		interface Resource[ uint8_t id ];
	}
}
implementation {
	components new FcfsArbiterC( UQ_ADG715 );
	Resource = FcfsArbiterC;
	components new HplAdg715C(FALSE, TRUE) as Comm;
	CommChannels = Comm.ChannelMask;
	components new HplAdg715C(FALSE, FALSE) as Power;
	PowerChannels = Power.ChannelMask;
}
