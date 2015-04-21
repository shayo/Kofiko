function [fLocalTime, fServerTimePTB,fServerTimeHardware, fJitter] = fnSyncClockWithSpikeServer(iNumPings)
global g_strctSpikeServer
% Clear Buffer
X = 1;
iCounter = 0;
while (~isempty(X))
    [X] = msrecv(g_strctSpikeServer.m_iSocket,0);
end
mssend(g_strctSpikeServer.m_iSocket, {'PingGetSecs',iNumPings});
afRecvTime = zeros(1,iNumPings);
afTimeStart = zeros(1,iNumPings);
afTimeEnd = zeros(1,iNumPings);
for k=1:iNumPings
    afTimeStart(k)=GetSecs();
    mssend(g_strctSpikeServer.m_iSocket, {1});
    [X] = msrecv(g_strctSpikeServer.m_iSocket);
    if ~isempty(X) && strncmpi(X{1},'PongGetSecs',11)
            afRecvTime(k) = X{2};
        else
            afTimeStart(k) = NaN;
            iCounter = iCounter + 1;
            acMessageQueue{iCounter} = X;
        end
    end
    afTimeEnd(k)=GetSecs();
end
afTimeDiffSec=(afTimeEnd-afTimeStart);

[fMaxJitter, iIndex] = min(afTimeDiffSec);
fJitter = afTimeDiffSec(iIndex);
fLocalTime = afTimeStart(iIndex) + fJitter/2;
fServerTime = afRecvTime(iIndex);
% Requeue Messages
for k=1:iCounter
    mssend(g_strctSpikeServer.m_iSocket, {'Echo',acMessageQueue{k}});
end
return;

