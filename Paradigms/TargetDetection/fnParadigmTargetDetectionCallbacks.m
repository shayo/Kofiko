function fnParadigmTargetDetectionCallbacks(strCallback,varargin)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global  g_strctParadigm g_strctStimulusServer  


switch strCallback
        case 'Start'
        g_strctParadigm.m_iMachineState = 1;

    case 'JuiceTimeMS'
    case 'InterTrialIntervalMinSec'
    case 'InterTrialIntervalMaxSec'
    case 'HoldFixationToStartTrialMS'
    case 'IncorrectTrialDelayMS'
    case 'HoldFixationAtTargetMS'
    case 'TimeoutMS'    
    case 'FixationRadiusPix'
    case 'HitRadius'
    case 'ObjectHalfSizePix'
        if g_strctParadigm.m_iMachineState > 0
            g_strctParadigm.m_iMachineState = 1;
        end
    case 'ObjectSeparationPix'
        if g_strctParadigm.m_iMachineState > 0
            g_strctParadigm.m_iMachineState = 1;
        end
    case 'NumTargets'
        if g_strctParadigm.m_iMachineState > 0
            g_strctParadigm.m_iMachineState = 1;
        end
    case 'NumNonTargets'
        if g_strctParadigm.m_iMachineState > 0
            g_strctParadigm.m_iMachineState = 1;
        end
    case 'ToggleJuicePulses'
        g_strctParadigm.m_bJuicePulses = ~g_strctParadigm.m_bJuicePulses;
    case 'LoadList'
        fnParadigmToKofikoComm('SafeCallback','LoadListSafe');
    case 'LoadFavoriteList'
        fnParadigmToKofikoComm('SafeCallback','SafeLoadFavoriteList');
    case 'SafeLoadFavoriteList'
          iSelected = get(g_strctParadigm.m_strctControllers.m_hFavroiteLists,'value');
          fnLoadListAux(g_strctParadigm.m_acFavroiteLists{iSelected});
    case 'LoadListSafe'
          % This is safe because callback was NOT during a call to
        % draw/cycle/.....
        fnHidePTB();
        [strFile, strPath] = uigetfile([g_strctParadigm.m_strInitial_DefaultFolder,'*.txt;*.mat']);
        fnShowPTB()
        if strFile(1) ~= 0
            strNextList = [strPath, strFile];
            fnLoadListAux(strNextList);
        end;        
    case 'StimulationOffsetMS'
    case 'ToggleMicroStim'
        bNewValue = get(g_strctParadigm.m_strctControllers.m_hExternalStimulation,'value');
        fnTsSetVarParadigm('StimulationON',bNewValue);
        if bNewValue
            set(g_strctParadigm.m_strctControllers.m_hExternalStimulation,'ForegroundColor','r','FontWeight','bold');
        else
            set(g_strctParadigm.m_strctControllers.m_hExternalStimulation,'ForegroundColor','k','FontWeight','normal');
        end
        
    case 'ToggleExtinguish'
        g_strctParadigm.m_bExtinguishObjectsAfterSaccade = ~g_strctParadigm.m_bExtinguishObjectsAfterSaccade;
    case 'TogglePrediction'
        g_strctParadigm.m_bEmulatorON = ~g_strctParadigm.m_bEmulatorON;
        set( g_strctParadigm.m_strctControllers.m_hResponsePrediction,'value',g_strctParadigm.m_bEmulatorON);
    case 'ToggleEmulator'
        g_strctParadigm.m_bEmulatorON = ~g_strctParadigm.m_bEmulatorON;
        fnParadigmToKofikoComm('MouseEmulator',g_strctParadigm.m_bEmulatorON);
    case 'ResetStat'
        g_strctParadigm.m_strctStatistics.m_iNumCorrect = 0;
        g_strctParadigm.m_strctStatistics.m_iNumIncorrect = 0;
        g_strctParadigm.m_strctStatistics.m_iNumTimeout = 0;
        g_strctParadigm.m_strctStatistics.m_iNumShortHold = 0;
        
    case 'MotionStarted'
        g_strctParadigm.m_iMachineState = 0;
        fnParadigmToStimulusServer('ClearScreen');
    case 'MotionFinished'
        if ~fnParadigmToKofikoComm('IsPaused')
            g_strctParadigm.m_iMachineState = 1;
        end
        
    otherwise
        fnParadigmToKofikoComm('DisplayMessage', [strCallback,' not handeled']);
         
end;


return;


function fnLoadListAux(strNextList)
global g_strctParadigm
fnParadigmToKofikoComm('JuiceOff');
fnParadigmToStimulusServer('PauseButRecvCommands');

[fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(100);
fnTsSetVarParadigm('SyncTime', [fLocalTime,fServerTime,fJitter]);

% If not available in the favorite list, add it!
iIndex = -1;
for k=1:length(g_strctParadigm.m_acFavroiteLists)
    if strcmpi(g_strctParadigm.m_acFavroiteLists{k}, strNextList)
        iIndex = k;
        break;
    end
end
if iIndex == -1
    % Not found, add!
    g_strctParadigm.m_acFavroiteLists = [strNextList,g_strctParadigm.m_acFavroiteLists];
    set(g_strctParadigm.m_strctControllers.m_hFavroiteLists,'String',fnCellToCharShort(g_strctParadigm.m_acFavroiteLists),'value',1);
else
    set(g_strctParadigm.m_strctControllers.m_hFavroiteLists,'value',iIndex);
end

% Close Previous handles
if ~isempty(g_strctParadigm.m_strctObjects.m_ahPTBHandles)
    Screen('Close',g_strctParadigm.m_strctObjects.m_ahPTBHandles);
    g_strctParadigm.m_strctObjects.m_ahPTBHandles = [];
end

fnTsSetVarParadigm('ListFileName',strNextList);

[strPath,strFile,strExt] = fileparts(strNextList);
if strcmpi(strExt,'.mat')
    strctData = load(strNextList);
    g_strctParadigm.m_strctObjects.m_ahPTBHandles = [];
    g_strctParadigm.m_strctObjects.m_acImages = strctData.acImages;
    g_strctParadigm.m_strctObjects.m_a2iImageSize = strctData.a2iImageSize';
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
    fnParadigmToStimulusServer('LoadList',strNextList);
    [g_strctParadigm.m_strctObjects.m_ahPTBHandles, ...
        g_strctParadigm.m_strctObjects.m_a2iImageSize, ...
        g_strctParadigm.m_strctObjects.m_aiGroup, ...
        g_strctParadigm.m_strctObjects.m_afWeights, ...
        g_strctParadigm.m_strctObjects.m_acFileNamesNoPath] = fnLoadWeightedImageList(strNextList);
    g_strctParadigm.m_strctObjects.m_acImages = [];
    fnTsSetVarParadigm('ObjectNames',g_strctParadigm.m_strctObjects.m_acFileNamesNoPath);
end

g_strctParadigm.m_iMachineState = 1;

g_strctParadigm.m_strctCurrentTrial = [];
