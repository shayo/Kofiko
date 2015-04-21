function bSuccessful = fnParadigmTouchScreenInit()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm  

g_strctParadigm.m_fStartTime = GetSecs;

% Default initializations...
g_strctParadigm.m_iMachineState = 0; % Always initialize first state to zero.

iSmallBuffer = 500;
iLargeBuffer = 50000;
% Finite State Machine related parameters
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'JuiceTimeMS', g_strctParadigm.m_fInitial_JuiceTimeMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'InterTrialIntervalMinSec', g_strctParadigm.m_fInitial_InterTrialIntervalMinSec, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'InterTrialIntervalMaxSec', g_strctParadigm.m_fInitial_InterTrialIntervalMaxSec, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'TrialTimeOutSec', g_strctParadigm.m_fInitial_TrialTimeOutSec, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'CorrectDistancePix', g_strctParadigm.m_fInitial_CorrectDistancePix, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'MaxNumTrials', g_strctParadigm.m_fInitial_MaxNumTrials, iSmallBuffer);

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'SpotRadius', g_strctParadigm.m_fInitial_SpotRadius, iSmallBuffer);

%%
g_strctParadigm.m_fAudioSamplingRate = 44100;
g_strctParadigm.m_bMonkeyInitiatesTrials = g_strctParadigm.m_fInitial_MonkeyStartTrial;
g_strctParadigm.m_bMultipleAttempts =  g_strctParadigm.m_fInitial_MultipleAttempts;

if ~isempty(g_strctParadigm.m_strCorrectTrialSoundFile) && exist(g_strctParadigm.m_strCorrectTrialSoundFile,'file')
    g_strctParadigm.m_afCorrectSound = wavread(g_strctParadigm.m_strCorrectTrialSoundFile);
    if isfield(g_strctParadigm,'m_fInitial_PlayTrialStart') 
        g_strctParadigm.m_bPlayCorrect =g_strctParadigm.m_fInitial_PlayTrialCorrect > 0;
    else
        g_strctParadigm.m_bPlayCorrect = true;
    end
else
    g_strctParadigm.m_afCorrectSound = [];
    g_strctParadigm.m_bPlayCorrect = false;
end

if ~isempty(g_strctParadigm.m_strIncorrectTrialSoundFile) && exist(g_strctParadigm.m_strIncorrectTrialSoundFile,'file')
    g_strctParadigm.m_afIncorrectTrialSound = wavread(g_strctParadigm.m_strIncorrectTrialSoundFile);
    if isfield(g_strctParadigm,'m_fInitial_PlayTrialIncorrect') 
        g_strctParadigm.m_bPlayIncorrect =g_strctParadigm.m_fInitial_PlayTrialIncorrect > 0;
    else
        g_strctParadigm.m_bPlayIncorrect = true;
    end
    
else
    g_strctParadigm.m_afIncorrectTrialSound = [];
    g_strctParadigm.m_bPlayIncorrect = false;
end

if ~isempty(g_strctParadigm.m_strTrialOnsetSoundFile) && exist(g_strctParadigm.m_strTrialOnsetSoundFile,'file')
    g_strctParadigm.m_afTrialOnsetSound = wavread(g_strctParadigm.m_strTrialOnsetSoundFile);
     if isfield(g_strctParadigm,'m_fInitial_PlayTrialStart') 
        g_strctParadigm.m_bPlayTrialOnset = g_strctParadigm.m_fInitial_PlayTrialStart > 0;
    else
        g_strctParadigm.m_bPlayTrialOnset = true;
    end
else
    g_strctParadigm.m_afTrialOnsetSound = [];
    g_strctParadigm.m_bPlayTrialOnset = false;
end

if ~isempty(g_strctParadigm.m_strTrialTimeoutSoundFile) && exist(g_strctParadigm.m_strTrialTimeoutSoundFile,'file')
    g_strctParadigm.m_afTrialTimeoutSound = wavread(g_strctParadigm.m_strTrialTimeoutSoundFile);
    if isfield(g_strctParadigm,'m_fInitial_PlayTrialTimeout')
        g_strctParadigm.m_bPlayTrialTimeout = g_strctParadigm.m_fInitial_PlayTrialTimeout > 0;
    else
        g_strctParadigm.m_bPlayTrialTimeout = true;
    end
else
    g_strctParadigm.m_afTrialTimeoutSound = [];
    g_strctParadigm.m_bPlayTrialTimeout = false;
end

%%
g_strctParadigm.m_strctStatistics.m_iNumCorrect = 0;
g_strctParadigm.m_strctStatistics.m_iNumIncorrect = 0;
g_strctParadigm.m_strctStatistics.m_iNumTimeout = 0;
g_strctParadigm.m_strctStatistics.m_iNumShortHold = 0;
g_strctParadigm.m_strctStatistics.m_iNumTrials = 0;

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'acTrials',{},iLargeBuffer);
g_strctParadigm.m_strState = 'Doing Nothing';
bSuccessful = true;
return;



