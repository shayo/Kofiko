function fnRunParadigm()
% Setup the stuff that is needed to run the paradigm and then loop over the
% cycle function
global g_bParadigmRunning g_strctGUIParams g_iCurrParadigm  g_strctAppConfig
global g_strctParadigm g_strctStimulusServer g_strctDAQParams g_strctSystemCodes 
global g_abParadigmInitialized g_astrctAllParadigms 
global g_strctCycle g_iNextParadigm 

g_strctParadigm = g_astrctAllParadigms{g_iCurrParadigm};

g_bParadigmRunning = true;

g_strctCycle.m_bMouseDown = false;

g_strctCycle.m_bTrialNotInProgress = true;

g_strctCycle.m_strctDisplayMsg.m_fTimer = 0;
g_strctCycle.m_strctDisplayMsg.m_fLengthSec = 2;
g_strctCycle.m_strctDisplayMsg.m_iMachineState = 0;
g_strctCycle.m_strctDisplayMsg.m_strMessage = '';



g_strctCycle.m_strctStatistics.m_iTrialType = 0;

g_strctCycle.m_strctPrevMouse.m_fMouseX  = 0;

g_strctCycle.m_strctMicroStim.m_bShow = false;
g_strctCycle.m_strctMicroStim.m_fDisplayTimer = 0;
g_strctCycle.m_strctMicroStim.m_fStimTimer = GetSecs();
g_strctCycle.m_strctMicroStim.m_fDurationMS = 150;
g_strctCycle.m_strctMicroStim.m_bActive = false;

% Set the triggering Finite state machines
iNumMicroStimChannels = length(g_strctAppConfig.m_strctDAQ.m_afStimulationPort);
for iMicroStimIter=1:iNumMicroStimChannels      
    g_strctCycle.m_strctMicroStim.m_astrctTriggeringMachines(iMicroStimIter).m_bActive = false;
    g_strctCycle.m_strctMicroStim.m_astrctTriggeringMachines(iMicroStimIter).m_fRequestTrigTS = 0;
    g_strctCycle.m_strctMicroStim.m_astrctTriggeringMachines(iMicroStimIter).m_strctTriggerInformation = [];
end



g_strctCycle.m_iTrialCounter = 1;
g_strctCycle.m_fTrialStartTime = GetSecs;

g_strctCycle.m_iTrialFSM_NumStimuli = 0;
g_strctCycle.m_bValveOpen = 0;


if ~g_strctAppConfig.m_strctStimulusServer.m_fSingleComputerMode
    fnParadigmToStimulusServer('UpdateParadigm',g_strctParadigm.m_strDrawCycle);
end

if ~g_abParadigmInitialized(g_iCurrParadigm)
    fnLog('Initializing Paradigm %s',g_strctParadigm.m_strName);
    bSuccessful = feval(g_strctParadigm.m_strInit);
    if ~bSuccessful
        fprintf('Failed to initialize paradigm %s\n',g_strctParadigm.m_strName);
        fnParadigmToKofikoComm('DisplayMessage', sprintf('Failed to Initialize %s',g_strctParadigm.m_strName));
        g_iNextParadigm = 1;
        return;
    end
    
    g_strctCycle.m_strStartedTimeDate = datestr(now,13);
    g_strctCycle.m_bParadigmPaused = false;
    g_strctCycle.m_fStartPause = GetSecs();
    g_strctCycle.m_pt2fCurrentFixationPosition = g_strctStimulusServer.m_aiScreenSize(3:4)/2;
else
    % Very important(!), otherwise drawing on stimulus server will crash since
    % it will not know which paradigm is running.
    fnLog('Initializing Stimulus Server for new paradigm');
    feval(g_strctParadigm.m_strParadigmSwitch,'Init');
    fnLog('Finished initializing Stimulus Server for new paradigm');
end;

if ~g_abParadigmInitialized(g_iCurrParadigm)
    % Setup paradigm GUI only once. Afterthat, it is hidden
    feval(g_strctParadigm.m_strGUI);
else
    % Set the main panel visible
    if isfield(g_strctParadigm,'m_strctControllers') && isfield(g_strctParadigm.m_strctControllers,'m_hPanel') 
        set(g_strctParadigm.m_strctControllers.m_hPanel,'visible','on');
    end;
end;

if ~g_abParadigmInitialized(g_iCurrParadigm)
    g_abParadigmInitialized(g_iCurrParadigm) = 1;
end;

