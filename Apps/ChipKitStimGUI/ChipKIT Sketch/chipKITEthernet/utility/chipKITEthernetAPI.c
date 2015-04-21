/************************************************************************/
/*																		*/
/*	chipKITEthernetAPI.c	-- Ethernet interface APIs to implement the */
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
/*	This module exposes API's to be used in conjuction with 			*/
/*	chipKITEthernetAPI.cpp to implement a software compatible Arduino	*/
/*	Ethernet sketch library. These API's are designed specifcally to 	*/
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

#define THIS_IS_STACK_APPLICATION

// Include all headers for any enabled TCPIP Stack functions
#include "TCPIP Stack/TCPIP.h"

// Include functions specific to this stack application
#include "chipKITEthernetAPI.h"


// UDP Socket Buffering
static void ChipKITUDPUpdateBufferCache(void);

typedef struct
{
    WORD   		iEnd;
	WORD		cbAvailable;
	NODE_INFO	remoteNodeInfo;
	WORD		remotePort;
    BYTE    	rgbBuffer[RXSIZE];
} UDPSB;

static UDPSB * rgUDPSocketBuffers[MAX_UDP_SOCKETS];


// Used for Wi-Fi assertions
// #define WF_MODULE_NUMBER   WF_MODULE_MAIN_DEMO

// Declare AppConfig structure and some other supporting stack variables
APP_CONFIG AppConfig;
static unsigned short wOriginalAppConfigChecksum;	// Checksum of the ROM defaults for AppConfig
BYTE AN0String[8];

// Private helper functions.
// These may or may not be present in all applications.
static void InitAppConfig(void);
static void InitializeBoard(void);
	
	void _general_exception_handler(unsigned cause, unsigned status)
	{
		Nop();
		Nop();
	}


/****************************************************************************
  Function:
    static void InitializeBoard(void)

  Description:
    This routine initializes the hardware.  It is a generic initialization
    routine for many of the Microchip development boards, using definitions
    in HardwareProfile.h to determine specific initialization.

  Precondition:
    None

  Parameters:
    None - None

  Returns:
    None

  Remarks:
    None
  ***************************************************************************/
static void InitializeBoard(void)
{	
#if defined(_BOARD_MEGA_) || defined(_BOARD_CEREBOT_32MX7_)    
	TRISEbits.TRISE9 = 0;   // output phy enable SMSC8720, data part of the NIC
	LATEbits.LATE9 = 1; 	// high, enable the phy
#elif defined(_BOARD_CEREBOT_MX7CK_)
	TRISAbits.TRISA6 = 0;   // output phy enable SMSC8720, data part of the NIC
	LATAbits.LATA6 = 1; 	// high, enable the phy
#else
	#error	Board/CPU combination not defined
#endif
}

/*********************************************************************
 * Function:        void InitAppConfig(void)
 *
 * PreCondition:    MPFSInit() is already called.
 *
 * Input:           None
 *
 * Output:          Write/Read non-volatile config variables.
 *
 * Side Effects:    None
 *
 * Overview:        None
 *
 * Note:            None
 ********************************************************************/
// MAC Address Serialization using a MPLAB PM3 Programmer and 
// Serialized Quick Turn Programming (SQTP). 
// The advantage of using SQTP for programming the MAC Address is it
// allows you to auto-increment the MAC address without recompiling 
// the code for each unit.  To use SQTP, the MAC address must be fixed
// at a specific location in program memory.  Uncomment these two pragmas
// that locate the MAC address at 0x1FFF0.  Syntax below is for MPLAB C 
// Compiler for PIC18 MCUs. Syntax will vary for other compilers.
//#pragma romdata MACROM=0x1FFF0
static ROM BYTE SerializedMACAddress[6] = {MY_DEFAULT_MAC_BYTE1, MY_DEFAULT_MAC_BYTE2, MY_DEFAULT_MAC_BYTE3, MY_DEFAULT_MAC_BYTE4, MY_DEFAULT_MAC_BYTE5, MY_DEFAULT_MAC_BYTE6};
//#pragma romdata

static void InitAppConfig(void)
{
	
	while(1)
	{
		// Start out zeroing all AppConfig bytes to ensure all fields are 
		// deterministic for checksum generation
		memset((void*)&AppConfig, 0x00, sizeof(AppConfig));
		
		AppConfig.Flags.bIsDHCPEnabled = TRUE;
		AppConfig.Flags.bInConfigMode = TRUE;
		memcpypgm2ram((void*)&AppConfig.MyMACAddr, (ROM void*)SerializedMACAddress, sizeof(AppConfig.MyMACAddr));
//		{
//			_prog_addressT MACAddressAddress;
//			MACAddressAddress.next = 0x157F8;
//			_memcpy_p2d24((char*)&AppConfig.MyMACAddr, MACAddressAddress, sizeof(AppConfig.MyMACAddr));
//		}
		AppConfig.MyIPAddr.Val = MY_DEFAULT_IP_ADDR_BYTE1 | MY_DEFAULT_IP_ADDR_BYTE2<<8ul | MY_DEFAULT_IP_ADDR_BYTE3<<16ul | MY_DEFAULT_IP_ADDR_BYTE4<<24ul;
		AppConfig.DefaultIPAddr.Val = AppConfig.MyIPAddr.Val;
		AppConfig.MyMask.Val = MY_DEFAULT_MASK_BYTE1 | MY_DEFAULT_MASK_BYTE2<<8ul | MY_DEFAULT_MASK_BYTE3<<16ul | MY_DEFAULT_MASK_BYTE4<<24ul;
		AppConfig.DefaultMask.Val = AppConfig.MyMask.Val;
		AppConfig.MyGateway.Val = MY_DEFAULT_GATE_BYTE1 | MY_DEFAULT_GATE_BYTE2<<8ul | MY_DEFAULT_GATE_BYTE3<<16ul | MY_DEFAULT_GATE_BYTE4<<24ul;
		AppConfig.PrimaryDNSServer.Val = MY_DEFAULT_PRIMARY_DNS_BYTE1 | MY_DEFAULT_PRIMARY_DNS_BYTE2<<8ul  | MY_DEFAULT_PRIMARY_DNS_BYTE3<<16ul  | MY_DEFAULT_PRIMARY_DNS_BYTE4<<24ul;
		AppConfig.SecondaryDNSServer.Val = MY_DEFAULT_SECONDARY_DNS_BYTE1 | MY_DEFAULT_SECONDARY_DNS_BYTE2<<8ul  | MY_DEFAULT_SECONDARY_DNS_BYTE3<<16ul  | MY_DEFAULT_SECONDARY_DNS_BYTE4<<24ul;
	
	
		// Load the default NetBIOS Host Name
		memcpypgm2ram(AppConfig.NetBIOSName, (ROM void*)MY_DEFAULT_HOST_NAME, 16);
		FormatNetBIOSName(AppConfig.NetBIOSName);

		// Compute the checksum of the AppConfig defaults as loaded from ROM
		wOriginalAppConfigChecksum = CalcIPChecksum((BYTE*)&AppConfig, sizeof(AppConfig));

		break;
	}
}

