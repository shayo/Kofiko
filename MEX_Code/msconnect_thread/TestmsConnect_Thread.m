 addpath('Z:\MEX\win32');
 H=msconnect_thread('StartConnectThread','192.168.50.96',8000);
 
 while (1)
  msconnect_thread('IsConnected',H)
  tic
  while toc < 1
  end
 end
 
      
 