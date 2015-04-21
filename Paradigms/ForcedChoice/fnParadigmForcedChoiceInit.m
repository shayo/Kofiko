function bSuccessful = fnParadigmForcedChoiceInit()
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
% Finite State Machine related parameters
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'JuiceTimeMS', g_strctParadigm.m_fInitial_JuiceTimeMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'InterTrialIntervalMinSec', g_strctParadigm.m_fInitial_InterTrialIntervalMinSec, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'InterTrialIntervalMaxSec', g_strctParadigm.m_fInitial_InterTrialIntervalMaxSec, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'HoldFixationToStartTrialMS', g_strctParadigm.m_fInitial_HoldFixationToStartTrialMS, iSmallBuffer);

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'FixationTimeOutMS', 2000, iSmallBuffer);

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'DelayBeforeChoicesMS', g_strctParadigm.m_fInitial_DelayBeforeChoicesMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'MemoryIntervalMS', g_strctParadigm.m_fInitial_MemoryIntervalMS, iSmallBuffer);



g_strctParadigm.m_bExtinguishObjectsAfterSaccade = g_strctParadigm.m_fInitial_ExtinguishChoicesAfterSaccade;
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ShowObjectsAfterSaccadeMS ', g_strctParadigm.m_fInitial_ShowObjectsAfterSaccadeMS , iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'TimeoutMS', g_strctParadigm.m_fInitial_TimeoutMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'IncorrectTrialDelayMS ', g_strctParadigm.m_fInitial_IncorrectTrialDelayMS, iSmallBuffer);

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ImageHalfSizePix ', g_strctParadigm.m_fInitial_ImageHalfSizePix , iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ChoicesHalfSizePix ', g_strctParadigm.m_fInitial_ChoicesHalfSizePix , iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'HitRadius', g_strctParadigm.m_fInitial_HitRadius, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'FixationRadiusPix', g_strctParadigm.m_fInitial_FixationRadiusPix, iSmallBuffer);

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'DesignFileName',g_strctParadigm.m_strInitial_DesignFile,iSmallBuffer);

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ExperimentDesigns',{},iSmallBuffer);

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'NoiseIndex', 1, iLargeBuffer);

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'NoiseLevel', g_strctParadigm.m_fInitial_NoiseLevel, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'StairCaseUp', g_strctParadigm.m_fInitial_StairCaseUp, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'StairCaseDown', g_strctParadigm.m_fInitial_StairCaseDown, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'StairCaseStepPerc', g_strctParadigm.m_fInitial_StairCaseStepPerc, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'NoiseFile', g_strctParadigm.m_strInitial_NoiseFile, iSmallBuffer);

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'acTrials',{},iLargeBuffer);

if ~isempty(g_strctParadigm.m_strInitial_NoiseFile) && exist(g_strctParadigm.m_strInitial_NoiseFile,'file')
    g_strctParadigm.m_strctNoise = load(g_strctParadigm.m_strInitial_NoiseFile);
else
    g_strctParadigm.m_strctNoise = [];
end
%g_strctParadigm.m_iNoiseIndex = 1;

g_strctParadigm.m_hNoiseHandle = [];

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




if ~isempty(g_strctParadigm.m_strInitial_DesignFile) && exist(g_strctParadigm.m_strInitial_DesignFile,'file')
    [strPath,strFile,strExt] = fileparts(g_strctParadigm.m_strInitial_DesignFile);
    if strcmpi(strExt,'.mat')
     else
        [g_strctParadigm.m_astrctTrials, g_strctParadigm.m_astrctChoices] = fnReadForcedChoiceDesignFile(g_strctParadigm.m_strInitial_DesignFile);
        fnTsSetVarParadigm('DesignFileName',g_strctParadigm.m_strInitial_DesignFile);
        
        A=rmfield(g_strctParadigm.m_astrctTrials,'m_Image');
        B=rmfield(g_strctParadigm.m_astrctChoices,'m_Image');
        fnTsSetVarParadigm('ExperimentDesigns',{A,B});
  
        for k=1:length(acFavroiteLists)
            if strcmpi(acFavroiteLists{k}, g_strctParadigm.m_strInitial_DesignFile)
                iInitialIndex = k;
                break;
            end
        end
        if iInitialIndex == -1
            acFavroiteLists = [g_strctParadigm.m_strInitial_DesignFile,acFavroiteLists];
            iInitialIndex = 1;
        end

    end


else
    g_strctParadigm.m_astrctTrials = [];
    g_strctParadigm.m_astrctChoices = [];

    iInitialIndex = 1;
end



g_strctParadigm.m_acFavroiteLists = acFavroiteLists;
g_strctParadigm.m_iInitialIndexInFavroiteList = iInitialIndex;

aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
fnParadigmToKofikoComm('SetFixationPosition',aiScreenSize(3:4)/2);
g_strctParadigm.m_pt2fFixationSpot = aiScreenSize(3:4)/2;

[fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(100);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'SyncTime',[fLocalTime,fServerTime,fJitter],iLargeBuffer);

g_strctParadigm.m_strctStatistics.m_iNumCorrect = 0;
g_strctParadigm.m_strctStatistics.m_iNumIncorrect = 0;
g_strctParadigm.m_strctStatistics.m_iNumTimeout = 0;
g_strctParadigm.m_strctStatistics.m_iNumShortHold = 0;

g_strctParadigm.m_ahPTBHandles = [];
g_strctParadigm.m_bEmulatorON = 0;


g_strctParadigm.m_iTrialCounter = 1;
g_strctParadigm.m_iTrialRep = 0;



fnParadigmForcedChoiceSendDefaultStat();

g_strctParadigm.m_strState = 'Doing Nothing';
bSuccessful = true;
return;



