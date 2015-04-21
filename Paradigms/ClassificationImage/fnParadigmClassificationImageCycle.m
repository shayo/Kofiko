function [strctOutput] = fnParadigmClassificationImageCycle(strctInputs)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm 

iParadigmMode = fnTsGetVar(g_strctParadigm,'CurrParadigmMode');

switch iParadigmMode
    case 1 %'Scan'
        fnScanImagesCycle(strctInputs);
    case 2 %'Neurometric'
        fnNeurometricCurveCycle(strctInputs);
    case 3 %'ClassificationImage'
        fnClassificationImageCycle(strctInputs);
end
fnHandleJuice(strctInputs);
strctOutput = strctInputs;
return;

function  fnScanImagesCycle(strctInputs)
global g_strctParadigm  g_strctPTB g_strctNoise
fCurrTime = GetSecs;
switch g_strctParadigm.m_iMachineState
    case 1
        g_strctParadigm.m_iMachineState = 2;
        fnTsSetVarParadigm('m_strctStimulusParams.CurrNoiseIndex',1);
    case 2
        [iNewStimulusIndex, iNewNoiseIndex] = fnSelectNewStimulus();
        if g_strctParadigm.m_bRandFixPos
            fnSelectNewStimulusPos();
        end
        strctCurrentStimulusParamsValues = fnParadigmClassificationImageStripBuffer();
        fnParadigmToStimulusServer('UpdateDrawParams',strctCurrentStimulusParamsValues);
        fnDAQWrapper('StrobeWord', iNewStimulusIndex);

          
        fAlpha = strctCurrentStimulusParamsValues.m_fNoiseLevel/100;
        a2fNoise = g_strctNoise.m_a2fRand(:,:,iNewNoiseIndex);
        a2fNoise = a2fNoise * 128/3.9 + 128;
        a2fImage = double(g_strctParadigm.m_acImages{iNewStimulusIndex});
%        I = uint8(min(255,max(0,(1-fAlpha) * a2fImage + (fAlpha) * a2fNoise)));
      
        fnParadigmToStimulusServer('Display', a2fImage, a2fNoise, fAlpha);
        
        fnParadigmToKofikoComm('SetParadigmState', sprintf('Image %d, Rep %d', iNewStimulusIndex, g_strctParadigm.m_iRepeatitionCount));
        g_strctParadigm.m_iMachineState = 3;
        g_strctParadigm.m_fSentMessageTimer = fCurrTime;
    case 3
        if ~isempty(strctInputs.m_acInputFromStimulusServer) && strcmp(strctInputs.m_acInputFromStimulusServer{1},'FlipON')
            fnParadigmToKofikoComm('TrialStart',g_strctParadigm.m_iLastStimulusPresentedIndex)
            g_strctParadigm.m_bCorrectTrial = true;
            g_strctParadigm.m_fStimulusOnTimer = fCurrTime;
            iStimulusOFF_MS = g_strctParadigm.m_strctStimulusParams.StimulusOFF_MS.Buffer(:,:,g_strctParadigm.m_strctStimulusParams.StimulusOFF_MS.BufferIdx);
            if iStimulusOFF_MS > 0
                g_strctParadigm.m_iMachineState = 4;
            else
                g_strctParadigm.m_iMachineState = 5;
            end;
        elseif fCurrTime-g_strctParadigm.m_fSentMessageTimer > 5
            fnParadigmToKofikoComm('DisplayMessage','Missed FlipON Event');
            g_strctParadigm.m_iMachineState = 2;
        end

    case 4
        iStimulusOFF_MS = g_strctParadigm.m_strctStimulusParams.StimulusOFF_MS.Buffer(:,:,g_strctParadigm.m_strctStimulusParams.StimulusOFF_MS.BufferIdx);
        iStimulusON_MS = g_strctParadigm.m_strctStimulusParams.StimulusON_MS.Buffer(:,:,g_strctParadigm.m_strctStimulusParams.StimulusON_MS.BufferIdx);
        if ~isempty(strctInputs.m_acInputFromStimulusServer) && strcmp(strctInputs.m_acInputFromStimulusServer{1},'FlipOFF')
            % Update the stimulus index to be zero.
            fnTsSetVarParadigm('m_strctStimulusParams.CurrStimulusIndex',0);
