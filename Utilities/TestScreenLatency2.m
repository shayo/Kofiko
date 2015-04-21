
sendvar = 3;                
srvsock = mslisten(3000);   
sock = msaccept(srvsock);   
msclose(srvsock);
[windowPtr,rect]=Screen('OpenWindow',0,[0,0,0]);
while (1)
Screen('Flip',windowPtr);
Screen('FillRect',windowPtr,[255 255 255]);
Screen('Flip',windowPtr);
 mssend(sock,sendvar);
 % Sleep for 1 sec.
 WaitSecs(1);
Screen('FillRect',windowPtr,[0 0 0]);
Screen('Flip',windowPtr); 
  WaitSecs(10);
end 
 
 msclose(sock);      
