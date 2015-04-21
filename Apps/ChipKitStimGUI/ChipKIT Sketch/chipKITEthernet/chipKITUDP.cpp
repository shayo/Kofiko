/************************************************************************/
/*																		*/
/*	chipKITUDP.cpp	-- Client interface APIs to implement the           */
/*                  Arduino software compatible UDP Ethernet Library    */
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
/*	8/25/2011(KeithV): Created											*/
/*																		*/
/************************************************************************/

#include "chipKITEthernet.h"
#include "chipKITEthernetAPI.h"


/***	UDP Constructor
**
**	Synopsis:   Constructs and initializes the UDP class
**
**	Parameters:
**      None
**  
**	Return Values:
**      None
**
**	Errors:
**
**	Description:
**      
*/
UDP::UDP()
{
    _hUDP = INVALID_UDP_SOCKET;
    _cSecTimeout = ETHERNET_DEFAULT_TIMEOUT;
    _localPort = 0;
}

/***	uint8_t begin(uint16_t localPort)
**
**	Synopsis:   Opens and allocates a socket and starts listening on the port
**
**	Parameters:
**      None
**  
**	Return Values:
**      true if the socket was opened, false otherwise
**
**	Errors:
**
**	Description:
**      
*/
uint8_t UDP::begin(uint16_t localPort)
{
    _localPort = localPort;

    _hUDP = ChipKITUDPBegin(localPort);

    return(_hUDP != INVALID_UDP_SOCKET);
}

/***	int UDP::available()
**
**	Synopsis:   Returns the number of bytes ready to read on the socket
**
**	Parameters:
**      None
**  
**	Return Values:
**      Returns the number of bytes ready to read on the socket, 0 if none available
**
**	Errors:
**
**	Description:
**      
*/
int UDP::available()					
{
    int cbAvailable = ChipKITUDPAvailable(_hUDP);

    // this is compatibility with Arduino
    // it is stupid, pretend there is a header there; even though you can't get to it
    // with a read.
    if(cbAvailable > 0)
    {
        cbAvailable += 8;   
    }
     return(cbAvailable);
}

/***	uint16_t sendPacket(uint8_t * rgbBuf, uint16_t cbBuf, uint8_t * rgbIP, uint16_t port)
**
**	Synopsis:   This routine writes a datagram to the recipient
**              This routine will return if more than the timeout times has elapsed
**              However, if progress is observed by some bytes being written
**              the timeout time will reset as progress is being made.
**              only if no progress is made for the timeout period will the write be aborted
**
**	Parameters:
**      rgbBuf  - pointer to a buffer of bytes to send
**      cbBuf   - number of bytes to send
**      rgbIP   - 4 byte array representing the IP address to send the packet to
**      port    - the port to send it to
**  
**	Return Values:
**      The number of bytes that were sent, 0 if none or an error
**      This is open ended, the bytes may go out, but maybe no-one is there to pick them up. 
**
**	Errors:
**
**	Description:
**      
*/
uint16_t UDP::sendPacket(uint8_t * rgbBuf, uint16_t cbBuf, uint8_t * rgbIP, uint16_t port)
{
    return(ChipKITUDPSendPacketIP(_hUDP, rgbBuf, cbBuf, rgbIP, port, _cSecTimeout));
}

/***	uint16_t sendPacket(uint8_t * rgbBuf, uint16_t cbBuff, const char szURL[], uint16_t port)
**
**	Synopsis:   This routine writes a datagram to the recipient
**              This routine will return if more than the timeout times has elapsed
**              However, if progress is observed by some bytes being written
**              the timeout time will reset as progress is being made.
**              only if no progress is made for the timeout period will the write be aborted
**
**	Parameters:
**      rgbBuf  - pointer to a buffer of bytes to send
**      cbBuf   - number of bytes to send
**      szURL   - a zero terminated string representing the IP address or a hostname. DNS is used to resolve the hostname
**      port    - the port to send it to
**  
**	Return Values:
**      The number of bytes that were sent, 0 if none or an error
**      This is open ended, the bytes may go out, but maybe no-one is there to pick them up. 
**
**	Errors:
**
**	Description:
**      
*/
uint16_t UDP::sendPacket(uint8_t * rgbBuf, uint16_t cbBuff, const char szURL[], uint16_t port)
{
    return(ChipKITUDPSendPacketURL(_hUDP, rgbBuf, cbBuff, (const char *) szURL, port, _cSecTimeout));
}