/****************************************************************************
// ChipKIT Client APIs
// Here is where the chipKIT Arduino software compatible underlying
// APIs are implemented.
  ***************************************************************************/

/****************************************************************************
  Function:
    void ChipKITEthernetBegin(const BYTE *rgbMac, const BYTE *rgbIP, const BYTE *rgbGateWay, const BYTE *rgbSubNet, const BYTE *rgbDNS1, const BYTE *rgbDNS2)

  Description:
    This routine impements the Arduino Ethernet.Begin Method. This initializes the
	board, start supporting tasks, builds a default application configuration data structure,
	overrides the configuration structure if static IPs or assigned MACs are specified,
	and starts the Ethernet stack.

  Precondition:
    None

  Parameters:
    rgbMac 	- If all 6 bytes are zero, than use the internal MCU programed MAC address
			as defined by Microchip. It will be a unique MAC address in the Microchip range. 
			The range will be somewhere starting with 00:04:A3:XX:XX:XX

			If non-zero, the specified MAC address will be used.

	rgbIP 	-	If all 4 bytes are zero, then DHCP is used and rest of the parameters are ignored

			If an IP is specified then DHCP is not used and the IP represents a static IP address to use. The 
			remainng parameters have value.

	rgbGateWay 	- 4 bytes IP address of the gateway to use. Only valid if rgbIP is specified
	rgbSubNet	- 4 byte mask representing the subnet mask.Only valid if rgbIP is specified
	rgbDNS1		- 4 byte IP address of the primary DNS server. Only valid if rgbIP is specified. This value may be 0s if not required
	rgbDNS2		- 4 byte IP address of the secondary DNS server. Only valid if rgbIP is specifed. This value may be 0s if not required

  Returns:

    None

  Remarks:
    None
  ***************************************************************************/
void ChipKITEthernetBegin(const BYTE *rgbMac, const BYTE *rgbIP, const BYTE *rgbGateWay, const BYTE *rgbSubNet, const BYTE *rgbDNS1, const BYTE *rgbDNS2)
{
	DWORD t = 0;
	const DWORD tDHCPTimeout = 30 * TICK_SECOND;

	// Initialize application specific hardware
	InitializeBoard();

	// Initialize stack-related hardware components that may be 
	// required by the UART configuration routines
    TickInit();

	// Initialize Stack and application related NV variables into AppConfig.
	InitAppConfig();

	// see if we have something other than to use our MAC address
	if((rgbMac[0] | rgbMac[1] | rgbMac[2] | rgbMac[3] | rgbMac[4] | rgbMac[5]) != 0)
	{
		memcpy(&AppConfig.MyMACAddr, rgbMac, 6);
	}

	// if we are not to use DHCP; fill in what came in.
	if((rgbIP[0] | rgbIP[1] | rgbIP[2] | rgbIP[3]) != 0)
	{
		AppConfig.Flags.bIsDHCPEnabled = FALSE;		// don't use dhcp
		memcpy(&AppConfig.MyIPAddr, rgbIP, 4);
		memcpy(&AppConfig.MyGateway, rgbGateWay, 4);
		memcpy(&AppConfig.MyMask,rgbSubNet, 4);
		memcpy(&AppConfig.PrimaryDNSServer, rgbDNS1, 4);
		memcpy(&AppConfig.SecondaryDNSServer, rgbDNS2, 4);
		
		AppConfig.DefaultIPAddr = AppConfig.MyIPAddr;
		AppConfig.DefaultMask = AppConfig.MyMask;
	}


	// make sure our static array is zeroed out.
	memset(rgUDPSocketBuffers, 0, sizeof(rgUDPSocketBuffers));

	// Initialize core stack layers (MAC, ARP, TCP, UDP) and
	// application modules (HTTP, SNMP, etc.)
    StackInit();

	// arp will not work right until DHCP finishes
	// if DHCP won't configure after the timeout; then just go with it
	// maybe later it will configure, but until then, things might not work right.
	t = TickGet();
	while(AppConfig.Flags.bIsDHCPEnabled && !DHCPIsBound(0) && ((TickGet() - t) < tDHCPTimeout))
	{
		ChipKITPeriodicTasks();
	}
}



/****************************************************************************
  Function:
    void ChipKITPeriodicTasks(void)

  Description:
    This routine will run the periodic tasks needed to keep the Ethernet
	stack alive and to run the tasks such as ping or DHCP as part of supporting the stack.

  Precondition:
    None

  Parameters:
    None - None

  Returns:
    None

  Remarks:
    This funciton needs to be called on a regular basis in order to service
	incoming TCPIP / UDP tasks. If it is not called the stack will freeze.
	Most Arduino interface APIs specified in the file call ChipKITPeriodicTasks 
	implicitly so that it is called at the right time to execution the stack
	functions. But this routine is made available to the sketch so that the
	sketch can keep the stack alive while the sketch is idle.
  ***************************************************************************/
void ChipKITPeriodicTasks(void)
{
   	// This task performs normal stack task including checking
   	// for incoming packet, type of packet and calling
    // appropriate stack entity to process it.
    StackTask();

    // an annoying thing is that the MAL will not hold on to the
    // UDP buffer for another iteration of StackTask, so we must
    // buffer the UDP data so we don't lose it.
	ChipKITUDPUpdateBufferCache();

    // This tasks invokes each of the core stack application tasks
    StackApplications();
}

