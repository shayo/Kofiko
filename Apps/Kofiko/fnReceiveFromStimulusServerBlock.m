function bOK = fnReceiveFromStimulusServerBlock(strMessage,fTimeoutSec)
global g_strctStimulusServer g_strctPTB
fStart = GetSecs();
bOK  = false;
while (1)
    [acInputFromStimulusServer, iSocketErrorCode] = msrecv(g_strctStimulusServer.m_iSocket,0);

    if ~isempty(acInputFromStimulusServer) && strcmp(acInputFromStimulusServer{1},strMessage)
        bOK  = true;
        return;
    end;
    if GetSecs()-fStart > fTimeoutSec
        return;
    end
    %afTimeStamp(2) = GetSecs();
    if iSocketErrorCode == -2
        g_strctStimulusServer.m_bConnected = false;
    end
end
return;