%            fnTsSetVarParadigm('m_strctStimulusParams.NoiseLevel',fnTsGetVar(g_strctParadigm.m_strctStimulusParams,'NoiseLevel'));
            fnDAQWrapper('StrobeWord', 0);
            g_strctParadigm.m_iMachineState = 5;
        elseif fCurrTime-g_strctParadigm.m_fStimulusOnTimer > iStimulusON_MS + 10 * iStimulusOFF_MS/1e3
            fnParadigmToKofikoComm('DisplayMessage','Missed FlipOFF Event');
            g_strctParadigm.m_iMachineState = 2;
        end

    case 5
        if ~isempty(strctInputs.m_acInputFromStimulusServer) && strcmp(strctInputs.m_acInputFromStimulusServer{1},'DisplayFinished')
            g_strctParadigm.m_iMachineState = 2;
            fnParadigmToKofikoComm('TrialEnd', g_strctParadigm.m_bCorrectTrial);
        end;

end;
return;


function  fnNeurometricCurveCycle(strctInputs)
global g_strctParadigm  g_strctPTB g_strctNoise 
fCurrTime = GetSecs;
switch g_strctParadigm.m_iMachineState
    case 1
        
        % StartRecording
        if ~fnParadigmToKofikoComm('IsRecording')
            fnParadigmToKofikoComm('StartRecording');
        end;
        
        % Generate the stimulus-noise list that is going to be used
        if sum(g_strctParadigm.m_iNoiseImageIndex == g_strctParadigm.m_aiSelectedImageList) == 0
            % Add the empty image to the list
            g_strctParadigm.m_aiSelectedImageList = [g_strctParadigm.m_aiSelectedImageList,g_strctParadigm.m_iNoiseImageIndex];
            set(g_strctParadigm.m_strctControllers.hImageList,'value',g_strctParadigm.m_aiSelectedImageList);
        end

        iNumImagesSelected = length(g_strctParadigm.m_aiSelectedImageList)-1; % Do not consider the empty image
        iNumStimuli = iNumImagesSelected*sum(g_strctParadigm.m_aiNumSamplesPerNoiseLevel) * 2;
        g_strctParadigm.m_aiStimulusList = zeros(1,iNumStimuli);
        g_strctParadigm.m_aiStimulusIndexList = zeros(1,iNumStimuli);
        g_strctParadigm.m_afNoiseList = zeros(1,iNumStimuli);
        iCounter = 1;
        for k=1:length(g_strctParadigm.m_afNeurometricCurveSamplePoints)
            for iImageIter=1:iNumImagesSelected
                iNumSamples = g_strctParadigm.m_aiNumSamplesPerNoiseLevel(k);
                g_strctParadigm.m_aiStimulusList(iCounter:iCounter+2*iNumSamples-1) = ...
                    [ones(1,iNumSamples)*g_strctParadigm.m_aiSelectedImageList(iImageIter), ones(1,iNumSamples)*g_strctParadigm.m_iNoiseImageIndex];
                g_strctParadigm.m_aiStimulusIndexList(iCounter:iCounter+2*iNumSamples-1) = ...
                    [ones(1,iNumSamples)*iImageIter, ones(1,iNumSamples)* (iNumImagesSelected+1)];
                g_strctParadigm.m_afDisplayStimulusNoiseLevel(iCounter:iCounter+2*iNumSamples-1) = g_strctParadigm.m_afNeurometricCurveSamplePoints(k);
                iCounter = iCounter + 2*iNumSamples;
            end
        end
        aiRandPerm = randperm(iNumStimuli);
        g_strctParadigm.m_aiStimulusList=g_strctParadigm.m_aiStimulusList(aiRandPerm);
        g_strctParadigm.m_afDisplayStimulusNoiseLevel=g_strctParadigm.m_afDisplayStimulusNoiseLevel(aiRandPerm);
        g_strctParadigm.m_aiStimulusIndexList = g_strctParadigm.m_aiStimulusIndexList(aiRandPerm);
        g_strctParadigm.m_afResponse = zeros(1, iNumStimuli);
        g_strctParadigm.m_abValidTrial = zeros(1, iNumStimuli);
        fnTsSetVarParadigm('m_strctStimulusParams.CurrNoiseIndex',1);

        fnParadigmToKofikoComm('ResetStat');
        g_strctParadigm.m_iStimuliCounter = 1;
        g_strctParadigm.m_iMachineState = 2;
        g_strctParadigm.m_iUnitUsed = fnParadigmToKofikoComm('ActiveUnit');

    case 2

        iNewStimulusIndex = g_strctParadigm.m_aiStimulusList(g_strctParadigm.m_iStimuliCounter);
        fNewNoiseLevel = g_strctParadigm.m_afDisplayStimulusNoiseLevel(g_strctParadigm.m_iStimuliCounter);

        fnTsSetVarParadigm('m_strctStimulusParams.NoiseLevel',fNewNoiseLevel);
        fnTsSetVarParadigm('m_strctStimulusParams.CurrStimulusIndex',iNewStimulusIndex);
        
        if g_strctParadigm.m_bRandFixPos
            fnSelectNewStimulusPos();
        end
        strctCurrentStimulusParamsValues = fnParadigmClassificationImageStripBuffer();
        
        fnParadigmToStimulusServer('UpdateDrawParams',strctCurrentStimulusParamsValues);
        fnDAQWrapper('StrobeWord', iNewStimulusIndex);

        iCurrNoiseIndex = fnTsGetVar(g_strctParadigm.m_strctStimulusParams,'CurrNoiseIndex');
        
        
        fAlpha = fNewNoiseLevel/100;
        a2fNoise = g_strctNoise.m_a2fRand(:,:,iCurrNoiseIndex);
        a2fNoise = a2fNoise * 128/3.9 + 128;
        a2fImage = double(g_strctParadigm.m_acImages{iNewStimulusIndex});
 %       I = uint8(min(255,max(0,(1-fAlpha) * a2fImage + (fAlpha) * a2fNoise)));

        fnParadigmToStimulusServer('Display', a2fImage, a2fNoise, fAlpha);
        
