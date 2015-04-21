fnDAQ('Init',0);

fnDAQ('SetBit',16,0);
strKofiko = '192.168.50.93';
strStimulusServer = '192.168.50.94';
sock = msconnect(strStimulusServer,3000);  
while (1)
    recvvar = msrecv(sock);
    fnDAQ('SetBit',16,1);
    % Sleep for 4 ms
    WaitSecs(1/1000 * 4);
    fnDAQ('SetBit',16,0);    
end

msclose(sock);