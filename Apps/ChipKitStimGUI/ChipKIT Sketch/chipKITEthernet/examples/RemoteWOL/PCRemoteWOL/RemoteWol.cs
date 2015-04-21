/************************************************************************/
/*																		*/
/*	RemoteWol	Sends, receives or broadcast a Magic Packet             */
/*                  on a local subnet to wake the sleeping              */
/*					computer with the specified MAC address	            */
/*																		*/
/************************************************************************/
/*	Author: 	Keith Vogel 											*/
/*	Copyright 2011  									                */
/************************************************************************/
/*
  This source is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This source is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  To get a copy of the GNU Lesser General Public
  License write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/
/************************************************************************/
/*  Module Description: 												*/
/*																		*/
/*	An issue with Wake-On-LAN is that most routers and gateways			*/
/*	block broadcast messages and it is difficult or impossible			*/
/*	to remotely wake up a sleeping computer outside of your subnet		*/
/*	as the WOL broadcast message will not make it though the router.	*/
/*																		*/
/*	If there is a server always running on the local subnet where		*/
/*	other computers are sleeping and you would like to remotely	        */
/*	wake them up, so for example, so you can remote desktop into them. 	*/
/*	This application can listen on a port for a TCIP request to send	*/
/*	a WOL broadcast message and wake the sleeping computer.				*/
/*																		*/
/*	It may seem odd to provide a solution to get to a sleeping computer */
/*  that requires another computer to alwasy be running. However,		*/
/*	if you have a WEB, FTP or other server running that has limited		*/
/*	functionality and is well protected from threats and you would like */
/*	your personal computer to usually be sleeping and off the network, 	*/
/*	this program allows for waking up the personal computer only 	    */
/*	when needed.														*/
/*																		*/
/*	This program acts as 3 compoents, a WOL server, a WOL client, or	*/
/*	an immediate Magic Packet Broadcast application.					*/
/*																		*/
/*	As a server it will wait and listen on the specified port		    */
/*	and when a MAC address is sent to it, it will re-broadcast			*/
/*	that MAC as a WOL Magic Packet on the local subnet to wake up		*/
/*	the sleeping computer. The network card on the sleeping computer	*/
/*	must be configured for Magic Packet Wake-up for this to work; see   */
/*	your computer documentation or search online for Wake-On-LAN.		*/
/*	To get to your local network, your router will probably need        */
/*	to port forward the servers port to the machine you are running	    */
/*	the RemoteWol Server			                                    */
/*																		*/
/*	As a client, RemoteWol will send to the IP and port of              */
/*	a the listening RemoteWOL server, the MAC address that the server   */
/*	should broadcast the WOL packet. That is, the MAC address of the    */
/*	machine you want to wake up.										*/
/*																		*/
/*	As an appliation, RemoteWol will immediately broadcast on its		*/
/*	local network the WOL Magic Packet without connecting to a 			*/
/*	RemoteWol server.													*/
/*																		*/
/*	Because it might be undesirable to run a machine on a local network	*/
/*	exclusively to run the RemoteWol server, as part of the 			*/
/*	chipKIT(tm) Arduino complient MAX32 and Network Sheild examples,	*/
/*	there is an example sketch that implements the server RemoteWol		*/
/*	application, and the client RemoteWol can trigger the MAX32			*/
/*	to issue the local WOL Magic Packet, thus eliminating the need		*/
/*	to run a computer continously on the local network. 				*/
/*																		*/
/************************************************************************/
/*  Revision History:													*/
/*																		*/
/*	5/20/2011(KeithV): Created											*/
/*	8/30/2011(KeithV): Modified to work with the MAX32 / Network Shield	*/
/*																		*/
/************************************************************************/

// uncomment this is you want to support remote termination of the WOL Server
// #define QUIT

using System;
using System.Collections.Generic;
using System.Text;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Diagnostics;
using System.Net.NetworkInformation;

namespace RemoteWol
{
    class RemoteWol
    {

