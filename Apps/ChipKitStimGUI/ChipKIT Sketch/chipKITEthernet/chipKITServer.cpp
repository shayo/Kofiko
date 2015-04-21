/************************************************************************/
/*																		*/
/*	chipKITServer.cpp	-- Server interface APIs to implement the */
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

/***	Server Constructor 
**
**	Description:
**      Same as defined by http://arduino.cc/en/Reference/ServerConstructor
**      
*/
Server::Server(uint16_t port)
{
  _port = port;
  sklListening.hTCP = UNKNOWN_SOCKET;
  sklListening.psklNext = NULL;
  sklListening.psklBack = NULL;
  _cSecTimeout = ETHERNET_DEFAULT_TIMEOUT;
}

/***	Server Destructor
**
**	Synopsis:   This clean up all allocated data and releases all clients
**              attached to the server.
**
*/
Server::~Server()
{
    SKL *   psklNow = sklListening.psklNext;

    while(psklNow != NULL) 
    {

        SKL *   psklDelete = psklNow;
        psklNow = psklNow->psklNext;

        // We have to close this so the socket goes back to the TCPIP stack.
        ChipKITClientStop(psklDelete->hTCP);

        free(psklDelete);
    }

  _port = 0;
  sklListening.hTCP = UNKNOWN_SOCKET;
  sklListening.psklNext = NULL;
  sklListening.psklBack = NULL;
}

/***	void begin()
**
**	Description:
**      Same as defined by http://arduino.cc/en/Reference/ServerBegin
**      
*/
void Server::begin()
{
    // we have already begun, don't do it again
    if(ChipKITValidTCPHandle(sklListening.hTCP))
    {
        return;
    }

    // really too bad we can't return an error to
    // tell us if we got a socket or not.
    sklListening.hTCP = ChipKITServerListenPORT(_port);
}

/***	void ServiceSocketListen(void)
**
**	Synopsis:   This is a private routine that walks all clients that have
**              connected to the server and removes all connections that are lost
**              and picks up any new connection and adds it to the client list.
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
**      This is a server maintainace routine
**      
*/
void Server::ServiceSocketListen(void)
{
    SKL * psklNow = NULL;

    // let things run so we can pick up a listen event
    Ethernet.PeriodicTasks();

    // if the handle we are listening on is valid and  connected
    // then create a Client in the list with this handle
    if(ChipKITValidTCPHandle(sklListening.hTCP) && ChipKITClientConnected(sklListening.hTCP))
    {  
        SKL *   psklFirst = sklListening.psklNext;

        TCP_SOCKET hTCP = ChipKITServerListenPORT(_port);  // immediately start listening on another socket
        
        // Now create and entry for the connected socket
        sklListening.psklNext = (SKL *) malloc(sizeof(SKL));
        sklListening.psklNext->hTCP = sklListening.hTCP;
        sklListening.hTCP = hTCP;  // put the new listening socket in the listing skl      
   
        // and put it at the front of the list
        sklListening.psklNext->psklNext = psklFirst;    // the old first client in the list after this new one
        sklListening.psklNext->psklBack = &sklListening;  // point back to the dummy false client

        // fix the back point if any to the newly created client
        if(psklFirst != NULL)
        {
            psklFirst->psklBack = sklListening.psklNext;
        }
   }

    // now go through the list and delete any sockets that are not connected.
    // remember the first Client is always a false client, so start with the first one in the list after the false one.
    psklNow = sklListening.psklNext;
    while(psklNow != NULL)
    {
 
        // here is one that is no longer connected
        if(!ChipKITClientConnected(psklNow->hTCP))
        {
            SKL * psklFree = psklNow;
            psklNow = psklNow->psklBack;

            if(psklFree->psklNext != NULL)
            {
                psklFree->psklNext->psklBack = psklFree->psklBack;
            }
    
            // there should always be a back pointer; if not point back to sklListening
            psklFree->psklBack->psklNext = psklFree->psklNext;

            // We have to close this so the socket goes back to the TCPIP stack.
            ChipKITClientStop(psklFree->hTCP);

            // get rid of this client;
            free(psklFree);
        }

        psklNow = psklNow->psklNext;
    }
}

