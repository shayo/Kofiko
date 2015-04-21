function fnParadigmTouchScreenCallbacks(strCallback,varargin)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm 


switch strCallback
    case 'Start'
        g_strctParadigm.m_iMachineState = 1;
        g_strctParadigm.m_fParadigmStarted_TS = GetSecs();
        fnParadigmToKofikoComm('ClearEyeTraces');
        fnParadigmToKofikoComm('HideEyeTraces');
        
    case 'JuiceTimeMS'
    case 'MaxNumTrials'
    case 'InterTrialIntervalMinSec'
    case 'InterTrialIntervalMaxSec'
    case 'TrialTimeOutSec'
    
    case 'CorrectDistancePix'
    case 'SpotRadius'
    case 'ResetStat'
        g_strctParadigm.m_strctStatistics.m_iNumCorrect = 0;
        g_strctParadigm.m_strctStatistics.m_iNumIncorrect = 0;
        g_strctParadigm.m_strctStatistics.m_iNumTimeout = 0;
        g_strctParadigm.m_strctStatistics.m_iNumShortHold = 0;
        g_strctParadigm.m_strctStatistics.m_iNumTrials = 0;

    case 'ToggleTrialOnsetAudio'
        g_strctParadigm.m_bPlayTrialOnset = ~g_strctParadigm.m_bPlayTrialOnset;
        set(g_strctParadigm.m_strctControllers.m_hTrialOnsetAudio,'value',g_strctParadigm.m_bPlayTrialOnset);

    case 'ToggleTrialTimeoutAudio'
        g_strctParadigm.m_bPlayTrialTimeout = ~g_strctParadigm.m_bPlayTrialTimeout;
        set(g_strctParadigm.m_strctControllers.m_hTrialTimeoutAudio,'value',g_strctParadigm.m_bPlayTrialTimeout);


    case 'ToggleCorrectTrialAudio'
        g_strctParadigm.m_bPlayCorrect = ~g_strctParadigm.m_bPlayCorrect;
        set(g_strctParadigm.m_strctControllers.m_hCorrectTrialAudio,'value',g_strctParadigm.m_bPlayCorrect);

    case 'ToggleIncorrectTrialAudio'
        g_strctParadigm.m_bPlayIncorrect = ~g_strctParadigm.m_bPlayIncorrect;
        set(g_strctParadigm.m_strctControllers.m_hIncorrectTrialAudio,'value',g_strctParadigm.m_bPlayIncorrect);

    case 'ToggleMultipleAttempts'
        g_strctParadigm.m_bMultipleAttempts = ~g_strctParadigm.m_bMultipleAttempts;
        set(g_strctParadigm.m_strctControllers.m_hMultipleAttempts,'value',g_strctParadigm.m_bMultipleAttempts);

    case 'ToggleMonkeyStartTrials'
        g_strctParadigm.m_bMonkeyInitiatesTrials = ~g_strctParadigm.m_bMonkeyInitiatesTrials;
        set(g_strctParadigm.m_strctControllers.m_hMonkeyInitiatesTrials,'value',g_strctParadigm.m_bMonkeyInitiatesTrials);

    otherwise
        fnParadigmToKofikoComm('DisplayMessage', [strCallback,' not handeled']);

end;


return;