        // these are debug constants to help while debugging.
        const bool fRunServerAndClient = false;          // normal operations, should be false
        const bool fDoNotRunServerOrClient = false;      // normal operations, should be false

        const int cbMACAddress = 6;    // length of a MAC address
        byte[] rgTerm = { 0xFF, 0xFF, 0xFF, 0xFF };

        /***	void Main(string[] args)
         *
         *	Parameters:
         *	
         *      args - command line strings
         *              
         *
         *	Return Values:
         *      None
         *
         *	Errors:
         *
         *
         *	Description: 
         *	
         *      Main entrypoint to the program.
         *      
         *      if only a port number, it is assumed to be a server side (listening) code
         *      if only a MAC, then it is an immediate broadcast of the Magic Packet.
         *      Otherwise as a client an IP address, Port number, and MAC value is expected.
         *      See help screen info below.
         * ------------------------------------------------------------ */
        static void Main(string[] args)
        {
            IPINFO ipInfo = new IPINFO();
            bool fServer = false;
            bool fClient = false;
            bool fBroadCast = false;
            bool fQuit = false;

            RemoteWol remoteWol = new RemoteWol();
            Thread thrdListen = new Thread(remoteWol.ListenForWOLRequest);

            Console.WriteLine("RemoteWol Version {0}", typeof(RemoteWol).Assembly.GetName().Version.ToString());
            Console.WriteLine("Keith Vogel, Copywrite 2011");
            Console.WriteLine("");
 
            // if we only have only 1 parameter, then we have either a port number and we are server
            // or we have a MAC and we are to send a Magic Packet broadcast to the MAC
            if (args.Length == 1)
            {
                // if this is a Mac Address, a valid port number would never be 6 bytes long.
                if (args[0].Length == 12 || args[0].Length == 17)
                {
                    fBroadCast = remoteWol.GetMac(args[0], ipInfo); ;
                }
                else
                {
                    fServer = remoteWol.GetPort(args[0], ipInfo);
                }
            }

#if QUIT
            // else if we have IP and Port but no MAC, this means to terminate the server side.
            else if (args.Length == 2)
            {
                // Get the IP
                if (remoteWol.GetIPAddress(args[0], ipInfo))
                {
                    // now get the port
                    fQuit = remoteWol.GetPort(args[1], ipInfo);
                }
            }
#endif
            // else if we have IP, Port, and MAC, we are sending a WOL request
            else if (args.Length == 3)
            {
                // Get the IP
                if (remoteWol.GetIPAddress(args[0], ipInfo))
                {
                    // now get the port
                    if (remoteWol.GetPort(args[1], ipInfo))
                    {
                        // and finally get the MAC
                        fClient = remoteWol.GetMac(args[2], ipInfo);

                        // if we want both server and client to run.
                        fServer = (fRunServerAndClient && fClient);
                    }
                }
            }

            // if we are to run the server
            if (fServer)
            {
                // this starts a thread and will return immediately
                thrdListen.Start(ipInfo);

                // this is so we don't start the client too fast if the client is to be started as well.
                Thread.Sleep(5000); // give it sometime to start the server
            }

            // if we are to run the client
            if (fClient || fQuit)
            {
                remoteWol.SenderWOLRequest(ipInfo);
            }

            // if we are to broadcast the Magic Packet
            if (fBroadCast)
            {
                if (remoteWol.BroadCast(ipInfo.mac))
                {
                    Console.WriteLine("Magic Packet Sent");
                }
                else
                {
                    Console.WriteLine("Unable to send Magic Packet");
                }
            }

            // This is the Help Screen Info
            // if we are to do nothing, print help.
            if (!fServer && !fClient && !fBroadCast && !fQuit)
            {
                Console.WriteLine("Server:\t\tRemoteWol Port");
                Console.WriteLine("Client:\t\tRemoteWol ServerURL Port MAC");
                Console.WriteLine("WOL Broadcast:\tRemoteWol MAC");
#if QUIT
                Console.WriteLine("Quit Server:\tRemoteWol ServerURL Port");
#endif
                Console.WriteLine("");
                Console.WriteLine("Where:");
                Console.WriteLine("");
                Console.WriteLine("    ServerURL:\tis the IP/DNS Name of the server to transmit the WOL.");
                Console.WriteLine("    Port:\tis the decimal port number the server is listening on.");
                Console.WriteLine("    MAC:\tis the 12 hex character MAC Address of the machine to wake up,");
                Console.WriteLine("    \t\t    colons \":\" and dashes \"-\" are allowed between hex bytes.");
                Console.WriteLine("");
                Console.WriteLine("Example:");
                Console.WriteLine("");
                Console.WriteLine("    RemoteWol mynetwork.com 2000 65:24:EF:04:23:FC");

                return;
            }       
        }

