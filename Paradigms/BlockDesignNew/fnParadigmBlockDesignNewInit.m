function bSuccessful = fnParadigmBlockDesignNewInit()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm
g_strctParadigm.m_fStartTime = GetSecs;

% Default initializations...

% This variable MUST be present in a paradigm
g_strctParadigm.m_iMachineState = 0; % Always initialize first state to zero.

iSmallBuffer = 100;
iLargeBuffer = 20000;
% Here we add "Timestamped" variables.

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'GazeBoxPix', g_strctParadigm.m_fInitial_GazeBoxPix, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'JuiceTimeMS', g_strctParadigm.m_fInitial_JuiceTimeMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'JuiceTimeHighMS', g_strctParadigm.m_fInitial_JuiceTimeHighMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'GazeTimeMS', g_strctParadigm.m_fInitial_GazeTimeMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'GazeTimeLowMS', g_strctParadigm.m_fInitial_GazeTimeLowMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'BlinkTimeMS', g_strctParadigm.m_fInitial_BlinkTimeMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'PositiveIncrement', g_strctParadigm.m_fInitial_PositiveIncrementPercent, iSmallBuffer);


g_strctParadigm = fnTsAddVar(g_strctParadigm, 'FixationSizePix', g_strctParadigm.m_fInitial_FixationSizePix, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'CurrStimulusIndex', 0, iLargeBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'StimulusSizePix', g_strctParadigm.m_fInitial_StimulusSizePix, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'RotationAngle', g_strctParadigm.m_fInitial_RotationAngleDeg, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'TR', g_strctParadigm.m_fInitial_TR_MS, iSmallBuffer);

 
g_strctParadigm.m_iTotalTRs= 0;

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'RecordedRun',{},100);

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'Designs',{},100);
g_strctParadigm.m_strctDesign = [];

%%
if isfield(g_strctParadigm,'m_strInitial_DesignFile') && exist(g_strctParadigm.m_strInitial_DesignFile,'file')
    g_strctParadigm.m_strctDesign = fnLoadBlockDesignNewDesignFile(g_strctParadigm.m_strInitial_DesignFile);
    g_strctParadigm.m_iActiveOrder = 1;
    fnTsSetVarParadigm('Designs', g_strctParadigm.m_strctDesign);
    fnKofikoClearTextureMemory();
    fnParadigmToStimulusServer('LoadImageList',{g_strctParadigm.m_strctDesign.m_astrctMedia.m_strFileName});
    [g_strctParadigm.m_ahHandles,g_strctParadigm.m_a2iTextureSize,...
        g_strctParadigm.m_abIsMovie,g_strctParadigm.m_aiApproxNumFrames, g_strctParadigm.m_afMovieLengthSec] = fnInitializeTexturesAux({g_strctParadigm.m_strctDesign.m_astrctMedia.m_strFileName});
    g_strctParadigm.m_acFavroiteLists  = {g_strctParadigm.m_strInitial_DesignFile};
else
    g_strctParadigm.m_acFavroiteLists  = {};
end

acFields= fieldnames(g_strctParadigm);
for k=1:length(acFields)
    if strncmpi(acFields{k},'m_strInitial_FavroiteList',length('m_strInitial_FavroiteList'));
        strFile = getfield(g_strctParadigm,acFields{k});
        if exist(strFile,'file') && ~ismember(strFile,g_strctParadigm.m_acFavroiteLists)
            g_strctParadigm.m_acFavroiteLists = [g_strctParadigm.m_acFavroiteLists,strFile];
        end
    end
end

%%


%                 fnPrepareImageListWithTime(g_strctParadigm.m_strInitial_Default_RunType, acBlocks);

g_strctParadigm.m_iLastFlippedImageIndex = [];
g_strctParadigm.m_bFixationWhileNotScanning = true;
g_strctParadigm.m_bSimulatedTrigger = false;
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'FlipTime',[0,0,0],iLargeBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'SyncTime',[0,0,0],iLargeBuffer);

g_strctParadigm.m_fMovieStartedTimer = 0;

g_strctParadigm.m_fStimulusStartTimer = GetSecs();
g_strctParadigm.m_fInsideGazeRectTimer = GetSecs();
g_strctParadigm.m_fFixationCmdTimer = GetSecs();
g_strctParadigm.m_bUseTriggerToStart = true;
g_strctParadigm.m_acExperimentDescription = [];
g_strctParadigm.m_iTriggerCounter = 0;
aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
fnParadigmToKofikoComm('SetFixationPosition',aiScreenSize(3:4)/2);
g_strctParadigm.m_pt2fFixationSpot = aiScreenSize(3:4)/2;
g_strctParadigm.m_fBlockTimer = GetSecs();
g_strctParadigm.m_iCurrentBlock = 1;

g_strctParadigm.m_afInitial_BackgroundColor = [128,128,128];
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'BackgroundColor',  g_strctParadigm.m_afInitial_BackgroundColor, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'FixationSpotColor',  [255,255,255], iSmallBuffer);

g_strctParadigm.m_bFirstTriggerArrived = false;
g_strctParadigm.m_bGetAnotherSyncTimeStamp = true;

% Initialize Dynamic Juice Reward System
g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime = 0;
g_strctParadigm.m_strctDynamicJuice.m_fTotalNonFixationTime = 0;
g_strctParadigm.m_strctDynamicJuice.m_iState = 1;
g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;

bSuccessful = true;
return;
