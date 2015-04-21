function fnParadigmForcedChoiceCallbacks(strCallback,varargin)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global  g_strctParadigm 


switch strCallback
        case 'Start'
        g_strctParadigm.m_iMachineState = 1;

    case 'JuiceTimeMS'
    case 'InterTrialIntervalMinSec'
    case 'InterTrialIntervalMaxSec'
    case 'HoldFixationToStartTrialMS'
    case 'HoldFixationAtTargetMS'
    case 'TimeoutMS'    
    case 'FixationRadiusPix'
    case 'HitRadius'
    case 'ImageHalfSizePix'
        g_strctParadigm.m_iMachineState = 1;
    case 'ChoicesHalfSizePix'
        g_strctParadigm.m_iMachineState = 1;
    case 'LoadDesign'
        fnParadigmToKofikoComm('SafeCallback','LoadDesignSafe');
    case 'LoadFavoriteList'
        fnParadigmToKofikoComm('SafeCallback','SafeLoadFavoriteDesign');
    case 'SafeLoadFavoriteDesign'
          iSelected = get(g_strctParadigm.m_strctControllers.m_hFavroiteLists,'value');
          fnLoadDesignAux(g_strctParadigm.m_acFavroiteLists{iSelected});
    case 'LoadDesignSafe'
          % This is safe because callback was NOT during a call to
        % draw/cycle/.....
        fnParadigmToKofikoComm('JuiceOff');
        fnParadigmToStimulusServer('PauseButRecvCommands');
        fnHidePTB();
        [strFile, strPath] = uigetfile([g_strctParadigm.m_strInitial_DefaultFolder,'*.txt;*.mat']);
        fnShowPTB()
        if strFile(1) ~= 0
            strNextList = [strPath, strFile];
            fnLoadDesignAux(strNextList);
        end;        
        
    case 'ToggleExtinguish'
        g_strctParadigm.m_bExtinguishObjectsAfterSaccade = ~g_strctParadigm.m_bExtinguishObjectsAfterSaccade;
    case 'ToggleEmulator'
        g_strctParadigm.m_bEmulatorON = ~g_strctParadigm.m_bEmulatorON;
        fnParadigmToKofikoComm('MouseEmulator',g_strctParadigm.m_bEmulatorON);
        
    case 'NoiseLevel'
        g_strctParadigm.m_strctCurrentTrial.m_fNoiseLevel = fnTsGetVar(g_strctParadigm, 'NoiseLevel');
    case 'StairCaseUp'
    case 'StairCaseDown'
    case 'StairCaseStepPerc'
    case 'LoadNoiseFile'
        fnParadigmToKofikoComm('SafeCallback','SafeLoadNoiseFile');
    case 'SafeLoadNoiseFile'
        fnParadigmToKofikoComm('JuiceOff');
        fnParadigmToStimulusServer('PauseButRecvCommands');
        fnHidePTB();
        [strFile, strPath] = uigetfile([g_strctParadigm.m_strInitial_DefaultFolder,'*.mat']);
        fnShowPTB()
        if strFile(1) ~= 0
            strNoiseFile = [strPath, strFile];
            %fnLoadNoiseFile(strNoiseFile);

            fnTsSetVarParadigm('NoiseFile', strNoiseFile);
            g_strctParadigm.m_strctNoise = load(strNoiseFile);
            g_strctParadigm.m_iNoiseIndex = 1;
        end;
        
    case 'ResetStat'
        g_strctParadigm.m_strctStatistics.m_iNumCorrect = 0;
        g_strctParadigm.m_strctStatistics.m_iNumIncorrect = 0;
        g_strctParadigm.m_strctStatistics.m_iNumTimeout = 0;
        g_strctParadigm.m_strctStatistics.m_iNumShortHold = 0;
        g_strctParadigm.m_iTrialCounter = 1;
        g_strctParadigm.m_iTrialRep = 0;

    otherwise
        fnParadigmToKofikoComm('DisplayMessage', [strCallback,' not handeled']);
         
end;


return;


function fnLoadDesignAux(strNextList)
global g_strctParadigm
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


[strPath,strFile,strExt] = fileparts(strNextList);
if strcmpi(strExt,'.mat')
 
else
    [g_strctParadigm.m_astrctTrials, g_strctParadigm.m_astrctChoices] = fnReadForcedChoiceDesignFile(strNextList);
    fnTsSetVarParadigm('DesignFileName',strNextList);    
    A=rmfield(g_strctParadigm.m_astrctTrials,'m_Image');
    B=rmfield(g_strctParadigm.m_astrctChoices,'m_Image');
    fnTsSetVarParadigm('ExperimentDesigns',{A,B});
    
end
fnParadigmForcedChoiceSendDefaultStat();

if g_strctParadigm.m_iMachineState > 0
    g_strctParadigm.m_iMachineState = 1;
end

g_strctParadigm.m_iTrialCounter = 1;
g_strctParadigm.m_iTrialRep = 0;

g_strctParadigm.m_strctCurrentTrial = [];
