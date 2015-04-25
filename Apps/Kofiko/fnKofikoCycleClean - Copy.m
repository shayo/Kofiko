function fnKofikoCycleClean
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
%
% This is the main cycle function which runs at high frequency, so be
% careful what type of functions you call from here.
%
% afCycleDebugTimers is to test runtime for a cycle

global g_strctEyeCalib g_strctGUIParams  g_bRecording g_strctAppConfig g_bParadigmRunning g_strctAcquisitionServer
global g_strctParadigm g_bLastLoggedList g_strctPTB g_strctDAQParams g_strctSystemCodes g_bVERBOSE
global g_handles g_strctCycle g_strctStimulusServer g_strctRecordingInfo  g_strctRealTimeStatServer



fCycleTic = GetSecs;
%afCycleDebugTimers = ones(1,50)*NaN;
%afCycleDebugTimers(1) = GetSecs();

%% Get feedback from stimulus server?
if ~g_strctAppConfig.m_strctStimulusServer.m_fSingleComputerMode
    
    if ~isempty(g_strctStimulusServer)
        %afCycleDebugTimers(2) = GetSecs();
        [acInputFromStimulusServer, iSocketErrorCode] = msrecv(g_strctStimulusServer.m_iSocket,0);
        %afCycleDebugTimers(3) = GetSecs();
    else
        acInputFromStimulusServer = [];
        iSocketErrorCode = 0;
    end
    
    if iSocketErrorCode == -2
        % Oh no! we lost connection to the stimulus server.
        % Pause everything and don't allow to resume before we established
        % connection again....
        if g_strctStimulusServer.m_bConnected  == true
            % First time we are here...
            g_strctStimulusServer.m_bConnected = false;
            g_strctCycle.m_bParadigmPaused = true;
            g_strctParadigm.m_iMachineState = 0;
        
            % Make sure monkey doesn't accidently get juice if we paused during
            % juice event
            fnDAQWrapper('SetBit',g_strctDAQParams.m_fJuicePort, 0);
            fnDAQWrapper('StrobeWord', g_strctSystemCodes.m_iJuiceOFF);
            fnDAQWrapper('StrobeWord', g_strctSystemCodes.m_iPauseParadigm);
            set(g_handles.hPauseButton, 'String','Resume','enable','off');
            set(g_handles.hStartButton,'enable','off');
            g_strctCycle.m_fStartPause = GetSecs;
        end
     end;
    
    
    if ~isempty(acInputFromStimulusServer)
        strCommand = acInputFromStimulusServer{1};
        if strcmpi(strCommand,'TrialPreparationDone')
            dbg = 1;
        end;
        switch strCommand
            case 'Pong'
                g_strctCycle.m_fPongTime = fCycleTic;
                fPongValue = acInputFromStimulusServer{2};
                if g_strctCycle.m_fPingPongValue == fPongValue
                    g_strctCycle.m_iPingPongMachineState = 2;
                else
                    g_strctCycle.m_iPingPongMachineState = 3;
                end

        end
    end;
else
    acInputFromStimulusServer = [];
end

%afCycleDebugTimers(4) = GetSecs();
%% Statistics server - still alive?
if g_strctRealTimeStatServer.m_bConnected
    %afCycleDebugTimers(5) = GetSecs();
    [acMessageFromRealTimeStatServer, iSocketError]=msrecv(g_strctRealTimeStatServer.m_iSocket,0);
    %afCycleDebugTimers(6) = GetSecs();
    if iSocketError == -2
        g_strctRealTimeStatServer.m_bConnected = false;
    end
    % TODO - Handle messages from statistics server... (Strobe word
    % requests?)
    if ~isempty(acMessageFromRealTimeStatServer) 
        strCommand = acMessageFromRealTimeStatServer{1};
        if strcmpi(strCommand,'Ping')
            fStatServerTS = acMessageFromRealTimeStatServer{2};
            %afCycleDebugTimers(7) = GetSecs();
            fnParadigmToStatServerComm('Pong',fStatServerTS);
            %afCycleDebugTimers(8) = GetSecs();
        end
    end
end

%% Acquisition Server still alive?

%afCycleDebugTimers(9) = GetSecs();

%% Video Streaming
if ~isempty(g_strctAppConfig.m_hVideoGrabber) && ~g_strctCycle.m_bInCriticalSection 
    if fCycleTic - g_strctCycle.m_strctVideo.m_fTimer > 1/g_strctAppConfig.m_strctVideoStreaming.m_fSampleRateHz
        g_strctCycle.m_strctVideo.m_a3iImage = YUY2toRGB(getsnapshot(g_strctAppConfig.m_hVideoGrabber));
        g_strctCycle.m_strctVideo.m_fTimer = fCycleTic;
    end
end
%% Remote Access
if g_strctCycle.m_bTrialNotInProgress && ~g_strctAppConfig.m_strctRemoteAccess.m_bClientConnected
   [iCommSocket,strIP] = msaccept(g_strctAppConfig.m_strctRemoteAccess.m_hSocket,0);
    if iCommSocket ~= -1
        % Someone connected remotely
        g_strctAppConfig.m_strctRemoteAccess.m_iCommSocket = iCommSocket;
        g_strctAppConfig.m_strctRemoteAccess.m_strIP = strIP;
        g_strctAppConfig.m_strctRemoteAccess.m_bClientConnected = true;
        fnParadigmToKofikoComm('DisplayMessage','Remote Access Login',10);
    end
end

if g_strctAppConfig.m_strctRemoteAccess.m_bClientConnected
    [acInputFromRemoteClient, iRemoteAccessSocketErrorCode] = msrecv(g_strctAppConfig.m_strctRemoteAccess.m_iCommSocket,0);
    if iRemoteAccessSocketErrorCode == -2
        g_strctAppConfig.m_strctRemoteAccess.m_bClientConnected = false;
        fnParadigmToKofikoComm('DisplayMessage','Remote Client Disconnected',10);
    end
    if ~isempty(acInputFromRemoteClient)
        fnExecuteRemoteCommand(acInputFromRemoteClient);
    end
   
end

%% Sync with Plexon and stimulus server
% This is very important signal that will be later used to synchronize
% the clocks between Kofiko and plexon.
% The default sync signal frequency is 1 Hz
if fCycleTic - g_strctCycle.m_fSyncTimer > g_strctCycle.m_fSyncPeriodSec && ~g_strctAppConfig.m_strctStimulusServer.m_fSingleComputerMode
    %afCycleDebugTimers(10) = GetSecs();

    fnDAQWrapper('StrobeWord', g_strctSystemCodes.m_iSync);

    %afCycleDebugTimers(11) = GetSecs();

    % Sync with real time stat server as well!
    if g_strctRealTimeStatServer.m_bConnected
        mssend(g_strctRealTimeStatServer.m_iSocket,{'SyncWithKofiko',fCycleTic});
        %afCycleDebugTimers(12) = GetSecs();

    end
    g_strctCycle.m_fSyncTimer = fCycleTic;
end;

bSyncStimServerEvent = false;

