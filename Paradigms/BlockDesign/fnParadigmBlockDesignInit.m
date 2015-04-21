function bSuccessful = fnParadigmBlockDesignInit()
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
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'NumTRsPerBlock', g_strctParadigm.m_fInitial_NumTRsPerBlock, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'StimulusTimeMS', g_strctParadigm.m_fInitial_StimulusTimeMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ImageList', '',20);

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ImageFileList', {},20);

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'BlockNameList', {},20);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'BlockImageIndicesList', {},20);
 g_strctParadigm = fnTsAddVar(g_strctParadigm, 'BlockRunOrder', {},20);
 
g_strctParadigm.m_iTotalTRs= 0;

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'RecordedRun',{},100);

%g_strctParadigm.m_acBlockRun = cell(0);
if ~isfield(g_strctParadigm,'m_strInitial_Default_RunType')
    g_strctParadigm.m_strInitial_Default_RunType = 'Block TR With Repeats';
end
 
if isfield(g_strctParadigm,'m_strInitial_DefaultImageList') && ~isempty(g_strctParadigm.m_strInitial_DefaultImageList) && exist(g_strctParadigm.m_strInitial_DefaultImageList,'file')
    g_strctParadigm = fnTsSetVar(g_strctParadigm, 'ImageList', g_strctParadigm.m_strInitial_DefaultImageList);

    fnLog('Loading images locally on Kofiko');
    [acFileNames, acFileNamesNoPath] = fnLoadMRIStyleImageList(g_strctParadigm.m_strInitial_DefaultImageList);
    fnParadigmToStimulusServer('LoadImageList',acFileNames);
    [g_strctParadigm.m_ahHandles,g_strctParadigm.m_a2iTextureSize,...
        g_strctParadigm.m_abIsMovie,g_strctParadigm.m_aiApproxNumFrames, g_strctParadigm.m_afMovieLengthSec] = fnInitializeTexturesAux(acFileNames);
    
    g_strctParadigm = fnTsAddVar(g_strctParadigm, 'ImageFileList', acFileNames,20);

    if isfield(g_strctParadigm,'m_strInitial_DefaultBlockList') && ~isempty(g_strctParadigm.m_strInitial_DefaultBlockList) && exist(g_strctParadigm.m_strInitial_DefaultBlockList,'file')
        %    g_strctParadigm = fnTsSetVar(g_strctParadigm, 'ImageList', g_strctParadigm.m_strInitial_DefaultImageList);

        %    fnParadigmToStimulusServer('LoadImageList',g_strctParadigm.m_strInitial_DefaultImageList);
        %    fnLOG('Loading images locally on Kofiko');
        [acImageIndices,acBlockNames] = fnLoadMRIStyleBlockList(g_strctParadigm.m_strInitial_DefaultBlockList);

        g_strctParadigm = fnTsSetVar(g_strctParadigm, 'BlockNameList', acBlockNames);
        g_strctParadigm = fnTsSetVar(g_strctParadigm, 'BlockImageIndicesList', acImageIndices);

        
        if isfield(g_strctParadigm,'m_strInitial_DefaultRunList') && ... 
                ~isempty(g_strctParadigm.m_strInitial_DefaultRunList) && exist(g_strctParadigm.m_strInitial_DefaultRunList,'file') 
            
                  
            acBlocks = fnLoadBlockOrderListTextFile(g_strctParadigm.m_strInitial_DefaultRunList);
            if all(ismember( acBlocks, acBlockNames))
                %g_strctParadigm.m_acBlockRun = acBlocks;
                
                g_strctParadigm = fnTsSetVar(g_strctParadigm, 'BlockRunOrder', acBlocks);
                
%                fnUpdateListController(g_strctParadigm.m_strctControllers.hBlockRunList, g_strctParadigm.m_acBlockRun,1, true);
                fnPrepareImageListWithTime(g_strctParadigm.m_strInitial_Default_RunType, acBlocks);
                
%iSelectedMode = get(g_strctParadigm.m_strctControllers.m_hRunOptions,'value');
%set(g_strctParadigm.m_strctControllers.m_hNumTR,'string', sprintf('Num TR = %d', iTotalTRs));
                
                
%                g_strctParadigm.m_iMachineState = 1;
            else
                fnLog('Error reading the deafult run list');
                
            end
            
            
             
            
        end
        
    end
end;
g_strctParadigm.m_iLastFlippedImageIndex = [];
g_strctParadigm.m_bFixationWhileNotScanning = true;
g_strctParadigm.m_bSimulatedTrigger = false;
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'FlipTime',[0,0,0],iLargeBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'SyncTime',[0,0,0],iLargeBuffer);

g_strctParadigm.m_fMovieStartedTimer = 0;
g_strctParadigm.m_bMicroStim = false;
if isfield(g_strctParadigm,'m_fInitial_MicroStim') && g_strctParadigm.m_fInitial_MicroStim
    g_strctParadigm.m_bMicroStim = true;
end

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'MicroStimCycleMS', '',1000);
g_strctParadigm.m_fMicroStimTimer = GetSecs();
if isfield(g_strctParadigm,'m_fInitial_MicroStimCycleMS') 
    fnTsSetVarParadigm('MicroStimCycleMS', g_strctParadigm.m_fInitial_MicroStimCycleMS);
end
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

g_strctParadigm.m_bFirstTriggerArrived = false;
g_strctParadigm.m_bGetAnotherSyncTimeStamp = true;

% Initialize Dynamic Juice Reward System
g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime = 0;
g_strctParadigm.m_strctDynamicJuice.m_fTotalNonFixationTime = 0;
g_strctParadigm.m_strctDynamicJuice.m_iState = 1;
g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;

bSuccessful = true;
return;
