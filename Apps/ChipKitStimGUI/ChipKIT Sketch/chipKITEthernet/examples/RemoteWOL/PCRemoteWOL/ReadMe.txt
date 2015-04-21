To Run the RemoteWol Demo:

Build and upload the sketch.
Start the serial monitor and wait for:

	Start of RemoteWOL 1.0
 
	Listening

to print out.

From a Windows command window start RemoteWol with the chipKit IP and port as
the first 2 command line arguments, and the MAC address you want to broadcast 
as the 3rd command line argument. For the sake of the demo any validly formatted
MAC address may be used.

For example:

	RemoteWol 192.168.1.190 9040 11:22:33:44:55:66

If you use this command line with the proper chipKIT IP address, the port and MAC
address should be correct enough for the example sketch to work.

In the serial monitor window you should see (date/time corrected):

	Start of RemoteWOL 1.0
 
	Listening
	Current Day and UTC time: Sep 15, 2011  21:41:55
	Request to Wake MAC: 11:22:33:44:55:66
	WOL BroadCast Succeeded
 
	Listening

And in the windows command window you should see (IP corrected):

	RemoteWol 192.168.1.179 9040 11:22:33:44:55:66
	RemoteWol Version 1.0.4259.18973
	Keith Vogel, Copywrite 2011

	Magic Packet Sent