/***	Client available()
**
**	Return Values:
**      A newly constructed Client Class representing a socket with data to read.
**      The client class will compart to true if data is available, or compare to false
**      if no data is available to read (that is client == true, or client == false).
**
**      Since many Clients instances can be created with this call that represents the same socket
**      as a Digilent extension you may compare a client to a client (clientA == clientB) and they 
**      will compare true if they represent the same socket, false otherwise if they are different.
**
**	Description:
**      
**      First it will do server maintance to make sure the server client list
**      is as up to date as possible. Then it walks all clients to see if any
**      data is ready to be read from any client. It then constructs a client class
**      with the first client in the list with data to read.
**
**      Same as defined by http://arduino.cc/en/Reference/ServerAvailable
**      
*/
Client Server::available()
{
    // just an empty client with an invalid socket
    // static only because we want to construct it once.
    static Client ClientFail;  

    SKL * psklNow = NULL; 

    // Process the list for only valid sockets
    // this could mess with our client list, so wait to
    // after this to set psklNow.
    ServiceSocketListen();

    // go through the list and see if there is any data to read
    // remember the Fist is a false client, we know not to start there.
    psklNow = sklListening.psklNext; 
    while(psklNow != NULL)
    {
        // if we find someone with some available bytes to read, return the client.
        if(ChipKITClientAvailable(psklNow->hTCP) > 0)
        {
            Client clientActive(psklNow->hTCP);
            return(clientActive);
        }

        psklNow = psklNow->psklNext;
    }

    // nothing found with bytes to read
    // this is our false client
    return(ClientFail);
}

/***	void write(uint8_t b)
**
**	Description:
**      Same as defined by http://arduino.cc/en/Reference/ServerWrite
**      And http://arduino.cc/en/Reference/ServerPrint
**      And http://arduino.cc/en/Reference/ServerPrintln
**      
*/
void Server::write(uint8_t b) 
{
   SKL * psklNow = sklListening.psklNext;

    while(psklNow != NULL)
    {
        ChipKITClientPutByte(psklNow->hTCP, b);
        psklNow = psklNow->psklNext;
    }
}

/***	void write(const char *str)
**
**	Description:
**      Same as defined by http://arduino.cc/en/Reference/ServerWrite
**      And http://arduino.cc/en/Reference/ServerPrint
**      And http://arduino.cc/en/Reference/ServerPrintln
**      
*/
void Server::write(const char *str) 
{
   SKL * psklNow = sklListening.psklNext;

    while(psklNow != NULL)
    {
        ChipKITClientPutSz(psklNow->hTCP, str, _cSecTimeout);
        psklNow = psklNow->psklNext;
    }
}

/***	void write(const uint8_t *buffer, size_t size)
**
**	Description:
**      Same as defined by http://arduino.cc/en/Reference/ServerWrite
**      And http://arduino.cc/en/Reference/ServerPrint
**      And http://arduino.cc/en/Reference/ServerPrintln
**      
*/
void Server::write(const uint8_t *buffer, size_t size) 
{
   SKL * psklNow = sklListening.psklNext;

    while(psklNow != NULL)
    {
        ChipKITClientPutBuff(psklNow->hTCP, buffer, size, _cSecTimeout);
        psklNow = psklNow->psklNext;
    }
}

/***	void SetSecTimeout(unsigned int cSecTimeout)
**
**	Synopsis:   This routine allows you to set the timeout value for
**              write methods. By default this is 
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
**      This will apply to all of the client writes in the server list.
*/
void Server::SetSecTimeout(unsigned int cSecTimeout)
{
    _cSecTimeout = cSecTimeout;
}
