function bSuccessful = fnParadigmPassiveFixationInitNew()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm g_strctStimulusServer
g_strctParadigm.m_fStartTime = GetSecs;

% Default initializations...
g_strctParadigm.m_iMachineState = 0; % Always initialize first state to zero.

if fnParadigmToKofikoComm('IsTouchMode')
    bSuccessful = false;
    return;
end

g_strctParadigm.m_strBlockDoneAction = 'Repeat Same Order';
g_strctParadigm.m_iNumTimesBlockShown = 0;
g_strctParadigm.m_iCurrentBlockIndexInOrderList = 1;
g_strctParadigm.m_iCurrentMediaIndexInBlockList = 1;
g_strctParadigm.m_iCurrentOrder = 1;
g_strctParadigm.m_bBlockLooping = false;

%g_strctParadigm.m_bDoNotDrawThisCycle = false;

% Finite State Machine related parameters
g_strctParadigm.m_bRandom = g_strctParadigm.m_fInitial_RandomStimuli; 

g_strctParadigm.m_bRepeatNonFixatedImages = true;

iSmallBuffer = 500;
iLargeBuffer = 50000;

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'JuiceTimeMS', g_strctParadigm.m_fInitial_JuiceTimeMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'JuiceTimeHighMS', g_strctParadigm.m_fInitial_JuiceTimeHighMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'GazeTimeMS', g_strctParadigm.m_fInitial_GazeTimeMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'GazeTimeLowMS', g_strctParadigm.m_fInitial_GazeTimeLowMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'BlinkTimeMS', g_strctParadigm.m_fInitial_BlinkTimeMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'PositiveIncrement', g_strctParadigm.m_fInitial_PositiveIncrementPercent, iSmallBuffer);

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'SyncTime',[0,0,0],iLargeBuffer);

% Stimulus related parameters. These will be sent to the stimulus server,
% so make sure all required stimulus parameters (that can change) are
% represented in this structure.

g_strctParadigm.m_iPhotoDiodeWindowPix = 10; % Very important if you want to get a signal from the photodiode to plexon


g_strctParadigm = fnTsAddVar(g_strctParadigm, 'BackgroundColor',  g_strctParadigm.m_afInitial_BackgroundColor, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'CurrStimulusIndex', 0, iLargeBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'FixationSizePix', g_strctParadigm.m_fInitial_FixationSizePix, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'FixationSpotPix', g_strctStimulusServer.m_aiScreenSize(3:4)/2, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'GazeBoxPix', g_strctParadigm.m_fInitial_GazeBoxPix, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'StimulusPos', g_strctStimulusServer.m_aiScreenSize(3:4)/2, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'StimulusSizePix', g_strctParadigm.m_fInitial_StimulusSizePix, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'StimulusON_MS', g_strctParadigm.m_fInitial_StimulusON_MS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'StimulusOFF_MS', g_strctParadigm.m_fInitial_StimulusOFF_MS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'RotationAngle', 0, iLargeBuffer);


g_strctParadigm = fnTsAddVar(g_strctParadigm, 'MicroStimulationAmplitude', 0, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'MicrostimDelayMS', 0, iSmallBuffer);


bForceStereoOnMonocularInitialValue = false;

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ForceStereoOnMonocularLists', bForceStereoOnMonocularInitialValue, iSmallBuffer);


g_strctParadigm.m_strctSavedParam.m_pt2fStimulusPosition = fnTsGetVar('g_strctParadigm','StimulusPos');
g_strctParadigm.m_strctSavedParam.m_fTheta = fnTsGetVar('g_strctParadigm','RotationAngle');
g_strctParadigm.m_strctSavedParam.m_fSize = fnTsGetVar('g_strctParadigm','StimulusSizePix');

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'Trials',[0;0;0;0;0;0;0],iLargeBuffer);

g_strctParadigm.m_strctCurrentTrial = [];
g_strctParadigm.m_bShowPhotodiodeRect = g_strctParadigm.m_fInitial_ShowPhotodiodeRect;

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ImageList', '',20);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'Designs', {},20);

g_strctParadigm.m_iNumStimuli = 0;
g_strctParadigm.m_bStimulusDisplayed = false;
g_strctParadigm.m_aiCurrentRandIndices = [];

g_strctParadigm.m_strSavedImageList = '';
g_strctParadigm.m_fInsideGazeRectTimer = 0; 
g_strctParadigm.m_bUpdateFixationSpot = false;
g_strctParadigm.m_bUpdateStimulusPos = false;

g_strctParadigm.m_strLocalStereoMode = 'Side by Side (Large)';
    
g_strctParadigm.m_strState = 'Doing Nothing;';