        /***	SenderWOLRequest(IPINFO ipInfo)
         * 
         *	Parameters:
         *               
         *      ipInfo  - The global class containing all of the IP like info about the
         *                this machine we are running on; and the server we want to contact.
         * 
         *	Return Values:
         *      None
         *          
         *	Errors:
         *
         *
         *	Description: 
         *
         *      This is the start of the client side RemoteWol code.
         * ------------------------------------------------------------ */
        private void SenderWOLRequest(IPINFO ipInfo)
        {
            TcpClient tcpClient = new TcpClient();
            IPAddress ipAddrTarget = new IPAddress(ipInfo.ip4);
            IPEndPoint ipEndPoint = new IPEndPoint(ipAddrTarget, ipInfo.port);
            NetworkStream targetStrm = null;
            bool fFoundMac = false;
            byte[] rgRcv = new byte[1024];
            int cbRead = 0;

            try
            {

                // connect to the server; there is some default timeout, it does break out if it can not connect.
                tcpClient.Connect(ipEndPoint);
                targetStrm = tcpClient.GetStream();


                // send the MAC
                if (ipInfo.mac != null)
                { 
                    Debug.Assert(ipInfo.mac.Length == 6);

                    try
                    {
                        
                        // write out the MAC address
                        targetStrm.WriteTimeout = 30000;    // set to 30 seconds for the write
                        targetStrm.Write(ipInfo.mac, 0, ipInfo.mac.Length);

                        // now the MAC and only the MAC should come back
                        targetStrm.ReadTimeout = 30000;     // set to 30 seconds for the read
                        cbRead = targetStrm.Read(rgRcv, 0, rgRcv.Length);
                    }

                    // just want to catch errors and get out.
                    // this could be caused by the timeout
                    catch (Exception e)
                    {
                        Console.WriteLine(e.ToString());
                    }

                    // See what we got back, it should only be the MAC we sent
                    // This is not intended to be secure, it is only a sanity check
                    // so that we know we probably sent it to a RemoteWOL server
                    // instead of some random server that sent us goo back.

                    if ((fFoundMac = (cbRead == ipInfo.mac.Length)))
                    {
                        for(int i = 0; i < ipInfo.mac.Length; i++)
                        {
                            fFoundMac = fFoundMac  && rgRcv[i] == ipInfo.mac[i];
                        }
                    }

                    if (fFoundMac)
                    {
                        Console.WriteLine("Magic Packet Sent");
                    }
                    else
                    {
                        Console.WriteLine("Unable to send Magic Packet");
                    }

                }

#if QUIT
                // send the exit code
                // this only make sense if we are supporting remote exit.
                else
                {
                    targetStrm.Write(rgTerm, 0, rgTerm.Length);
                    cbRead = targetStrm.Read(rgRcv, 0, rgRcv.Length);
                    if (cbRead == rgTerm.Length)
                    {
                        Console.WriteLine("Server terminated");
                    }
                    else
                    {
                        Console.WriteLine("Unable terminate server");
                    }
                }
#endif
                Console.WriteLine("");

                // success or failure, close up the tcp Client
                targetStrm.Close();
                tcpClient.Close();
            }
        
            // we didn't even connect, probably the IP address is bad.
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
                return;
            }
        }

