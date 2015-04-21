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
  Web client
 
 This sketch connects to a website (http://www.google.com)
 using an Arduino Wiznet Ethernet shield. 
 
 */

// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = {  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 192,168,10,210 };
byte gateway[] = { 192,168,1,129 };
byte subnet[] = { 255,255,255,192 };
byte dns1[] = {0,0,0,0};
byte dns2[] = {24,113,32,29};

//byte server[] = { 173,194,33,104 }; // Google
const char * szGoogle = "www.google.com";
// const char * szGoogle = "74.125.53.106";

// Initialize the Ethernet client library
// with the IP address and port of the server 
// that you want to connect to (port 80 is default for HTTP):
Client client(szGoogle, 80);

void setup() {
  // start the Ethernet connection:

  Ethernet.begin();                                   // DHCP is used, default ENCX24J600 (ENC24J60) MAC address 
//  Ethernet.begin(mac);                                // DHCP is used
//  Ethernet.begin(mac, ip);                            // Static IP, gateway equal to the IP with the last byte set to 1 => IP[3].IP[2].IP[1].1
//  Ethernet.begin(mac, ip, gateway);                   // default subnet 255.255.255.0
//  Ethernet.begin(mac, ip, gateway, subnet);           // default dns1 is equal to gateway, some router/gateways act as DNS servers
//  Ethernet.begin(mac, ip, gateway, subnet, dns1);     // default dns2 is 0.0.0.0
//  Ethernet.begin(mac, ip, gateway, subnet, dns1, dns2);

  // start the serial library:
  // PLEASE NOTE THE SERIAL MODEM SPEED!
  // the speed is not the typical 9600; this is because
  // the serial monitor can not keep up with the page update
  // and will drop characters, the serial monitor must run faster
  // When you open the serial monitor, go to the bottom right and select 11500 as the speed
  Serial.begin(115200);
  
  // give the Ethernet shield a second to initialize:
  delay(1000);
  Serial.println("connecting...");

  // if you get a connection, report back via serial:
  if (client.connect()) {
    Serial.println("connected");
    // Make a HTTP request:
    client.println("GET /search?q=arduino HTTP/1.0");
    client.println();
  } 
  else {
    // kf you didn't get a connection to the server:
    Serial.println("connection failed");
  }
}

void loop()
{
  // if there are incoming bytes available 
  // from the server, read them and print them:
  if (client.available()) {
    char c = client.read();
    Serial.print(c);
  }

  // if the server's disconnected, stop the client:
  if (!client.connected()) {
    Serial.println();
    Serial.println("disconnecting.");
    client.stop();

    // do nothing forevermore:
    for(;;)
      Ethernet.PeriodicTasks();
  }
}