%        fnParadigmToStimulusServer('Display',I);
        
        
        fnParadigmToKofikoComm('SetParadigmState', sprintf('Iteration %d / %d', g_strctParadigm.m_iStimuliCounter, length(g_strctParadigm.m_aiStimulusList) ));
        g_strctParadigm.m_iMachineState = 3;
        g_strctParadigm.m_fSentMessageTimer = fCurrTime;
    case 3
        if ~isempty(strctInputs.m_acInputFromStimulusServer) && strcmp(strctInputs.m_acInputFromStimulusServer{1},'FlipON')
            iImageIndex = g_strctParadigm.m_aiStimulusIndexList(g_strctParadigm.m_iStimuliCounter);
            fnParadigmToKofikoComm('TrialStart',iImageIndex)
            g_strctParadigm.m_bCorrectTrial = true;
            g_strctParadigm.m_fStimulusOnTimer = fCurrTime;
            iStimulusOFF_MS = g_strctParadigm.m_strctStimulusParams.StimulusOFF_MS.Buffer(:,:,g_strctParadigm.m_strctStimulusParams.StimulusOFF_MS.BufferIdx);
            if iStimulusOFF_MS > 0
                g_strctParadigm.m_iMachineState = 4;
            else
                g_strctParadigm.m_iMachineState = 5;
            end;
        elseif fCurrTime-g_strctParadigm.m_fSentMessageTimer > 5
            fnParadigmToKofikoComm('DisplayMessage','Missed FlipON Event');
            g_strctParadigm.m_iMachineState = 2;
        end

    case 4
        iStimulusOFF_MS = g_strctParadigm.m_strctStimulusParams.StimulusOFF_MS.Buffer(:,:,g_strctParadigm.m_strctStimulusParams.StimulusOFF_MS.BufferIdx);
        iStimulusON_MS = g_strctParadigm.m_strctStimulusParams.StimulusON_MS.Buffer(:,:,g_strctParadigm.m_strctStimulusParams.StimulusON_MS.BufferIdx);
        if ~isempty(strctInputs.m_acInputFromStimulusServer) && strcmp(strctInputs.m_acInputFromStimulusServer{1},'FlipOFF')
            % Update the stimulus index to be zero.
            fnTsSetVarParadigm('m_strctStimulusParams.CurrStimulusIndex', 0);
            fnDAQWrapper('StrobeWord', 0);
            g_strctParadigm.m_iMachineState = 5;
        elseif fCurrTime-g_strctParadigm.m_fStimulusOnTimer > iStimulusON_MS + 10 * iStimulusOFF_MS/1e3
            fnParadigmToKofikoComm('DisplayMessage','Missed FlipOFF Event');
            g_strctParadigm.m_iMachineState = 2;
        end
    case 5
        if ~isempty(strctInputs.m_acInputFromStimulusServer) && strcmp(strctInputs.m_acInputFromStimulusServer{1},'DisplayFinished')

            g_strctParadigm.m_iMachineState = 2;
            [afResponse,afAvgResponse] = fnParadigmToKofikoComm('TrialEnd', g_strctParadigm.m_bCorrectTrial);

            g_strctParadigm.m_afResponse(g_strctParadigm.m_iStimuliCounter) = afResponse(g_strctParadigm.m_iUnitUsed);
            g_strctParadigm.m_abValidTrial(g_strctParadigm.m_iStimuliCounter) = g_strctParadigm.m_bCorrectTrial;
            
            if g_strctParadigm.m_bCorrectTrial
                % Increment
                g_strctParadigm.m_iStimuliCounter = g_strctParadigm.m_iStimuliCounter + 1;

                if g_strctParadigm.m_iStimuliCounter > length(g_strctParadigm.m_aiStimulusList)
                    fnParadigmToStimulusServer('ClearScreen');
                    g_strctParadigm.m_iMachineState = 6;
                end

                iCurrNoiseIndex = fnTsGetVar(g_strctParadigm.m_strctStimulusParams,'CurrNoiseIndex');
                iCurrNoiseIndex = iCurrNoiseIndex + 1;
                if iCurrNoiseIndex > size(g_strctNoise.m_a2fRand,3)
                    iCurrNoiseIndex = 1;
                end;
                fnTsSetVarParadigm('m_strctStimulusParams.CurrNoiseIndex',iCurrNoiseIndex);
            end
        end;
    case 6
        iNumNoiseLevels = length(g_strctParadigm.m_afNeurometricCurveSamplePoints);
        afPerecentCorrect = zeros(1,iNumNoiseLevels);
        aiBadTrials = find(g_strctParadigm.m_abValidTrial==0);
        for iNoiseIter=1:iNumNoiseLevels
            aiInd = find(g_strctParadigm.m_afDisplayStimulusNoiseLevel == g_strctParadigm.m_afNeurometricCurveSamplePoints(iNoiseIter));
            
            aiNegInd = aiInd(g_strctParadigm.m_aiStimulusList(aiInd) == g_strctParadigm.m_iNoiseImageIndex);
            aiPosInd = aiInd(g_strctParadigm.m_aiStimulusList(aiInd) ~= g_strctParadigm.m_iNoiseImageIndex);
        
            afResPos = g_strctParadigm.m_afResponse(setdiff(aiPosInd,aiBadTrials));
            afResNeg = g_strctParadigm.m_afResponse(setdiff(aiNegInd,aiBadTrials));

            dPrime = abs(mean(afResPos) - mean(afResNeg)) / sqrt( (std(afResPos).^2+std(afResNeg).^2)/2);
            afPerecentCorrect(iNoiseIter) = normcdf(dPrime / sqrt(2)) * 100;
        end
        g_strctParadigm.m_afNeurometricCurve = afPerecentCorrect;
        
        fnTsSetVarParadigm('m_strctStimulusParams.CurrNoiseIndex',0);
        fnDAQWrapper('StrobeWord', 0);
        
        fnTsSetVarParadigm('m_strctStimulusParams.CurrStimulusIndex',0);
        
        if fnParadigmToKofikoComm('IsRecording')
            fnParadigmToKofikoComm('StopRecording');
        end;
       g_strctParadigm.m_iMachineState = 7;
    case 7
        % Do nothing