/****************************************************************************
  Function:
   TCP_SOCKET ChipKITClientConnect(unsigned int dwOpenVal, BYTE vRemoteHostType, unsigned short wPort, unsigned int cSecTimout)

  Description:
    This routine opens a socket and for clients only, attempts to connect to the server.
	DNS lookups are done if a URL is specifed for dwOpenVal and vRemoteHostType == TCP_OPEN_RAM_HOST
	
  Precondition:
    None

  Parameters:
    dwOpenVal		- Same as in TCPOpen
	vRemoteHostType	- Same as in TCPOpen
	wPort			- Same as in TCPOpen
	cSecTimout		- If this is a client connecting to a host, this is the number of seconds to wait for a 
						successful connection to occur

  Returns:
   	The valid socket if the open was successful, or INVALID_SOCKET if no sockets were avaiable or 
	the connection was not made (in the case of a client)

  Remarks:
	This routine will attempt to wait until the connection is made for client, but will return immediately for servers as servers
	listen for connections. For the client case, if cSecTimout is exceeded, the connection is close and the socket released back to
	the stack for reuse.
   ***************************************************************************/
TCP_SOCKET ChipKITClientConnect(unsigned int dwOpenVal, BYTE vRemoteHostType, unsigned short wPort, unsigned int cSecTimout)
{
	TCP_SOCKET hTCP = UNKNOWN_SOCKET;
	DWORD t = 0;

	hTCP = TCPOpen((DWORD) dwOpenVal, vRemoteHostType, (WORD) wPort, TCP_PURPOSE_DEFAULT);
	ChipKITPeriodicTasks();

	// if it just fails, don't even attempt a retry
	if(hTCP == INVALID_SOCKET)
	{
		return(hTCP);
	}

	// if this is a client, we have to wait until we connect
	// No need to do this for servers as they connect when some one comes in on the listen
	if(vRemoteHostType != TCP_OPEN_SERVER) 
	{
		t = TickGet(); // so we don't loop forever
		while(!TCPIsConnected(hTCP))
		{
		 	ChipKITPeriodicTasks();
	
			// if after 10 seconds we do not connect, just fail and clean up
			if( (TickGet() - t) >= (cSecTimout * TICK_SECOND))
			{
				TCPClose(hTCP);
				TCPDiscard(hTCP);
				hTCP = INVALID_SOCKET;
				
				// make sure we run tasks again to get for the close to take effect
				// so don't return here, break out of the while to clean up
				break;  
			}
		}
				
		ChipKITPeriodicTasks();
	}

	return(hTCP);
}

/****************************************************************************
  Function:
    unsigned int ChipKITClientAvailable(TCP_SOCKET hTCP)

  Description:
    This routine checks to see if any bytes are ready to be read on the specified socket.

  Precondition:
    hTCP must be open and valid.

  Parameters:
    hTCP - The socket to check

  Returns:
    Number of bytes ready to be read, zero if none.

  Remarks:
	This is to match functionality of the Arduino Client class available method
  ***************************************************************************/
unsigned int ChipKITClientAvailable(TCP_SOCKET hTCP)
{
	ChipKITPeriodicTasks();
	return(TCPIsGetReady(hTCP));
}

/****************************************************************************
  Function:
    int ChipKITClientGetByte(TCP_SOCKET hTCP)

  Description:
    This routine read 1 byte from the specified socket, if any are available.

  Precondition:
    hTCP must be open and valid.

  Parameters:
    hTCP - The socket to check

  Returns:
    The read byte or -1 if no bytes are available.

  Remarks:
	This is to match functionality of the Arduino Client class Read method
  ***************************************************************************/
int ChipKITClientGetByte(TCP_SOCKET hTCP)
{
	BYTE b;

	// run our tasks
	ChipKITPeriodicTasks();

	// Follow the Ardunio rules
    if( TCPIsGetReady(hTCP)> 0 && TCPGet(hTCP, &b))
	{
		return((int) ((unsigned int) b));
	}
	else
	{
		return(-1);
	}
}

/****************************************************************************
  Function:
    unsigned int ChipKITClientGetBuff(TCP_SOCKET hTCP, BYTE * rgBuff, unsigned short cbRead)

  Description:
    This routine reads a buffer from the specified socket, if any data is available.

  Precondition:
    hTCP must be open and valid.

  Parameters:
    hTCP - The socket to check
	rgbBuff - a pointer to a buffer to receive the data.
	cbRead - the size of the buffer.

  Returns:
    The number of byte read, 0 if none.

  Remarks:
	This is to match functionality of the Arduino Client class Read method
  ***************************************************************************/
unsigned int ChipKITClientGetBuff(TCP_SOCKET hTCP, BYTE * rgBuff, unsigned short cbRead)
{
	WORD cb = 0;
	WORD cbCur = 0;

	// run our tasks
	ChipKITPeriodicTasks();

	// if there is anything to read
	// we don't even have to be connected for this to
	// return what is in the buffer.
	// we will return when we empty the buffer so we will not 
	// have an infinite loop problem waiting for data.
	while(cbRead > 0 && (cb = TCPIsGetReady(hTCP)) > 0)
	{
		// get as much as we want or can read
		cb = cb > cbRead ? cbRead : cb;

		// read it
		cb = TCPGetArray(hTCP, &rgBuff[cbCur], cb);

		cbCur += cb;
		cbRead -= cb;

		// run our tasks so everything is updated after the read
		ChipKITPeriodicTasks();
	}

	// return what we read
	return(cbCur);
}

/****************************************************************************
  Function:
    ChipKITClientPutByte(TCP_SOCKET hTCP, BYTE b)

  Description:
    This routine write 1 byte out on the socket

  Precondition:
    hTCP must be open and valid.

  Parameters:
    hTCP - The socket to check
	b - the byte to write out.

  Returns:
    True if it succeeded, false otherwise.

  Remarks:
	This is to match functionality of the Arduino Client class write method
	This is an expensive function to call as it flushes the1 byte out; we don't know
	how many bytes will be written, and the Arduino code expects the byte to go out.
	Also, this will run the periodic tasks, so a lot of over head is used for this task.
  ***************************************************************************/
BOOL ChipKITClientPutByte(TCP_SOCKET hTCP, BYTE b)
{
	BOOL fRet = FALSE;
	
	// really don't care if it is connected or not
	// just return the error
	fRet = TCPPut(hTCP, b);

	// this is very expensive!
	if(TCPIsConnected(hTCP))
	{
		TCPFlush(hTCP);				// flush any remaining stuff out
	}

	// run our tasks so things can be put out and come in.
	ChipKITPeriodicTasks();

	return(fRet);
}