fnResetStat();
g_strctCycle.m_bRefreshScreen = true;

g_strctCycle.m_fRateTimer = GetSecs;
g_strctCycle.m_iNumCycle = 0;
g_strctCycle.m_fScreenTimer = GetSecs;

g_strctCycle.m_strctJuiceProcess.m_fRewardTimer = GetSecs;
g_strctCycle.m_strctJuiceProcess.m_iRewardMachineState = 0;
g_strctCycle.m_strctJuiceProcess.m_fRewardOpenTimeMS = 0;
g_strctCycle.m_strctJuiceProcess.m_iNumJuicePulses = 0;
g_strctCycle.m_strctJuiceProcess.m_iInterPulseIntervalMS = 0;

g_strctCycle.m_fLastCycleRate = 0;
g_strctCycle.m_fDebugTimer = 0;
%g_iRewardMachineState = 0;

%fMaxSamplingRate = 20000; % 20 kHz
%iMaxBufferLength = ceil(fMaxSamplingRate * g_strctGUIParams.m_fSpikeRateUpdateMS/1000);
%g_strctCycle.m_a2bSpikeBuffers = zeros(iNumSpikeChannels, iMaxBufferLength,'uint8')>0;
%g_strctCycle.m_iSpikeBufferIndex = 1;
%g_strctCycle.m_afFiringRateMethodA = zeros(1, iNumSpikeChannels);
%g_strctCycle.m_afFiringRateMethodB = zeros(1, iNumSpikeChannels);
%g_strctCycle.m_fSpikeRateTimer = 0;

fnDAQWrapper('StrobeWord', g_strctSystemCodes.m_iParadigmSwitch);
fnLog('Switching to paradigm %s',g_strctParadigm.m_strName);

% This will replace the silly fnLog in version later than 1010
g_strctAppConfig = fnTsSetVar(g_strctAppConfig,'ParadigmSwitch',g_strctParadigm.m_strName);

fnLog('Finite state machine of %s is running, starting from state %d',...
    g_strctParadigm.m_strName, g_strctParadigm.m_iMachineState);


g_strctCycle.m_fKeyboardMouseInteractionTimer = GetSecs;
g_strctCycle.m_fKeyboardMouseInteractionMS = 60;
g_strctCycle.m_fLastMousePosX = 0;
g_strctCycle.m_fLastMousePosY = 0;
g_strctCycle.m_aiLastMouseButtons = [0,0,0];
g_strctCycle.m_bLastkeyIsDown = false;
g_strctCycle.m_abLastkeyCode = zeros(1,256);


g_strctCycle.m_afCycleTime = zeros(1,3600 * 10);  %10 hours should be enough....
g_strctCycle.m_iCycleTimeIndex = 1;
g_strctCycle.m_fLastMaxCycle = 0;

g_strctCycle.m_bShowRecord = true;
g_strctCycle.m_iShowRecordState = 1;
g_strctCycle.m_fShowRecordTimer = 0;

g_strctCycle.m_bShowSpikes = true;
g_strctCycle.m_iKeyFSM = 0;
g_strctCycle.m_iMouseFSM = 0;

g_strctCycle.m_fMaxCycleTime = 0;
g_strctCycle.m_fMaxUpdateTime = 0;
g_strctCycle.m_fLastMaxCycle = 0;
g_strctCycle.m_fStatisticsTimer = 0;
g_strctCycle.m_fSettingsTimer = 0;
g_strctCycle.m_fLastAvgCycle = 0;
g_strctCycle.m_fLastMaxUpdateTime = 0;

g_strctCycle.m_fMaxUpdateTimeMatlab = 0;
g_strctCycle.m_fMaxUpdateTimePTB = 0;
g_strctCycle.m_fLastMaxUpdateTimeMatlab = 0;
g_strctCycle.m_fLastMaxUpdateTimePTB = 0;
g_strctCycle.m_fEyeTrackTimer = 0;
g_strctCycle.m_fEyeTrackElapsedMS = 1/g_strctAppConfig.m_strctVarSave.m_fEyePosSampleRateHz *1000;
    
g_strctCycle.m_aiCycleTime = zeros(1,50000); % No way we gonna get a cycle time larger than 50kHz

g_strctCycle.m_fParadigmStarted = GetSecs();

g_strctCycle.m_fSyncTimer = GetSecs();
g_strctCycle.m_fSyncPeriodSec = 1; % Send SYNC every 1 sec to align clocks
g_strctCycle.m_fStimServSyncTimer = GetSecs();

