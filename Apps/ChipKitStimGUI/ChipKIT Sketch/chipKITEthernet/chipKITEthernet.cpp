/************************************************************************/
/*																		*/
/*	chipKITEthernet.cpp	-- Ethernet interface APIs to implement the */
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

/***	void begin()
**
**	Synopsis:   This will initialize the TCPIP Static.
**              DHCP will be used to obtain the IP address, subnet, gateway, and DNS servers.
**              The MAC address of the Max32 MCU as assigned by Microchip will be used.
**              It MAC address will be in the range of 00:04:A3:XX:XX:XX
**              This is a Digilent extension to the Arduino Ethernet Class.
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
**      Refer to the Arduino documentation http://arduino.cc/en/Reference/EthernetBegin 
*/
void ChipKITEthernetClass::begin()
{
  uint8_t mac[6];
  
  // if zero is specifed as the MAC address then the 
  // MAC address of the Max32 MCU as specifed by Microchip is used
  mac[0] = 0;
  mac[1] = 0;
  mac[2] = 0;
  mac[3] = 0;
  mac[4] = 0;
  mac[5] = 0;
  
  begin(mac);
}

/***	void begin(uint8_t *mac)
**
**	Synopsis:  This will initialize the TCPIP Static.
**              DHCP will be used to obtain the IP address, subnet, gateway, and DNS servers.
**              The specified MAC address will be used.
**              This is a Digilent extension to the Arduino Ethernet Class.
**
**	Parameters:
**      mac - pointer to the 6 byte MAC address to use
**
**	Return Values:
**      None
**
**	Errors:
**
**	Description:
**      Refer to the Arduino documentation http://arduino.cc/en/Reference/EthernetBegin 
*/
void ChipKITEthernetClass::begin(uint8_t *mac)
{
    uint8_t ip[] = {0,0,0,0};   // zero IP will cause DHCP to be used

    begin(mac, ip);
}

/***	void begin(uint8_t *mac, uint8_t *ip)
**
**	Synopsis: This will initialize the TCPIP Static.
**
**	Parameters:
**      mac     - pointer to the 6 byte MAC address to use.
**      ip      - pointer to the 4 byte static IP address to use
**
**  Default Parameters
**
**      gateway - same as the IP address with the last byte being 1 IP[0].IP[1].IP[2].1
**      subnet  - 255.255.255.0
**      dns1    - same as gateway as many routers/gateways will act as a DNS forwarder (Digilent extension)
**      dns2    - 0.0.0.0 (Digilent extension)
**
**	Return Values:
**      None
**
**	Errors:
**
**	Description:
**      Refer to the Arduino documentation http://arduino.cc/en/Reference/EthernetBegin 
*/
void ChipKITEthernetClass::begin(uint8_t *mac, uint8_t *ip)
{
  uint8_t gateway[4];
  
  // by default the gateway is the IP with the LSB set to 1. ip[0].ip[1].ip[2].1
  // but if the IP is zero, DHCP will be used overriding this value.
  gateway[0] = ip[0];
  gateway[1] = ip[1];
  gateway[2] = ip[2];
  gateway[3] = 1;
  
  begin(mac, ip, gateway);
}

/***	void begin(uint8_t *mac, uint8_t *ip, uint8_t *gateway)
**
**	Synopsis: This will initialize the TCPIP Static.
**
**	Parameters:
**      mac     - pointer to the 6 byte MAC address to use.
**      ip      - pointer to the 4 byte static IP address to use
**      gateway - pointer to the 4 byte gateway IP address to use
**
**  Default Parameters
**
**      subnet  - 255.255.255.0
**      dns1    - same as gateway as many routers/gateways will act as a DNS forwarder (Digilent extension)
**      dns2    - 0.0.0.0 (Digilent extension)
**
**	Return Values:
**      None
**
**	Errors:
**
**	Description:
**      Refer to the Arduino documentation http://arduino.cc/en/Reference/EthernetBegin 
*/
void ChipKITEthernetClass::begin(uint8_t *mac, uint8_t *ip, uint8_t *gateway)
{
  uint8_t subnet[] = { 
    255, 255, 255, 0   };
    
   // default value of the subnet is 255.255.255.0 is used
   // unless the IP is zero and DHCP will override this.   
  begin(mac, ip, gateway, subnet);
}

