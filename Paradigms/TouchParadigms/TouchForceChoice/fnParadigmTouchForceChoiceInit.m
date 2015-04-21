function bSuccessful = fnParadigmTouchForceChoiceInit()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm  


% Default initializations...
g_strctParadigm.m_fStartTime = GetSecs;
g_strctParadigm.m_iMachineState = 0; % Always initialize first state to zero.

iSmallBuffer = 500;
iLargeBuffer = 50000;

%% Pre Cue
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'PreCueFixationPeriodMS', g_strctParadigm.m_fInitial_PreCueFixationPeriodMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'PreCueFixationSpotSize', g_strctParadigm.m_fInitial_PreCueFixationSpotSize, iSmallBuffer);
if isfield(g_strctParadigm,'m_strInitial_PreCueFixationSpotType')
    g_strctParadigm = fnTsAddVar(g_strctParadigm, 'PreCueFixationSpotType', g_strctParadigm.m_strInitial_PreCueFixationSpotType, iSmallBuffer);
else
    g_strctParadigm = fnTsAddVar(g_strctParadigm, 'PreCueFixationSpotType', 'Disc', iSmallBuffer);
end

%% Cue
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'CuePeriodMS', g_strctParadigm.m_fInitial_CuePeriodMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'CueMemoryPeriodMS', g_strctParadigm.m_fInitial_CueMemoryPeriodMS, iSmallBuffer);
if isfield(g_strctParadigm,'m_fInitial_CueNoiseLevel')
    g_strctParadigm = fnTsAddVar(g_strctParadigm, 'CueNoiseLevel', g_strctParadigm.m_fInitial_CueNoiseLevel, iSmallBuffer);
else
    g_strctParadigm = fnTsAddVar(g_strctParadigm, 'CueNoiseLevel', 0, iSmallBuffer);
end
if isfield( g_strctParadigm,'m_fInitial_CueSizePix')
    g_strctParadigm = fnTsAddVar(g_strctParadigm, 'CueSizePix', g_strctParadigm.m_fInitial_CueSizePix, iSmallBuffer);
else
    g_strctParadigm = fnTsAddVar(g_strctParadigm, 'CueSizePix', 100, iSmallBuffer);
end

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'AbortTrialIfBreakFixationDuringCue', g_strctParadigm.m_fInitial_AbortTrialIfBreakFixationDuringCue, iSmallBuffer);

%% Memory
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'MemoryPeriodMS', g_strctParadigm.m_fInitial_MemoryPeriodMS, iSmallBuffer);

%% Choices

%% Post-Choice

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'InterTrialIntervalMinSec', g_strctParadigm.m_fInitial_InterTrialIntervalMinSec, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'InterTrialIntervalMaxSec', g_strctParadigm.m_fInitial_InterTrialIntervalMaxSec, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'JuiceTimeMS', g_strctParadigm.m_fInitial_JuiceTimeMS, iSmallBuffer);

if isfield(g_strctParadigm,'m_fInitial_TimeoutMS')
    g_strctParadigm = fnTsAddVar(g_strctParadigm, 'TimeoutMS', g_strctParadigm.m_fInitial_TimeoutMS, iSmallBuffer);
else
    g_strctParadigm = fnTsAddVar(g_strctParadigm, 'TimeoutMS', 2000, iSmallBuffer);
end

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'IncorrectTrialDelayMS ', g_strctParadigm.m_fInitial_IncorrectTrialDelayMS, iSmallBuffer);
 


%% Micro stim
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'MicroStimActive', false, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'MicroStimAmplitude', 0, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'MicroStimDelayMS', 0, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'MicroStimPulseWidthMS', 0.15, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'MicroStimBiPolar', true, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'MicroStimSecondPulseWidthMS', 0.25, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'MicroStimBipolarDelayMS', 0.15, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'MicroStimPulseRateHz', 300, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'MicroStimTrainRateHz', 0.1, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'MicroStimTrainDurationMS', 300, iSmallBuffer);

%% Main output variable...

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'acTrials',{},iLargeBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ExperimentDesigns',{},iSmallBuffer);

%% Load initial design if availble....
g_strctParadigm.m_acMedia = [];
g_strctParadigm.m_strctCurrentTrial = [];


