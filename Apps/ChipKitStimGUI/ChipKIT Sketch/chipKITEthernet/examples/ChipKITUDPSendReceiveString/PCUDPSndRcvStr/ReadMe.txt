To run this demo, build and upload the sketch.
From MPIDE, open the serial monitor window and wait for "Start of Sketch" to print out

Once the sketch is running, from a Windows command line start UDPSndRcvStr with 
the IP and port number of the chipKIT as command line arguments.

For Example:

	UDPSndRcvStr 192.168.1.190 8888

 
You should see this in the serial monitor window:

Start of Sketch
Received packet of size 11
Contents: Hello World
Received packet of size 12
Contents: acknowledged
Received packet of size 12
Contents: acknowledged
Received packet of size 12
Contents: acknowledged

And this in the Windows command window:

Sending string: Hello World
Received string: acknowledged
Sending string: acknowledged
Received string: acknowledged
Sending string: acknowledged
Received string: acknowledged
Sending string: acknowledged
