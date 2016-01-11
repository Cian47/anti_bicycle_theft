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

#include <Atm128Uart.h>
#include <string.h>
#include "mts420cc.h"
#include "Lea4a.h"

#define OFF 0
#define POWERING_UP 1
#define POWERING_DOWN 2
#define PICKING_UP 3
#define HANGING_UP 4

module Lea4aGpsP {
	provides {
		interface GpsMsg;
		interface SplitControl;
	}
	uses {
		interface ChannelMask<uint8_t> as PowerChannels;
		interface ChannelMask<uint8_t> as CommChannels;
		interface Resource as AdgRes;
		interface StdControl as Uart1Ctrl;
		interface UartStream as Uart1;
		interface Atm128Calibrate;
	}
}
implementation {
	gps_msg_t msgbuf[2];
	uint8_t curm = 0, send = 0, stage = OFF, u1l, u1h, len;
	bool os;
	char buf[64];
	
	//finalize and send event
	void parser_end(bool success) {

		if(!success) {
			//Failure to interpret message or invalid data:
			msgbuf[curm].deg[0] = 99; //impossible coordinates
			msgbuf[curm].deg[1] = 99;
			msgbuf[curm].t_hr = 99;
			msgbuf[curm].t_min = 99;
			msgbuf[curm].t_sec = 99;
			msgbuf[curm].t_msec = 99;
			//send FAIL error flag
			signal GpsMsg.newMessage(&msgbuf[curm], FAIL);
		} else {
			//Success, send data
			signal GpsMsg.newMessage(&msgbuf[curm], SUCCESS);
		}
		curm ^= 1;
		//in continuous listening mode, reenable the UART interrupt
		if(!os) call Uart1.enableReceiveInterrupt();
	}
	
	//check NMEA0183 checksum
	bool checksum() {
		char *p, *end, t[10];
		uint8_t sum = 0, given;
		p = buf;
		while(*p != '*' && p-buf<64) p++;
		if(p-buf == 64) return FALSE;
		p++;
		strncpy(t, p, 2);
		*(t+2) = '\0';
		given = (uint8_t) strtoul(t, &end, 16);
		
		p = buf+1;
		
		while(*p != '*' && p-buf<64) {
			sum ^= *p;
			p++;
		}
		
		return (given == sum);
	}
	
	//Interpret the GLL message.
	//
	// GLL example:		
	//01234567890123456789012345678901234567890123456789
	//$GPGLL,5133.36883,N,00956.90352,E,154551.00,A,A*6D
	task void parse_and_send() {
		char t[10];
		char *p, *end;
		
		//if checksum is invalid, abort and send failure event
		if(!checksum()) {
			parser_end(FALSE);
			return;
		}
		//if valid-data flag is missing, abort and send failure event
		if(buf[44] != 'A') {
			parser_end(FALSE);
			return;
		}
		
		//Latitude
		p = buf+7;
		strncpy(t, p, 2);
		*(t+2) = '\0';
		//Degrees
		msgbuf[curm].deg[0] = (int16_t) strtol(t, &end, 10);
		if(end==t) {
			parser_end(FALSE);
			return;
		}
		if(*(buf+18) == 'S') msgbuf[curm].deg[0] *= -1;
		
		p = buf+9;
		strncpy(t, p, 2);
		*(t+2) = '\0';
		//Minutes, integer part
		msgbuf[curm].minhi[0] = (uint8_t) strtoul(t, &end, 10);
		if(end==t) {
			parser_end(FALSE);
			return;
		}
		
		p = buf+12;
		strncpy(t, p, 5);
		*(t+5) = '\0';
		//Minutes, fractional part
		msgbuf[curm].minlo[0] = (uint32_t) strtoul(t, &end, 10);
		if(end==t) {
			parser_end(FALSE);
			return;
		}
		
		//Longitude
		p = buf+20;
		strncpy(t, p, 3);
		*(t+3) = '\0';
		//Degrees
		msgbuf[curm].deg[1] = (int16_t) strtol(t, &end, 10);
		if(end==t) {
			parser_end(FALSE);
			return;
		}
		if(*(buf+32) == 'W') msgbuf[curm].deg[1] *= -1;
		
		p = buf+23;
		strncpy(t, p, 2);
		*(t+2) = '\0';
		//Minutes, integer part
		msgbuf[curm].minhi[1] = (uint8_t) strtoul(t, &end, 10);
		if(end==t) {
			parser_end(FALSE);
			return;
		}
		
		p = buf+26;
		strncpy(t, p, 5);
		*(t+5) = '\0';
		//Minutes, fractional part
		msgbuf[curm].minlo[1] = (uint32_t) strtoul(t, &end, 10);
		if(end==t) {
			parser_end(FALSE);
			return;
		}
		
		//Time
		p = buf+34;
		strncpy(t, p, 2);
		*(t+2) = '\0';
		//hours
		msgbuf[curm].t_hr = (uint8_t) strtoul(t, &end, 10);
		if(end==t) {
			parser_end(FALSE);
			return;
		}
		
		p = buf+36;
		strncpy(t, p, 2);
		*(t+2) = '\0';
		//minutes
		msgbuf[curm].t_min = (uint8_t) strtoul(t, &end, 10);
		if(end==t) {
			parser_end(FALSE);
			return;
		}
		
		p = buf+38;
		strncpy(t, p, 2);
		*(t+2) = '\0';
		//seconds
		msgbuf[curm].t_sec = (uint8_t) strtoul(t, &end, 10);
		if(end==t) {
			parser_end(FALSE);
			return;
		}
		
		p = buf+41;
		strncpy(t, p, 2);
		*(t+2) = '\0';
		//milliseconds
		msgbuf[curm].t_msec = (uint8_t) strtoul(t, &end, 10);
		if(end==t) {
			parser_end(FALSE);
			return;
		}
		
		parser_end(TRUE);
	}
		
		
	//send events, when SplitControl is done, whichever way
	task void startFail() {
		signal SplitControl.startDone(FAIL);
	}

	task void stopFail() {
		signal SplitControl.stopDone(FAIL);
	}

	task void doneStarting() {
		signal SplitControl.startDone(SUCCESS);
	}

	task void doneStopping() {
		signal SplitControl.stopDone(SUCCESS);
	}
	
	/**
	 * Power up the GPS module. Sends an event, when done.
	 **/
	command error_t SplitControl.start() {
		atomic {
			if(stage == OFF) {
				stage = POWERING_UP;
				call AdgRes.request();
				return SUCCESS;
			}
		}
		return FAIL;
	}
	
	/**
	 * Power down the GPS module. Sends an event, when done.
	 **/
	command error_t SplitControl.stop() {
		stage = POWERING_DOWN;
		if(!os) call Uart1Ctrl.stop();
		call AdgRes.request();
	}
	
	/**
	 * Open communication channels and start listening to the GPS.
	 * Sends an event, when a GLL message has been received and interpreted.
	 * This will occupy UART1.
	 * 
	 * @param oneShot If TRUE, the driver will stop listening after having
	 * received one message and close the comm channels. Useful for sharing
	 * UART1.
	 **/
	command void GpsMsg.Listen(bool oneShot) {
		uint16_t ubrr = 0;
		atomic {
			os = oneShot;
			stage = PICKING_UP;
		}
		ubrr = call Atm128Calibrate.baudrateRegister(9600);
		call Uart1Ctrl.start();
		atomic {
			u1l = UBRR1L;
			u1h = UBRR1H;
			UBRR1L = ubrr;
			UBRR1H = ubrr>>8;
		}
		call Uart1.enableReceiveInterrupt();
		call AdgRes.request();
	}

	event void AdgRes.granted() {
		atomic {
			if(stage == POWERING_UP) {
				uint8_t mask = call PowerChannels.get();
				mask |= MICAWB_GPS_POWER | MICAWB_GPS_ENABLE;
				call PowerChannels.set(mask);
				return;
			}
		
			if(stage == POWERING_DOWN && !os) {
				uint8_t mask = call CommChannels.get();
				mask &= !MTS420_GPS_RX_SELECT & !MTS420_GPS_TX_SELECT;
				call CommChannels.set(mask);
				return;
			}
		
			if(stage == POWERING_DOWN) {
				uint8_t mask = call PowerChannels.get();
				mask &= !MICAWB_GPS_POWER & !MICAWB_GPS_ENABLE;
				call PowerChannels.set(mask);
				return;
			}
		
			if(stage == PICKING_UP) {
				uint8_t mask = call CommChannels.get();
				mask |= MTS420_GPS_RX_SELECT | MTS420_GPS_TX_SELECT;
				call CommChannels.set(mask);
				return;
			}
		
			if(stage == HANGING_UP) {
				uint8_t mask = call CommChannels.get();
				mask &= !MTS420_GPS_RX_SELECT & !MTS420_GPS_TX_SELECT;
				call CommChannels.set(mask);
				return;
			}
		}
	}
	
	event void PowerChannels.setDone(error_t error) {
		atomic {
			if(error == FAIL) {
				if(stage == POWERING_UP)
					post startFail();
				else
					post stopFail();
			} else {
				call AdgRes.release();
				if(stage == POWERING_UP)
					post doneStarting();
				else
					post doneStopping();
			}
		}
	}

	event void CommChannels.setDone(error_t error) {
			atomic {
				if(stage == POWERING_DOWN && !os) {
					uint8_t mask = call PowerChannels.get();
					mask &= !MICAWB_GPS_POWER & !MICAWB_GPS_ENABLE;
					call PowerChannels.set(mask);
					return;
				}
			}
			call AdgRes.release();
			atomic { if(stage == HANGING_UP) post parse_and_send(); }
	}
	
	
	//Matching a GLL message and buffering it for subsequent interpretation
	char* ptr = buf;
	uint8_t state = 0;
	async event void Uart1.receivedByte(uint8_t byte) {
		if (state == 0 && byte == '$') {
			*(ptr++) = (char) byte;
			state++;
			return;
		} else if(state == 1 && byte == 'G') {
			*(ptr++) = (char) byte;
			state++;
			return;
		} else if(state == 2 && byte == 'P') {
			*(ptr++) = (char) byte;
			state++;
			return;
		} else if(state == 3 && byte == 'G') {
			*(ptr++) = (char) byte;
			state++;
			return;
		} else if(state == 4 && byte == 'L') {
			*(ptr++) = (char) byte;
			state++;
			return;
		} else if(state == 5 && byte == 'L') {
			*(ptr++) = (char) byte;
			state++;
			return;
		} else if(state > 5 && state <= 49) {
			*(ptr++) = (char) byte;
			state++;
			return;
		} else if(state > 49) {
			call Uart1.disableReceiveInterrupt();
			*ptr = '\0';
			if(os) {
				UBRR1L = u1l;
				UBRR1H = u1h;
				call Uart1Ctrl.stop();
				stage = HANGING_UP;
				call AdgRes.request();
			} else {
				post parse_and_send();
			}
			state = 0;
			ptr = buf;
			return;
		} else {
			state = 0;
			ptr = buf;
			return;
		}
	}

	
	async event void Uart1.receiveDone(uint8_t *ubuf, uint16_t l, error_t error) {}
	async event void Uart1.sendDone(uint8_t *ubuf, uint16_t l, error_t error) {}
	
	/**
	 * This event is sent, when the GPS module has been powered down.
	 * 
	 * @param error Indicates if communication with the ADG switch has succeeded or not.
	 **/
	default event void SplitControl.startDone(error_t error) {}
	/**
	 * This event is sent, when the GPS module has been powered down.
	 * 
	 * @param error Indicates if communication with the ADG switch has succeeded or not.
	 **/
	default event void SplitControl.stopDone(error_t error) {}
	
	
	/**
	 * This event is sent, when a GLL message has been received and interpreted.
	 * 
	 * @param msg Will contain position and time data on success, otherwise all
	 * fields will contain 99 (as this represents an impossible time and position)
	 * @param err Will read FAIL if interpretation has failed due to invalid checksum,
	 * invalid-data flag or conversion error(s)
	 **/
	default event void GpsMsg.newMessage(gps_msg_t *msg, error_t err) {}
}