end;
return;

function fnClassificationImageCycle(strctInputs)
global g_strctParadigm  g_strctPTB g_strctNoise
fCurrTime = GetSecs;
switch g_strctParadigm.m_iMachineState
    case 1
      % StartRecording
        if ~fnParadigmToKofikoComm('IsRecording')
            fnParadigmToKofikoComm('StartRecording');
        end;
           
        
       if sum(g_strctParadigm.m_iNoiseImageIndex == g_strctParadigm.m_aiSelectedImageList) == 0
            % Add the empty image to the list
            g_strctParadigm.m_aiSelectedImageList = [g_strctParadigm.m_aiSelectedImageList,g_strctParadigm.m_iNoiseImageIndex];
            set(g_strctParadigm.m_strctControllers.hImageList,'value',g_strctParadigm.m_aiSelectedImageList);
       end
       fnTsSetVarParadigm('m_strctStimulusParams.CurrNoiseIndex',0);
       fnParadigmToKofikoComm('ResetStat');
       g_strctParadigm.m_iStimuliCounter = 1;
       g_strctParadigm.m_iMachineState = 2;
    case 2
        [iNewStimulusIndex, iNewNoiseIndex] = fnSelectNewStimulus();
        % Select random noise level between low and high
        if g_strctParadigm.m_bRandFixPos
            fnSelectNewStimulusPos();
        end
        strctCurrentStimulusParamsValues = fnParadigmClassificationImageStripBuffer();
        fnParadigmToStimulusServer('UpdateDrawParams',strctCurrentStimulusParamsValues);
        fnDAQWrapper('StrobeWord', iNewStimulusIndex);
        
     
        fAlpha = strctCurrentStimulusParamsValues.m_fNoiseLevel/100;
        a2fNoise = g_strctNoise.m_a2fRand(:,:,iNewNoiseIndex);
        a2fNoise = a2fNoise * 128/3.9 + 128;
        a2fImage = double(g_strctParadigm.m_acImages{iNewStimulusIndex});