/****************************************************************************
  Function:
    unsigned int ChipKITClientPutSz(TCP_SOCKET hTCP, const char * sz, unsigned int cSecTimout)

  Description:
    This routine writes out a string on to the wire.

  Precondition:
    hTCP must be open and valid.

  Parameters:
    hTCP - The socket to check
	sz - a zero terminated string to write out
	cSecTimout - The number of seconds to wait before aborting the write.

  Returns:
    Returns the number of character written, zero if none.

  Remarks:
	This is to match functionality of the Arduino Client class write method
	A flush to push the bytes out on the wire is done.
  ***************************************************************************/
unsigned int ChipKITClientPutSz(TCP_SOCKET hTCP, const char * sz, unsigned int cSecTimout)
{
	DWORD t = 0;
	char * szCur = (char *) sz;
	char * szLast = szCur;

	// there is a rare potential that this could loop forever
	// if the connection stays active yet the otherside does not read
	// the buffer.

	// loop until this is written out, or timeout
	t = TickGet();
	while(*szCur !=0x00) 
	{
		// if we lost the connection, get out
		if( !TCPIsConnected(hTCP) )
		{
			break;
		}

		// try to write some char out
		szCur = TCPPutString(hTCP, szCur);

		// if we are done, get out.
		if(*szCur == 0x00)
		{
			break;
		}
		
		// we did move forward, so reset our timers and pointers.
		else if(szCur != szLast)
		{
			szLast = szCur;	// last written location
			t = TickGet();	// reset wait timer, we are moving forward
		}

		// we have not moved forward, so check our timeout value
		else if((TickGet() - t) >= (cSecTimout * TICK_SECOND)) 
		{
			break;
		}
			
		// if the buffer is full, it should automatically flush
		// so we should not need to write TCPFlush
		// run our tasks so things can be put out and come in.
		ChipKITPeriodicTasks();
	}

	if(TCPIsConnected(hTCP))
	{
		TCPFlush(hTCP);				// flush any remaining stuff out
	}

	ChipKITPeriodicTasks();		// run the tasks to get it done
	return( ((unsigned int) (szCur - sz)) / sizeof(char) ); // return # char written
}

/****************************************************************************
  Function:
    unsigned int ChipKITClientPutBuff(TCP_SOCKET hTCP, const BYTE * rgBuff, unsigned short cbWrite, unsigned int cSecTimeout)

  Description:
    This routine write out a buffer onto the wire

  Precondition:
    hTCP must be open and valid.

  Parameters:
    hTCP - The socket to check
	rgBuff - the buffer to write out.
	cbWrite - the number of bytes to write out.
	cSecTimout - The number of seconds to wait before aborting the write.

  Returns:
    Returns the number of bytes written, zero if none.

  Remarks:
	This is to match functionality of the Arduino Client class write method
	A flush to push the bytes out on the wire is done.
  ***************************************************************************/
unsigned int ChipKITClientPutBuff(TCP_SOCKET hTCP, const BYTE * rgBuff, unsigned short cbWrite, unsigned int cSecTimeout)
{
	WORD cbReady = 0;
	WORD cbPut = 0;
	WORD cbToWrite = 0;
	WORD cbPutTotal = 0;
	DWORD t = 0;

	// loop until this is written out, or timeout
	t = TickGet();
	while(cbWrite > 0) 
	{
		// get out if we lost connection
		if(!TCPIsConnected(hTCP))
		{
			break;
		}

		// see how much buffer space is available
		if((cbReady = TCPIsPutReady(hTCP)) > 0)
		{
			// only put out what we can
			cbToWrite = cbWrite > cbReady ? cbReady : cbWrite;

			// put the data out
			cbPut = TCPPutArray(hTCP, (BYTE *) &rgBuff[cbPutTotal], cbToWrite);

			// update our loop counters
			cbPutTotal += cbPut;
			cbWrite -= cbPut;
		}

		// if we are done get out
		if(cbWrite == 0)
		{
			break;
		}

		// check to see if we are moving forward
		else if(cbPut > 0) 
		{
			t = TickGet();	// reset wait timer, we are moving forward
		}

		// didn't move forward, see if we are timing out
		else if((TickGet() - t) >= (cSecTimeout * TICK_SECOND)) 
		{
			break;
		}

		// run our tasks so things can be put out and come in.
		cbPut = 0;	// to see if we are moving forward
		ChipKITPeriodicTasks();
	}
	
	if(TCPIsConnected(hTCP))
	{
		TCPFlush(hTCP);				// flush any remaining stuff out
	}

	ChipKITPeriodicTasks();		// run tasks to do it
	return(cbPutTotal);
}

/****************************************************************************
  Function:
    void ChipKITClientStop(TCP_SOCKET hTCP)

  Description:
    This routine closes the socket, discards the input buffer, and returns the socket to the TCPIP stack.

  Precondition:
    hTCP must be open and valid.

  Parameters:
    hTCP - The socket to close

  Returns:
    none

  Remarks:
	This is to match functionality of the Arduino Client class stop method
  ***************************************************************************/
void ChipKITClientStop(TCP_SOCKET hTCP)
{

	// the MAL can hang if you attempt to close an invalid socket
	if(hTCP == INVALID_SOCKET || hTCP == UNKNOWN_SOCKET)
	{
		return;
	}

	// close the handle
	TCPClose(hTCP);

	// empty the receive buffer because we are killing it.
	TCPDiscard(hTCP);

	// loop until it is acknowledged to be closed
	do
	{
		ChipKITPeriodicTasks();
	} while(TCPIsConnected(hTCP));	

}

/****************************************************************************
  Function:
    BOOL ChipKITClientConnected(TCP_SOCKET hTCP)

  Description:
    This routine checks to see if the socket is still connected

  Precondition:
    none

  Parameters:
    hTCP - The socket to check

  Returns:
    TRUE is the socket is open and connected, FALSE otherwise.

  Remarks:
	This is to match functionality of the Arduino Client class Connected method.
	This will return TRUE even if the socket is no longer connected yet there are still
	some unread bytes in the socket buffer. This is to match Arduino functionality
  ***************************************************************************/
BOOL ChipKITClientConnected(TCP_SOCKET hTCP)
{
	// even though we are disconnected we may 
	// still have data in the input buffer
	// Arduino defines this as still open
	// so check to see if we have stuff. 
	if(TCPIsGetReady(hTCP) == 0)
	{
		// nothing in the buffer, return the truth about the connection
		return(TCPIsConnected(hTCP));
	}
	// still have stuff in the buffer, say we are connected.
	else
	{
		return(TRUE);
	}
}

