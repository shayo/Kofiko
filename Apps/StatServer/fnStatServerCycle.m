function fnStatServerCycle()
global g_strctCycle g_strctConfig g_strctNet g_strctNeuralServer g_strctWindows g_DebugDataLog g_counter  
fCurrTime = GetSecs();

if ~g_strctCycle.m_bClientConnected
    fnStatLog('Listening on port %d...',g_strctConfig.m_strctServer.m_fPort);
    drawnow
    [g_strctNet.m_iCommSocket,g_strctNet.m_strIP] = msaccept(g_strctNet.m_iServerSocket, g_strctConfig.m_strctServer.m_fListenTimeOutSec);
    if g_strctNet.m_iCommSocket > 0
        g_strctCycle.m_bClientConnected = true;
        fnStatLog('Client connected! [%s] \n',g_strctNet.m_strIP);
        drawnow          
    end;
    
end

if g_strctCycle.m_bClientConnected
    [acInputFromKofiko, iSocketErrorCode] = msrecv(g_strctNet.m_iCommSocket,0);
    if iSocketErrorCode == -2
        fnStatLog('Connection to client is lost!\n');
        drawnow
        
        if sum(g_strctNeuralServer.m_a2iCurrentActiveUnits(:)>0) > 0
           strAnswer=questdlg('Connection to Kofiko is lost, but some units are still active. Do you want to inactivate them?','Warning!','Yes','No','Yes');
           if ~strcmpi(strAnswer,'No')
               aiInd = find(g_strctNeuralServer.m_a2iCurrentActiveUnits>0);
               [aiChannel,aiUnit] = ind2sub(size(g_strctNeuralServer.m_a2iCurrentActiveUnits),aiInd);
               for k=1:length(aiInd)
                    fnStatServerCallbacks('ToggleActive',aiChannel(k),aiUnit(k));
               end
           end
        end
        
        g_strctNet.m_iCommSocket = 0;
        g_strctCycle.m_bClientConnected = false;
        g_strctCycle.m_bConditionInfoAvail = false;
    end
    

    
    fCurrTime = GetSecs();
    if fCurrTime - g_strctCycle.m_fSyncTimer > g_strctConfig.m_strctServer.m_fPingPongSec
        mssend(g_strctNet.m_iCommSocket, {'Ping',fCurrTime});
        g_strctCycle.m_fSyncTimer=fCurrTime;
    end
    
    if ~isempty(acInputFromKofiko) && iscell(acInputFromKofiko) && length(acInputFromKofiko) >= 1 && g_strctNeuralServer.m_bConnected
        fnStatServerCallbacks('KofikoInput',acInputFromKofiko);
    end
end

%
if g_strctNeuralServer.m_bConnected && g_strctCycle.m_bConditionInfoAvail
    fnTransferNeuralDataToBuffer(); % Blocking until new data is available(!)
    fnStatServerConsistencyChecks();
end

if g_strctNeuralServer.m_bConnected && (~g_strctCycle.m_bConditionInfoAvail ||  ~g_strctCycle.m_bClientConnected)
    % No information about trials, so no point in trying to parse plexon
    % data. Nevertheless, still sample and update the timestamp!
    
    PL_WaitForServer(g_strctNeuralServer.m_hSocket, 100);
    [NumSpikeAndStrobeEvents, a2fSpikeAndEvents, a2fWaveForms] =PL_GetWFEvs(g_strctNeuralServer.m_hSocket); % PL_GetWFEvs,PL_GetTS
    if isempty(NumSpikeAndStrobeEvents) || NumSpikeAndStrobeEvents == 0
        a2fSpikeAndEvents = zeros(0, g_strctNeuralServer.m_iNumberUnitsPerChannel);
    end
    [NumAnalog, afAnalogTime, a2fLFP] = PL_GetADVEx(g_strctNeuralServer.m_hSocket);
    if isempty(NumAnalog) || NumAnalog(1) == 0
        a2fLFP = zeros(0, 1); 
    end
    TrialCircularBuffer('UpdateTimeStamp', a2fSpikeAndEvents, a2fLFP, afAnalogTime);
end

if  ~g_strctNeuralServer.m_bConnected && (fCurrTime -g_strctCycle.m_fRefreshTimer > 1/g_strctConfig.m_strctGUIParams.m_fRefreshHz) && ~g_strctCycle.m_bConditionInfoAvail
    g_strctCycle.m_fRefreshTimer = fCurrTime;
    drawnow
end

iPrevSystemScrollValue = g_strctCycle.m_afAdvancerPrevReadOut(g_strctConfig.m_strctGUIParams.m_iSystemMouse);
aiCurrentAdvancerReadOut=fnSampleAdvancersAndUpate();
iCurrSystemScrollValue = aiCurrentAdvancerReadOut(g_strctConfig.m_strctGUIParams.m_iSystemMouse);
 iDeltaScroll = iPrevSystemScrollValue-iCurrSystemScrollValue;

if iDeltaScroll ~= 0
    bDisplayNow = true;
    iNumVisibleChannels = sum(g_strctNeuralServer.m_abChannelsDisplayed);
    iNumChannelsOnScreen = size(g_strctWindows.m_strctStatPanel.m_a2hPlotAxes,1);
     g_strctConfig.m_strctGUIParams.m_iChannelDisplayStart = min(iNumVisibleChannels-iNumChannelsOnScreen+1,max(1,g_strctConfig.m_strctGUIParams.m_iChannelDisplayStart + iDeltaScroll));
     fnUpdatePushButtonsTitle();
     fnUpdateAdvancerText();
else
     bDisplayNow = false;
end
   
 

if g_strctCycle.m_bClientConnected && ~g_strctCycle.m_bConditionInfoAvail && (fCurrTime -g_strctCycle.m_fRefreshTimer > 1/g_strctConfig.m_strctGUIParams.m_fRefreshHz)
    fnStatLog('Waiting for paradigm design...');
    g_strctCycle.m_fRefreshTimer = fCurrTime;
    drawnow
end


if  g_strctNeuralServer.m_bConnected && g_strctCycle.m_bConditionInfoAvail && (bDisplayNow || ...
    (fCurrTime -g_strctCycle.m_fRefreshTimer > 1/g_strctConfig.m_strctGUIParams.m_fRefreshHz))
    fnDisplayOverview();
    g_strctCycle.m_fRefreshTimer = fCurrTime;
end

if ~isempty(g_strctCycle.m_strSafeCallback)
    fnStatServerCallbacks(g_strctCycle.m_strSafeCallback,g_strctCycle.m_acSafeCallbackParams{:});
    g_strctCycle.m_strSafeCallback = [];
end

return