/***	uint16_t sendPacket(const char sz[], uint8_t * rgbIP, uint16_t port)
**
**	Synopsis:   This routine writes a datagram to the recipient
**              This routine will return if more than the timeout times has elapsed
**              However, if progress is observed by some bytes being written
**              the timeout time will reset as progress is being made.
**              only if no progress is made for the timeout period will the write be aborted
**
**	Parameters:
**      sz      - zero terminated string to send
**      rgbIP   - 4 byte array representing the IP address to send the packet to
**      port    - the port to send it to
**  
**	Return Values:
**      The number of bytes that were sent, 0 if none or an error
**      This is open ended, the bytes may go out, but maybe no-one is there to pick them up. 
**
**	Errors:
**
**	Description:
**      
*/
uint16_t UDP::sendPacket(const char sz[], uint8_t * rgbIP, uint16_t port)
{
        if(sz == NULL)
        {
            return(0);
        }
        else
        {
            return(ChipKITUDPSendPacketIP(_hUDP, (uint8_t *) sz, strlen(sz), rgbIP, port, _cSecTimeout));
        }
}

/***	uint16_t sendPacket(const char sz[], const char szURL[], uint16_t port)
**	Synopsis:   This routine writes a datagram to the recipient
**              This routine will return if more than the timeout times has elapsed
**              However, if progress is observed by some bytes being written
**              the timeout time will reset as progress is being made.
**              only if no progress is made for the timeout period will the write be aborted
**
**	Parameters:
**      sz      - zero terminated string to send
**      szURL   - a zero terminated string representing the IP address or a hostname. DNS is used to resolve the hostname
**      port    - the port to send it to
**  
**	Return Values:
**      The number of bytes that were sent, 0 if none or an error
**      This is open ended, the bytes may go out, but maybe no-one is there to pick them up. 
**
**	Errors:
**
**	Description:
**      
*/
uint16_t UDP::sendPacket(const char sz[], const char szURL[], uint16_t port)
{
        if(sz == NULL)
        {
            return(0);
        }
        else
        {
            return(ChipKITUDPSendPacketURL(_hUDP, (uint8_t *) sz, strlen(sz), (const char *) szURL, port, _cSecTimeout));
        }
}

/***	int readPacket(uint8_t * rgbBuff, uint16_t cbBuff)
**
**	Synopsis:   This routine reads the available data out of the UDP socket
**
**	Parameters:
**      rgbBuf  - pointer to a buffer to receive the data
**      cbBuf   - the maximum size of the buffer
**  
**	Return Values:
**          The number of bytes actually read. If the buffer was too small to hold all of the 
**          avaiable bytes, the negative of the total number of available bytes are returned.
**          The number of bytes actually read is cbBuff. The number of byte remain is the total
**          number available (the negative of the returned value) less cbBuff. If there was nothing to 
**          read, 0 is returned. Note that the 8 byte header is not returned as data, unlike that value
**          returned by available which will include the 8 bytes of header in its count.
**
**	Errors:
**
**	Description:
**      
*/
int UDP::readPacket(uint8_t * rgbBuff, uint16_t cbBuff)
{
    return(ChipKITUDPReadPacket(_hUDP, rgbBuff, cbBuff, NULL, NULL));
}

