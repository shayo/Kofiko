//************************************************************************/
/*																		*/
/*	chipKITEthernetAPI.h	-- Ethernet interface APIs to implement the */
/*                  Arduino software compatible Ethernet Library        */
/*					using the chipKIT Max32 and chipKIT Network Shield	*/
/*																		*/
/************************************************************************/
/*	Author: 	Keith Vogel 											*/
/*	Copyright 2011, Digilent Inc.										*/
/************************************************************************/
/*
  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/
/************************************************************************/
/*  Module Description: 												*/
/*																		*/
/*	This library is explicity targeting the chipKIT Max32 				*/
/*	PIC32MX795F512L MCU using the internal MAC along with the 			*/
/*  chipKIT Network Shield using the physical SMSC8720 analog driver    */
/*																		*/
/*	This replicates the Arduino Ethernet Class to be used in conjuction */
/*	with chipKITEthernetAPI.c to implement a software compatible Arduino*/
/*	Ethernet sketch library. This class is designed specifcally to 	    */
/*	to offer software compatibility to the existing Arduino Ethernet	*/
/*	Class, and are not intended for general use.						*/
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/*																		*/
/*	8/08/2011(KeithV): Created											*/
/*	8/29/2011(KeithV): Added UDP support								*/
/*																		*/
/************************************************************************/

#ifndef _CHIPKITETHERNETAPI_H
#define _CHIPKITETHERNETAPI_H

#ifdef __cplusplus
    #define MYBYTE uint8_t
#else
    #define MYBYTE BYTE
#endif

#ifndef __GENERIC_TYPE_DEFS_H_
    typedef enum _BOOL { FALSE = 0, TRUE } BOOL;    /* Undefined size */
    typedef unsigned short int      WORD;                           /* 16-bit unsigned */
    typedef unsigned long           DWORD;                          /* 32-bit unsigned */
#endif

// so we don't have to include TCP.h
#ifndef __TCP_HITECH_WORKAROUND_H

    #ifndef UNKNOWN_SOCKET
 	    typedef MYBYTE TCP_SOCKET;
		typedef MYBYTE UDP_SOCKET;
	    #define INVALID_SOCKET      (0xFE)	// The socket is invalid or could not be opened
	    #define UNKNOWN_SOCKET      (0xFF)	// The socket is not known
   		#define INVALID_UDP_SOCKET  (0xFFu) // Invalide udp socket
		#define INVALID_UDP_PORT    (0ul)	// Indicates a UDP port that is not valid
    #endif

    #define TCP_OPEN_SERVER         0u
    #define TCP_OPEN_RAM_HOST	    1u
//	#define TCP_OPEN_ROM_HOST	    2u
    #define TCP_OPEN_IP_ADDRESS		3u
//	#define TCP_OPEN_NODE_INFO	    4u

	// Structure to contain a MAC address
	typedef struct __attribute__((__packed__))
	{
	    MYBYTE v[6];
	} MAC_ADDR;
	
	// Definition to represent an IP address
    typedef struct __attribute__((__packed__))
	{
	    MYBYTE v[4];
	} IP_ADDR;

	#define UDP_PORT    unsigned short
	
	// Address structure for a node
	typedef struct __attribute__((__packed__))
	{
	    IP_ADDR     IPAddr;
	    MAC_ADDR    MACAddr;
	} NODE_INFO;
#endif

#define ChipKITValidTCPHandle(a) (a != UNKNOWN_SOCKET && a != INVALID_SOCKET)
#define ChipKITClientConnectDNS(a, b, c) ChipKITClientConnect((unsigned int) a, TCP_OPEN_RAM_HOST, (unsigned short) b, c)
#define ChipKITClientConnectIP(a, b, c) ChipKITClientConnect(*((unsigned int *) a), TCP_OPEN_IP_ADDRESS, (unsigned short) b, c)
#define ChipKITServerListenPORT(p) ChipKITClientConnect(0u, TCP_OPEN_SERVER, (unsigned short) p, 1)

#ifdef __cplusplus
extern "C" {
#endif

	void ChipKITEthernetBegin(const MYBYTE *rgbMac, const MYBYTE *rgbIP, const MYBYTE *rgbGateWay, const MYBYTE *rgbSubNet, const MYBYTE *rgbDNS1, const MYBYTE *rgbDNS2);
	void ChipKITPeriodicTasks(void);
    DWORD SNTPGetUTCSeconds();


	TCP_SOCKET ChipKITClientConnect(unsigned int dwOpenVal, MYBYTE vRemoteHostType, unsigned short wPort, unsigned int cSecTimout);
	unsigned int ChipKITClientAvailable(TCP_SOCKET hTCP);

	int ChipKITClientGetByte(TCP_SOCKET hTCP);
	unsigned int ChipKITClientGetBuff(TCP_SOCKET hTCP, MYBYTE * rgBuff, unsigned short cbRead);

	BOOL ChipKITClientPutByte(TCP_SOCKET hTCP, MYBYTE b);
	unsigned int ChipKITClientPutSz(TCP_SOCKET hTCP, const char * sz, unsigned int cSecTimout);
	unsigned int ChipKITClientPutBuff(TCP_SOCKET hTCP, const MYBYTE * rgBuff, unsigned short cbWrite, unsigned int cSecTimeout);

	void ChipKITClientStop(TCP_SOCKET hTCP);
	BOOL ChipKITClientConnected(TCP_SOCKET hTCP);
	void ChipKITClientFlush(TCP_SOCKET hTCP);

	int ChipKITClientPeek(TCP_SOCKET hTCP);


	UDP_SOCKET ChipKITUDPBegin(UDP_PORT localPort);
	WORD ChipKITUDPSendPacketIP(UDP_SOCKET hUDP, MYBYTE * rgbBuf, WORD cbBuff, MYBYTE * rgbIP, WORD port, unsigned int cSecTimeout);
	WORD ChipKITUDPSendPacketURL(UDP_SOCKET hUDP, MYBYTE * rgbBuf, WORD cbBuff, const char * szURL, WORD port, unsigned int cSecTimeout);
	int ChipKITUDPAvailable(UDP_SOCKET hUDP);
	int ChipKITUDPReadPacket(UDP_SOCKET hUDP, MYBYTE * rgbBuff, WORD cbBuff, NODE_INFO * pnodeInfo, WORD * pwPort);
    void ChipKITUDPClose(UDP_SOCKET hUDP);

#ifdef __cplusplus
}
#endif


#endif // _CHIPKITETHERNETAPI_H
