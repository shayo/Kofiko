/************************************************************************/
/*																		*/
/*	chipKITEthernet.h	-- Ethernet interface APIs to implement the */
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
#ifndef _CHIPKITETHERNETCLASS_H
#define _CHIPKITETHERNETCLASS_H

#include "WProgram.h"	
#include "Print.h"

#ifndef UNKNOWN_SOCKET
 	typedef uint8_t TCP_SOCKET;
    typedef uint8_t UDP_SOCKET;
	#define INVALID_SOCKET      (0xFEu)	// The socket is invalid or could not be opened
	#define UNKNOWN_SOCKET      (0xFFu)	// The socket is not known
    #define INVALID_UDP_SOCKET  (0xFFu) // Invalide udp socket
#endif

#define ETHERNET_DEFAULT_TIMEOUT   30   // in seconds

class ChipKITEthernetClass {
private:
public:
  void begin();
  void begin(uint8_t *);
  void begin(uint8_t *, uint8_t *);
  void begin(uint8_t *, uint8_t *, uint8_t *);
  void begin(uint8_t *, uint8_t *, uint8_t *, uint8_t *);
  void begin(uint8_t *, uint8_t *, uint8_t *, uint8_t *, uint8_t *);
  void begin(uint8_t *, uint8_t *, uint8_t *, uint8_t *, uint8_t *, uint8_t *);
  void PeriodicTasks();
  unsigned int SecondsSinceEpoch(void);

  friend class Client;
  friend class Server;
};

class Client : public Print {

private:
    TCP_SOCKET _hTCP;
    unsigned int _ip;
    char *_szURL;
    unsigned short _port;
    unsigned int _cSecTimeout;

    Client(TCP_SOCKET hTCP);
    void PrivateInit(void);
    void PrivateReset(void);

public:
    Client();
    Client(uint8_t *ip, uint16_t port);
    Client(const char *szURL, uint16_t port);
    ~Client();

    Client( const Client& );
    Client& operator=( const Client& );

    uint8_t operator==(int);
    uint8_t operator!=(int);
    operator bool();

    uint8_t operator==(const Client& otherClient);
    uint8_t operator!=(const Client& otherClient);

    uint8_t status();
    uint8_t connect();
    virtual void write(uint8_t);
    virtual void write(const char *str);
    virtual void write(const uint8_t *buf, size_t size);
    virtual int available();
    virtual int read();
    virtual int read(uint8_t *buf, size_t size);
    virtual int peek();
    virtual void flush();
    void stop();
    uint8_t connected();
    void SetSecTimeout(unsigned int cSecTimeout);

    friend class Server;
};

typedef struct _SKL
{
    TCP_SOCKET hTCP;
    struct _SKL * psklBack;
    struct _SKL * psklNext;
} SKL;

class Server : public Print {

private:
    uint16_t _port;
    SKL sklListening;
    unsigned int _cSecTimeout;
 
    void ServiceSocketListen(void);

public:
  Server(uint16_t);
  ~Server();
  Client available();
  void begin();
  void SetSecTimeout(unsigned int cSecTimeout);

  virtual void write(uint8_t);
  virtual void write(const char *str);
  virtual void write(const uint8_t *buf, size_t size);

  friend class Client;
};

class UDP {
private:
  UDP_SOCKET _hUDP;  
  unsigned int _cSecTimeout;
  uint16_t _localPort;
 
public:
  UDP();
  uint8_t begin(uint16_t);	// initialize, start listening on specified port. Returns 1 if successful, 0 if there are no sockets available to use
  int available();								// has data been received?

  // C-style buffer-oriented functions
  uint16_t sendPacket(uint8_t * rgbBuff, uint16_t cbBuff, uint8_t * rgbIP, uint16_t port); //send a packet to specified peer 
  uint16_t sendPacket(uint8_t * rgbBuff, uint16_t cbBuff, const char szURL[], uint16_t port);
  uint16_t sendPacket(const char sz[], uint8_t * rgbIP, uint16_t port);  //send a string as a packet to specified peer
  uint16_t sendPacket(const char sz[], const char szURL[], uint16_t port);
  int readPacket(uint8_t *, uint16_t);		// read a received packet 
  int readPacket(uint8_t *, uint16_t, uint8_t *, uint16_t *);		// read a received packet, also return sender's ip and port 	
  // readPacket that fills a character string buffer
  int readPacket(char *, uint16_t, uint8_t *, uint16_t &);

  // Finish with the UDP socket
  void stop();

  void SetSecTimeout(unsigned int cSecTimeout);
};

extern ChipKITEthernetClass Ethernet;

#endif  // _CHIPKITETHERNETCLASS_H