g_strctCycle.m_bMotionBufferInitialized = false;
g_strctCycle.m_afMotionBuffer = zeros(1,1000);
g_strctCycle.m_iMotionBufferIndex = 1;
g_strctCycle.m_fMotionTimer = GetSecs;
g_strctCycle.m_fMotionUpdateMedianSec = 2;

% Motion for statistics
g_strctCycle.m_fMaxMotionUpdateSec = 1;
g_strctCycle.m_iMaxMotionIndex = 1;
g_strctCycle.m_afMaxMotion = zeros(1,10);
g_strctCycle.m_fMaxMotionTimer = GetSecs;
g_strctCycle.m_fMaxMotion = 0;


g_strctCycle.m_iMotionFSM_State = 0;
g_strctCycle.m_fMotionBaseline = 0;
%g_strctCycle.m_bMajorParamChange = false;


g_strctCycle.m_iPingPongMachineState = 0;
g_strctCycle.m_fPingTime = 0;
g_strctCycle.m_fPongTime = 0;
g_strctCycle.m_fPingPongValue = 0;
g_strctCycle.m_fPingPongEveryMS = 3000;
g_strctCycle.m_fPingPongTimeoutMS = 3000;
g_strctCycle.m_strPingPongStatus = '';


g_strctCycle.m_strctEyeTraces.m_bShowEyeTraces = true;
g_strctCycle.m_strctEyeTraces.m_iBufferSize = 1000;
g_strctCycle.m_strctEyeTraces.m_apt2fPreviousFixations = zeros(4,g_strctCycle.m_strctEyeTraces.m_iBufferSize);
g_strctCycle.m_strctEyeTraces.m_iPrevFixationIndex = 1;
g_strctCycle.m_strctEyeTraces.m_iPrevFixationTimer = GetSecs();
g_strctCycle.m_strctEyeTraces.m_iPrevFixationUpdateMS = 500;

g_strctCycle.m_strctEyeTraces.m_iLineTraceBuffer = 150;
g_strctCycle.m_strctEyeTraces.m_apt2fLastDifferentPos = zeros(2, g_strctCycle.m_strctEyeTraces.m_iLineTraceBuffer);
g_strctCycle.m_strctEyeTraces.m_iLineIndex = 1;

g_strctCycle.m_iTrialFSM_Success = false;

g_strctCycle.m_strctMotion.m_fSampleTimer = GetSecs();
g_strctCycle.m_strctMotion.m_fElapsedMS = 1/g_strctAppConfig.m_strctVarSave.m_fMotionSampleRateHz * 1000;

g_strctCycle.m_bDoNotDrawDueToCriticalSection = false;
g_strctCycle.m_bInCriticalSection = false;

g_strctCycle.m_strctVideo.m_fTimer = GetSecs();
g_strctCycle.m_strctVideo.m_a3iImage = [];

g_strctCycle.m_strSafeCallback = [];
g_strctCycle.m_acSafeCallbackParams = [];
g_strctCycle.m_fMouseTouchTimer = GetSecs();       
% 
% iNumAdvancers = length(g_strctDAQParams.m_a2iAdvancerMappingToChamberHole(:,1));
% if iNumAdvancers > 0
%     g_strctCycle.m_aiPrevWheelPosition = fndllMiceHook('GetWheels',g_strctDAQParams.m_a2iAdvancerMappingToChamberHole(:,1));
% else
%     g_strctCycle.m_aiPrevWheelPosition = [];
% end

g_strctCycle.m_pt2fPrevMousePos = [0,0];

g_strctCycle.m_iDebugCounter = 1;
g_strctCycle.m_a2fDebugTS = zeros(50,50000);

g_strctCycle.m_strState  = '';
%% Main call is here
while (g_bParadigmRunning)
        fnKofikoCycleClean();
 end;

%%

% various clean ups what user may have forgotten to code.

% Just in case we were in a state in which the juicer was open.
fnParadigmToKofikoComm('JuiceOff');
fnLog('Closing juice valve');

feval(g_strctParadigm.m_strParadigmSwitch,'Close');

% And clear the screen 
fnLog('Clearing screen');
if ~g_strctAppConfig.m_strctStimulusServer.m_fSingleComputerMode
    fnParadigmToStimulusServer('ClearScreen');
end
fnDeleteCurrentGUI();

g_astrctAllParadigms{g_iCurrParadigm} = g_strctParadigm;
return;