g_strctParadigm.m_strImageList = '';
% g_strctParadigm.m_strOnlyFacesImageList = g_strctParadigm.m_strInitial_FacesImageList;
% g_strctParadigm.m_strFOBImageList = g_strctParadigm.m_strInitial_FOBImageList;

g_strctParadigm.m_bDisplayStimuliLocally = true;
g_strctParadigm.m_bMovieInitialized = false;

g_strctParadigm.m_iRandFixCounter = 0;
g_strctParadigm.m_bRandFixPos = g_strctParadigm.m_fInitial_RandomPosition;
g_strctParadigm.m_fRandFixPosMin = g_strctParadigm.m_fInitial_RandomPositionMin;
g_strctParadigm.m_fRandFixPosMax = g_strctParadigm.m_fInitial_RandomPositionMax;
g_strctParadigm.m_fRandFixRadius = g_strctParadigm.m_fInitial_RandomPositionRadius;
g_strctParadigm.m_iRandFixCounterMax = g_strctParadigm.m_fRandFixPosMin + round(rand() * (g_strctParadigm.m_fRandFixPosMax-g_strctParadigm.m_fRandFixPosMin));
g_strctParadigm.m_bRandFixSyncStimulus = true;

g_strctParadigm.m_bHideStimulusWhenNotLooking = g_strctParadigm.m_fInitial_HideStimulusWhenNotLooking;
g_strctParadigm.m_fLastFixatedTimer = 0; 

g_strctParadigm.m_a2bStimulusCategory = [];
g_strctParadigm.m_acCatNames = [];

% Initialize Dynamic Juice Reward System
g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime = 0;
g_strctParadigm.m_strctDynamicJuice.m_fTotalNonFixationTime = 0;
g_strctParadigm.m_strctDynamicJuice.m_iState = 1;
g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;

g_strctParadigm.m_bPausedDueToMotion = false;


acFieldNames = fieldnames(g_strctParadigm);
acFavroiteLists = cell(1,0);
iListCounter = 1;
for k=1:length(acFieldNames)
    if strncmpi(acFieldNames{k},'m_strInitial_FavroiteList',25)
        strImageListFileName = getfield(g_strctParadigm,acFieldNames{k});
        if exist(strImageListFileName,'file')
           acFavroiteLists{iListCounter} = strImageListFileName;
           iListCounter = iListCounter + 1;
        end
    end
end
% Changelog 10/21/13 josh - initializes fit to screen parameter
g_strctParadigm.m_bFitToScreen = g_strctParadigm.m_fInitial_FitToScreen;

% End Changelog
g_strctParadigm.m_bParameterSweep = g_strctParadigm.m_fInitial_ParameterSweep;
g_strctParadigm.m_iParameterSweepMode = 1;

g_strctParadigm.m_astrctParameterSweepModes(1).m_strName = 'Fixed';
g_strctParadigm.m_astrctParameterSweepModes(1).m_afX  = 0;
g_strctParadigm.m_astrctParameterSweepModes(1).m_afY  = 0;
g_strctParadigm.m_astrctParameterSweepModes(1).m_afSize  = [];
g_strctParadigm.m_astrctParameterSweepModes(1).m_afTheta  = [];

g_strctParadigm.m_astrctParameterSweepModes(2).m_strName = '7x7 Position Only';
g_strctParadigm.m_astrctParameterSweepModes(2).m_afX  = [-300:100:300];
g_strctParadigm.m_astrctParameterSweepModes(2).m_afY  = [-300:100:300];
g_strctParadigm.m_astrctParameterSweepModes(2).m_afSize  = [];
g_strctParadigm.m_astrctParameterSweepModes(2).m_afTheta  = [];

g_strctParadigm.m_astrctParameterSweepModes(3).m_strName = '7x7x3 Position & Scale';
g_strctParadigm.m_astrctParameterSweepModes(3).m_afX  = [-300:100:300];
g_strctParadigm.m_astrctParameterSweepModes(3).m_afY  = [-300:100:300];
g_strctParadigm.m_astrctParameterSweepModes(3).m_afSize  = [32 64 128];
g_strctParadigm.m_astrctParameterSweepModes(3).m_afTheta  = [];

g_strctParadigm.m_astrctParameterSweepModes(4).m_strName = '21x21 Position Only';
g_strctParadigm.m_astrctParameterSweepModes(4).m_afX  = -400:40:400;
g_strctParadigm.m_astrctParameterSweepModes(4).m_afY  = -300:30:300;
g_strctParadigm.m_astrctParameterSweepModes(4).m_afSize  = [];
g_strctParadigm.m_astrctParameterSweepModes(4).m_afTheta  = [];