%        I = uint8(min(255,max(0,(1-fAlpha) * a2fImage + (fAlpha) * a2fNoise)));

        fnParadigmToStimulusServer('Display', a2fImage, a2fNoise, fAlpha);
          
%        fnParadigmToStimulusServer('Display', I);
        fnParadigmToKofikoComm('SetParadigmState', sprintf('Iteration %d, Noise = %d (%d)', iNewNoiseIndex, round(strctCurrentStimulusParamsValues.m_fNoiseLevel),iNewStimulusIndex));
        g_strctParadigm.m_iMachineState = 3;
        g_strctParadigm.m_fSentMessageTimer = fCurrTime;
    case 3
        if ~isempty(strctInputs.m_acInputFromStimulusServer) && strcmp(strctInputs.m_acInputFromStimulusServer{1},'FlipON')
            fnParadigmToKofikoComm('TrialStart',g_strctParadigm.m_iLastStimulusPresentedIndex)
            g_strctParadigm.m_bCorrectTrial = true;
            g_strctParadigm.m_fStimulusOnTimer = fCurrTime;
            iStimulusOFF_MS = g_strctParadigm.m_strctStimulusParams.StimulusOFF_MS.Buffer(:,:,g_strctParadigm.m_strctStimulusParams.StimulusOFF_MS.BufferIdx);
            if iStimulusOFF_MS > 0
                g_strctParadigm.m_iMachineState = 4;
            else
                g_strctParadigm.m_iMachineState = 5;
            end;
        elseif fCurrTime-g_strctParadigm.m_fSentMessageTimer > 5
            fnParadigmToKofikoComm('DisplayMessage','Missed FlipON Event');
            g_strctParadigm.m_iMachineState = 2;
        end
    case 4
        iStimulusOFF_MS = g_strctParadigm.m_strctStimulusParams.StimulusOFF_MS.Buffer(:,:,g_strctParadigm.m_strctStimulusParams.StimulusOFF_MS.BufferIdx);
        if ~isempty(strctInputs.m_acInputFromStimulusServer) && strcmp(strctInputs.m_acInputFromStimulusServer{1},'FlipOFF')
            % Update the stimulus index to be zero.
            fnTsSetVarParadigm('m_strctStimulusParams.CurrStimulusIndex',0);
