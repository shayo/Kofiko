
libdir = 'c:\\MATLAB\R2011b_x64\\extern\\lib\\win64\\microsoft'

eval(sprintf('mex -I.  -L"%s" mssendraw.c ws2_32.lib',libdir));
eval(sprintf('mex -I.  -L"%s" msrecvraw.c ws2_32.lib',libdir));
clear mex
eval(sprintf('mex -I.  -L"%s" msconnect.c ws2_32.lib',libdir));


strctParams.m_strIP = '192.168.50.17';
strctParams.m_strPort = '5000';
strctParams.m_hSocket = msconnect(strctParams.m_strIP,str2num(strctParams.m_strPort)); % try to connect.
mssendraw(strctParams.m_hSocket, uint8([70+rand(1,20),0]));
X=msrecvraw(strctParams.m_hSocket, 2, 0);
msclose(strctParams.m_hSocket)