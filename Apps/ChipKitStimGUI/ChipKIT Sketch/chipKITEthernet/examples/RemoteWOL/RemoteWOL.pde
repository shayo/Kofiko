#include <chipKITEthernet.h>

/************************************************************************/
/*									*/
/*	RemoteWOL                                                       */
/*									*/
/*	A chipKIT Max32 / Network Shield Server implementation	        */
/*	to broadcast a Wake-On-LAN MAC datagram to wake sleeping	*/
/*	computers.						        */
/*	This sketch is designed to work with the RemoteWOL		*/
/*	Windows application supplied in the examples directory		*/
/*									*/
/************************************************************************/
/*	Author: 	Keith Vogel 					*/
/*	Copyright 2011, Digilent Inc.					*/
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
/*									*/
/*	This library is explicity targeting the chipKIT Max32 		*/
/*	PIC32MX795F512L MCU using the internal MAC along with the 	*/
/*      chipKIT Network Shield using the physical SMSC8720 driver       */
/*									*/
/*  RemoteWOL Description: 						*/
/*									*/
/*	An issue with Wake-On-LAN is that most routers and gateways     */
/*	block broadcast messages and it is difficult or impossible	*/
/*	to remotely wake up a sleeping computer outside of your subnet	*/
/*	as the WOL broadcast message will not make it though the router.*/
/*									*/
/*	If this application is running on the subnet where	        */
/*	other computers are sleeping and you would like to remotely	*/
/*	wake them up, so for example, so you can remote desktop to them.*/
/*	This application can listen on a port for a TCIP request to send*/
/*	a WOL broadcast message and wake the sleeping computer.		*/
/*									*/
/*	RemoteWOL will wait and listen on the specified port		*/
/*	and when a MAC address is sent to it, it will re-broadcast	*/
/*	that MAC as a WOL Magic Packet on the local subnet to wake up	*/
/*	the sleeping computer. The network card on the sleeping computer*/
/*	must be configured for Magic Packet Wake-up for this to work;   */
/*	see your computer documentation or search online for Wake-On-LAN*/
/*	To get to your local network, your router will probably need    */
/*	to port forward the servers port to the machine you are running */
/*	the RemoteWol Server	                                        */
/*									*/
/*	This sketch is designed to work with the RemoteWOL		*/
/*	Windows application supplied in the examples directory		*/
/*									*/
/*									*/
/************************************************************************/
/*  Revision History:							*/
/*									*/
/*	8/30/2011(KeithV): Created					*/
/*									*/
/************************************************************************/

typedef enum
{
  LISTENING,
  CHECKING,
  DISPLAYTIME,
  VERIFYPACKET,
  BROADCAST,
  ECHO,
  STOPCLIENT,
} STATE;

// A UDP instance to let us send and receive packets over UDP
UDP Udp;
Server TCPListen(9040);
STATE state = LISTENING;

byte rgbUDPBroadCastIP[4] = {0xFF, 0xFF, 0xFF, 0xFF};
word wBroadCastPort = 0xFF; 

byte rgbMAC[6];
Client clientCur;

// Enter a MAC address and IP address for your controller below. 
// A zero MAC address means that the chipKIT MAC is to be used
byte mac[] = {  
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };

//       !!MODIFY THIS!!
// The IP address will be dependent on your local network:
byte ip[] = { 
  192,168,1,190 };
  
byte gateway[] = { 
  192,168,1,1 };

byte subnet[] = { 
 255,255,255,0 };

// google public DNS 1
byte dns1[] = { 
  8,8,8,8 };

// google public DNS 2
byte dns2[] = { 
  8,8,4,4 };
// GET THEM RIGHT OR use DHCP, --- or try Ethernet.begin() instead and lookup your IP

/***	void setup()
 *
 *	Parameters:
 *          None
 *              
 *	Return Values:
 *          None
 *
 *	Description: 
 *	
 *      Arduino setup function.
 *      
 *      Initialize the Serial Monitor, TCPIP and UDP Ethernet Stack
 *      
 *      Use DHCP to get the IP, mask, and gateway
 *      Listening on port 9040
 *      
 * ------------------------------------------------------------ */
void setup() 
{
  // we must specify an DNS server if we expect to find a time server
  // otherwise Ethernet.SecondsSinceEpoch() will return junk
  Ethernet.begin(mac, ip, gateway, subnet, dns1, dns2);
  
  Udp.begin(0);  // let it select whatever port it wants
  TCPListen.begin();
  
  Serial.begin(9600);  
  Serial.println("Start of RemoteWOL 1.0");
  Serial.println(" ");
}