/***	int readPacket(uint8_t *rgbBuff, uint16_t cbBuff, uint8_t * rgbIP, uint16_t * pwPort)
**
**	Synopsis:   This routine reads the available data out of the UDP socket
**
**	Parameters:
**      rgbBuf  - pointer to a buffer to receive the data
**      cbBuf   - the maximum size of the buffer
**      rgbIP   - a pointer to a 4 byte array to receive the remote endpoint IP address of who sent the datagram
**      pwPort  - a pointer to a WORD value to receive the remote endpoint port of who sent the datagram
**  
**	Return Values:
**          The number of bytes actually read. If the buffer was too small to hold all of the 
**          avaiable bytes, the negative of the total number of available bytes are returned.
**          The number of bytes actually read is cbBuff. The number of byte remain is the total
**          number available (the negative of the returned value) less cbBuff. If there was nothing to 
**          read, 0 is returned. Note that the 8 byte header is not returned as data, unlike that value
**          returned by available which will include the 8 bytes of header in its count.
**
**	Errors:
**
**	Description:
**      
*/
int UDP::readPacket(uint8_t *rgbBuff, uint16_t cbBuff, uint8_t * rgbIP, uint16_t * pwPort)
{
    NODE_INFO nodeInfo;
 
    int cbRead = ChipKITUDPReadPacket(_hUDP, rgbBuff, cbBuff, &nodeInfo, pwPort);

    if(rgbIP != NULL)
    {
        rgbIP[0] = nodeInfo.IPAddr.v[0];
        rgbIP[1] = nodeInfo.IPAddr.v[1];
        rgbIP[2] = nodeInfo.IPAddr.v[2];
        rgbIP[3] = nodeInfo.IPAddr.v[3];
    }

    return(cbRead);
}

/***	int readPacket(char * sz, uint16_t cbsz, uint8_t * rgbIP, uint16_t &wPort)
**
**	Synopsis:   This routine reads the available data out of the UDP socket
**
**	Parameters:
**      sz  - pointer to a buffer to receive a zero terminated string
**      cbsz   - the maximum size of the string buffer including the null terminator
**      rgbIP   - a pointer to a 4 byte array to receive the remote endpoint IP address of who sent the datagram
**      pwPort  - a pointer to a WORD value to receive the remote endpoint port of who sent the datagram
**  
**	Return Values:
**          The number of bytes actually read. If the buffer was too small to hold all of the 
**          avaiable bytes, the negative of the total number of available bytes are returned.
**          The number of bytes actually read is cbBuff. The number of byte remain is the total
**          number available (the negative of the returned value) less cbBuff. If there was nothing to 
**          read, 0 is returned. Note that the 8 byte header is not returned as data, unlike that value
**          returned by available which will include the 8 bytes of header in its count.
**
**	Errors:
**
**	Description:
**      
*/
int UDP::readPacket(char * sz, uint16_t cbsz, uint8_t * rgbIP, uint16_t &wPort)
{
    // call if the buffer is zero, this will get what is ready
    int cchRet = 0;

    // if we are not specifying a buffer, then just get how much to read.
    if(cbsz == 0)
    {
        return(readPacket((uint8_t *) sz, 0, rgbIP, &wPort));
    }

    // we have some space
    else 
    {
        sz[(cbsz - 1)] = 0; // just in case a full buffer is returned and cchRet is negative.

        // read in the data
        cchRet = readPacket((uint8_t *) sz, cbsz-1, rgbIP, &wPort);

        // put the null in at the end of the buffer
        if(cchRet >= 0)
        {
            sz[cchRet] = 0;
        }
    }

    return(cchRet);
}

/***	void stop()
**
**	Synopsis:   This routine closes the UDP socket and releases all resources back to the UDP stack
**
**	Parameters:
**      None
**  
**	Return Values:
**      None
**
**	Errors:
**
**	Description:
**      
*/
void UDP::stop()
{
    ChipKITUDPClose(_hUDP);
    _hUDP = INVALID_UDP_SOCKET;
    _localPort = 0;
}

/***	void SetSecTimeout(unsigned int cSecTimeout)
**
**	Synopsis:   This routine allows you to set the timeout value for
**              the connect, and write methods. By default this is 
**              set to 30 seconds.
**              This is a Digilent extension.
**
**	Parameters:
**      cSecTimeout - The maximum number of seconds to wait for the API to complete
**  
**	Return Values:
**      None
**
**	Errors:
**
**	Description:
**      
*/
void UDP::SetSecTimeout(unsigned int cSecTimeout)
{
    _cSecTimeout = cSecTimeout;
}