%            fnTsSetVarParadigm('m_strctStimulusParams.NoiseLevel',fnTsGetVar(g_strctParadigm.m_strctStimulusParams,'NoiseLevel'));
            fnDAQWrapper('StrobeWord', 0);
            g_strctParadigm.m_iMachineState = 5;
        elseif fCurrTime-g_strctParadigm.m_fStimulusOnTimer > 10 * iStimulusOFF_MS/1e3
            fnParadigmToKofikoComm('DisplayMessage','Missed FlipOFF Event');
            g_strctParadigm.m_iMachineState = 2;
        end

    case 5
        if ~isempty(strctInputs.m_acInputFromStimulusServer) && strcmp(strctInputs.m_acInputFromStimulusServer{1},'DisplayFinished')
            g_strctParadigm.m_iMachineState = 2;
            fnParadigmToKofikoComm('TrialEnd', g_strctParadigm.m_bCorrectTrial);
        end;

end;
return;


function fnHandleJuice(strctInputs)
global g_strctParadigm
%% Reward related stuff
fCurrTime = GetSecs;

if g_strctParadigm.m_iMachineState > 0
    pt2iFixationSpotPix = g_strctParadigm.m_strctStimulusParams.FixationSpotPix.Buffer(:,:,g_strctParadigm.m_strctStimulusParams.FixationSpotPix.BufferIdx);
    iGazeBoxPix = g_strctParadigm.m_strctStimulusParams.GazeBoxPix.Buffer(:,:,g_strctParadigm.m_strctStimulusParams.GazeBoxPix.BufferIdx);

    aiGazeRect = [pt2iFixationSpotPix-iGazeBoxPix,pt2iFixationSpotPix+iGazeBoxPix];

    bInsideGazeRect = strctInputs.m_pt2iEyePosScreen(1) > aiGazeRect(1) && ...
        strctInputs.m_pt2iEyePosScreen(2) > aiGazeRect(2) && ...
        strctInputs.m_pt2iEyePosScreen(1) < aiGazeRect(3) && ...
        strctInputs.m_pt2iEyePosScreen(2) < aiGazeRect(4);

    if ~bInsideGazeRect
        g_strctParadigm.m_fInsideGazeRectTimer = fCurrTime;
        g_strctParadigm.m_bCorrectTrial = false;
    end;

    iGazeTimeMS = g_strctParadigm.GazeTimeMS.Buffer(g_strctParadigm.GazeTimeMS.BufferIdx);

    if fCurrTime - g_strctParadigm.m_fInsideGazeRectTimer > iGazeTimeMS / 1000

        fnParadigmToKofikoComm('Juice', g_strctParadigm.JuiceTimeMS.Buffer(g_strctParadigm.JuiceTimeMS.BufferIdx));
        g_strctParadigm.m_fInsideGazeRectTimer = fCurrTime;
        %g_strctParadigm.m_afCorrectTrial = [g_strctParadigm.m_afCorrectTrial, fCurrTime];
    end;
