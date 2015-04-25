function fnStimulusServerCycle()
global g_strctDAQCycle g_strctNet g_strctPTB g_strctConfig g_strctSoundMedia

fCurrTime = GetSecs;
g_strctDAQCycle.m_iNumCycles = g_strctDAQCycle.m_iNumCycles + 1;

if fCurrTime-g_strctDAQCycle.m_fCycleTimer > g_strctDAQCycle.m_fCycleTimerRateMS/1e3
%    fprintf('%d\n',g_strctDAQCycle.m_iNumCycles);
    g_strctDAQCycle.m_fCycleTimer = fCurrTime;
    g_strctDAQCycle.m_iNumCycles = 0;
end;


if fCurrTime-g_strctDAQCycle.m_fKBCheckTimer > g_strctDAQCycle.m_fKBCheckTimerRateMS/1e3
    g_strctDAQCycle.m_fKBCheckTimer = fCurrTime;
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    if keyIsDown && keyCode(27)
        fnLog('Stopping server');
        g_strctDAQCycle.m_fbClientConnected = false;
        return;
    end;
end

acInputFromKofiko = msrecv(g_strctNet.m_iCommSocket,g_strctConfig.m_strctStimulusServer.m_fNetworkCmdTimeout);
if ~isempty(acInputFromKofiko)
    strCommand = acInputFromKofiko{1};

    switch strCommand
   fCurrTime = GetSecs();
	if ~g_strctAppConfig.m_strctDAQ.m_fVirtualDAQ
	
        Out = parfeval(fnDAQNI(strCommand, varargin{:}));
    else 
        Out = 1;
    end
	
	if strcmpi(strCommand,'StrobeWord')
        if ~isfield(g_strctDAQParams,'LastStrobe')
            iStrobeWordBuffer = 2^18;
            g_strctDAQParams = fnTsAddVar(g_strctDAQParams,'LastStrobe',varargin{1} , iStrobeWordBuffer);
        else

            iLastEntry = g_strctDAQParams.LastStrobe.BufferIdx;
            if iLastEntry+1 > g_strctDAQParams.LastStrobe.BufferSize
                g_strctDAQParams.LastStrobe = fnIncreaseBufferSize(g_strctDAQParams.LastStrobe);
            end;
            iValueToSend = varargin{1};
           
            g_strctDAQParams.LastStrobe.Buffer(:,:,iLastEntry+1) = iValueToSend;
            g_strctDAQParams.LastStrobe.TimeStamp(iLastEntry+1) = fCurrTime;
            g_strctDAQParams.LastStrobe.BufferIdx = iLastEntry+1;
        end;
    end;

else
    acInputFromKofiko = [];
end;




return;