/****************************************************************************
  Function:
    void ChipKITClientFlush(TCP_SOCKET hTCP)

  Description:
    This routine discards any bytes in the socket input buffer

  Precondition:
    hTCP must be open and valid.

  Parameters:
    hTCP - The socket to check

  Returns:
    none.

  Remarks:
	This is to match functionality of the Arduino Client class flush method
	In Arduino, flush means to discard the input buffer which is different than
	Flush in the MAL which means to push the data out on the wire.
  ***************************************************************************/
void ChipKITClientFlush(TCP_SOCKET hTCP)
{
	TCPDiscard(hTCP);
	ChipKITPeriodicTasks();
}

/****************************************************************************
  Function:
    int ChipKITClientPeek(TCP_SOCKET hTCP)

  Description:
    This routine returns the next byte in the buffer without removing it from the buffer
	or -1 if no byes are available.

  Precondition:
    hTCP must be open and valid.

  Parameters:
    hTCP - The socket to check

  Returns:
    The number of bytes in the input buffer or -1 if no bytes are available.

  Remarks:
	This is to match functionality of the Arduino Client class peek method
  ***************************************************************************/
int ChipKITClientPeek(TCP_SOCKET hTCP)
{
	unsigned int cb = 0;

	ChipKITPeriodicTasks();

	cb = TCPIsGetReady(hTCP);

	// follow the Arduino convension or return -1 on empty
	if(cb == 0)
	{
		return(-1);
	}
	else
	{
		return( (int) ((unsigned int) TCPPeek(hTCP, 0)));
 	}
}


// End ChipKIT APIs






// UDP helper functions

/****************************************************************************
  Function:
    UDP_SOCKET_INFO * PUDPSocketInfoFromUDPSocket(UDP_SOCKET hUDP)

  Description:
    Finds the underlying MAL socket data structure based on the hUDP
	or NULL if it is not a valide hUDP

  Precondition:
    hUDP must be within the range of assigned sockets

  Parameters:
    hUDP - The socket to check

  Returns:
    A pointer to the MAL UDP Socket data structure or NULL if the hUDP doesn't exist

  Remarks:
    None
  ***************************************************************************/
static UDP_SOCKET_INFO * PUDPSocketInfoFromUDPSocket(UDP_SOCKET hUDP)
{
	if(hUDP >= MAX_UDP_SOCKETS)
	{
		return(NULL);
	}
	else
	{
		return(&UDPSocketInfo[hUDP]);
	}
}

/****************************************************************************
  Function:
    BOOL UDPNodeInfoFromIP(IP_ADDR ipAddrRemote, NODE_INFO * pnodeInfo, unsigned int cSecTimeout)

  Description:
    Does an ARP to resolve the MAC address for a give IP Address

  Precondition:
    UDP stack has to be up an running

  Parameters:
    ipAddrRemote    - an IP_ADDR with the IP address of the remote machine you want to
                        discover the MAC address for.
    pnoeInfo        - a pointer to an empty NODE_INFO structure. The IP address and MAC will
                        be loaded into the sturcture
    cSecTimout      - The maximum number of seconds to wait for the arp address to be resolved
                        if it can't be done in this amount of time, return with FALSE as unresolved.

  Returns:
    TRUE if the MAC address was resolved, FALSE if it was not.

  Remarks:
    None
  ***************************************************************************/
static BOOL UDPNodeInfoFromIP(IP_ADDR ipAddrRemote, NODE_INFO * pnodeInfo, unsigned int cSecTimeout) 
{
	DWORD t = 0;
    
    pnodeInfo->IPAddr = ipAddrRemote;

    // if this the broadcast IP address, then set the broadcast mac.
    if(ipAddrRemote.Val == 0xFFFFFFFF)
    {
        memset(&pnodeInfo->MACAddr, 0xFF, sizeof(pnodeInfo->MACAddr));
        return(TRUE);
    }

    // resolve the IP address to get a MAC
    ARPResolve(&ipAddrRemote);
	t = TickGet();
    while( !ARPIsResolved(&ipAddrRemote, &pnodeInfo->MACAddr) )
    {
        if((TickGet() - t) >= (cSecTimeout * TICK_SECOND))
        {
            return(FALSE);
        }

        ChipKITPeriodicTasks();
    }

    return(TRUE);
}

/****************************************************************************
  Function:
     BOOL UDPAdjustSocketToMe(UDP_SOCKET hUDP, IP_ADDR ipAddrRemote, UDP_PORT remotePort, unsigned int cSecTimeout)

  Description:
    Annoying thing about Arduino is that they just change the to address on each individual write, not by closing
    and opening another socket. This is a HACK to dynamically change the remote to address without closing and reopening the socket

  Precondition:
    UDP stack has to be up an running

  Parameters:
    ipAddrRemote    - an IP_ADDR with the IP address of the remote machine you want to
                        send the UDP packet to
    remotePort      - the remote port you are sending to.
                       
    cSecTimout      - The maximum number of seconds to wait for the arp address to be resolved

  Returns:
    TRUE if the remote address was successfully changed, FALSE otherwise

  Remarks:
    The APR must be able to succeed, that is the MAC address was discovered, in order for this call to succeed.
  ***************************************************************************/
static BOOL UDPAdjustSocketToMe(UDP_SOCKET hUDP, IP_ADDR ipAddrRemote, UDP_PORT remotePort, unsigned int cSecTimeout)
{
    NODE_INFO nodeInfo;
	UDP_SOCKET_INFO * pSocketInfo = PUDPSocketInfoFromUDPSocket(hUDP);

    if(pSocketInfo == NULL)
    {
        return(FALSE);
    }

    if( pSocketInfo->remoteNode.IPAddr.Val != ipAddrRemote.Val) 
    {
        // do the ARP to get our target MAC address
        if(!UDPNodeInfoFromIP(ipAddrRemote, &nodeInfo, cSecTimeout))
        {
            return(FALSE);
        }

		pSocketInfo->remoteNode = nodeInfo;
		pSocketInfo->remotePort = remotePort;
    }

    return(TRUE);
}

