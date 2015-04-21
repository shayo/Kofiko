% Remote Access
iRemoteAccessPort = 2000;
iConnectionTimeOutSec = 5;
iDataTimeOut = 1;
iSocket = msconnect('Touch', iRemoteAccessPort, iConnectionTimeOutSec); 

mssend(iSocket, {'GetParadigm'});
strctParadigm  = msrecv(iSocket, iDataTimeOut);



msclose(iSocket)