if fCycleTic - g_strctCycle.m_fStimServSyncTimer > g_strctCycle.m_fSyncPeriodSec && g_strctCycle.m_bTrialNotInProgress
    bSyncStimServerEvent = true;
    %afCycleDebugTimers(13) = GetSecs();

    [fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(10);
    %afCycleDebugTimers(14) = GetSecs();

    fnTsSetVar('g_strctDAQParams','StimulusServerSync',[fLocalTime,fServerTime,fJitter]);
    %afCycleDebugTimers(15) = GetSecs();

    g_strctCycle.m_fStimServSyncTimer = fCycleTic;
end

%afCycleDebugTimers(16) = GetSecs();

%% Sample analog signals and distribute them around...
iNumExternalTriggers = length(g_strctDAQParams.m_afExternalTriggers);
if  strcmpi(g_strctDAQParams.m_strEyeSignalInput,'Analog')
    if ~(g_strctDAQParams.m_fUseMouseClickAsEyePosition || g_strctDAQParams.m_bMouseGazeEmulator)
        
        [afAnalogSignals] = fnDAQWrapper('GetAnalog',[g_strctDAQParams.m_fMotionPort,...
            g_strctDAQParams.m_fEyePortX,g_strctDAQParams.m_fEyePortY, g_strctDAQParams.m_fEyePortPupil, ...
            g_strctDAQParams.m_afExternalTriggers]); % This can take up to 2ms....
        
        %afCycleDebugTimers(18) = GetSecs();
        fMotionSignal = afAnalogSignals(1);
        aiExternalTriggerIndices = 5:5+iNumExternalTriggers-1;
        afRAWEyeSig = afAnalogSignals(2:4);
        afExternalTriggerValues = afAnalogSignals(aiExternalTriggerIndices);
    else
        fMotionSignal= 0;
        afExternalTriggerValues = zeros(size(g_strctDAQParams.m_afExternalTriggers));
    end
elseif strcmpi(g_strctAppConfig.m_strctDAQ.m_strAcqusitionCard,'arduino')
    % Eye signal is sampled using Serial
    % assume this is the arduino configuration, so external triggers
    % and motion are sampled through the arduino board.
    iLastEntry = g_strctEyeCalib.EyeRaw.BufferIdx;
    
    nAvail = IOPort('BytesAvailable', g_strctDAQParams.m_hISCAN);
    if nAvail >= 23 % Single data packet (should be changed to XML related calculation...)
        %  Read, parse and update buffer
        [pktdata, treceived] =  IOPort('Read', g_strctDAQParams.m_hISCAN, 1, nAvail);
        if pktdata(22) == 13 && pktdata(23) == 10 && mod(nAvail,23) == 0
            iNumPackets = nAvail/23;
            fEyeSignalSamplingRate = 120;
            
            fTS_FirstPacket = treceived-iNumPackets/fEyeSignalSamplingRate;
            
            Tmp=sscanf(char(pktdata),'%f %f %f');
            afX = Tmp(1:3:end);
            afY = Tmp(2:3:end);
            afPupil = Tmp(3:3:end);
            
            afRAWEyeSig = [afX(end),afY(end),afPupil(end)];
            afTimeStamps = fTS_FirstPacket:1/fEyeSignalSamplingRate:fTS_FirstPacket+(iNumPackets-1)*(1/fEyeSignalSamplingRate);
            % Update buffer
            if iLastEntry+iNumPackets > g_strctEyeCalib.EyeRaw.BufferSize
                g_strctEyeCalib.EyeRaw = fnIncreaseBufferSize(g_strctEyeCalib.EyeRaw);
            end;
            
            g_strctEyeCalib.EyeRaw.Buffer(1,:,iLastEntry+1:iLastEntry+iNumPackets) = [afX,afY,afPupil]';
            g_strctEyeCalib.EyeRaw.TimeStamp(iLastEntry+1:iLastEntry+iNumPackets) = afTimeStamps;
            g_strctEyeCalib.EyeRaw.BufferIdx = iLastEntry+iNumPackets;
            
        else
            % lost sync with iscan or Iscan was disconnected.
            if all(pktdata == 0)
                % Pause paradigm and show a message to user.
                % Can we recover from this?
                fnPauseParadigm();
                fnParadigmToKofikoComm('DisplayMessage','Lost ISCAN Connection',20);
                      afRAWEyeSig = g_strctEyeCalib.EyeRaw.Buffer(1,:,iLastEntry);
  
            else
                assert(false); % lost sync with ISCAN
            end
        end
    else
        % Packet not yet ready, use buffer....
        afRAWEyeSig = g_strctEyeCalib.EyeRaw.Buffer(1,:,iLastEntry);
    end
    MedFiltEyePos = true;
    if MedFiltEyePos && iLastEntry > 3
        iMedianFilterSize = 3;
        afRAWEyeSig =median(squeeze(g_strctEyeCalib.EyeRaw.Buffer(1,:,iLastEntry-iMedianFilterSize-1:iLastEntry)),2)';
        %afRAWEyeSig = median(
    end
    
end

%% Listen to what Arduino has to say
if strcmpi(g_strctAppConfig.m_strctDAQ.m_strAcqusitionCard,'arduino')
    
    fMotionSignal  =0;
    afExternalTriggerValues = zeros(1, length(g_strctDAQParams.m_afExternalTriggers));
        
    NumBytesAvail =  IOPort('BytesAvailable', g_strctDAQParams.m_hArduino);
    if NumBytesAvail > 0
        Buffer=IOPort('Read',g_strctDAQParams.m_hArduino,0,NumBytesAvail);
        acInputFromArduino = fnSplitString(Buffer,10); % Drop the 13 at the end...
        for k=1:length(acInputFromArduino)
            % Input needs to be parsed.
            % Packets could be either Analog monitored inputs.
            % or Triggers....
            if strncmpi(char(acInputFromArduino{k}),'Trigger',7)
                iTriggeredChanneled = str2num(char(acInputFromArduino{k}(8:end-1)));
                if ~isempty(iTriggeredChanneled)
                    afExternalTriggerValues(iTriggeredChanneled+1) = true;
                end
            end
            
        end        
    end    
end

        
if isempty(g_strctDAQParams.m_fMotionPort)
    fMotionSignal = 0;
end;
%% convert raw eye signal to screen coordinates
if ~(g_strctDAQParams.m_fUseMouseClickAsEyePosition || g_strctDAQParams.m_bMouseGazeEmulator) && ~isempty(g_strctStimulusServer)
    
    fCenterX = g_strctEyeCalib.CenterX.Buffer(g_strctEyeCalib.CenterX.BufferIdx);
    fCenterY = g_strctEyeCalib.CenterY.Buffer(g_strctEyeCalib.CenterY.BufferIdx);
    fGainX = g_strctEyeCalib.GainX.Buffer(g_strctEyeCalib.GainX.BufferIdx);
    fGainY = g_strctEyeCalib.GainY.Buffer(g_strctEyeCalib.GainY.BufferIdx);
    
    fEyeXPix = (afRAWEyeSig(1) - fCenterX)*fGainX + g_strctStimulusServer.m_aiScreenSize(3)/2;
    fEyeYPix = (afRAWEyeSig(2) - fCenterY)*fGainY + g_strctStimulusServer.m_aiScreenSize(4)/2;
	
else
    fEyeXPix = NaN;
    fEyeYPix = NaN;
end

%%

%afCycleDebugTimers(19) = GetSecs();
%% Update motion signal FSM
g_strctCycle.m_afMotionBuffer(g_strctCycle.m_iMotionBufferIndex) = fMotionSignal;

g_strctCycle.m_iMotionBufferIndex = g_strctCycle.m_iMotionBufferIndex + 1;
if g_strctCycle.m_iMotionBufferIndex > length(g_strctCycle.m_afMotionBuffer)
    g_strctCycle.m_iMotionBufferIndex = 1; % Cyclic buffer
end;
if fCycleTic - g_strctCycle.m_fMotionTimer > g_strctCycle.m_fMotionUpdateMedianSec
    g_strctCycle.m_fMotionTimer = fCycleTic;
    g_strctCycle.m_fMotionBaseline = median(g_strctCycle.m_afMotionBuffer);
    %afCycleDebugTimers(20) = GetSecs();
    g_strctCycle.m_bMotionBufferInitialized = true;
end;

%afCycleDebugTimers(21) = GetSecs();
if g_strctCycle.m_bMotionBufferInitialized
    if g_strctCycle.m_iMotionFSM_State == 0 && abs(fMotionSignal-g_strctCycle.m_fMotionBaseline) > g_strctGUIParams.m_fMotionThreshold
        g_strctCycle.m_iMotionFSM_State = 1;
        g_strctCycle.m_fLastMotionDetectecd = fCycleTic;
    end
    
    if g_strctCycle.m_iMotionFSM_State == 1 && fCycleTic - g_strctCycle.m_fLastMotionDetectecd > g_strctGUIParams.m_fPauseTaskAfterMotionSec
        % Pause task
        %         if ~g_strctCycle.m_bParadigmPaused
        %             fnPauseParadigm('monkey moved too much');
        %         end;
        feval(g_strctParadigm.m_strCallbacks,'MotionStarted');
        g_strctCycle.m_iMotionFSM_State = 2;
    end;
    
    if g_strctCycle.m_iMotionFSM_State == 2 && abs(fMotionSignal-g_strctCycle.m_fMotionBaseline) < g_strctGUIParams.m_fMotionThreshold
        g_strctCycle.m_fStationaryTimer = fCycleTic;
        g_strctCycle.m_iMotionFSM_State = 3;
    end;
    
    if g_strctCycle.m_iMotionFSM_State == 3 && abs(fMotionSignal-g_strctCycle.m_fMotionBaseline) > g_strctGUIParams.m_fMotionThreshold
        g_strctCycle.m_iMotionFSM_State = 2;
    end;
    
    if g_strctCycle.m_iMotionFSM_State == 3 && fCycleTic - g_strctCycle.m_fStationaryTimer >  g_strctGUIParams.m_fMotionResumeTaskSec
        % Resume task
        feval(g_strctParadigm.m_strCallbacks,'MotionFinished');
        %         if g_strctCycle.m_bParadigmPaused && ~g_strctGUIParams.m_bUserPaused
        %             fnResumeParadigm();
        %         end;
        g_strctCycle.m_iMotionFSM_State = 0;
    end;
end;


if g_strctCycle.m_bMotionBufferInitialized
    % measure maximum motion for statistics plot
    g_strctCycle.m_fMaxMotion = max(g_strctCycle.m_fMaxMotion,  abs(fMotionSignal-g_strctCycle.m_fMotionBaseline));
    if fCycleTic - g_strctCycle.m_fMaxMotionTimer > g_strctCycle.m_fMaxMotionUpdateSec
        
        g_strctCycle.m_iMaxMotionIndex = g_strctCycle.m_iMaxMotionIndex + 1;
        if g_strctCycle.m_iMaxMotionIndex > length(g_strctCycle.m_afMaxMotion)
            g_strctCycle.m_iMaxMotionIndex = 1;
        end;
        g_strctCycle.m_afMaxMotion(g_strctCycle.m_iMaxMotionIndex) = g_strctCycle.m_fMaxMotion;
        
        g_strctCycle.m_fMaxMotionTimer = fCycleTic;
        g_strctCycle.m_fMaxMotion = 0;
    end;
end;
%afCycleDebugTimers(22) = GetSecs();

%% Save raw signal to Kofiko data struture
% Although raw eye signal is recorded with high precision in plexon, we
% also keep additional copy here (maybe for MRI experiments where plexon is
% not available)
if strcmpi(g_strctDAQParams.m_strEyeSignalInput,'Analog') && ...
    ~(g_strctDAQParams.m_fUseMouseClickAsEyePosition || g_strctDAQParams.m_bMouseGazeEmulator)&& ...
        g_strctAppConfig.m_strctVarSave.m_fEyePos && ~g_strctCycle.m_bParadigmPaused  % i.e., running
    if fCycleTic - g_strctCycle.m_fEyeTrackTimer > g_strctCycle.m_fEyeTrackElapsedMS/1000
        iLastEntry = g_strctEyeCalib.EyeRaw.BufferIdx;
        if iLastEntry+1 > g_strctEyeCalib.EyeRaw.BufferSize
            g_strctEyeCalib.EyeRaw = fnIncreaseBufferSize(g_strctEyeCalib.EyeRaw);
        end;
        g_strctEyeCalib.EyeRaw.Buffer(:,:,iLastEntry+1) = afRAWEyeSig;
        g_strctEyeCalib.EyeRaw.TimeStamp(iLastEntry+1) = fCycleTic;
        g_strctEyeCalib.EyeRaw.BufferIdx = iLastEntry+1;
        
        g_strctCycle.m_fEyeTrackTimer = fCycleTic;
    end;
end;
%afCycleDebugTimers(23) = GetSecs();


if g_strctAppConfig.m_strctVarSave.m_fMotion && g_strctCycle.m_bMotionBufferInitialized
    if fCycleTic - g_strctCycle.m_strctMotion.m_fSampleTimer > g_strctCycle.m_strctMotion.m_fElapsedMS/1000
        
        fMaxMotion = max(g_strctCycle.m_fMaxMotion,  abs(fMotionSignal-g_strctCycle.m_fMotionBaseline));
        
        iLastEntry = g_strctDAQParams.m_strctMotionSensor.MotionSensor.BufferIdx;
        if iLastEntry+1 > g_strctDAQParams.m_strctMotionSensor.MotionSensor.BufferSize
            g_strctDAQParams.m_strctMotionSensor.MotionSensor= fnIncreaseBufferSize(g_strctDAQParams.m_strctMotionSensor.MotionSensor);
        end;
        g_strctDAQParams.m_strctMotionSensor.MotionSensor.Buffer(:,:,iLastEntry+1) = fMaxMotion;
        g_strctDAQParams.m_strctMotionSensor.MotionSensor.TimeStamp(iLastEntry+1) = fCycleTic;
        g_strctDAQParams.m_strctMotionSensor.MotionSensor.BufferIdx = iLastEntry+1;
        
        g_strctCycle.m_strctMotion.m_fSampleTimer = fCycleTic;
    end;
    
end


%% Handle External Triggers
%afCycleDebugTimers(24) = GetSecs();

abExternalTriggers = zeros(1,iNumExternalTriggers);
if g_strctAppConfig.m_strctVarSave.m_fExternalTriggers
    for k=1:iNumExternalTriggers
        switch g_strctDAQParams.m_aiExternalTriggerFSM_State(k)
            case 0
                if afExternalTriggerValues(k) >= g_strctDAQParams.m_fExternalTriggerThreshold
                    g_strctDAQParams.m_aiExternalTriggerFSM_State(k) = 1;
                    g_strctDAQParams.m_astrctExternalTriggers(k) = fnTsSetVar(g_strctDAQParams.m_astrctExternalTriggers(k),'Trigger',1);
                    %                    feval(g_strctParadigm.m_strCallbacks,'Trigger',k,1);
                    abExternalTriggers(k) = 1;
                    %fnLog('Trigger %d is ON\n',k);
                end
            case 1
                if afExternalTriggerValues(k) < g_strctDAQParams.m_fExternalTriggerThreshold
                    g_strctDAQParams.m_aiExternalTriggerFSM_State(k) = 0;
                    g_strctDAQParams.m_astrctExternalTriggers(k) = fnTsSetVar(g_strctDAQParams.m_astrctExternalTriggers(k),'Trigger',0);
                    %                    feval(g_strctParadigm.m_strCallbacks,'Trigger',k,0);
                    %fnLog('Trigger %d is OFF\n',k);
                end
        end
    end
end;
%afCycleDebugTimers(25) = GetSecs();

%% Get mouse coordinates (might be used in some paradigms to change values)

if fCycleTic - g_strctCycle.m_fKeyboardMouseInteractionTimer > g_strctCycle.m_fKeyboardMouseInteractionMS/1e3
    g_strctCycle.m_fKeyboardMouseInteractionTimer = fCycleTic;
    
    %afCycleDebugTimers(26) = GetSecs();

    % This silly thing is because sometimes PTB would crash upon a call to
    % GetMouse, and would not return the buttons, but only the coordinate...
    try
        [fMouseX, fMouseY, aiButtons] = GetMouse(g_strctPTB.m_hWindow);  % This takes 0.06 ms
    catch
        [fMouseX, fMouseY] = GetMouse(g_strctPTB.m_hWindow);
        aiButtons = [0,0,0];
    end
    
if g_strctGUIParams.m_bUseSpecialKeys    
    
    try
        strStyle = get(gco,'style');
        if strcmp(strStyle,'edit')
            bHotKeysActive = false;
        else
            bHotKeysActive = true;
        end
    catch
        bHotKeysActive = true;
    end
    
    if bHotKeysActive
        [keyIsDown, secs, keyCode] = KbCheck; % This shitty thing takes 0.15 ms
    else
        keyIsDown = false;
        keyCode = zeros(1,256);
    end
    
    %afCycleDebugTimers(27) = GetSecs();

    if bHotKeysActive && aiButtons(1) && keyCode(16) && (keyCode(160) || keyCode(161))
        fDiff = fMouseX-g_strctCycle.m_strctPrevMouse.m_fMouseX;
        g_strctPTB.m_fScale = min(2, max(0.2, g_strctPTB.m_fScale + fDiff/500));

    end
else
    keyIsDown = false;
    keyCode = 0;
end
    
    g_strctCycle.m_strctPrevMouse.m_fMouseX = fMouseX;
    g_strctCycle.m_strctPrevMouse.m_fMouseY = fMouseY;

    
    
    g_strctCycle.m_fLastMousePosX = fMouseX - g_strctPTB.m_aiScreenRect(1);
    g_strctCycle.m_fLastMousePosY = fMouseY - g_strctPTB.m_aiScreenRect(2);
    g_strctCycle.m_aiLastMouseButtons = aiButtons;
    g_strctCycle.m_bLastkeyIsDown = keyIsDown;
    g_strctCycle.m_abLastkeyCode = keyCode;
end
if ~g_bParadigmRunning
    return;
end;



fMouseX = g_strctCycle.m_fLastMousePosX;
fMouseY = g_strctCycle.m_fLastMousePosY;
aiButtons = g_strctCycle.m_aiLastMouseButtons;
keyIsDown = g_strctCycle.m_bLastkeyIsDown;
keyCode = g_strctCycle.m_abLastkeyCode;

%afCycleDebugTimers(28) = GetSecs();
%% Prepare input structure for paradigm cycle function
% inputs include:  eye signal, mouse, and spike channels

if g_strctDAQParams.m_fUseMouseClickAsEyePosition || g_strctDAQParams.m_bMouseGazeEmulator
    try
        [fEyeXPix, fEyeYPix, aiButtons] = GetMouse(g_strctPTB.m_hWindow);
    catch
        [fEyeXPix, fEyeYPix] = GetMouse(g_strctPTB.m_hWindow);
        aiButtons = [0,0,0];
    end   % aiButtons = fndllMiceHook('GetButtons',0);
    afRAWEyeSig = [fEyeXPix,fEyeYPix];
    
    % If user clicks on another screen, do not consider this as a touch
    if fEyeXPix < g_strctPTB.m_fScale *g_strctStimulusServer.m_aiScreenSize(1) ||  ...
            fEyeXPix > g_strctPTB.m_fScale *g_strctStimulusServer.m_aiScreenSize(3) || ...
            fEyeYPix < g_strctPTB.m_fScale *g_strctStimulusServer.m_aiScreenSize(2) || ...
            fEyeYPix > g_strctPTB.m_fScale *g_strctStimulusServer.m_aiScreenSize(4)
        aiButtons = zeros(1,3)>0;
        ShowCursor();
    else
        
        if ~g_strctDAQParams.m_fSimulateTouchScreenForDebug
            HideCursor();
            if g_strctCycle.m_pt2fPrevMousePos(1) ~= fEyeXPix || g_strctCycle.m_pt2fPrevMousePos(2) ~= fEyeYPix 
                % Mouse move is considered a click
                aiButtons = [1 0 0] > 0;
                g_strctCycle.m_fMouseTouchTimer = GetSecs();
            end;
        end
    end;
    
    if aiButtons(1) > 0  && all(g_strctCycle.m_pt2fPrevMousePos == [fEyeXPix, fEyeYPix]) && ...
               (GetSecs() - g_strctCycle.m_fMouseTouchTimer) > 1 && ~g_strctDAQParams.m_fSimulateTouchScreenForDebug
            aiButtons(1) = 0;
            fnParadigmToKofikoComm('displaymessage','Releasing Mouse',0.5);
    end
    
    g_strctCycle.m_pt2fPrevMousePos = [fEyeXPix, fEyeYPix];
end



strctInputs.m_pt2iRawEyeSignal = afRAWEyeSig(1:2);
strctInputs.m_bMouseInPTB = fMouseX >=  g_strctPTB.m_aiRect(1) && fMouseX <= g_strctPTB.m_aiRect(3) && ...
    fMouseY >=  g_strctPTB.m_aiRect(2) && fMouseY <= g_strctPTB.m_aiRect(4);
strctInputs.m_pt2iMouse = [fMouseX, fMouseY];
strctInputs.m_abMouseButtons = aiButtons;
strctInputs.m_pt2iEyePosScreen = [fEyeXPix,fEyeYPix];
strctInputs.m_abExternalTriggers = abExternalTriggers;
strctInputs.m_abSpikes = [];
strctInputs.m_acInputFromStimulusServer = acInputFromStimulusServer;

% Edits by Josh for hand mapping paradigm
g_strctPTB.m_strctControlInputs.m_mousePosition = [fMouseX, fMouseY];
g_strctPTB.m_strctControlInputs.m_mouseInPTB = strctInputs.m_bMouseInPTB;
g_strctPTB.m_strctControlInputs.m_mouseButtons = aiButtons;

if fCycleTic - g_strctCycle.m_strctEyeTraces.m_iPrevFixationTimer > g_strctCycle.m_strctEyeTraces.m_iPrevFixationUpdateMS/1000
    g_strctCycle.m_strctEyeTraces.m_iPrevFixationTimer = fCycleTic;
    g_strctCycle.m_strctEyeTraces.m_apt2fPreviousFixations(:,g_strctCycle.m_strctEyeTraces.m_iPrevFixationIndex) = ...
        [(g_strctPTB.m_fScale * [fEyeXPix fEyeYPix fEyeXPix fEyeYPix] +[-1 -1 1 1])]';
    
    g_strctCycle.m_strctEyeTraces.m_iPrevFixationIndex = g_strctCycle.m_strctEyeTraces.m_iPrevFixationIndex + 1;
    if g_strctCycle.m_strctEyeTraces.m_iPrevFixationIndex >  size(g_strctCycle.m_strctEyeTraces.m_apt2fPreviousFixations,2)
        g_strctCycle.m_strctEyeTraces.m_iPrevFixationIndex = 1;
    end;
end;

% More eye trace issues
iPrevIndex = g_strctCycle.m_strctEyeTraces.m_iLineIndex-1;
if iPrevIndex <= 0
    iPrevIndex = g_strctCycle.m_strctEyeTraces.m_iLineTraceBuffer;
end

pt2fLastKnown = g_strctCycle.m_strctEyeTraces.m_apt2fLastDifferentPos(:, iPrevIndex);
if pt2fLastKnown(1) ~= fEyeXPix || pt2fLastKnown(2) ~= fEyeYPix
    g_strctCycle.m_strctEyeTraces.m_apt2fLastDifferentPos(:,g_strctCycle.m_strctEyeTraces.m_iLineIndex) = [fEyeXPix; fEyeYPix];
    g_strctCycle.m_strctEyeTraces.m_iLineIndex = g_strctCycle.m_strctEyeTraces.m_iLineIndex + 1;
    if g_strctCycle.m_strctEyeTraces.m_iLineIndex > g_strctCycle.m_strctEyeTraces.m_iLineTraceBuffer
        g_strctCycle.m_strctEyeTraces.m_iLineIndex = 1;
    end
end


%% Here comes the most important call - the paradigm cycle function
% This function should update the paradigm FSM and should not block
% execution!
% At the moment, we are using the output for anything....
%afCycleDebugTimers(29) = GetSecs();
%if ~g_strctCycle.m_bParadigmPaused

    feval(g_strctParadigm.m_strCycle, strctInputs, g_strctCycle.m_bParadigmPaused);  % This takes 0.1ms for the Passive fixation

	%end;
%afCycleDebugTimers(30) = GetSecs();
%% This is the micro stim FSM that can be used by paradigms
iNumMicroStimChannels = length(g_strctAppConfig.m_strctDAQ.m_afStimulationPort);
fCurrTime = GetSecs();

for iMicroStimIter=1:iNumMicroStimChannels      

    if g_strctCycle.m_strctMicroStim.m_astrctTriggeringMachines(iMicroStimIter).m_bActive  && ...
            ( (fCurrTime - g_strctCycle.m_strctMicroStim.m_astrctTriggeringMachines(iMicroStimIter).m_fRequestTrigTS) >=  ...
            g_strctCycle.m_strctMicroStim.m_astrctTriggeringMachines(iMicroStimIter).m_strctTriggerInformation.m_fDelayToTrigMS/1e3)
            %  Time to trig!
            g_strctCycle.m_strctMicroStim.m_astrctTriggeringMachines(iMicroStimIter).m_bActive  = false;
           % try % try statement so if this fails we don't cook the monkey
				
				if g_strctParadigm.MicroStimBiPolar.Buffer(g_strctParadigm.MicroStimBiPolar.BufferIdx) && strcmpi(g_strctParadigm.m_strMicroStimSource,'wpi')
					% We're using the wpi device, in bipolar mode it needs two pulses of constant 5 volts describing the length of the stimulation
                    
                    % MicroStim code since the fnDAQNI function doesn't
                    % seem to cut it
					%tic
                    fnDAQWrapper('SetBit', g_strctAppConfig.m_strctDAQ.m_afStimulationPort(iMicroStimIter), 1);
                    delay(g_strctParadigm.MicroStimPulseWidthMS.Buffer(g_strctParadigm.MicroStimPulseWidthMS.BufferIdx)*1e-3)
                    fnDAQWrapper('SetBit', g_strctAppConfig.m_strctDAQ.m_afStimulationPort(iMicroStimIter), 0);
					%toc
					%tic
                    delay(g_strctParadigm.MicroStimBipolarDelayMS.Buffer(g_strctParadigm.MicroStimBipolarDelayMS.BufferIdx)*1e-3)
					%toc
					%tic
                    fnDAQWrapper('SetBit', g_strctAppConfig.m_strctDAQ.m_afStimulationPort(iMicroStimIter), 1);
                    delay(g_strctParadigm.MicroStimSecondPulseWidthMS.Buffer(g_strctParadigm.MicroStimSecondPulseWidthMS.BufferIdx)*1e-3)
                    fnDAQWrapper('SetBit', g_strctAppConfig.m_strctDAQ.m_afStimulationPort(iMicroStimIter), 0);
                    %toc
				elseif strcmpi(g_strctParadigm.m_strMicroStimSource,'wpi') && ~ g_strctParadigm.MicroStimBiPolar.Buffer(g_strctParadigm.MicroStimBiPolar.BufferIdx)
					fnDAQWrapper('TTL', g_strctAppConfig.m_strctDAQ.m_afStimulationPort(iMicroStimIter), g_strctParadigm.MicroStimPulseWidthMS);
				else
					fnDAQWrapper('TTL', g_strctAppConfig.m_strctDAQ.m_afStimulationPort(iMicroStimIter), 250*1e-6); % TTL pulse 0.25 ms
				end
			%catch 
			%	fnDAQWrapper('SetBit', g_strctAppConfig.m_strctDAQ.m_afStimulationPort(iMicroStimIter), 0); % Just in case
			%	warning('Stimulation failed for some reason, do not proceed with experiment until this is fixed')
				%fnDAQWrapper('TTL', g_strctAppConfig.m_strctDAQ.m_afStimulationPort(iMicroStimIter), 250*1e-6); % TTL pulse 0.25 ms
			%end

			fnDAQWrapper('StrobeWord',g_strctSystemCodes.m_iMicroStim);
            g_strctCycle.m_strctMicroStim.m_bShow  = true;
            g_strctCycle.m_strctMicroStim.m_fDisplayTimer  = fCurrTime;
			
    end
end

%% Handle Key Events
if g_strctGUIParams.m_bUseSpecialKeys
    if keyIsDown && g_strctCycle.m_iKeyFSM == 0
        if keyCode(g_strctGUIParams.m_fJuiceKey)
            fnParadigmToKofikoComm('Juice', g_strctGUIParams.m_fJuiceTimeMS, true);
        end;
        if keyCode(g_strctGUIParams.m_fRecenterKey)
            fnRecenterGaze();
        end;
        if keyCode(g_strctGUIParams.m_fDrawAttentionKey)
            fnDrawAttention();
        end
        if keyCode(g_strctGUIParams.m_fEyeTracesKey)
            g_strctCycle.m_strctEyeTraces.m_bShowEyeTraces = ~g_strctCycle.m_strctEyeTraces.m_bShowEyeTraces;
            if g_strctCycle.m_strctEyeTraces.m_bShowEyeTraces == 0
                g_strctCycle.m_strctEyeTraces.m_apt2fPreviousFixations(:) = 0;
            end
        end;
        if keyCode(g_strctGUIParams.m_fResetStatKey)
            feval(g_strctParadigm.m_strCallbacks,'ResetStat');
        end
        
        if keyCode(g_strctGUIParams.m_fToggleStat)
            fnToggleShowStatistics([],[]);
        end
        
        if keyCode(g_strctGUIParams.m_fTogglePTB)
            fnTogglePTB();
        end
        
        
        g_strctCycle.m_iKeyFSM = 1;
    end;
    if ~keyIsDown
        g_strctCycle.m_iKeyFSM = 0;
    end;
end
%afCycleDebugTimers(31) = GetSecs();

%afTimeStamp(13) = GetSecs();
% This crap takes forever, disable it when we need timing to be active for the microstimulator



if g_strctGUIParams.m_bSettingsPanelOn
    fCurrTime = fCycleTic;
	if fCurrTime-g_strctCycle.m_fSettingsTimer > g_strctGUIParams.m_fSettingsRefreshRateMS / 1000 
		%fnDrawSettings();
		set(g_handles.m_strctSettingsPanel.m_hMotionValue,'String',sprintf('Motion Value: %.1f, max(%.1f)',...
			g_strctCycle.m_afMaxMotion(g_strctCycle.m_iMaxMotionIndex),max(g_strctCycle.m_afMaxMotion)));
		g_strctCycle.m_fSettingsTimer =  fCycleTic;
	end;
end;

%% This is the juice FSM that can be used by paradigms
% if a paradigm has a field called m_iRewardMachineState, it can set it to
% one, and the valve will oepn for JuiceTimeMS
if g_strctCycle.m_strctJuiceProcess.m_iRewardMachineState > 0
    switch g_strctCycle.m_strctJuiceProcess.m_iRewardMachineState
        case 1
            fnJuiceOn();
            g_strctCycle.m_strctJuiceProcess.m_iNumJuicePulses = g_strctCycle.m_strctJuiceProcess.m_iNumJuicePulses - 1;
            g_strctCycle.m_strctJuiceProcess.m_iRewardMachineState = 2;

        case 2
            fCurrTime = fCycleTic;
            if fCurrTime-g_strctCycle.m_strctJuiceProcess.m_fParadigmRewardTimer > g_strctCycle.m_strctJuiceProcess.m_fRewardOpenTimeMS / 1e3
                fnJuiceOff();
                if g_strctCycle.m_strctJuiceProcess.m_iNumJuicePulses > 0
                    g_strctCycle.m_strctJuiceProcess.m_iRewardMachineState = 3;
                    g_strctCycle.m_strctJuiceProcess.m_fParadigmRewardTimer = fCurrTime;
                else
                    g_strctCycle.m_strctJuiceProcess.m_iRewardMachineState = 0;
                end;
            end

        case 3
            % Wait Inter Juice Interval
            if fCurrTime-g_strctCycle.m_strctJuiceProcess.m_fParadigmRewardTimer > g_strctCycle.m_strctJuiceProcess.m_iInterPulseIntervalMS / 1e3
               g_strctCycle.m_strctJuiceProcess.m_iRewardMachineState = 1; 
            end
    end;
end;
%afCycleDebugTimers(32) = GetSecs();

%% Actual screen update (i.e., the flip)
fCurrTime = fCycleTic;
if (fCurrTime-g_strctCycle.m_fScreenTimer) > g_strctGUIParams.m_fRefreshRateMS / 1000 && ...
        g_strctCycle.m_bRefreshScreen  && ~g_strctCycle.m_bValveOpen && ~g_strctCycle.m_bDoNotDrawDueToCriticalSection...
		
    % Remove buffer from stimulus parameters and call the draw function
    %afCycleDebugTimers(33) = GetSecs();
    Screen('FillRect', g_strctPTB.m_hWindow,  1);
    %if ~g_strctCycle.m_bParadigmPaused
		
        feval(g_strctParadigm.m_strDraw, g_strctCycle.m_bParadigmPaused);

	%end
    
    %afCycleDebugTimers(34) = GetSecs();
    % DrawMicro stim
    if g_strctCycle.m_strctMicroStim.m_bShow 
        if fCurrTime - g_strctCycle.m_strctMicroStim.m_fDisplayTimer < g_strctCycle.m_strctMicroStim.m_fDurationMS/1e3
            % Draw the micro stimulation sign
            
            fWidth = 30;
            fHeight = 60;
            fPenWidth = 3;
            pt2fStartPos = [50,20];
            Screen('DrawLine', g_strctPTB.m_hWindow, [255 0 0],  pt2fStartPos(1)+fWidth, pt2fStartPos(2)+0,         pt2fStartPos(1)+0,      pt2fStartPos(2)+fHeight/2, fPenWidth);
            Screen('DrawLine', g_strctPTB.m_hWindow, [255  0 0],  pt2fStartPos(1)+0,      pt2fStartPos(2)+fHeight/2, pt2fStartPos(1)+fWidth, pt2fStartPos(2)+fHeight/2, fPenWidth);
            Screen('DrawLine', g_strctPTB.m_hWindow, [255 0 0 ],  pt2fStartPos(1)+fWidth, pt2fStartPos(2)+fHeight/2, pt2fStartPos(1)+0,      pt2fStartPos(2)+fHeight,   fPenWidth);
        else
            g_strctCycle.m_strctMicroStim.m_bShow = false;
        end
    end
    if ~isempty(g_strctStimulusServer)
    Screen('FrameRect', g_strctPTB.m_hWindow,[255 255 255],...
        [0 0 g_strctPTB.m_fScale*g_strctStimulusServer.m_aiScreenSize(3),...
        g_strctPTB.m_fScale*g_strctStimulusServer.m_aiScreenSize(4)]);
    end
    
    %afCycleDebugTimers(35) = GetSecs();
    if g_strctDAQParams.m_fUseMouseClickAsEyePosition || g_strctDAQParams.m_bMouseGazeEmulator
        
        if aiButtons(1)
            fTouchRad = 80;
            aiTouchRect = [strctInputs.m_pt2iEyePosScreen-fTouchRad,strctInputs.m_pt2iEyePosScreen+fTouchRad];
            Screen('DrawArc',g_strctPTB.m_hWindow,[255 0 0],g_strctPTB.m_fScale*aiTouchRect,0,360);
            
        end
    end
    
    %afCycleDebugTimers(36) = GetSecs();
    if g_strctCycle.m_strctEyeTraces.m_bShowEyeTraces && ~g_bRecording
        Screen('FillRect',g_strctPTB.m_hWindow,[255 0 255],  g_strctCycle.m_strctEyeTraces.m_apt2fPreviousFixations);
    end
    %afCycleDebugTimers(37) = GetSecs();
    
    set(g_handles.hLogLine,'String',g_bLastLoggedList);
    
    
    % Draw where the monkey has looked before...
    
    
    aiInd = [g_strctCycle.m_strctEyeTraces.m_iLineIndex+1:g_strctCycle.m_strctEyeTraces.m_iLineTraceBuffer, 1:g_strctCycle.m_strctEyeTraces.m_iLineIndex-1];
    apt2fEyeTrace = g_strctPTB.m_fScale*g_strctCycle.m_strctEyeTraces.m_apt2fLastDifferentPos(:,[aiInd, aiInd(end:-1:1)]);
    Screen('FramePoly', g_strctPTB.m_hWindow,[100 0 0], apt2fEyeTrace',1);

    % Draw where the monkey is looking
    aiFixationRect = g_strctPTB.m_fScale*[fEyeXPix,fEyeYPix,fEyeXPix,fEyeYPix] + [-5 -5 5 5];
    Screen(g_strctPTB.m_hWindow,'FillRect',[255 0 0], aiFixationRect);
    
    % Always draw the center of the screen
    aiCrossHair1 = [g_strctPTB.m_fScale*g_strctStimulusServer.m_aiScreenSize(3)/2-5, g_strctPTB.m_fScale*g_strctStimulusServer.m_aiScreenSize(4)/2-1, ...
        g_strctPTB.m_fScale*g_strctStimulusServer.m_aiScreenSize(3)/2+5,g_strctPTB.m_fScale*g_strctStimulusServer.m_aiScreenSize(4)/2+1];
    aiCrossHair2 = [g_strctPTB.m_fScale*g_strctStimulusServer.m_aiScreenSize(3)/2-1, g_strctPTB.m_fScale*g_strctStimulusServer.m_aiScreenSize(4)/2-5, ...
        g_strctPTB.m_fScale*g_strctStimulusServer.m_aiScreenSize(3)/2+1,  g_strctPTB.m_fScale*g_strctStimulusServer.m_aiScreenSize(4)/2+5];
    
    Screen(g_strctPTB.m_hWindow,'FillRect',[0 255 0],  aiCrossHair1);
    Screen(g_strctPTB.m_hWindow,'FillRect',[0 255 0],  aiCrossHair2);
    
    % Draw the cycle time information (in red, if longer than the stimulus machine refresh rate
    %afCycleDebugTimers(38) = GetSecs();
    if ~isempty(g_strctStimulusServer) && g_strctCycle.m_fLastMaxCycle < g_strctStimulusServer.m_fRefreshRateMS || bSyncStimServerEvent
        aiColor = [0,0,0];
        strOut = sprintf('%d Hz (%.2f - %d ms, M %d P %d), %s J=%.2f ms',round(g_strctCycle.m_fLastCycleRate), g_strctCycle.m_fLastAvgCycle, ...
            g_strctCycle.m_fLastMaxCycle,g_strctCycle.m_fLastMaxUpdateTimeMatlab,...
            g_strctCycle.m_fLastMaxUpdateTimePTB, g_strctCycle.m_strPingPongStatus,g_strctDAQParams.StimulusServerSync.Buffer(1,3,g_strctDAQParams.StimulusServerSync.BufferIdx) * 1e3);
        set(g_handles.hRuntimeStatus,'String',strOut,'ForegroundColor', aiColor/255,'fontweight','normal');
    else
        aiColor = [255,0,0];
        strOut = sprintf('* %d Hz (%.2f - %d ms M %d P %d), %s J=%.2f ms',round(g_strctCycle.m_fLastCycleRate), g_strctCycle.m_fLastAvgCycle, ...
            g_strctCycle.m_fLastMaxCycle,g_strctCycle.m_fLastMaxUpdateTimeMatlab,...
            g_strctCycle.m_fLastMaxUpdateTimePTB, g_strctCycle.m_strPingPongStatus,g_strctDAQParams.StimulusServerSync.Buffer(1,3,g_strctDAQParams.StimulusServerSync.BufferIdx) * 1e3);
        set(g_handles.hRuntimeStatus,'String',strOut,'ForegroundColor', aiColor/255,'fontweight','bold');
    end;
    
    %afCycleDebugTimers(39) = GetSecs();
    % How long have we been running
    set(g_handles.hText2,'String',sprintf('Started @ %s\n',g_strctCycle.m_strStartedTimeDate));%, round((GetSecs()-g_strctCycle.m_fParadigmStarted) / 60)));
    
    %    afTimeStamp(16) = GetSecs();
    if g_strctCycle.m_strctDisplayMsg.m_iMachineState == 1
        pt2iCenter = g_strctPTB.m_aiRect(3:4)/2;
        iCharSizeInPix = 24;
        Screen('DrawText', g_strctPTB.m_hWindow,g_strctCycle.m_strctDisplayMsg.m_strMessage, pt2iCenter(1)-length(g_strctCycle.m_strctDisplayMsg.m_strMessage)/2*iCharSizeInPix,pt2iCenter(2),[50 0 200]);
        if fCycleTic - g_strctCycle.m_strctDisplayMsg.m_fTimer > g_strctCycle.m_strctDisplayMsg.m_fLengthSec
            g_strctCycle.m_strctDisplayMsg.m_iMachineState = 0;
        end
    end
    
    %afCycleDebugTimers(40) = GetSecs();
    % This is the fancy flashing red circle, indicating that we are
    % currently recording
    if ~g_bRecording
        if g_strctRealTimeStatServer.m_bConnected
            Screen(g_strctPTB.m_hWindow,'DrawText', 'RealTime Statistics on-line',g_strctPTB.m_aiRect(3) - 500 ,g_strctPTB.m_aiRect(1)+40, [0 255 0]);
        else
            Screen(g_strctPTB.m_hWindow,'DrawText', 'RealTime Statistics off-line',g_strctPTB.m_aiRect(3) - 500 ,g_strctPTB.m_aiRect(1)+40, [255 0 0]);
        end
    end
   
   %afCycleDebugTimers(41) = GetSecs();
    
    if g_bRecording
        fCurrTimer = fCycleTic;
        if g_strctCycle.m_iShowRecordState == 1 && (fCurrTimer - g_strctCycle.m_fShowRecordTimer > 0.8)
            g_strctCycle.m_fShowRecordTimer  = fCycleTic;
            g_strctCycle.m_iShowRecordState = 2;
            g_strctCycle.m_bShowRecord = false;
        end
        if g_strctCycle.m_iShowRecordState == 2 && (fCurrTimer - g_strctCycle.m_fShowRecordTimer > 0.2)
            g_strctCycle.m_iShowRecordState = 1;
            g_strctCycle.m_bShowRecord = true;
            g_strctCycle.m_fShowRecordTimer  = fCycleTic;
        end;
        if g_strctCycle.m_bShowRecord
            aiRecordSpot = [...
                g_strctPTB.m_aiRect(3) - 30,...
                g_strctPTB.m_aiRect(1),...
                g_strctPTB.m_aiRect(3),...
                g_strctPTB.m_aiRect(1) + 30];
            Screen(g_strctPTB.m_hWindow,'FillArc',[255 0 0], aiRecordSpot,0,360);
            Screen(g_strctPTB.m_hWindow,'DrawText',...
                sprintf('Exp [%d] Rec for %.0f min %.0f sec ', g_strctRecordingInfo.m_iSession, ...
                floor( (fCycleTic-g_strctRecordingInfo.m_fStart)/60),...
                mod( (fCycleTic-g_strctRecordingInfo.m_fStart),60)),...
                g_strctPTB.m_aiRect(3)-500,g_strctPTB.m_aiRect(2), [255 0 0]);
            
                  
        end;
    end;
    
    %afCycleDebugTimers(42) = GetSecs();
    Screen(g_strctPTB.m_hWindow,'DrawText',sprintf('%d Juice Rewards (%.0f ml)',g_strctGUIParams.m_iJuiceCounter, ...
        g_strctGUIParams.m_fJuiceTimeOpenTotalMS / g_strctGUIParams.m_fJuiceMl_To_Ms),...
        g_strctPTB.m_aiRect(1)+65,g_strctPTB.m_aiRect(4)-50, [255 0 255]);
    
    Screen(g_strctPTB.m_hWindow,'DrawText',sprintf('[%d] %s',g_strctParadigm.m_iMachineState,g_strctCycle.m_strState),...
        g_strctPTB.m_aiRect(1)+65,g_strctPTB.m_aiRect(4)-30, [0 255 0]);
     
    if g_strctCycle.m_bParadigmPaused
        Screen(g_strctPTB.m_hWindow,'DrawText',...
            sprintf('Paused for %.1f sec ', fCycleTic-g_strctCycle.m_fStartPause),...
            g_strctPTB.m_aiRect(1),g_strctPTB.m_aiRect(2), [0 255 0]);
    end;
   
    %afCycleDebugTimers(43) = GetSecs();
    
    if ~isempty(g_strctCycle.m_strSafeCallback)
        feval(g_strctParadigm.m_strCallbacks, g_strctCycle.m_strSafeCallback,g_strctCycle.m_acSafeCallbackParams{:});
        g_strctCycle.m_strSafeCallback = [];
    end
    %afCycleDebugTimers(44) = GetSecs();
    
    if isempty(g_strctStimulusServer) || ~g_strctStimulusServer.m_bConnected
        pt2iCenter = g_strctPTB.m_aiRect(3:4)/2;
        Screen('DrawText', g_strctPTB.m_hWindow, 'CONNECTION LOST!!!', pt2iCenter(1),pt2iCenter(2),[255 0 0]);
    end
    % Finally, the asynchornous flip (so we don't block Kofiko cycle function)
    fDrawTic=GetSecs;
    %    afTimeStamp(19) = GetSecs();
    %afCycleDebugTimers(45) = GetSecs();
    Screen('Flip', g_strctPTB.m_hWindow, 0, 0, 2);
    fDrawToc1 = GetSecs;
    %afCycleDebugTimers(46) = GetSecs();
    %    afTimeStamp(20) = GetSecs();
    g_strctCycle.m_fScreenTimer = fCurrTime;
    drawnow% update
    %afCycleDebugTimers(47) = GetSecs();
    %    afTimeStamp(21) = GetSecs();
    fDrawToc2 = GetSecs;
    g_strctCycle.m_fMaxUpdateTimeMatlab = max(g_strctCycle.m_fMaxUpdateTimeMatlab, fDrawToc2-fDrawToc1);
    g_strctCycle.m_fMaxUpdateTimePTB = max(g_strctCycle.m_fMaxUpdateTimePTB,fDrawToc1-fDrawTic);
end;


fCycleToc = GetSecs;

if ~isempty(g_strctStimulusServer) && (fCycleToc-fCycleTic)*1e3 >  g_strctStimulusServer.m_fRefreshRateMS && ~bSyncStimServerEvent
    %g_strctCycle.m_a2fDebugTS(:,g_strctCycle.m_iDebugCounter) = afCycleDebugTimers;
    g_strctCycle.m_iDebugCounter = g_strctCycle.m_iDebugCounter + 1;
    if g_strctCycle.m_iDebugCounter > size(g_strctCycle.m_a2fDebugTS,2)
        g_strctCycle.m_iDebugCounter = 1;
    end;
end

%afCycleDebugTimers(48) = GetSecs();
if ~isempty(g_strctStimulusServer) && ~g_strctAppConfig.m_strctStimulusServer.m_fSingleComputerMode
    %% Test Kofiko-Stimulus Server timing....
    switch g_strctCycle.m_iPingPongMachineState
        case 0
            % Send Ping
            g_strctCycle.m_fPingPongValue = rand();
            fnParadigmToStimulusServer('Ping',g_strctCycle.m_fPingPongValue);
            g_strctCycle.m_fPingTime = fCycleToc;
            g_strctCycle.m_iPingPongMachineState = 1;
        case 1
            if fCycleToc - g_strctCycle.m_fPingTime > g_strctCycle.m_fPingPongTimeoutMS /1e3
                % Warning. Lost connection with stimulus server (ping packet
                % lost)
                g_strctCycle.m_fPongTime = fCycleToc;
                g_strctCycle.m_iPingPongMachineState = 4;
                g_strctCycle.m_strPingPongStatus = 'Packet Lost'; %fprintf('Packet Lost!\n');
            end
        case 2
            % Pong recv with same rand value (i.e., good!)
            if g_strctCycle.m_fPongTime -  g_strctCycle.m_fPingTime > g_strctCycle.m_fPingPongTimeoutMS /1e3
                % Pong recved, but with a large timeout
                g_strctCycle.m_strPingPongStatus = 'Packet timedout'; %)  %.5f MS !\n', g_strctCycle.m_fPingPongTimeoutMS );
            else
                g_strctCycle.m_strPingPongStatus = sprintf('Pong=%.2f, ', 1e3*(g_strctCycle.m_fPongTime -  g_strctCycle.m_fPingTime) );
            end
            g_strctCycle.m_iPingPongMachineState = 4;
            
        case 3
            % Pong recv, but with incorrect rand value. something is terribly
            % wrong!
            g_strctCycle.m_iPingPongMachineState = 4;
            g_strctCycle.m_strPingPongStatus = 'Incorrect packet recved';
            
        case 4
            % Wait some time, and then go back to state 0
            if fCycleToc - g_strctCycle.m_fPongTime > g_strctCycle.m_fPingPongEveryMS/1e3
                g_strctCycle.m_iPingPongMachineState = 0;
            end
    end
end

%afCycleDebugTimers(49) = GetSecs();


%% Measure cycle timing
fCurrTime = fCycleTic;
if fCurrTime-g_strctCycle.m_fRateTimer > 1 % Update every one sec
    % We have three measures for cycle timing:
    % 1. Number of calls (how many times did this function was called in 1 sec)
    % 2. Max (the longest time this function took in the last sec)
    % 2. Mean (avg. time that this function took in the last sec)
    g_strctCycle.m_fLastCycleRate = g_strctCycle.m_iNumCycle /(fCurrTime-g_strctCycle.m_fRateTimer);
    g_strctCycle.m_fLastMaxCycle = round(g_strctCycle.m_fMaxCycleTime*1e3);
    g_strctCycle.m_fLastAvgCycle = mean(g_strctCycle.m_aiCycleTime(1:g_strctCycle.m_iNumCycle-1)) * 1e3;
    
    if g_bVERBOSE
        fprintf('Rate = %.2f Hz, avg %.2f max %.2f ms, drawnow %.2f \n',g_strctCycle.m_fLastCycleRate,g_strctCycle.m_fLastAvgCycle,...
            g_strctCycle.m_fLastMaxCycle,g_strctCycle.m_fMaxUpdateTime*1e3 );
    end;
    
    g_strctCycle.m_afCycleTime(g_strctCycle.m_iCycleTimeIndex) = g_strctCycle.m_fLastMaxCycle;
    g_strctCycle.m_iCycleTimeIndex = g_strctCycle.m_iCycleTimeIndex + 1;
    
    
    g_strctCycle.m_fLastMaxUpdateTimeMatlab = round(1e3*g_strctCycle.m_fMaxUpdateTimeMatlab);
    g_strctCycle.m_fLastMaxUpdateTimePTB = round(1e3*g_strctCycle.m_fMaxUpdateTimePTB);
    
    g_strctCycle.m_fMaxUpdateTimeMatlab = 0;
    g_strctCycle.m_fMaxUpdateTimePTB = 0;
    g_strctCycle.m_fMaxCycleTime = 0;
    g_strctCycle.m_fMaxUpdateTime = 0;
    g_strctCycle.m_fRateTimer = fCycleTic;
    g_strctCycle.m_iNumCycle = 0;
end;


%% Update timers that measure cycle time
g_strctCycle.m_fMaxCycleTime = max(fCycleToc-fCycleTic, g_strctCycle.m_fMaxCycleTime);
g_strctCycle.m_iNumCycle = g_strctCycle.m_iNumCycle + 1;
g_strctCycle.m_aiCycleTime(g_strctCycle.m_iNumCycle) = fCycleToc-fCycleTic;
return;


function delay(seconds)
% function pause the program
% seconds = delay time in seconds
tic;
while toc < seconds
end
return;
