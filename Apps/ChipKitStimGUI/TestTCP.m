
S=msconnect('192.168.50.17',5000,1);

mssendraw(S, uint8(['Hello',0]));
X=msrecvraw(S,  100,0)
msclose(S)