        /***	void ListenForWOLRequest(Object obj)
         * 
         *	Parameters:
         *               
         *      obj -       The obj is really an ipInfo and is casted to such.
         *                  The ipInfo class containing all of the IP like info about the
         *                  this machine we are running on; and the server we want to contact.
         * 
         *	Return Values:
         *      None
         *          
         *	Errors:
         *
         *
         *	Description: 
         *
         *      This is the start of the server side RemoteWol code.
         *      
         *      This was written as a seperate thread so that debugging of
         *      the client in the main thread against a server in a different
         *      thread could be done in one debug session. Client / Server
         *      combined application is only when the debug flag fRunServerAndClient is TRUE.
         * ------------------------------------------------------------ */
        private void ListenForWOLRequest(Object obj)
        {
            IPINFO ipInfo = (IPINFO) obj;
            byte[] rgRcv = new byte[2 * cbMACAddress];
            uint terminate = 0;

            TcpListener tcpListener = null;

            try
            {
  
                // this will throw and exception if ipAddress == null;
                tcpListener = new TcpListener(ipInfo.myIPs.ipMe, ipInfo.port);
                tcpListener.Start();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.ToString());
                return;
            }

            // go in a loop waiting for someone to connect.
            do
            {
                int cbRead = 0;
                bool fEcho = false;
                TcpClient client = null;
                NetworkStream targetStrm = null;

                try
                {

                    // block until we get something
                    client = tcpListener.AcceptTcpClient();
                    targetStrm = client.GetStream();

                    // read the buffer
                    targetStrm.ReadTimeout = 10000;     // set to 10 seconds for the read

                    // wait for something to come in
                    cbRead = targetStrm.Read(rgRcv, 0, rgRcv.Length);

                    // if it is a MAC address, then broadcast it.
                    if (cbRead == cbMACAddress)
                    {
                        // do the broadcast
                        fEcho = BroadCast(rgRcv);
                    }
#if QUIT
                    // if this is potentially a terminate
                    else if (cbRead == rgTerm.Length)
                    {
                        IPEndPoint ipEndPointClient = (IPEndPoint)client.Client.RemoteEndPoint;
                        if(ipInfo.myIPs.ipMe.Equals(ipEndPointClient.Address))
                        {
                            terminate = (uint)((rgRcv[0] << 24) | (rgRcv[1] << 16) | (rgRcv[2] << 8) | rgRcv[3]);
                            fEcho = (terminate == 0xFFFFFFFF);
                        }
                    }
#endif
                    // okay send something back.
                    if (fEcho)
                    {
 
                        // if we got something valid, echo it back as an ack
                        targetStrm.Write(rgRcv, 0, cbRead);
                        fEcho = false;

                        // print out the time and mac address
                        Array.Resize(ref rgRcv, 6);
                        PhysicalAddress macAddress = new PhysicalAddress(rgRcv);
                        Console.WriteLine(DateTime.Now.ToString("g") + " : " + macAddress.ToString());
                    }
                    else
                    {
                        // if not, then just return 1 byte to keep things from timing out on the client
                        targetStrm.Write(rgTerm, 0, 1);
                        fEcho = false;
                    }

                    // we have done our work, close the stream
                    targetStrm.Close();
                    client.Close();
                }

                // something bad happened, but we want to just print the exception and go back and wait
                // for another connection.
                catch (Exception e)
                {
                    Console.WriteLine(e.ToString());
                    terminate = 0;
                }

            } while (terminate != 0xFFFFFFFF);