/****************************************************************************
  Function:
     WORD UDPSendPacket(UDP_SOCKET hUDP, BYTE * rgbBuf, WORD cbBuff, IP_ADDR ipAddr, WORD port, unsigned int cSecTimeout)

  Description:
    This is the core UDP send API, it will adjust the socket to the remote address we want to send to
    and then blast the data out.

  Precondition:
    UDP stack has to be up an running

  Parameters:
    hUDP        - An opened UDP socket to use to send on

    rgbBuf      - pointer to an array of bytes to send
                        
    cbBuff      - number of bytes in the buffer to send

    ipAddr      - the remote ip address to write to

    port        - the remote port to write to.
                       
    cSecTimout  - The maximum number of seconds to wait for the arp or write to take
                    before just returning with the number of bytes actually written, which could be 0.

  Returns:
    The number of bytes actually written to the remote target

  Remarks:
    UDP does not guarantee success, this could just go out on the wire to deaf ears.
  ***************************************************************************/
static WORD UDPSendPacket(UDP_SOCKET hUDP, BYTE * rgbBuf, WORD cbBuff, IP_ADDR ipAddr, WORD port, unsigned int cSecTimeout)
{

    WORD cbReady = 0;
    WORD cbSent = 0;
	DWORD t = 0;
 	
    if(!UDPAdjustSocketToMe(hUDP, ipAddr, port, cSecTimeout))
    {
        return(0);
    }

    t = TickGet();
    while(cbSent < cbBuff) 
    {
        if((cbReady = UDPIsPutReady(hUDP)) > 0)
        {
			WORD cb = cbBuff - cbSent;

			cb = cb < cbReady ? cb : cbReady;
            cbSent += UDPPutArray(&rgbBuf[cbSent], cb);
            UDPFlush();
 
            t = TickGet();
        }
        else if((TickGet() - t) >= (cSecTimeout * TICK_SECOND))
        {
            break;
        }

        ChipKITPeriodicTasks();
    }

    return(cbSent);
}

// start of UDP data cache helper functions
// The MAL does not maintain the UDP data withing the UDP socket between StackTask calls. This will maintain the 
// in a parallet socket info data structure (UDPSB - UDP Socket Buffer).


/****************************************************************************
  Function:
    UDPSB * UDPGetUDPSB(UDP_SOCKET hUDP)

  Description:
    Finds the parallel socket cache data structure
	or NULL if it is not a valide hUDP

  Precondition:
    hUDP must be within the range of assigned sockets

  Parameters:
    hUDP - The socket to check

  Returns:
    A pointer to the parallel Socket data structure or NULL if the hUDP doesn't exist

  Remarks:
    None
  ***************************************************************************/
static UDPSB * UDPGetUDPSB(UDP_SOCKET hUDP)
{
	if(hUDP >= MAX_UDP_SOCKETS)
	{
		return(NULL);
	}

	return(rgUDPSocketBuffers[hUDP]);
}

/****************************************************************************
  Function:
   WORD UDPAvailable(UDP_SOCKET hUDP)

  Description:
    Finds the number of available / unread bytes currently in the
    UDP buffer cache

  Precondition:
    hUDP must be within the range of assigned sockets

  Parameters:
    hUDP - The socket to check

  Returns:
    The count of available bytes, or 0 if no data is available to be read.

  Remarks:
    The cache is a circular buffer with first in first out. However, if data
    comes in on the wire faster than it is read out by the application, the 
    buffer will start to overwrite data and the earlier data will just be lost.
    Therefore, the maximum number of unread data will be the maximum size
    of the cache; which is RXMAX, or typically 1536 (0x600) bytes.
    
  ***************************************************************************/
static WORD UDPAvailable(UDP_SOCKET hUDP)
{
	UDPSB * pUDPSB = NULL;

	if(hUDP >= MAX_UDP_SOCKETS  || (pUDPSB = rgUDPSocketBuffers[hUDP]) == NULL)
	{
		return(0);
	}

	return(pUDPSB->cbAvailable);
}

/****************************************************************************
  Function:
   WORD UDPRead(UDP_SOCKET hUDP, BYTE * rgbRead, WORD cbMaxRead)

  Description:
    Reads data in from the UDP Cache

  Precondition:
    hUDP must be within the range of assigned sockets

  Parameters:
    hUDP    - The UDP socket to check

    rgbRead - A pointer to a buffer to receive the data

    cbMaxRead - the size of the buffer to receive the data

  Returns:
    The number of bytes actually read from the socket cache, this may be 0
    if no bytes are available.

  Remarks:
    The maximum number of unread data will be the maximum size
    of the cache; which is RXMAX, or typically 1536 (0x600) bytes.
    
  ***************************************************************************/
static WORD UDPRead(UDP_SOCKET hUDP, BYTE * rgbRead, WORD cbMaxRead)
{
	UDPSB * pUDPSB = NULL;
	WORD	cbCopy = 0;
	WORD	cbRead = 0;
	WORD	iRead = 0;
	WORD	iStart = 0;

	if(hUDP >= MAX_UDP_SOCKETS  || (pUDPSB = rgUDPSocketBuffers[hUDP]) == NULL)
	{
		return(0);
	}


	// calculate the start position
	iStart = sizeof(pUDPSB->rgbBuffer) + pUDPSB->iEnd - pUDPSB->cbAvailable;
	if(iStart >= sizeof(pUDPSB->rgbBuffer))
	{
		iStart -= sizeof(pUDPSB->rgbBuffer);
	}

	// read the requested bytes
	cbRead = pUDPSB->cbAvailable < cbMaxRead ? pUDPSB->cbAvailable : cbMaxRead;
	while(cbRead > 0)
	{
		cbCopy = sizeof(pUDPSB->rgbBuffer) - iStart;
		cbCopy = cbCopy < cbRead ? cbCopy : cbRead;
		memcpy(&rgbRead[iRead], &pUDPSB->rgbBuffer[iStart], cbCopy);
		iRead += cbCopy;
		iStart += cbCopy;
		cbRead -= cbCopy;
		
		// run to the front of the bufer if we read to the end
		if(iStart == sizeof(pUDPSB->rgbBuffer))
		{
			iStart = 0;
		}	
	}

	// adjust how much we read
	pUDPSB->cbAvailable -= iRead;

	return(iRead);
}

