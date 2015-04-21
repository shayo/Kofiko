/************************************************************************/
/*																		*/
/*	chipKITClient.cpp	-- Client interface APIs to implement the */
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
/*																		*/
/************************************************************************/

#include "chipKITEthernet.h"
#include "chipKITEthernetAPI.h"

/***	Client Constructors
**
**	Synopsis:   This will construct a Client Class to represent an invalid socket
**
**	Parameters:
**      None
**
**	Description:
**      
*/
Client::Client()
{
    PrivateInit();
}

/***	Client Constructors
**
**	Synopsis:   This will construct a Client Class to represent a TCPIP connection on a specific socket.
**              This is a private constructor.
**
**	Parameters:
**      hTCP    - socket to use.
**
**	Description:
**      
*/
Client::Client(TCP_SOCKET hTCP)
{
    PrivateInit();
    _hTCP = hTCP;
}

/***	Client Constructors
**
**	Synopsis:   This will constuct a Client Class pointed to by a URL and port number.
**              This is a Digilent extension as the URL will use DNS to discover the target IP address
**
**	Parameters:
**      szip    - pointer to a URL or string form of an IP address.
**      port    - the port to connect to.
**
**	Description:
**      See http://arduino.cc/en/Reference/ClientConstructor
*/
Client::Client(const char *szip, uint16_t port)
{
    PrivateInit();
    _szURL = (char *) malloc(strlen(szip) + 1);
    strcpy(_szURL, szip);
    _port = port;
}

/***	Client Constructors
**
**	Synopsis:   This will constuct a Client Class pointed to 4 byte IP address and port number
**
**	Parameters:
**      ip      - pointer to a 4 byte target IP address
**      port    - the port to connect to.
**
**	Description:
**      See http://arduino.cc/en/Reference/ClientConstructor
*/
Client::Client(uint8_t *ip, uint16_t port) 
{
    PrivateInit();
    _ip = *((unsigned int *) ip);
    _port = port;
}

/***	void PrivateInit(void)
**
**	Synopsis:   This is a private method used to initialize the Client Class data values
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
void Client::PrivateInit(void)
{
    _hTCP = INVALID_SOCKET;
    _szURL = NULL;
    _ip = 0;
    _port = 0;
    _cSecTimeout = ETHERNET_DEFAULT_TIMEOUT;  // default value
}

/***	void PrivateReset(void)
**
**	Synopsis:   This is a private method used to safely clean up 
**              an exiting client so that a copy can be done to it.
**              in particular, freeing the string
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
void Client::PrivateReset(void)
{
    if(_szURL != NULL)
    {
        free(_szURL);
        _szURL = NULL;
    }

    PrivateInit();
}

/***	Client Destructor
**
**	Synopsis:   This clean up all allocated data when the Client Class is destructed
**
*/
Client::~Client()
{
    PrivateReset();
}

// the next three functions are a hack so we can compare the client returned
// by Server::available() to null, or use it as the condition in an
// if-statement.  this lets us stay compatible with the Processing network
// library.

/***	uint8_t operator==(int p)
**
**	Synopsis:   Client == operator to an int. 
**              The Client will compare to NULL if the Client has an invalid socket
**
**	Parameters:
**      p   - Typically NULL
**  
**	Return Values:
**      true if the Client has an invalid handle compared to NULL
**      false if the Client has a valid handle compared to NULL
**
**	Errors:
**
**	Description:
**      
*/
uint8_t Client::operator==(int p) 
{
    if( p == 0)
    {
        return(!ChipKITValidTCPHandle(_hTCP));
    }
    else
    {
        return(ChipKITValidTCPHandle(_hTCP));
    }
}

/***	uint8_t operator!=(int p)
**
**	Synopsis:   Client != operator to an int. 
**              The opposite to the == operator.
**	Parameters:
**      p   - Typically NULL
**  
**	Return Values:
**      The opposite of the == operator
**
**	Errors:
**
**	Description:
**      
*/
uint8_t Client::operator!=(int p) 
{
    return( !(*this == 0) );
}

/***	uint8_t operator bool
**
**	Synopsis:   Check to see if the socket is valid 
**              
**	Parameters:
**      None
**  
**	Return Values:
**      true if a valid socket, false otherwise
**
**	Errors:
**
**	Description:
**      
*/
Client::operator bool() 
{
  return(ChipKITValidTCPHandle(_hTCP));
}

// the next 2 functions allow for a client to be copied and stand on its own
// and then having multiple copies being destructed without freeing the same szip memory

