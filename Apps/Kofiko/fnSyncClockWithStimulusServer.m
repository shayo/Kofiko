function [fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(iNumPings)
global g_strctStimulusServer


if isempty(g_strctStimulusServer)
    fLocalTime = GetSecs();
    fServerTime = NaN;
    fJitter = NaN;
    return;
end

if isfield(g_strctStimulusServer,'m_hWindow')
    fLocalTime = GetSecs();
    fServerTime = fLocalTime;
    fJitter = 0;
    return;
end

if ~g_strctStimulusServer.m_bConnected 
    fLocalTime = GetSecs();
    fServerTime = NaN;
    fJitter = NaN;
    return;
end

% Clear Buffer
X = 1;
acMessageQueue = cell(0);
iCounter = 0;
while (~isempty(X))
    [X] = msrecv(g_strctStimulusServer.m_iSocket,0);
    if ~isempty(X)
        iCounter = iCounter + 1;
        acMessageQueue{iCounter} = X;
    end
end
mssend(g_strctStimulusServer.m_iSocket, {'PingGetSecs',iNumPings});
afRecvTime = zeros(1,iNumPings);
afTimeStart = zeros(1,iNumPings);
afTimeEnd = zeros(1,iNumPings);
for k=1:iNumPings
    afTimeStart(k)=GetSecs();
    mssend(g_strctStimulusServer.m_iSocket, {1});
    [X] = msrecv(g_strctStimulusServer.m_iSocket);
    if length(X) == 1
        afTimeStart(k) = NaN;
        iCounter = iCounter + 1;
        acMessageQueue{iCounter} = X;
    else
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
    mssend(g_strctStimulusServer.m_iSocket, {'Echo',acMessageQueue{k}});
end
return;

