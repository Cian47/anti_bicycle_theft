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

#include "Lea4a.h"

interface GpsMsg {
	/**
	 * Open communication channels and start listening to the GPS.
	 * Sends an event, when a GLL message has been received and interpreted.
	 * This will occupy UART1.
	 * 
	 * @param oneShot If TRUE, the driver will stop listening after having
	 * received one message and close the comm channels. Useful for sharing
	 * UART1.
	 **/
	command void Listen (bool oneShot);
	
	/**
	 * This event is sent, when a GLL message has been received and interpreted.
	 * 
	 * @param msg Will contain position and time data on success, otherwise all
	 * fields will contain 99 (as this represents an impossible time and position)
	 * @param err Will read FAIL if interpretation has failed due to invalid checksum,
	 * invalid-data flag or conversion error(s)
	 **/
	event void newMessage (gps_msg_t *msg, error_t error);
}
