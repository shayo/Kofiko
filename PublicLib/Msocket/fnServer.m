%% Server

addpath('D:\Code\Doris\PublicLib\Msocket\');

% Listen on port 3000 
srvsock = mslisten(3000); 
% (the client calls connect here) 
% Accept a connection 
[sock,ip,name] = msaccept(srvsock); 
% Close the accept socket 
msclose(srvsock); 

% Send the variable over the socket 
while (1)
    recvvar = msrecv(sock,5); 
    if ~isempty(recvvar)
        recvvar
    else
        fprintf('Time out \n');
    end;
end;    
% Close the socket 
msclose(sock);