g_strctParadigm.m_astrctParameterSweepModes(5).m_strName = '21x21x3 Position Only';
g_strctParadigm.m_astrctParameterSweepModes(5).m_afX  = -400:40:400;
g_strctParadigm.m_astrctParameterSweepModes(5).m_afY  = -300:30:300;
g_strctParadigm.m_astrctParameterSweepModes(5).m_afSize  = [32 64 128];
g_strctParadigm.m_astrctParameterSweepModes(5).m_afTheta  = [];

% Search for noise patterns...
astrctNoisePatternsFiles = dir('\\kofiko-23b\StimulusSet\NoisePatterns\*.mat');
g_strctParadigm.m_acNoisePatternsFiles = {astrctNoisePatternsFiles.name};
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'NoiseOverlayActive', false, iSmallBuffer);
if ~isempty(g_strctParadigm.m_acNoisePatternsFiles) && exist(['\\kofiko-23b\StimulusSet\NoisePatterns\\',g_strctParadigm.m_acNoisePatternsFiles{1}],'file')
    try
    g_strctParadigm = fnTsAddVar(g_strctParadigm, 'NoiseFile', g_strctParadigm.m_acNoisePatternsFiles{1}, 20);
    strctTmp = load(['\\kofiko-23b\StimulusSet\NoisePatterns\\',g_strctParadigm.m_acNoisePatternsFiles{1}]);
    g_strctParadigm.m_a3fRandPatterns = strctTmp.a3fRand;
    g_strctParadigm.m_strctNoiseOverlay.m_iNumNoisePatterns = size(g_strctParadigm.m_a3fRandPatterns,3);
    catch
        g_strctParadigm = fnTsAddVar(g_strctParadigm, 'NoiseFile', '', 20);
        g_strctParadigm.m_strctNoiseOverlay.m_iNumNoisePatterns = 0 ;
    end
    
else
    g_strctParadigm = fnTsAddVar(g_strctParadigm, 'NoiseFile', '', 20);
    g_strctParadigm.m_strctNoiseOverlay.m_iNumNoisePatterns = 0 ;
end
g_strctParadigm.m_strctNoiseOverlay.m_iNoiseIndex = 0;
g_strctParadigm.m_strctNoiseOverlay.m_fNoiseIntensity = 0;

g_strctParadigm.m_acImageFileNames = [];


g_strctParadigm.m_strctMiroSctim.m_bActive = false;


TRIAL_START_CODE = 32700;
TRIAL_END_CODE = 32699;
TRIAL_ALIGN_CODE = 32698;
TRIAL_OUTCOME_MISS = 32695;
TRIAL_INCORRECT_FIX = 32696;
TRIAL_CORRECT_FIX = 32697;

strctDesign.TrialStartCode = TRIAL_START_CODE;
strctDesign.TrialEndCode = TRIAL_END_CODE;
strctDesign.TrialAlignCode = TRIAL_ALIGN_CODE;
strctDesign.TrialOutcomesCodes = [TRIAL_OUTCOME_MISS,TRIAL_INCORRECT_FIX,TRIAL_CORRECT_FIX];
strctDesign.KeepTrialOutcomeCodes = [TRIAL_CORRECT_FIX];
strctDesign.TrialTypeToConditionMatrix = [];
strctDesign.ConditionOutcomeFilter = cell(0);
strctDesign.NumTrialsInCircularBuffer = 200;
strctDesign.TrialLengthSec = 1.1 * (g_strctParadigm.m_fInitial_StimulusON_MS+g_strctParadigm.m_fInitial_StimulusOFF_MS)/1e3; % multiple by 10% to account for possible jitter
strctDesign.Pre_TimeSec = 0.5;
strctDesign.Post_TimeSec = 0.5;
g_strctParadigm.m_strctStatServerDesign = strctDesign;
g_strctParadigm.m_bJustLoaded = true;

iInitialIndex = -1;
if ~isempty(g_strctParadigm.m_strInitial_DefaultImageList) && exist(g_strctParadigm.m_strInitial_DefaultImageList,'file')
   if fnLoadPassiveFixationDesign(g_strctParadigm.m_strInitial_DefaultImageList)
    
    for k=1:length(acFavroiteLists)
        if strcmpi(acFavroiteLists{k}, g_strctParadigm.m_strInitial_DefaultImageList)
            iInitialIndex = k;
            break;
        end
    end
    if iInitialIndex == -1
        acFavroiteLists = [g_strctParadigm.m_strInitial_DefaultImageList,acFavroiteLists];
        iInitialIndex = 1;
    end
   end
else
    g_strctParadigm.m_strctDesign = [];
end;
g_strctParadigm.m_strWhatToReset = 'Unit';

g_strctParadigm.m_acFavroiteLists = acFavroiteLists;
g_strctParadigm.m_iInitialIndexInFavroiteList = iInitialIndex;
g_strctParadigm.m_bShowWhileLoading = true;





bSuccessful = true;
return;


 
