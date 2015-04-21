function varargout = fnParadigmToKofikoComm(strCommand, varargin)
global g_strctCycle g_strctGUIParams g_bRecording g_strctStimulusServer g_strctRecordingInfo g_strctPTB g_strctAppConfig g_strctEyeCalib g_strctSystemCodes g_strctDAQParams g_strctAcquisitionServer
switch lower(strCommand) 

    case 'setparadigmstate'
        g_strctCycle.m_strState = varargin{1};
    case 'multichannelstimulation'
        if ~isempty(g_strctAppConfig.m_strctDAQ.m_afStimulationPort)
             astrctTriggerInfo = varargin{1};
             
           % Set the triggering Finite state machines
             iNumChannelsNeedTrigger = length(astrctTriggerInfo);
             fCurrTime = GetSecs();
             afAmplitudes = fnTsGetVar(g_strctDAQParams,'MicroStimAmplitude');
             acMicroStimSource = fnTsGetVar(g_strctDAQParams,'MicroStimSource');
             for iIter=1:iNumChannelsNeedTrigger
                 if ~isfield(astrctTriggerInfo(iIter),'m_fAmplitude') || ...
                         (isfield(astrctTriggerInfo(iIter),'m_fAmplitude') && isempty(astrctTriggerInfo(iIter).m_fAmplitude))
                     astrctTriggerInfo(iIter).m_fAmplitude = afAmplitudes(astrctTriggerInfo(iIter).m_iChannel);
                 end
     
     
                if ~isfield(astrctTriggerInfo(iIter),'m_strSource') || ...
                         (isfield(astrctTriggerInfo(iIter),'m_strSource') && isempty(astrctTriggerInfo(iIter).m_strSource))
                     astrctTriggerInfo(iIter).m_strSource = acMicroStimSource{astrctTriggerInfo(iIter).m_iChannel};
                 end
  
                    iChannelNeedTrigger = astrctTriggerInfo(iIter).m_iChannel;
                    g_strctCycle.m_strctMicroStim.m_astrctTriggeringMachines(iChannelNeedTrigger).m_bActive = true;
                    g_strctCycle.m_strctMicroStim.m_astrctTriggeringMachines(iChannelNeedTrigger).m_fRequestTrigTS = fCurrTime;
                    g_strctCycle.m_strctMicroStim.m_astrctTriggeringMachines(iChannelNeedTrigger).m_strctTriggerInformation = astrctTriggerInfo(iIter);
             end
             
             % Add stimulation request to time stamped buffer (just to be
             % on the safe side. This information should be available in
             % trials somewhere because it is much easier to parse....
             
             g_strctDAQParams = fnTsSetVar(g_strctDAQParams,'MicroStimTriggers', astrctTriggerInfo);
             
             
        else
            fnParadigmToKofikoComm('DisplayMessage','No stim port defined in XML');
        end
        
    case 'juice'
        g_strctCycle.m_strctJuiceProcess.m_iRewardMachineState = 1; % Give Juice as defined in g_strctParadigm.m_iJuiceTimeMS
        g_strctCycle.m_strctJuiceProcess.m_fRewardOpenTimeMS = varargin{1};
        if nargin >= 3
            g_strctCycle.m_strctJuiceProcess.m_bManual = varargin{2} > 0;
        else
            g_strctCycle.m_strctJuiceProcess.m_bManual = false;
        end
        
        if nargin >= 4
            g_strctCycle.m_strctJuiceProcess.m_iNumJuicePulses = varargin{3};
        else
            g_strctCycle.m_strctJuiceProcess.m_iNumJuicePulses = 1;
        end
        if nargin >= 5
            g_strctCycle.m_strctJuiceProcess.m_iInterPulseIntervalMS = varargin{4};
        else
            g_strctCycle.m_strctJuiceProcess.m_iInterPulseIntervalMS = varargin{1};
        end
        g_strctGUIParams.m_iJuiceCounter = g_strctGUIParams.m_iJuiceCounter + g_strctCycle.m_strctJuiceProcess.m_iNumJuicePulses;
        g_strctGUIParams.m_fJuiceTimeOpenTotalMS = g_strctGUIParams.m_fJuiceTimeOpenTotalMS + ...
            g_strctCycle.m_strctJuiceProcess.m_fRewardOpenTimeMS*g_strctCycle.m_strctJuiceProcess.m_iNumJuicePulses;
        
    case 'juiceblock'
        fRewardOpenTimeMS = varargin{1};
        g_strctGUIParams.m_iJuiceCounter = g_strctGUIParams.m_iJuiceCounter +1;
        g_strctGUIParams.m_fJuiceTimeOpenTotalMS = g_strctGUIParams.m_fJuiceTimeOpenTotalMS + ...
            g_strctCycle.m_strctJuiceProcess.m_fRewardOpenTimeMS*g_strctCycle.m_strctJuiceProcess.m_iNumJuicePulses;
        fnDAQWrapper('TTL',g_strctDAQParams.m_fJuicePort, fRewardOpenTimeMS/1e3);
        
        fnDAQWrapper('StrobeWord', g_strctSystemCodes.m_iJuiceON);
        fnDAQWrapper('StrobeWord', g_strctSystemCodes.m_iJuiceOFF);
    case 'juiceoff'
        fnJuiceOff();
        g_strctCycle.m_strctJuiceProcess.m_iRewardMachineState = 0;
    case 'displaymessagenow'
        strMessage = varargin{1};
        pt2iCenter = g_strctPTB.m_aiRect(3:4)/2;
        pt2iCenter(1) = pt2iCenter(1) - length(strMessage) * 3;
        Screen('DrawText', g_strctPTB.m_hWindow, strMessage, pt2iCenter(1),pt2iCenter(2),[0 255 0]);
        Screen('Flip',g_strctPTB.m_hWindow,0);
    case 'displaymessage'
        g_strctCycle.m_strctDisplayMsg.m_iMachineState = 1;
        g_strctCycle.m_strctDisplayMsg.m_fTimer = GetSecs();
        g_strctCycle.m_strctDisplayMsg.m_strMessage = varargin{1};
        if length(varargin) >= 2
            g_strctCycle.m_strctDisplayMsg.m_fLengthSec = varargin{2};
        else
            g_strctCycle.m_strctDisplayMsg.m_fLengthSec = 3;
        end
    case 'resetstat'
        if nargin >= 2
            strWhatToReset = varargin{1};
            fnResetStat(strWhatToReset);
        else
            fnResetStat('AllChannels');
        end
    case 'trialstart'
        if isfield(g_strctDAQParams,'m_fTrialOnsetPort') && g_bRecording
            % Send sync pulse and pick a new sync interval
            fnDAQWrapper('TTL', g_strctDAQParams.m_fTrialOnsetPort,250 * 1e-6); % 250usec TTL pulse
        end
        g_strctCycle.m_bTrialNotInProgress = false;
        g_strctCycle.m_fTrialStartTime = GetSecs();
        g_strctCycle.m_strctStatistics.m_iTrialType= varargin{1};
        fnDAQWrapper('StrobeWord',g_strctCycle.m_strctStatistics.m_iTrialType);
        if g_strctAcquisitionServer.m_bConnected
            fndllZeroMQ_Wrapper('Send',g_strctAcquisitionServer.m_iSocket,['TrialType ',num2str(g_strctCycle.m_strctStatistics.m_iTrialType)]);
        end
    case 'trialend'
        g_strctCycle.m_bTrialNotInProgress = true;
        g_strctCycle.m_iTrialFSM_Success = varargin{1};
    case 'ispaused'
        varargout{1} = g_strctCycle.m_bParadigmPaused;
    case 'setfixationposition'
        g_strctCycle.m_pt2fCurrentFixationPosition =  varargin{1};
        if isfield(g_strctAppConfig,'m_strctAcquisitionServer') && g_strctAcquisitionServer.m_bConnected
            fndllZeroMQ_Wrapper('Send',g_strctAcquisitionServer.m_iSocket,['FixationSpotPosition ',...
                num2str(g_strctCycle.m_pt2fCurrentFixationPosition(1)),' ',num2str(g_strctCycle.m_pt2fCurrentFixationPosition(2)),' ',...
                num2str(g_strctStimulusServer.m_aiScreenSize(3)),' ',num2str(g_strctStimulusServer.m_aiScreenSize(4))]);
        end
    case 'showeyetraces'
        g_strctCycle.m_strctEyeTraces.m_bShowEyeTraces  = true;
    case 'hideeyetraces'
        g_strctCycle.m_strctEyeTraces.m_bShowEyeTraces  = false;        
    case 'cleareyetraces'
        g_strctCycle.m_strctEyeTraces.m_apt2fPreviousFixations(:) = 0;
    case 'activechannel'
        varargout{1} = g_strctGUIParams.m_iSelectedChannel;
    case 'activeunit'
        varargout{1} = g_strctGUIParams.m_iSelectedUnit;
    case 'startrecording'
        if length(varargin) >= 1
            varargout{1} = fnStartRecording(varargin{1});
        else
            varargout{1} = fnStartRecording(0.2); % Default Delay
        end
    case 'stoprecording'
        if g_bRecording
            if length(varargin) >= 1
                fnStopRecording(varargin{1});
            else
                fnStopRecording(0.2); % Default Delay
            end
        end
    case 'isrecording'
        varargout{1} = g_bRecording;
    case 'getrefreshrate'
        varargout{1} = g_strctStimulusServer.m_fRefreshRateMS;
    case 'getstimulusserverscreensize'
        varargout{1} = g_strctStimulusServer.m_aiScreenSize;
      
    case 'playsound'
        bTouchMode = isfield(g_strctStimulusServer,'m_hWindow');
        strSoundName = varargin{1};
        if bTouchMode
            % Play sound locally.
            fnPlayAsyncSound(strSoundName);
        else
            % Send request to stimulus server to play sound....
            fnParadigmToStimulusServer('PlaySound',strSoundName);
        end
    case 'getstimulusservercenter'
        varargout{1} = (g_strctStimulusServer.m_aiScreenSize(3:4)-g_strctStimulusServer.m_aiScreenSize(1:2))/2+g_strctStimulusServer.m_aiScreenSize(1:2);
    case 'numrecordedexperiments'
        varargout{1} = g_strctRecordingInfo.m_iSession;
    case 'isjuiceon'
        varargout{1} = g_strctCycle.m_bValveOpen == 1;
    case 'safecallback'
        g_strctCycle.m_strSafeCallback = varargin{1};
        if length(varargin) > 1
            g_strctCycle.m_acSafeCallbackParams = varargin(2:end);
        else
            g_strctCycle.m_acSafeCallbackParams = {[]};
        end
    case 'criticalsectionon'
        g_strctCycle.m_bInCriticalSection = true;
        if nargin > 1
            g_strctCycle.m_bDoNotDrawDueToCriticalSection = varargin{1};
        else
            g_strctCycle.m_bDoNotDrawDueToCriticalSection = false;
        end
    case 'criticalsectionoff'
        g_strctCycle.m_bDoNotDrawDueToCriticalSection = false;
        g_strctCycle.m_bInCriticalSection = false;
    case 'mouseemulator'
        bTurnON = varargin{1};
        
        if bTurnON
            g_strctDAQParams.m_bMouseGazeEmulator =1 ;
            % Keep original values!
            g_strctEyeCalib.m_fSavedGainX = fnTsGetVar(g_strctEyeCalib,'GainX');
            g_strctEyeCalib.m_fSavedGainY = fnTsGetVar(g_strctEyeCalib,'GainY');
            g_strctEyeCalib.m_fSavedCenterX = fnTsGetVar(g_strctEyeCalib,'CenterX');
            g_strctEyeCalib.m_fSavedCenterY = fnTsGetVar(g_strctEyeCalib,'CenterY');

            g_strctEyeCalib = fnTsSetVar(g_strctEyeCalib,'GainX',1);
            g_strctEyeCalib = fnTsSetVar(g_strctEyeCalib,'GainY',1);
            g_strctEyeCalib = fnTsSetVar(g_strctEyeCalib,'CenterX', g_strctPTB.m_aiRect(3)/2);
            g_strctEyeCalib = fnTsSetVar(g_strctEyeCalib,'CenterX', g_strctPTB.m_aiRect(4)/2);

        else
            g_strctDAQParams.m_bMouseGazeEmulator =0;
            g_strctEyeCalib = fnTsSetVar(g_strctEyeCalib,'GainX',g_strctEyeCalib.m_fSavedGainX);
            g_strctEyeCalib = fnTsSetVar(g_strctEyeCalib,'GainY',g_strctEyeCalib.m_fSavedGainY);
            g_strctEyeCalib = fnTsSetVar(g_strctEyeCalib,'CenterX',g_strctEyeCalib.m_fSavedCenterX);
            g_strctEyeCalib = fnTsSetVar(g_strctEyeCalib,'CenterY',g_strctEyeCalib.m_fSavedCenterY);
        end
    case 'stimulationttl'
        if ~isempty(g_strctAppConfig.m_strctDAQ.m_afStimulationPort)
            
            iChannel = varargin{1};
            if nargin > 1
                fAmplitude = varargin{2};
            else
                fAmplitude = NaN;
            end;
            
            acMicroStimSource = fnTsGetVar(g_strctDAQParams,'MicroStimSource');
            
            if nargin > 3
                strSource = varargin{4};
            else
                strSource = acMicroStimSource{iChannel};
            end;
            
            if iChannel >= 1 && iChannel <= length(g_strctAppConfig.m_strctDAQ.m_afStimulationPort)
                fnDAQWrapper('TTL', g_strctAppConfig.m_strctDAQ.m_afStimulationPort(iChannel), 250*1e-6); % TTL width is 250 micro seconds or 0.25ms
                fnDAQWrapper('StrobeWord',g_strctSystemCodes.m_iMicroStim);
                g_strctCycle.m_strctMicroStim.m_fDisplayTimer = GetSecs();
                g_strctCycle.m_strctMicroStim.m_bShow  = true;
                
                astrctTriggerInfo(1).m_iChannel = iChannel;
                astrctTriggerInfo(1).m_fDelayToTrigMS = 0;
                astrctTriggerInfo(1).m_fAmplitude = fAmplitude;
                astrctTriggerInfo(1).m_strSource = strSource;
                g_strctDAQParams = fnTsSetVar(g_strctDAQParams,'MicroStimTriggers', astrctTriggerInfo);
                
            else
                fnParadigmToKofikoComm('DisplayMessage','Stim port outside range defined in XML');
            end
            
        else
            fnParadigmToKofikoComm('DisplayMessage','No stim port defined in XML');
        end

        
    case 'istouchmode'
         varargout{1} = isfield(g_strctStimulusServer,'m_hWindow');
 
    case 'getvideoframe'
        varargout{1} = g_strctCycle.m_strctVideo.m_a3iImage;
        varargout{2} = g_strctCycle.m_strctVideo.m_fTimer;
   case 'getvideoframenow'
       g_strctCycle.m_strctVideo.m_a3iImage = YUY2toRGB(getsnapshot(g_strctAppConfig.m_hVideoGrabber));
       g_strctCycle.m_strctVideo.m_fTimer = GetSecs();
        varargout{1} = g_strctCycle.m_strctVideo.m_a3iImage;
        varargout{2} = g_strctCycle.m_strctVideo.m_fTimer;

    case 'clearmessagebuffer'
        % Clear message buffer
        X = 1;
        fTimer = GetSecs();
        while (~isempty(X))
            [X] = msrecv(g_strctStimulusServer.m_iSocket,0);
            if isempty(X) && GetSecs()-fTimer > 0.1
                break;
            else
                fTimer = GetSecs();
            end
        end
        
    case 'blockuntilmessage'
        
        
        strWaitForMsg = varargin{1};
        iWaitCounter = varargin{2};
        fTimeOut = varargin{3};
        fLastMessage = GetSecs();
        fTimer = GetSecs();
        iLastImageLoaded = 0;
        bTimeOut = true;
        while (1)
            [acInputFromStimulusServer, iSocketErrorCode] = msrecv(g_strctStimulusServer.m_iSocket,0.005);
            if ~isempty(acInputFromStimulusServer)&&  strcmp(acInputFromStimulusServer{1},strWaitForMsg)
                iImage = acInputFromStimulusServer{2};
                iLastImageLoaded =iImage;
                fLastMessage = GetSecs();
                if iWaitCounter== iImage
                    bTimeOut = false;
                    break;
                end
            end
            if GetSecs()- fLastMessage > fTimeOut
                fnParadigmToKofikoComm('DisplayMessage','Failed to load!');
                break;
            end
            if GetSecs()-fTimer > 1
                fTimer = GetSecs();
                fnParadigmToKofikoComm('DisplayMessageNow',sprintf('Still Loading %d/%d',iLastImageLoaded,iWaitCounter));
            end
        end
        varargout{1} = bTimeOut;
        return 
    otherwise
        % unknown kofiko command
        fnParadigmToKofikoComm('DisplayMessage', sprintf('Unknown API : %s', strCommand));
end

return;

    