%% Sync with stimulus server
if ~fnParadigmToKofikoComm('IsTouchMode')
    [fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(100);
    g_strctParadigm = fnTsAddVar(g_strctParadigm, 'SyncTime',[fLocalTime,fServerTime,fJitter],iLargeBuffer);
end



% Reward and punishment related variables
% 
% g_strctParadigm.m_bExtinguishObjectsAfterSaccade = g_strctParadigm.m_fInitial_ExtinguishChoicesAfterSaccade;
% g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ShowObjectsAfterSaccadeMS ', g_strctParadigm.m_fInitial_ShowObjectsAfterSaccadeMS , iSmallBuffer);
% 
% 
% g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ChoicesHalfSizePix ', g_strctParadigm.m_fInitial_ChoicesHalfSizePix , iSmallBuffer);
% g_strctParadigm = fnTsAddVar(g_strctParadigm, 'HitRadius', g_strctParadigm.m_fInitial_HitRadius, iSmallBuffer);
% g_strctParadigm = fnTsAddVar(g_strctParadigm, 'FixationRadiusPix', g_strctParadigm.m_fInitial_FixationRadiusPix, iSmallBuffer);
% 
% %%
% g_strctParadigm = fnTsAddVar(g_strctParadigm, 'DesignFileName',g_strctParadigm.m_strInitial_DesignFile,iSmallBuffer);
% 
% g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ExperimentDesigns',{},iSmallBuffer);
% 
% g_strctParadigm = fnTsAddVar(g_strctParadigm, 'NoiseIndex', 1, iLargeBuffer);
% 
% g_strctParadigm = fnTsAddVar(g_strctParadigm, 'NoiseLevel', g_strctParadigm.m_fInitial_NoiseLevel, iSmallBuffer);
% g_strctParadigm = fnTsAddVar(g_strctParadigm, 'StairCaseUp', g_strctParadigm.m_fInitial_StairCaseUp, iSmallBuffer);
% g_strctParadigm = fnTsAddVar(g_strctParadigm, 'StairCaseDown', g_strctParadigm.m_fInitial_StairCaseDown, iSmallBuffer);
% g_strctParadigm = fnTsAddVar(g_strctParadigm, 'StairCaseStepPerc', g_strctParadigm.m_fInitial_StairCaseStepPerc, iSmallBuffer);
% g_strctParadigm = fnTsAddVar(g_strctParadigm, 'NoiseFile', g_strctParadigm.m_strInitial_NoiseFile, iSmallBuffer);

% 
% if ~isempty(g_strctParadigm.m_strInitial_NoiseFile) && exist(g_strctParadigm.m_strInitial_NoiseFile,'file')
%     g_strctParadigm.m_strctNoise = load(g_strctParadigm.m_strInitial_NoiseFile);
% else
%     g_strctParadigm.m_strctNoise = [];
% end
%g_strctParadigm.m_iNoiseIndex = 1;
% 
% g_strctParadigm.m_hNoiseHandle = [];


g_strctParadigm.m_strAlignTo = 'CueOnset'; % TrialOnset / CueOnset / ChoicesOnset

aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
fnParadigmToKofikoComm('SetFixationPosition',aiScreenSize(3:4)/2);
g_strctParadigm.m_pt2fFixationSpot = aiScreenSize(3:4)/2;




g_strctParadigm.m_strctPrevTrial = [];

g_strctParadigm.m_ahPTBHandles = [];
g_strctParadigm.m_bEmulatorON = 0;

g_strctParadigm.m_strctTrialTypeCounter.m_iTrialCounter = 0;

g_strctParadigm.m_iTrialCounter = 1;
g_strctParadigm.m_iTrialRep = 0;
g_strctParadigm.m_iSelectedBlockInDesignTable = 0;
g_strctParadigm.m_bTrialRepetitionOFF = false;

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'TR', 2000, iSmallBuffer);

g_strctParadigm.m_bMRI_Mode = false;
g_strctParadigm.m_fFirstTriggerTS = NaN;
g_strctParadigm.m_iTriggerCounter = 0;
g_strctParadigm.m_fRunLengthSec_fMRI = NaN;
g_strctParadigm.m_iActiveBlock = 1;
g_strctParadigm.m_aiCumulativeTRs = NaN;
g_strctParadigm.m_iActiveBlock = 0;
g_strctParadigm.m_fMicroStimTimer = 0;

g_strctParadigm.m_strState = 'Doing Nothing';
bSuccessful = true;
return;
