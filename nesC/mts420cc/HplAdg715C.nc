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
 * The adg715 chip has 8 channels that are controlled through the I2C
 * bus.  This configuration provides a ChannelMask interface corresponding
 * to the 8 physical channels on the chip.  This implementation is
 * specific to how the I2C bus is implemented on the micaz platform.
 * 
 * @author Danny Park
 * @author Andreas Zdziarstek
 */
 
generic configuration HplAdg715C(bool pinA1High, bool pinA2High) {
	 provides {
		interface ChannelMask<uint8_t>;
	}
}
implementation {
	components new Adg715ControlC(pinA1High, pinA2High),
		new Atm128I2CMasterC();
  
	ChannelMask = Adg715ControlC.ChannelMask;
	Adg715ControlC.I2CPacket -> Atm128I2CMasterC;
	Adg715ControlC.Resource -> Atm128I2CMasterC;
}
