using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net.Sockets;
using System.Net;
using System.Threading;


namespace UDPSndRcvStr
{
    class UDPSndRcvStr
    {
        static void Main(string[] args)
        {

            UdpClient udp = new UdpClient(8005);
            IPAddress ipAddr = GetIPAddress(args[0]);
            int port = GetPort(args[1]);
            IPEndPoint remoteEP = new IPEndPoint(ipAddr, port);
            ASCIIEncoding ascii = new ASCIIEncoding();
            byte[] rgbDataGram = ascii.GetBytes("Hello World");
            string returnData = null;

            while (ipAddr != null && port != 0)
            {

                returnData = Encoding.ASCII.GetString(rgbDataGram);
                Console.Write("Sending string: ");
                Console.WriteLine(returnData);

                // send it
                udp.Send(rgbDataGram, rgbDataGram.Length, remoteEP);

                // wait for a byte to come in.
                rgbDataGram = udp.Receive(ref remoteEP);

                returnData = Encoding.ASCII.GetString(rgbDataGram);
                Console.Write("Received string: ");
                Console.WriteLine(returnData);

                // 5 sec wait
                Thread.Sleep(5000);
             }
        }

        /***	IPAddress GetIPAddress(string szIP)
         * 
         *	Parameters:
         *               
         *      szIP -  The hostname to get the IP address for
         * 
         *	Return Values:
         *      IPAddress that represent the IPv4 address
         *          
         *	Errors:
         *
         *	Description: 
         *	
         *      This resolves the hostname (szIP) to an binary IP address via DNS
         *      It looks specifically for an IPv4 IP address as we do not support IPv6.
         * ------------------------------------------------------------ */
        private static IPAddress GetIPAddress(string szIP)
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
                        if (ipAddr.GetAddressBytes().Length == 4)
                        {
                            return (ipAddr);
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
                return (null);
            }
            else
            {
                return (null);
            }
        }

        /***	int GetPort(string szPort)
         * 
         *	Parameters:
         *               
         *      szPort -    The port number represented as a string
         * 
         *	Return Values:
         *      The port number
         *          
         *	Errors:
         *
         *	Description: 
         *	
         *      Very simple, convert a string port number into a number port number
         *	
         * ------------------------------------------------------------ */
        private static int GetPort(string szPort)
        {

            try
            {
                int port;
                port = Convert.ToInt32(szPort);
                return (port);
            }
            catch (Exception e)
            {
                Console.WriteLine("Exception: " + e.ToString());
                Console.WriteLine("");
            }

            // if we had an error, print out that this is not a good Port
            Console.WriteLine("Invalid Port: " + szPort);
            Console.WriteLine("");

            return (0);
        }
    }
}
