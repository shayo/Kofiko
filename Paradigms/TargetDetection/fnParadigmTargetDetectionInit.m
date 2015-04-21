function bSuccessful = fnParadigmTargetDetectionInit()
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
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'HoldFixationAtTargetMS', g_strctParadigm.m_fInitial_HoldFixationAtTargetMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ObjectHalfSizePix ', g_strctParadigm.m_fInitial_ObjectHalfSizePix , iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ObjectSeparationPix ', g_strctParadigm.m_fInitial_ObjectSeparationPix, iSmallBuffer);

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'FixationRadiusPix', g_strctParadigm.m_fInitial_FixationRadiusPix, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'TimeoutMS', g_strctParadigm.m_fInitial_TimeoutMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'HitRadius', g_strctParadigm.m_fInitial_HitRadius, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'NumTargets', g_strctParadigm.m_fInitial_NumTargets, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'NumNonTargets', g_strctParadigm.m_fInitial_NumNonTargets, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ListFileName',g_strctParadigm.m_strInitial_ListFile,iSmallBuffer);

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'IncorrectTrialDelayMS ', g_strctParadigm.m_fInitial_IncorrectTrialDelayMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ShowObjectsAfterSaccadeMS ', g_strctParadigm.m_fInitial_ShowObjectsAfterSaccadeMS , iSmallBuffer);


g_strctParadigm = fnTsAddVar(g_strctParadigm, 'StimulationON ', 0 , iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'StimulationOffsetMS ', g_strctParadigm.m_fInitial_StimulationOffsetMS, iSmallBuffer);

g_strctParadigm.m_bExtinguishObjectsAfterSaccade = g_strctParadigm.m_fInitial_ExtinguishObjectsAfterSaccade;
g_strctParadigm.m_bMicroStimDone = false;
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'acTrials',{},iLargeBuffer);

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

    


if ~isempty(g_strctParadigm.m_strInitial_ListFile) && exist(g_strctParadigm.m_strInitial_ListFile,'file')
    

    [strPath,strFile,strExt] = fileparts(g_strctParadigm.m_strInitial_ListFile);
    if strcmpi(strExt,'.mat')
        strctData = load(g_strctParadigm.m_strInitial_ListFile);
        g_strctParadigm.m_strctObjects.m_ahPTBHandles = [];
        g_strctParadigm.m_strctObjects.m_acImages = strctData.acImages;
        g_strctParadigm.m_strctObjects.m_a2iImageSize = strctData.a2iImageSize;
        g_strctParadigm.m_strctObjects.m_aiGroup = strctData.aiGroup;
        g_strctParadigm.m_strctObjects.m_afWeights = strctData.afWeights;

        if isfield(strctData,'acFileNamesNoPath')
            g_strctParadigm.m_strctObjects.m_acFileNamesNoPath  = strctData.acFileNamesNoPath;
        else
            iNumImages = length(strctData.acImages);
            g_strctParadigm.m_strctObjects.m_acFileNamesNoPath = cell(1,iNumImages);
            for k=1:iNumImages
                g_strctParadigm.m_strctObjects.m_acFileNamesNoPath{k} = sprintf('Image %d',k);
            end;

        end
        fnParadigmToStimulusServer('ClearMemory');

    else
        fnParadigmToStimulusServer('LoadList',g_strctParadigm.m_strInitial_ListFile);
        [g_strctParadigm.m_strctObjects.m_ahPTBHandles, ...
            g_strctParadigm.m_strctObjects.m_a2iImageSize, ...
            g_strctParadigm.m_strctObjects.m_aiGroup, ...
            g_strctParadigm.m_strctObjects.m_afWeights, ...
            g_strctParadigm.m_strctObjects.m_acFileNamesNoPath] = fnLoadWeightedImageList(g_strctParadigm.m_strInitial_ListFile);
        g_strctParadigm.m_strctObjects.m_acImages = [];

        g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ObjectNames',g_strctParadigm.m_strctObjects.m_acFileNamesNoPath,iSmallBuffer);


        iInitialIndex = -1;
        for k=1:length(acFavroiteLists)
            if strcmpi(acFavroiteLists{k}, g_strctParadigm.m_strInitial_ListFile)
                iInitialIndex = k;
                break;
            end
        end
        if iInitialIndex == -1
            acFavroiteLists = [g_strctParadigm.m_strInitial_ListFile,acFavroiteLists];
            iInitialIndex = 1;
        end

    end

    
else
    g_strctParadigm.m_strctObjects.m_ahPTBHandles = [];
    g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ObjectNames',{},iSmallBuffer);
    iInitialIndex = 1;
end



g_strctParadigm.m_acFavroiteLists = acFavroiteLists;
g_strctParadigm.m_iInitialIndexInFavroiteList = iInitialIndex;

aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
fnParadigmToKofikoComm('SetFixationPosition',aiScreenSize(3:4)/2);
g_strctParadigm.m_pt2fFixationSpot = aiScreenSize(3:4)/2;

g_strctParadigm.m_bJuicePulses = g_strctParadigm.m_fInitial_JuicePulses;


[fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(100);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'SyncTime',[fLocalTime,fServerTime,fJitter],iLargeBuffer);

g_strctParadigm.m_strctStatistics.m_iNumCorrect = 0;
g_strctParadigm.m_strctStatistics.m_iNumIncorrect = 0;
g_strctParadigm.m_strctStatistics.m_iNumTimeout = 0;
g_strctParadigm.m_strctStatistics.m_iNumShortHold = 0;

g_strctParadigm.m_bEmulatorON = 0;
g_strctParadigm.m_bPredictionON = 1;
g_strctParadigm.m_strState = 'Doing Nothing';
bSuccessful = true;
return;



