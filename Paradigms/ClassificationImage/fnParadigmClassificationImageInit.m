function bSuccessful = fnParadigmClassificationImageInit()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm g_strctStimulusServer g_strctNoise
g_strctParadigm.m_fStartTime = GetSecs;

% Default initializations...
g_strctParadigm.m_iMachineState = 0; % Always initialize first state to zero.

% Finite State Machine related parameters
iSmallBuffer = 500;
iLargeBuffer = 50000;

g_strctParadigm = fnTsAddVar(g_strctParadigm, 'CurrParadigmMode', 1, iSmallBuffer);

g_strctParadigm.m_iRepeatitionCount = 0;
g_strctParadigm.m_bDoNotDrawThisCycle = false;


g_strctParadigm = fnTsAddVar(g_strctParadigm, 'JuiceTimeMS', g_strctParadigm.m_fInitial_JuiceTimeMS, iSmallBuffer);
g_strctParadigm = fnTsAddVar(g_strctParadigm, 'GazeTimeMS', g_strctParadigm.m_fInitial_GazeTimeMS, iSmallBuffer);


strctStimulusParams.m_iPhotoDiodeWindowPix = 30; % Very important if you want to get a signal from the photodiode to plexon
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'BackgroundColor',  g_strctParadigm.m_afInitial_BackgroundColor, iSmallBuffer);
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'CurrStimulusIndex', 0, iLargeBuffer);
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'CurrNoiseIndex', 1, iLargeBuffer);
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'FixationSizePix', g_strctParadigm.m_fInitial_FixationSizePix, iSmallBuffer);
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'FixationSpotPix', g_strctStimulusServer.m_aiScreenSize(3:4)/2, iSmallBuffer);
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'GazeBoxPix', g_strctParadigm.m_fInitial_GazeBoxPix, iSmallBuffer);
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'StimulusPos', g_strctStimulusServer.m_aiScreenSize(3:4)/2, iSmallBuffer);
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'StimulusSizePix', g_strctParadigm.m_fInitial_StimulusSizePix, iSmallBuffer);

strctStimulusParams = fnTsAddVar(strctStimulusParams, 'ImageOffsetX', 0, iSmallBuffer);
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'ImageOffsetY', 0, iSmallBuffer);
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'ImageSizePix', g_strctParadigm.m_fInitial_StimulusSizePix, iSmallBuffer);

strctStimulusParams = fnTsAddVar(strctStimulusParams, 'StimulusON_MS', g_strctParadigm.m_fInitial_StimulusON_MS, iSmallBuffer);
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'StimulusOFF_MS', g_strctParadigm.m_fInitial_StimulusOFF_MS, iSmallBuffer);
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'RotationAngle', 0, iLargeBuffer);
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'NoiseLevel', 0, iLargeBuffer);


strctStimulusParams = fnTsAddVar(strctStimulusParams, 'ImageList', '',20);
strctStimulusParams = fnTsAddVar(strctStimulusParams, 'RandFile', g_strctParadigm.m_strRandFile,20);

g_strctParadigm.m_iStimuliCounter = 1;
g_strctParadigm.m_aiCurrentRandIndices = [];

g_strctParadigm.m_strSavedImageList = '';
g_strctParadigm.m_fInsideGazeRectTimer = 0; 
g_strctParadigm.m_bUpdateFixationSpot = false;
g_strctParadigm.m_bUpdateStimulusPos = false;
g_strctParadigm.m_strctStimulusParams = strctStimulusParams;
    
g_strctParadigm.m_strState = 'Doing Nothing;';
g_strctParadigm.m_iRandFixCounter = 0;
g_strctParadigm.m_bRandFixPos = g_strctParadigm.m_fInitial_RandomPosition;
g_strctParadigm.m_fRandFixPosMin = g_strctParadigm.m_fInitial_RandomPositionMin;
g_strctParadigm.m_fRandFixPosMax = g_strctParadigm.m_fInitial_RandomPositionMax;
g_strctParadigm.m_fRandFixRadius = g_strctParadigm.m_fInitial_RandomPositionRadius;
g_strctParadigm.m_iRandFixCounterMax = g_strctParadigm.m_fRandFixPosMin + round(rand() * (g_strctParadigm.m_fRandFixPosMax-g_strctParadigm.m_fRandFixPosMin));
g_strctParadigm.m_bRandFixSyncStimulus = true;

g_strctParadigm.m_afNeurometricCurveSamplePoints = ...
    [  0   5  10  15  20  25  30  35  40  45  50 55  60 65  70 80 90 100];
g_strctParadigm.m_aiNumSamplesPerNoiseLevel = ...
    [  20  20 20  20  20  20  20  20  20  20  20 20  20 20  20 20 20 20];
    

if ~exist(g_strctParadigm.m_strRandFile,'file') || ~exist(g_strctParadigm.m_strImageList,'file')
    bSuccessful = false;
    return;
end




fprintf('Loading random matrix...');
strctTmp = load(g_strctParadigm.m_strRandFile,'a2fRand');
g_strctNoise.m_a2fRand = strctTmp.a2fRand;
clear strctTmp
fprintf('Done!\n');

fnLoadImageListAux2(g_strctParadigm.m_strImageList)

bSuccessful = true;
return;


 