/****************************************************************************
  Function:
   WORD UDPSBWrite(UDPSB * pUDPSB, WORD cbWrite)

  Description:
    Write data from the UDP socket buffers into the UDP socket cache

  Preconditions:
    UDPIsGetReady must have already been called so that UDPGetArray
    will retrieve data from the correct socket.

  Parameters:
    pUDPSB  - a point to the parallel socket cache data structure.

    cbWrite - The number of bytes to read from the socket

  Returns:
    The number of bytes actually written to the socket cache.

  Remarks:
    If more data is written to the socket cache than free space is available
    then the earlier data in the cache is overwritten. The available bytes will
    be set to the maximum size of the 
    of the cache; which is RXMAX, or typically 1536 (0x600) bytes.
    
  ***************************************************************************/
static WORD UDPSBWrite(UDPSB * pUDPSB, WORD cbWrite)
{
	WORD	cbCopy = 0;
	WORD	iWrite = 0;

	while(cbWrite > 0)
	{
		cbCopy = sizeof(pUDPSB->rgbBuffer) - pUDPSB->iEnd;
		cbCopy = cbCopy < cbWrite ? cbCopy : cbWrite;
		cbCopy = UDPGetArray(&pUDPSB->rgbBuffer[pUDPSB->iEnd], cbCopy);
		iWrite += cbCopy;
		pUDPSB->iEnd += cbCopy;
		cbWrite -= cbCopy;
		
		// run to the front of the bufer if we used it all up
		if(pUDPSB->iEnd == sizeof(pUDPSB->rgbBuffer))
		{
			pUDPSB->iEnd = 0;
		}	
	}

	// if we have a buffer overrun, then set the available count
	// to the max size of the buffer.
	pUDPSB->cbAvailable += iWrite;
	if(pUDPSB->cbAvailable > sizeof(pUDPSB->rgbBuffer))
	{
		pUDPSB->cbAvailable = sizeof(pUDPSB->rgbBuffer);
	}

	return(iWrite);
}


/****************************************************************************
  Function:
   void ChipKITUDPUpdateBufferCache(void)

  Description:
    This is called in PeriodicTasks to make sure that
    all UDP data is copied to the cache before the MAL 
    discards it on the next StackTasks

  Preconditions:

  Parameters:
    None

  Returns:
    None

  Remarks:
    By double buffering, we are able to save the UDP data before losing
    it on the next call to StackTasks
   
  ***************************************************************************/
static void ChipKITUDPUpdateBufferCache(void)
{
	UDP_SOCKET hUDP;
	WORD cbReady = 0;
	UDPSB * pUDPSB = NULL;
	UDP_SOCKET_INFO * pSocketInfo = NULL;

	for(hUDP = 0; hUDP < MAX_UDP_SOCKETS; hUDP++)
	{
		if((pUDPSB = rgUDPSocketBuffers[hUDP]) != NULL)
		{
			if((cbReady = UDPIsGetReady(hUDP)) > 0)
			{
				UDPSBWrite(pUDPSB, cbReady);
				pSocketInfo = PUDPSocketInfoFromUDPSocket(hUDP);
				pUDPSB->remoteNodeInfo = pSocketInfo->remoteNode;
				pUDPSB->remotePort = pSocketInfo->remotePort;;
			}
		}
	}
}

// End Socket Cache Helpers
// End UDP Helpers

// Start UDP Arduino compilant implementation

/****************************************************************************
  Function:
   UDP_SOCKET ChipKITUDPBegin(UDP_PORT localPort)

  Description:
    Implementes the Arduino UDP begin function.
 
  Parameters:
    localPort   - The port to start listening on.

  Returns:
    The socket that was opened, or INVALID_UDP_SOCKET if it couldn't get one

  Remarks:
    Creates a socket and starts listening on the specifed port.
    Note that Arduino never specifies an IP address with this, that
    is done on the individual send packetes.
    If there is not enough space for the socket cache, this API will fail
   
  ***************************************************************************/
UDP_SOCKET ChipKITUDPBegin(UDP_PORT localPort)
{
	UDP_SOCKET hUDP = INVALID_UDP_SOCKET;
    hUDP = UDPOpen(localPort, NULL, 0);

	if(hUDP < MAX_UDP_SOCKETS && rgUDPSocketBuffers[hUDP] == NULL)
	{
		rgUDPSocketBuffers[hUDP] = (UDPSB *) malloc(sizeof(UDPSB));	
		if(rgUDPSocketBuffers[hUDP] != NULL)
		{
			memset(rgUDPSocketBuffers[hUDP], 0, sizeof(sizeof(UDPSB)));
		}

		// no space for the buffer, no socket!
		else
		{
			UDPClose(hUDP);
			hUDP = INVALID_UDP_SOCKET;
		}
	}

    ChipKITPeriodicTasks();

    return(hUDP);
}

/****************************************************************************
  Function:
   WORD ChipKITUDPSendPacketURL(UDP_SOCKET hUDP, BYTE * rgbBuf, WORD cbBuff, const char * szURL, WORD port, unsigned int cSecTimeout)

  Description:
    Implementes the Arduino UDP SendPacket function.
 
  Parameters:
    hUDP        - the UDP socket to use

    rgbBuf      - a pointer to a buffer of bytes to send

    cbBuff      - the number of bytes to send

    szURL       - The URL to send the packet to. This is a hostname or string IP address

    port        - the remote port to send it data to

    cSecTimeout - the ARP may take too long, after this many seconds it wil fail and return with 0 bytes sent.
                    It may be somehow possible for the UDP transmit to fail as well and this function will abort if
                    the timeout is exceeded.
 
  Returns:
    The actually number of bytes sent, this may be 0 if the ARP failed, or less than cbBuff if something went wrong.

  Remarks:
    If the ARP succeeds, the data will typically just be blasted on the wire as UDP is an unreliable protocol and will rarely fail to transmit

  ***************************************************************************/