end;

return;


function [iNewStimulusIndex,iCurrNoiseIndex] = fnSelectNewStimulus()
global g_strctParadigm g_strctNoise

iCurrNoiseIndex = fnTsGetVar(g_strctParadigm.m_strctStimulusParams,'CurrNoiseIndex');
iCurrNoiseIndex = iCurrNoiseIndex + 1;
if iCurrNoiseIndex > size(g_strctNoise.m_a2fRand,3)
    iCurrNoiseIndex = 1;
end;
fnTsSetVarParadigm('m_strctStimulusParams.CurrNoiseIndex',iCurrNoiseIndex);

iNumImages = length(g_strctParadigm.m_aiSelectedImageList);
if g_strctParadigm.m_iStimuliCounter > length(g_strctParadigm.m_aiCurrentRandIndices)
    g_strctParadigm.m_iStimuliCounter = 1;
end

if g_strctParadigm.m_iStimuliCounter == 1
    % Generate a new set of random indices
    [afDummy, aiSortInd] = sort(rand(1,iNumImages));
    g_strctParadigm.m_aiRandInd = aiSortInd;
    g_strctParadigm.m_aiCurrentRandIndices = g_strctParadigm.m_aiSelectedImageList(aiSortInd);
    g_strctParadigm.m_iRepeatitionCount = g_strctParadigm.m_iRepeatitionCount + 1;
end;

iNewStimulusIndex = g_strctParadigm.m_aiCurrentRandIndices(g_strctParadigm.m_iStimuliCounter);

g_strctParadigm.m_iLastStimulusPresentedIndex = g_strctParadigm.m_aiRandInd(g_strctParadigm.m_iStimuliCounter);

g_strctParadigm.m_iStimuliCounter = g_strctParadigm.m_iStimuliCounter + 1;
if g_strctParadigm.m_iStimuliCounter > iNumImages
    g_strctParadigm.m_iStimuliCounter = 1;
end

fnTsSetVarParadigm('m_strctStimulusParams.CurrStimulusIndex',iNewStimulusIndex);

return;


function fnSelectNewStimulusPos()
global g_strctParadigm g_strctStimulusServer
g_strctParadigm.m_iRandFixCounter = g_strctParadigm.m_iRandFixCounter + 1;
if g_strctParadigm.m_iRandFixCounter >= g_strctParadigm.m_iRandFixCounterMax
    g_strctParadigm.m_iRandFixCounter = 0;
    g_strctParadigm.m_iRandFixCounterMax = g_strctParadigm.m_fRandFixPosMin + round(rand() * (g_strctParadigm.m_fRandFixPosMax-g_strctParadigm.m_fRandFixPosMin));
    pt2iCenter = g_strctStimulusServer.m_aiScreenSize(3:4)/2;
    pt2iNewFixationSpot = 2*(rand(1,2)-0.5) * g_strctParadigm.m_fRandFixRadius + pt2iCenter;
    % set a new random position for fixation point
    g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'FixationSpotPix',pt2iNewFixationSpot);

    fnParadigmToKofikoComm('SetFixationPosition',pt2iNewFixationSpot);

    fnDAQWrapper('StrobeWord', fnFindCode('Fixation Spot Position Changed'));
    if g_strctParadigm.m_bRandFixSyncStimulus
        g_strctParadigm.m_strctStimulusParams = fnTsSetVar(g_strctParadigm.m_strctStimulusParams,'StimulusPos',pt2iNewFixationSpot);
        fnDAQWrapper('StrobeWord', fnFindCode('Stimulus Position Changed'));
    end
end;
return;