/***	void begin(uint8_t *mac, uint8_t *ip, uint8_t *gateway, uint8_t *subnet)
**
**	Synopsis: This will initialize the TCPIP Static.
**
**	Parameters:
**      mac     - pointer to the 6 byte MAC address to use
**      ip      - pointer to the 4 byte static IP address to use
**      gateway - pointer to the 4 byte gateway IP address to use
**      subnet  - pointer to the 4 byte subnet mask to use
**
**  Default Parameters
**
**      dns1    - same as gateway as many routers/gateways will act as a DNS forwarder (Digilent extension)
**      dns2    - 0.0.0.0 (Digilent extension)
**
**	Return Values:
**      None
**
**	Errors:
**
**	Description:
**      Refer to the Arduino documentation http://arduino.cc/en/Reference/EthernetBegin 
*/
void ChipKITEthernetClass::begin(uint8_t *mac, uint8_t *ip, uint8_t *gateway, uint8_t *subnet)
{
    uint8_t dns[4];

    // often a router/gateway will work as a DNS server, so if no DNS server
    // is specifed, then apply the gateway
    memcpy(dns, gateway, 4);

    begin(mac, ip, gateway, subnet, dns);
}

/***	void begin(uint8_t *mac, uint8_t *ip, uint8_t *gateway, uint8_t *subnet, uint8_t *dns1)
**
**	Synopsis:   This will initialize the TCPIP Static.
**              This is a Digilent extension to the Arduino Ethernet Class.
**
**	Parameters:
**      mac     - pointer to the 6 byte MAC address to use
**      ip      - pointer to the 4 byte static IP address to use
**      gateway - pointer to the 4 byte gateway IP address to use
**      subnet  - pointer to the 4 byte subnet mask to use
**      dns1    - pointer to the 4 byte primary DNS server to use
**
**  Default Parameters
**
**      dns2    - 0.0.0.0 (Digilent extension)
**
**	Return Values:
**      None
**
**	Errors:
**
**	Description:
**      Refer to the Arduino documentation http://arduino.cc/en/Reference/EthernetBegin 
*/
void ChipKITEthernetClass::begin(uint8_t *mac, uint8_t *ip, uint8_t *gateway, uint8_t *subnet, uint8_t *dns1)
{
    uint8_t dns[] = {0,0,0,0};      // probably already set a DNS server in dns1

    begin(mac, ip, gateway, subnet, dns1, dns);
}

/***	void begin(uint8_t *mac, uint8_t *ip, uint8_t *gateway, uint8_t *subnet, uint8_t *dns1, uint8_t *dns2)
**
**	Synopsis:   This will initialize the TCPIP Static.
**              This is a Digilent extension to the Arduino Ethernet Class.
**
**	Parameters:
**      mac     - pointer to the 6 byte MAC address to use
**      ip      - pointer to the 4 byte static IP address to use
**      gateway - pointer to the 4 byte gateway IP address to use
**      subnet  - pointer to the 4 byte subnet mask to use
**      dns1    - pointer to the 4 byte primary DNS server to use
**      dns2    - pointer to the 4 byte secondary DNS server to use
**
**	Return Values:
**      None
**
**	Errors:
**
**	Description:
**      Refer to the Arduino documentation http://arduino.cc/en/Reference/EthernetBegin 
*/
void ChipKITEthernetClass::begin(uint8_t *mac, uint8_t *ip, uint8_t *gateway, uint8_t *subnet, uint8_t *dns1, uint8_t *dns2)
{
  
  ChipKITEthernetBegin(mac, ip, gateway, subnet, dns1, dns2);
}

/***	void  PeriodicTasks()
**
**	Synopsis:   The Microchip Application Library requires that the TCPIP Stack be called
**              on a periodic basis to keep the stack alive. As long as Ethernet methods are being called
**              the underlying code will implicitly make this call to keep the stack alive. 
**              However, should the sketch stop doing Ethernet activity, this method should be called
**              once through the loop to keep the stack alive and to service such services such as
**              the Ping service. While not calling this method will not break anything, the TCPIP stack
**              will freeze until these calls are made. It is possible to lose a connection if this method
**              is not called frequently enough.
**
**              This is a Digilent extension to the Arduino Ethernet Class.
**
**	Parameters:
**      None
**
**	Return Values:
**      None
**
**	Errors:
*/
void  ChipKITEthernetClass::PeriodicTasks()
{
    ChipKITPeriodicTasks();
}


/***	unsigned int ChipKITEthernetClass::SecondsSinceEpoch(void)
**
**	Synopsis:   
**
**
**
**              This is a Digilent extension to the Arduino Ethernet Class.
**
**	Parameters:
**      None
**
**	Return Values:
**      The number since Jan 1 1970; or epoch
**
**	Errors:
*/
unsigned int ChipKITEthernetClass::SecondsSinceEpoch(void)
{
    return(SNTPGetUTCSeconds());
}

// construct the Ethernet class
ChipKITEthernetClass Ethernet;