/***	void loop()
 *
 *	Parameters:
 *          None
 *              
 *	Return Values:
 *          None
 *
 *	Description: 
 *	
 *      Arduino loop function.
 *      
 *      This illistrates how to write a state machine like loop
 *      so that the PeriodicTask is called everytime through the loop
 *      so the stack stay alive and responsive.
 *
 *      In the loop we listen for a request, verify it so a limited degree
 *      and then broadcast the Magic Packet to wake the request machine.
 *      
 * ------------------------------------------------------------ */
void loop()
{
  Client client;

  switch(state)
  {         
    case LISTENING:
       Serial.println("Listening");
       state = CHECKING;
       break;

    case CHECKING:   
      // we waiting to read something.   
      if((client = TCPListen.available()))
      {       
        clientCur = client;
        state = DISPLAYTIME;
      }
      break;
      
    case DISPLAYTIME:       
      PrintDayAndTime();
      state = VERIFYPACKET;   
      break;
 
    case VERIFYPACKET:
      if((clientCur.available() == sizeof(rgbMAC)) && (clientCur.read(rgbMAC, sizeof(rgbMAC)) == sizeof(rgbMAC))) 
      {
        PrintMAC();
        state = BROADCAST;
      }
      
      // this is not one for us, just kill it
      else 
      {
        Serial.println("Invalid Request Attempt");
        state = STOPCLIENT;
      }
      break;
      
    case BROADCAST:
      BroadCast();
      state = ECHO;             
      break;
    
    case ECHO:      
      clientCur.write(rgbMAC, sizeof(rgbMAC));       
      state = STOPCLIENT;             
      break;
      
    case STOPCLIENT:   
      clientCur.stop();
      state = LISTENING;
      Serial.println(" ");
      break;
      
    default:
      break;
  }
  
  // Keep the Ethernet stack alive
  Ethernet.PeriodicTasks();
}

/***	void BroadCast(void)
 *
 *	Parameters:
 *          None
 *              
 *	Return Values:
 *          None
 *
 *	Description: 
 *	
 *      This builds the Magic Packet with the requested MAC
 *      address and then broadcasts the Magic Packet over 
 *      the local subnet.
 * ------------------------------------------------------------ */
void BroadCast(void)
{
  byte rgbDataGram[102];
  int i, j, k;
  
  // first there must be 6 bytes of 0xFF;
  for (i = 0; i < 6; i++) rgbDataGram[i] = 0xFF;

  // then 16 MAC 
  for (int j = 0; j < 16; j++)
  {
      for (int k = 0; k < 6; k++, i++) rgbDataGram[i] = rgbMAC[k];
  }
  
  // now Broadcast the MAC
  i = Udp.sendPacket(rgbDataGram, sizeof(rgbDataGram), rgbUDPBroadCastIP, wBroadCastPort); 
  
  if(i == sizeof(rgbDataGram))
  {
    Serial.println("WOL BroadCast Succeeded");
  }
  else
  {
    Serial.println("WOL BroadCast Failed");
  }
}

/***	void PrintMAC(void)
 *
 *	Parameters:
 *          None
 *              
 *	Return Values:
 *          None
 *
 *	Description: 
 *	
 *      A simple routine to print the MAC address out
 *      on the serial monitor.
 * ------------------------------------------------------------ */
void PrintMAC(void)
{
  int i = 0;
  
  Serial.print("Request to Wake MAC: ");
  
  for(i = 0; i < 5; i++)
  {
    if(rgbMAC[i] < 0x10)
    {
      Serial.print("0");
    }
    
    Serial.print(rgbMAC[i], HEX);
    Serial.print(":");
  }
  
  if(rgbMAC[5] < 0x10)
    {
      Serial.print("0");
    }
    Serial.println(rgbMAC[5], HEX);  
}

/***	void PrintDayAndTime()
 *
 *	Parameters:
 *          None
 *              
 *	Return Values:
 *          None
 *
 *	Description: 
 *	
 *      This illistrates how to use the Ethernet.SecondsSinceEpoch()
 *      method to get the current time and display it.
 * ------------------------------------------------------------ */