WORD ChipKITUDPSendPacketURL(UDP_SOCKET hUDP, BYTE * rgbBuf, WORD cbBuff, const char * szURL, WORD port, unsigned int cSecTimeout)
{
	DWORD 	t = 0;
	IP_ADDR	ipAddr;


// This will add full URL support (like HTTP=>port 80, TCPIP does not do this, so I am not implementing it for UDP either.
// that is, the URL is really just a hostname
#if 0
	BYTE * 	szHostName[256];	// max allowed for a host name
	WORD	cbHostNameBuff = sizeof(szHostName);
	WORD	wPort = INVALID_UDP_PORT;

	// parse the URL
	if(ExtractURLFields((BYTE *) szURL, NULL, NULL, NULL, NULL, NULL, (BYTE *) szHostName, &cbHostNameBuff, &wPort, NULL, NULL) != 0 )
	{
		return(0);
	}	
 
	// see if we should get the port from the URL
	if(port == INVALID_UDP_PORT)
	{
		port = wPort;
	}
#endif

    // but we do support DNS lookup
	t = TickGet();
	while(!DNSBeginUsage())
	{
		ChipKITPeriodicTasks();

		if((TickGet() - t) >= (cSecTimeout * TICK_SECOND))
		{
			return(0);
		}
	}

	DNSResolve((BYTE *) szURL, DNS_TYPE_A);

	t = TickGet();
	while(!DNSIsResolved(&ipAddr))
	{
		ChipKITPeriodicTasks();

		if((TickGet() - t) >= (cSecTimeout * TICK_SECOND))
		{
			DNSEndUsage();
			return(0);
		}
	}

	// if we actually resolved the URL
	if(DNSEndUsage())
	{
		return(UDPSendPacket(hUDP, rgbBuf, cbBuff, ipAddr, port, cSecTimeout));
	}

	return(0);
}

/****************************************************************************
  Function:
   WORD ChipKITUDPSendPacketURL(UDP_SOCKET hUDP, BYTE * rgbBuf, WORD cbBuff, const char * szURL, WORD port, unsigned int cSecTimeout)

  Description:
    Implementes the Arduino UDP SendPacket function.
 
  Parameters:
    hUDP        - the UDP socket to use

    rgbBuf      - a pointer to a buffer of bytes to send

    cbBuff      - the number of bytes to send

    rgbIP       - 4 byte IP array of the remote IP to send to

    port        - the remote port to send it data to

    cSecTimeout - the ARP may take too long, after this many seconds it wil fail and return with 0 bytes sent.
                    It may be somehow possible for the UDP transmit to fail as well and this function will abort if
                    the timeout is exceeded.
 
  Returns:
    The actually number of bytes sent, this may be 0 if the ARP failed, or less than cbBuff if something went wrong.

  Remarks:
    If the ARP succeeds, the data will typically just be blasted on the wire as UDP is an unreliable protocol and will rarely fail to transmit

  ***************************************************************************/
WORD ChipKITUDPSendPacketIP(UDP_SOCKET hUDP, BYTE * rgbBuf, WORD cbBuff, BYTE * rgbIP, WORD port, unsigned int cSecTimeout)
{
	IP_ADDR ipAddr;

	// make sure compiler alignment is met for conversion from a byte array to an IP_ADDR.
	ipAddr.v[0] = rgbIP[0];
	ipAddr.v[1] = rgbIP[1];
	ipAddr.v[2] = rgbIP[2];
	ipAddr.v[3] = rgbIP[3];

	return(UDPSendPacket(hUDP, rgbBuf, cbBuff, ipAddr, port, cSecTimeout));
}

/****************************************************************************
  Function:
   int ChipKITUDPAvailable(UDP_SOCKET hUDP)

  Description:
    Returnes the number of available (unread) bytes in the UDP cache
 
  Parameters:
    hUDP        - the UDP socket to use
 
  Returns:
    The number of available byte to ready to read

  Remarks:

  ***************************************************************************/
int ChipKITUDPAvailable(UDP_SOCKET hUDP)					
{
	// run the tasks so we read into the buffer
    ChipKITPeriodicTasks();

	// return what we got.
    return(UDPAvailable(hUDP));
}

/****************************************************************************
  Function:
   int ChipKITUDPReadPacket(UDP_SOCKET hUDP, BYTE * rgbBuff, WORD cbBuff, NODE_INFO * pnodeInfo, WORD * pwPort)

  Description:
    reads the available bytes out of the UDP cache
 
  Parameters:
    hUDP        - the UDP socket to use

    rgbBuff - a pointer to a byte buffer to receive the bytes

    cbBuff  - the maximum size of the receive buffer

    pnodeInfo   - a pointer to a NODE_INFO structure with the remote IP and MAC address that the data came from

    pwPort  - a pointer to the a WORD to receive the remote port that the data came from
 
  Returns:
    The number of bytes actually read into the buffer. 0 if no bytes were available to read. The remote IP/MAC/Port is the last
    know remote endpoint that sent data and may not represent the endpoint for all of the data read as the data may have come in
    from several different endpoints; only the last endpoint is preserved. If 0 is returned the endpoint data is the last valid endpoint to
    send data to the socket. In general, if 0 is returned the endpoint data is considered useless.

  Remarks:

  ***************************************************************************/
int ChipKITUDPReadPacket(UDP_SOCKET hUDP, BYTE * rgbBuff, WORD cbBuff, NODE_INFO * pnodeInfo, WORD * pwPort)
{
	WORD cbAvailable = UDPAvailable(hUDP);
    WORD cbRead = UDPRead(hUDP, rgbBuff, cbBuff);
	UDPSB * pUDPSB = UDPGetUDPSB(hUDP);

    if(pnodeInfo != NULL)
    {
        if(pUDPSB != NULL)
        {                  
            *pnodeInfo = pUDPSB->remoteNodeInfo;
        }
        else
        {
            memset(pnodeInfo, 0, sizeof(NODE_INFO));
        }
    }

    if(pwPort != NULL)
    {
        if(pUDPSB != NULL)
        {                  
            *pwPort = pUDPSB->remotePort;
        }
        else
        {
            *pwPort = INVALID_UDP_PORT;
        }
    }

    ChipKITPeriodicTasks();

    if(cbRead == cbAvailable)
    {
        return(cbRead);
    }
    else
    {
        return(-1*cbAvailable);
    }
}

/****************************************************************************
  Function:
   void ChipKITUDPClose(UDP_SOCKET hUDP)

  Description:
    reads the available bytes out of the UDP cache
 
  Parameters:
    hUDP        - the UDP socket to clsoe

 
  Returns:
    None
  Remarks:
    The socket is closed and the resources returned to the UDP stack. Also the cache buffers are released and freed.

  ***************************************************************************/
void ChipKITUDPClose(UDP_SOCKET hUDP)
{
    if(UDPIsGetReady(hUDP) > 0)
    {
        UDPDiscard();
    }

    UDPClose(hUDP);

	// delete our cache buffer
	if(rgUDPSocketBuffers[hUDP] != NULL)
	{
		free(rgUDPSocketBuffers[hUDP]);
		rgUDPSocketBuffers[hUDP] = NULL;
	}
}