/***	Copy Constructor
**
**	Synopsis:   Uses the assignment operator to copy to another instance of the client
**              
**	Parameters:
**      otherClient - the existing instance of the client
**  
**	Return Values:
**      None
**
**	Errors:
**
**	Description:
**      
*/
Client::Client(const Client& otherClient)
{
    PrivateInit();          // must be called as the this does not call the default constructor to init.
    *this = otherClient;    // use the assigment operator to do the copy.
}

/***	assignement operator (=)
**
**	Synopsis:   copies one client instance to another
**              allocating a new copy of the szURL so it can be freed
**              without distroying the original copy of szURL
**              
**	Parameters:
**      otherClient - the existing instance of the client
**  
**	Return Values:
**      the copied version of the client.
**
**	Errors:
**
**	Description:
**      
*/
Client& Client::operator=(const Client& otherClient)
{
    PrivateReset();
     _hTCP = otherClient._hTCP;
    _ip = otherClient._ip;
    _port = otherClient._port;
    _cSecTimeout = otherClient._cSecTimeout;
 
    if(otherClient._szURL != NULL)
    {
        _szURL = (char *) malloc(strlen(otherClient._szURL) + 1);
        strcpy(_szURL, otherClient._szURL);
    }

    return(*this);
}

// the next 2 functions will allow us to compare to copies of a client 
// to see if the represent the same client.
// These are Digilent extensions.

/***	uint8_t operator==(const Client& otherClient) 
**
**	Synopsis:   Client == another Client instance. 
**              If the sockets are the same, the client is the same.
**
**	 
**	Return Values:
**      true if the Client sockets are the same; false otherwise**
**      
*/
uint8_t Client::operator==(const Client& otherClient) 
{
    return(this->_hTCP == otherClient._hTCP);
}

/***	uint8_t operator!=(const Client& otherClient) 
**
**	Synopsis:   Client != another Client instance. 
**              If the sockets are not the same, the client is not the same.
**
**	 
**	Return Values:
**      true if the Client sockets are not the same; false otherwise**
**      
*/
uint8_t Client::operator!=(const Client& otherClient) 
{
    return(this->_hTCP != otherClient._hTCP);
}