void PrintDayAndTime(void)
{
    // Epoch is 1/1/1970; I guess that is when computers became real?
    // There are 365 days/year, every 4 years is leap year, every 100 years skip leap year. Every 400 years, do not skip the leap year. 2000 did not skip the leap year
    static const unsigned int secPerMin = 60;
    static const unsigned int secPerHour = 60 * secPerMin;
    static const unsigned int secPerDay  = 24 * secPerHour;
    static const unsigned int secPerYear = 365 * secPerDay;
    static const unsigned int secPerLeapYearGroup = 4 * secPerYear + secPerDay;
    static const unsigned int secPerCentury = 25 * secPerLeapYearGroup - secPerDay;
    static const unsigned int secPer400Years = 4 * secPerCentury + secPerDay;;
    static const int daysPerMonth[] = {31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31, 29}; // Feb has 29, we must allow for leap year.
    static const char * szMonths[] = {"Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan", "Feb"}; 
    
    // go ahead and adjust to a leap year, and to a century boundary
    // at Mar 2000 we have 30 years (From 1970) + 8 leap days (72,76,80,84,88,92,96, and Feb 2000 do not skip leap year) and Jan (31) + Feb(28)
    unsigned int secSinceMar2000 = Ethernet.SecondsSinceEpoch() - 30 * secPerYear - (8 + 31 + 28) * secPerDay;
 
    unsigned int nbr400YearGroupsFromMar2000 = secSinceMar2000 / secPer400Years;
    unsigned int secInThis400YearGroups = secSinceMar2000 % secPer400Years;
    
    // now we are aligned so the weirdness for the not skiping of a leap year is the very last day of the 400 year group.
    // because of this extra day in the 400 year group, it is possible to have 4 centries and a day.
    unsigned int nbrCenturiesInThis400YearGroup = secInThis400YearGroups / secPerCentury;
    unsigned int secInThisCentury = secInThis400YearGroups % secPerCentury;

    // if we come up with 4 centries, then we must be on leap day that we don't skip at the end of the 400 year group
    // so add the century back on as this  Century is the extra day in this century.
    if(nbrCenturiesInThis400YearGroup == 4)
    {
        nbrCenturiesInThis400YearGroup = 3;   // This can be a max of 3 years
        secInThisCentury += secPerCentury;    // go ahead and add the century back on to our time in this century
    }

    // This is going to work out just fine
    // either this is a normal century and the last leap year group is going to be a day short,
    // or this is at the end of the 400 year group and the last 4 year leap year group will work out to have 29 days as in a normal
    // 4 year leap year group.  
    unsigned int nbrLeapYearGroupsInThisCentury = secInThisCentury / secPerLeapYearGroup;
    unsigned int secInThisLeapYearGroup = secInThisCentury % secPerLeapYearGroup;
 
    // if this is at the end of the leap year group, there could be an extra day
    // which could cause us to come up with 4 years in this leap year group.
    unsigned int nbrYearsInThisLeapYearGroup = secInThisLeapYearGroup / secPerYear;
    unsigned int secInThisYear = secInThisLeapYearGroup % secPerYear;

    // are we on a leap day?
    if(nbrYearsInThisLeapYearGroup == 4)
    {
        nbrYearsInThisLeapYearGroup = 3;    // that is the max it can be.
        secInThisYear += secPerYear;        // add back the year we just took off the leap year group
    }
  
    int nbrOfDaysInThisYear = (int) (secInThisYear / secPerDay); // who cares if there is an extra day for leap year
    int secInThisDay = (int) (secInThisYear % secPerDay);
 
    int nbrOfHoursInThisDay = secInThisDay / secPerHour;
    int secInThisHours = secInThisDay % secPerHour;
 
    int nbrMinInThisHour = secInThisHours / secPerMin;
    int secInThisMin = secInThisHours % secPerMin;
    
    int monthCur = 0;
    int dayCur = nbrOfDaysInThisYear;
    int yearCur = 2000 + 400 * nbr400YearGroupsFromMar2000 + 100 * nbrCenturiesInThis400YearGroup + 4 * nbrLeapYearGroupsInThisCentury + nbrYearsInThisLeapYearGroup;
  
    // this will walk us past the current month as the dayCur can go negative.
    // we made the leap day the very last day in array, so if this is leap year, we will be able to
    // handle the 29th day.
    for(monthCur = 0, dayCur = nbrOfDaysInThisYear; dayCur >= 0; monthCur++)
    {
      dayCur -= daysPerMonth[monthCur];
    }
     
    // since we know we went past, we can back up a month
    monthCur--;
    dayCur += daysPerMonth[monthCur]; // put the last months days back to go positive on days
     
    // We did zero based days in a month, but we read 1 based days in a month.
    dayCur++;

    // we have one remaining issue
    // if this is Jan or Feb, we are really into the next year. Remember we started our year in Mar, not Jan
    // so if this is Jan or Feb, then add a year to the year
    if(monthCur >= 10)
    {
        yearCur++;
    }
     
    Serial.print("Current Day and UTC time: ");
    Serial.print(szMonths[monthCur]);
    Serial.print(" ");
    Serial.print(dayCur, DEC);
    Serial.print(", ");
    Serial.print(yearCur, DEC);
    Serial.print("  ");
    Serial.print(nbrOfHoursInThisDay, DEC);
    Serial.print(":");
    if(nbrMinInThisHour < 10)
    {
        Serial.print("0");
    }
    Serial.print(nbrMinInThisHour, DEC);
    Serial.print(":");
    if(secInThisMin < 10)
    {
        Serial.print("0");
    }
    Serial.println(secInThisMin, DEC);  
 }








