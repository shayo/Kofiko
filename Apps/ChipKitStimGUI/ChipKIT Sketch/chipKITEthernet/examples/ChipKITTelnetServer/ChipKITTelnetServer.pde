#include <chipKITEthernet.h>

/*
  This sketch is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This sketch is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this sketch; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/
/************************************************************************/
/*  Revision History:							*/
/* 									*/
/* 8/08/2011 Digilent Inc. (KeithV)					*/
/* Updated for use with the chipKIT Max32 and chipKIT Network Shield	*/
/*									*/
/************************************************************************/

/*
 Chat  Server
 
 A simple server that distributes any incoming messages to all
 connected clients.  To use telnet to  your device's IP address and type.
 You can see the client's input in the serial monitor as well.
 Using an Arduino Wiznet Ethernet shield. 
 
 Circuit:
 * Ethernet shield attached to pins 10, 11, 12, 13
 * Analog inputs attached to pins A0 through A5 (optional)
 
 created 18 Dec 2009
 by David A. Mellis
 modified 10 August 2010
 by Tom Igoe
 
 */


// Enter a MAC address and IP address for your controller below. 
// A zero MAC address means that the chipKIT MAC is to be used
byte mac[] = {  
  0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };

//       !!MODIFY THIS!!
// The IP address will be dependent on your local network:
byte ip[] = { 
  192,168,1,190 };

byte gateway[] = { 192,168,1, 1 };
byte subnet[] = { 255, 255, 0, 0 };

// telnet defaults to port 23
Server server(23);
boolean gotAMessage = false; // whether or not you got a message from the client yet

void setup() {
  // initialize the ethernet device
//  Ethernet.begin(mac, ip, gateway, subnet);
  Ethernet.begin(mac,ip);
  // start listening for clients
  server.begin();
  // open the serial port
  Serial.begin(9600);
}

void loop() {
  // wait for a new client:
  Client client = server.available();
  
  // when the client sends the first byte, say hello:
  if (client) {
    if (!gotAMessage) {
      Serial.println("We have a new client");
      client.println("Hello, client!"); 
      gotAMessage = true;
    }
    
    // read the bytes incoming from the client:
    char thisChar = client.read();
    // echo the bytes back to the client:
    server.write(thisChar);
    // echo the bytes to the server as well:
    Serial.print(thisChar);
  }
}