/***	uint8_t status() 
**
**	Synopsis:   Get the current connection status
**              
**	Parameters:
**      None
**  
**	Return Values:
**      0x17 if conneced, 0x00 otherwise
**
**	Errors:
**
**	Description:
**      This does not really mean anything to the MAL, so just return
**      If it is connected or not using the WizNet Status codes
**      This is meaningless for the MAL
*/
uint8_t Client::status() 
{
    if(connected())
    {
        return(0x17);   // in Arduino w5100 terms, this is established
    }
    else
    {
        return(0x00);   // in Arduino w5100 terms, this is closed
    }
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
void Client::SetSecTimeout(unsigned int cSecTimeout)
{
    _cSecTimeout = cSecTimeout;
}

/***	uint8_t connect()
**
**
**	Description:
**
**      This will attempt to connect to the IP/URL and port as specified in the Client constructor
**      It will return after the connection is made, or until the timeout value is reached.
**
**      Same as defined by http://arduino.cc/en/Reference/ClientConnect 
*/
uint8_t Client::connect() 
{
    // we have already connected, don't do it again
    if(!ChipKITValidTCPHandle(_hTCP))
    {
        if(_szURL != NULL)
        {
            _hTCP = ChipKITClientConnectDNS(_szURL, _port, _cSecTimeout);
        }
        else
        {
            _hTCP = ChipKITClientConnectIP(_ip, _port, _cSecTimeout);
        }
    }

  return(ChipKITValidTCPHandle(_hTCP));
}

/***	void stop() 
**
**	Description:
**      This routine closes the socket, purges the socket input buffer and returns
**      all resources (the socket) back to the TCPIP stack
**      Same as defined by http://arduino.cc/en/Reference/ClientStop
**      
*/
void Client::stop() 
{
    if(ChipKITValidTCPHandle(_hTCP))
    {
        ChipKITClientStop(_hTCP);
        _hTCP = INVALID_SOCKET;
    }

    // do not reset the client
    // as the URL and _cSecTimeout can be
    // reused if another connect is done later
    // stop/connect  stop/connect, same URL, same client
    // just a new socket.

    // if the client gets destructed, the URL will be freed.
}

/***	void write(uint8_t b)
**
**
**	Description:
**      Same as defined by http://arduino.cc/en/Reference/ClientWrite
**      And http://arduino.cc/en/Reference/ServerPrint
**      And http://arduino.cc/en/Reference/ServerPrintln
*/
void Client::write(uint8_t b) 
{
    ChipKITClientPutByte(_hTCP, b);
}

/***	void write(const char *str)
**
**	Synopsis:   This routine writes a string to the socket
**              This routine will return if more than the timeout times has elapsed
**              However, if progress is observed by some bytes being written
**              the timeout time will reset as progress is being made.
**              only if no progress is made for the timeout period will the write be aborted
**
**	Parameters:
**      str - zero terminated string to write
**  
**	Return Values:
**      None - it is unfortunate that this was defined without returning the actual number of characters written
**             there is no way to know if this succeeded.
**
**	Errors:
**
**	Description:
**      Implements write as defined by http://arduino.cc/en/Reference/ClientWrite
**      And http://arduino.cc/en/Reference/ServerPrint
**      And http://arduino.cc/en/Reference/ServerPrintln
**      
*/
void Client::write(const char *str) 
{
    ChipKITClientPutSz(_hTCP, str, _cSecTimeout);
}

/***	void write(const uint8_t *buf, size_t size)
**
**	Synopsis:   This routine writes a buffer to the client socket
**              This routine will return if more than the timeout times has elapsed
**              However, if progress is observed by some bytes being written
**              the timeout time will reset as progress is being made.
**              only if no progress is made for the timeout period will the write be aborted
**
**	Parameters:
**      buf - pointer to a buffer of bytes to write
**      size - number of bytes to write
**  
**	Return Values:
**      None - it is unfortunate that this was defined without returning the actual number of bytes written
**             there is no way to know if this succeeded.
**
**	Errors:
**
**	Description:
**      Implements write as defined by http://arduino.cc/en/Reference/ClientWrite
**      And http://arduino.cc/en/Reference/ServerPrint
**      And http://arduino.cc/en/Reference/ServerPrintln
**      
*/
void Client::write(const uint8_t *buf, size_t size)
{
    ChipKITClientPutBuff(_hTCP, buf, size, _cSecTimeout);
}

/***	int Client::available()
**
**
**	Description:
**      Same as defined by http://arduino.cc/en/Reference/ClientAvailable
*/
int Client::available() 
{
    if(ChipKITValidTCPHandle(_hTCP))
    {
        return(ChipKITClientAvailable(_hTCP));
    }
    else
    {
        return(0);
    }
}

/***	int read()
**
**	Return Values:
**      This routine returns immediately with the byte read, or -1 if no bytes are available.
**
**	Description:
**      Same as defined by http://arduino.cc/en/Reference/ClientRead
**      
*/
int Client::read() 
{
    return(ChipKITClientGetByte(_hTCP));
}

/***	int read(uint8_t *buf, size_t size)
**
**	Synopsis:   This routine read a buffer from a client socket
**
**	Parameters:
**      buf - pointer to a buffer to receive the bytes
**      size - maximum size of the buffer.
**  
**	Return Values:
**      This routine returns immediately with the number of bytes actually read, if no bytes are available, 0 is returned.
**
**	Errors:
**
**	Description:
**      See http://arduino.cc/en/Reference/ClientRead for more info
**      
*/
int Client::read(uint8_t *buf, size_t size) 
{
  return(ChipKITClientGetBuff(_hTCP, buf, size));
}

/***	int peek() 
**
**	Synopsis:   This routine returns the next byte to read in the client socket without removeing 
**              the byte from the socket buffer.
**
**	Parameters:
**      None
**  
**	Return Values:
**      This routine returns immediately with the the next byte to read, or -1 if no bytes are available.
**
**	Errors:
**
**	Description:
**      This is an undocumented but existing Arduino Ethernet method
**      
*/
int Client::peek() 
{
  return(ChipKITClientPeek(_hTCP));
}

/***	void flush()
**
**
**	Description:
**      Same as defined by http://arduino.cc/en/Reference/ClientFlush
**
**      Careful with the definition of "flush". In Arduino this
**      means to purge the input socket buffer, in the Microchip
**      MAL flush means to force an immediate transmit of any 
**      bytes in the socket buffer that has not been transmitted.
**      
**      This method just purges the socket input buffer of all bytes, it is the same
**      as the MAL's TCPDiscard() function.
**      
*/
void Client::flush() 
{
    ChipKITClientFlush(_hTCP);
}

/***	uint8_t connected() 
**
**	Description:
**      Same as defined by http://arduino.cc/en/Reference/ClientConnected
**      
*/
uint8_t Client::connected() 
{
   return(ChipKITClientConnected(_hTCP));
}
