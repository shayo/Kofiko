function S=fnRecvString(hSocket, iTimeOut)
S=char();
tic
while 1
    NumBytesAvail =  IOPort('BytesAvailable', hSocket);
    if NumBytesAvail > 0
      cChar=IOPort('Read',hSocket,0,1);
      if (cChar == 10)
          break;
      else
          if (cChar ~= 13)
                S=[S,cChar];
          end
      end
    end
    if toc > iTimeOut 
        break;
    end
end
return;