            // just stop listening, we are done.
            tcpListener.Stop();
        }

        /***	bool BroadCast(byte[] rgMAC)
         * 
         *	Parameters:
         *               
         *      rgMAC - The MAC address to broadcast as a Magic Packet
         * 
         *	Return Values:
         *      TRUE is the broadcast succeeded, FALSE otherwise.
         *      Since this is UDP, it probably succeeded.
         *          
         *	Errors:
         *
         *
         *	Description: 
         *	
         *      This creates a Magic Packet with the specified MAC address of 
         *      the machine to wake up and broadcasts it.
         *      
         *      A Magic Packet is 6 0xFF followed by 16 
         *      copies of the MAC address.
         * ------------------------------------------------------------ */
        private bool BroadCast(byte[] rgMAC)
        {
            int i = 0;
            byte[] rgDataGram = new byte[102]; // 6 0xFF and 16 * 6 byte MAC = 17 * 6 = 102 bytes

            UdpClient updClient = new UdpClient();
            IPEndPoint ipBroadCast = new IPEndPoint(IPAddress.Broadcast, 0xFF);

            int cbSent = 0;

            // only 6 bytes are used, but the buffer maybe longer.
            Debug.Assert(rgMAC.Length >= 6);

            // build the datagram

            // first there must be 6 bytes of 0xFF;
            for (i = 0; i < 6; i++) rgDataGram[i] = 0xFF;

            // then 16 MAC 
            for (int j = 0; j < 16; j++)
            {
                for (int k = 0; k < 6; k++, i++) rgDataGram[i] = rgMAC[k];
            }

            updClient.EnableBroadcast = true;
            cbSent = updClient.Send(rgDataGram, rgDataGram.Length, ipBroadCast);

            return (cbSent == rgDataGram.Length);
        }

        /***	bool GetIPAddress(string szIP, IPINFO ipd)
         * 
         *	Parameters:
         *               
         *      szIP -  The hostname to get the IP address for
         *      ipd -   This is the global data structure to save our server IP address into
         * 
         *	Return Values:
         *      true if we could resolve the remote IP address, false if not
         *          
         *	Errors:
         *
         *	Description: 
         *	
         *      This resolves the hostname (szIP) to an binary IP address via DNS
         *      It looks specifically for an IPv4 IP address as we do not support IPv6.
         * ------------------------------------------------------------ */
        private bool GetIPAddress(string szIP, IPINFO ipd)
        {
            byte[] ipAddress = new byte[0];

            try
            {
                // get the server to talk to
                IPAddress[] rgIPAddr = Dns.GetHostAddresses(szIP);

                // I have to find a IP4 address; don't support anything else
                foreach (IPAddress ipAddr in rgIPAddr)
                {
                    if (ipAddr.AddressFamily == AddressFamily.InterNetwork)
                    {
                        ipAddress = ipAddr.GetAddressBytes();
                        if (ipAddress.Length == 4)
                        {
                            ipd.ip4 = ipAddress;
                        }
                        break;
                    }
                }
            }
            catch (Exception e)
            {
                Console.WriteLine("Exception: " + e.ToString());
                Console.WriteLine("");
            }

            if (ipAddress.Length != 4)
            {
                Console.WriteLine("Invalid IP Address: " + szIP);
                Console.WriteLine("");
                return (false);
            }
            else
            {
                return (true);
            }
        }

        /***	bool GetPort(string szPort, IPINFO ipd)
         * 
         *	Parameters:
         *               
         *      szPort -    The port number represented as a string
         *      ipd -   This is the global data structure to save our server Port into
         * 
         *	Return Values:
         *      true if we got a valid port number, false otherwise
         *          
         *	Errors:
         *
         *	Description: 
         *	
         *      Very simple, convert a string port number into a number port number
         *	
         * ------------------------------------------------------------ */
        private bool GetPort(string szPort, IPINFO ipd)
        {

            try
            {
                ipd.port = Convert.ToInt32(szPort);
                return (true);
            }
            catch (Exception e)
            {
                Console.WriteLine("Exception: " + e.ToString());
                Console.WriteLine("");
            }

            // if we had an error, print out that this is not a good Port
            Console.WriteLine("Invalid Port: " + szPort);
            Console.WriteLine("");

            return (false);
        }

        /***	bool GetMac(string szMAC, IPINFO ipd)
         * 
         *	Parameters:
         *               
         *      szMAC -    The MAC number represented as a string
         *      ipd -   This is the global data structure to save our server MAC address into
         * 
         *	Return Values:
         *      true if we got a valid MAC, false otherwise
         *          
         *	Errors:
         *
         *	Description: 
         *	
         *      Very simple, convert a string MAC number into a number MAC number
         *	
         * ------------------------------------------------------------ */
        private bool GetMac(string szMAC, IPINFO ipd)
        {
            // MAC Addresses are 6 bytes (12 characters) long, plus maybe 5 characters for : or -
            if (szMAC.Length == 12 || szMAC.Length == 17)
            {
                try
                {
                    ipd.mac = PhysicalAddress.Parse((String.Copy(szMAC)).Replace(':', '-').ToUpper()).GetAddressBytes();
                    return (ipd.mac.Length == 6);
                }
                catch (Exception e)
                {
                    Console.WriteLine("Exception: " + e.ToString());
                    Console.WriteLine("");
                    Console.WriteLine("Invalid MAC Adress: " + szMAC);
                    Console.WriteLine("");
               }
            }

            return (false);
         }

        /*				IPINFO Class Implementation		
         * ------------------------------------------------------------ **
         * 
         *	Description: Global data structure to pass around to
         *	             all of the routines to use.
         *
         * ------------------------------------------------------------ */
        private class IPINFO
        {
            public MYIPS myIPs = new MYIPS();
            public byte[] ip4 = null;
            public int port = 0;
            public byte[] mac = null;
        }

        /*				MYIPS Class Implementation		
         * ------------------------------------------------------------ **
         * 
         *	Description: Represents the current machines
         *	             IP, Gateway, and submask
         *
         *
         * ------------------------------------------------------------ */
        private class MYIPS
        {
            public IPAddress ipMe = null;
            public IPAddress ipMask = null;
            public IPAddress ipGateway = null;

            /*				MYIPS Class Constructor	
             * ------------------------------------------------------------ **
             * 
             *	Description:
             *	
             *          This constructs the MYIPS class filling in 
             *          the IP address of the current machine
             *          along with the gateway and subnet mask.
             *
             *
             * ------------------------------------------------------------ */
            public MYIPS()
            {
                NetworkInterface[] adapters = NetworkInterface.GetAllNetworkInterfaces();

                // just look at all of the adaptors connected to this machine.
                foreach (NetworkInterface adaptor in adapters)
                {
                    // skip the loop back address
                    if (adaptor.NetworkInterfaceType == NetworkInterfaceType.Loopback) continue;

                    UnicastIPAddressInformationCollection UnicastIPInfoCol = adaptor.GetIPProperties().UnicastAddresses;
                    GatewayIPAddressInformationCollection listGateway = adaptor.GetIPProperties().GatewayAddresses;

                    foreach (UnicastIPAddressInformation ipInfo in UnicastIPInfoCol)
                    {
                        // here we guess what adaptor to pick
                        // there could be several, so go ahead and pick the first IPv4 IP
                        // Who know if this is the correct adaptor; but typically
                        // we only connect to 1 network at a time
                        // except maybe a wired connection and a wireless one; on the same network.
                        if (!IPAddress.IsLoopback(ipInfo.Address) && ipInfo.Address.AddressFamily == AddressFamily.InterNetwork)
                        {
                            ipMe = ipInfo.Address;
                            ipMask = ipInfo.IPv4Mask;
                            break;
                        }
                    }

                    // found it, get out.
                    if (ipMe != null)
                    {
                        // there should be a gateway for this adaptor
                        // probably only one gateway, but take the first one.
                        if (listGateway.Count > 0)
                        {
                            ipGateway = listGateway[0].Address;
                        }
                        break;
                    }
                }
            }
        }
    }
 }

