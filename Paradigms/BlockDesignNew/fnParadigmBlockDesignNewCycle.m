function [strctOutput] = fnParadigmBlockDesignNewCycle(strctInputs)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm 

fCurrTime = GetSecs;
bBlockOnsetEvent = false;

if strctInputs.m_abExternalTriggers(1) 
    g_strctParadigm.m_bFirstTriggerArrived = true;
    
    g_strctParadigm.m_iTriggerCounter = g_strctParadigm.m_iTriggerCounter + 1;
    fnParadigmToKofikoComm('SetParadigmState', sprintf('Trigger %d detected',g_strctParadigm.m_iTriggerCounter));
    if g_strctParadigm.m_iMachineState == 0
        if isfield(g_strctParadigm,'m_aiImageList') && isfield(g_strctParadigm,'m_afDisplayTimeMS') 
            g_strctParadigm.m_iMachineState = 2;
        else
            fnParadigmToKofikoComm('DisplayMessage','Could not start. Run list is empty!');
            g_strctParadigm.m_iMachineState = 0;
        end
    end
end

switch g_strctParadigm.m_iMachineState
    case 0
         if ~isfield(g_strctParadigm,'m_strctDesign') || (isfield(g_strctParadigm,'m_strctDesign') && isempty(g_strctParadigm.m_strctDesign))
               fnParadigmToKofikoComm('SetParadigmState', 'Waiting for user to load a design...');
         else
             fnParadigmToKofikoComm('SetParadigmState', 'Waiting for user to press Start...');
         end
         
    case 1 % Run some tests that everything is OK. Then goto 2
         if isfield(g_strctParadigm,'m_strctDesign') && ~isempty(g_strctParadigm.m_strctDesign)
          g_strctParadigm.m_strctCurrentRun = fnPrepareStimuliTimingFromBlockDesign();

%               
%             fTR_MS = fnTsGetVar(g_strctParadigm,'TR');
%             iNumTRsPerBlock = fnTsGetVar(g_strctParadigm,'NumTRsPerBlock');
%             g_strctParadigm.m_fBlockLengthSec = iNumTRsPerBlock*fTR_MS/1e3;
%             
            g_strctParadigm.m_iMachineState = 2;
        else
           fnParadigmToKofikoComm('SetParadigmState', 'Cannot Start. Waiting for user to load a run list...');
           g_strctParadigm.m_iMachineState = 0;
        end
        
         
    case 2
        
        if ~g_strctParadigm.m_bFirstTriggerArrived
            fnParadigmToKofikoComm('SetParadigmState', 'Waiting for first trigger...');
        end
        
        if g_strctParadigm.m_bGetAnotherSyncTimeStamp 
            [fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(100);
            fnTsSetVarParadigm('SyncTime', [fLocalTime,fServerTime,fJitter]);
            g_strctParadigm.m_bGetAnotherSyncTimeStamp = false;
        end
        
        
        if fCurrTime-g_strctParadigm.m_fFixationCmdTimer > 0.5
        
           if g_strctParadigm.m_bFixationWhileNotScanning
                fFixationSizePix = fnTsGetVar(g_strctParadigm, 'FixationSizePix');
                afBackgroundColor = fnTsGetVar(g_strctParadigm, 'BackgroundColor');
                afFixationColor = fnTsGetVar(g_strctParadigm, 'FixationSpotColor');
                fnParadigmToStimulusServer('ShowFixation', fFixationSizePix,afBackgroundColor,afFixationColor);
            else
                fnParadigmToStimulusServer('ClearScreen');
           end
           
           g_strctParadigm.m_fFixationCmdTimer = fCurrTime;
        end
        
        
        % Wait for first TR signal
        if g_strctParadigm.m_bUseTriggerToStart && (strctInputs.m_abExternalTriggers(1) || g_strctParadigm.m_bSimulatedTrigger)
            g_strctParadigm.m_bSimulatedTrigger = false;
            fnParadigmToKofikoComm('StartRecording',0);
            
            fFixationSizePix = fnTsGetVar(g_strctParadigm, 'FixationSizePix');
            fStimulusSizePix = fnTsGetVar(g_strctParadigm, 'StimulusSizePix');
            fRotationAngle = fnTsGetVar(g_strctParadigm, 'RotationAngle');
            afBackgroundColor = fnTsGetVar(g_strctParadigm, 'BackgroundColor');
            afFixationColor = fnTsGetVar(g_strctParadigm, 'FixationSpotColor');
         
            fnTsSetVarParadigm('RecordedRun', g_strctParadigm.m_strctCurrentRun);
            
            fnParadigmToStimulusServer('DisplayList', ...
                g_strctParadigm.m_strctCurrentRun.m_aiMediaList, g_strctParadigm.m_strctCurrentRun.m_afDisplayTimeMS,...
                fFixationSizePix,fStimulusSizePix,fRotationAngle,afBackgroundColor,afFixationColor );

            g_strctParadigm.m_fStimulusStartTimer = fCurrTime;
            
            
%             if g_strctParadigm.m_bMicroStim && g_strctParadigm.m_abMicroStimBlocks(1)
%                 fnParadigmToKofikoComm('StimulationTTL');
%                 g_strctParadigm.m_fMicroStimTimer = fCurrTime;
%             end
            g_strctParadigm.m_iCurrentBlock = 0;
            g_strctParadigm.m_iMachineState = 3;
            g_strctParadigm.m_fBlockOnsetTime = GetSecs();
            g_strctParadigm.m_fMicroStimTimer = 0;
        end
    case 3
        % Run is in progress
        fElapsedTimeSec = fCurrTime - g_strctParadigm.m_fStimulusStartTimer;
        iCurrentBlock = find(g_strctParadigm.m_strctCurrentRun.m_afBlockOnsetTimeSec(1:end-1) <= fElapsedTimeSec & ...
                                               g_strctParadigm.m_strctCurrentRun.m_afBlockOnsetTimeSec(2:end) >= fElapsedTimeSec,1,'last');
        
        if g_strctParadigm.m_iCurrentBlock ~= iCurrentBlock
            bBlockOnsetEvent = true;
            g_strctParadigm.m_fBlockOnsetTime = GetSecs();
            g_strctParadigm.m_iCurrentBlock = iCurrentBlock;
            if ~isempty(iCurrentBlock) && iCurrentBlock > 0
                set(g_strctParadigm.m_strctDesignControllers.m_hBlockOrder,'value',iCurrentBlock);
            end
        end
        
        % If we get input from stimulus server, display the corresponding
        % image...
        if ~isempty(strctInputs.m_acInputFromStimulusServer) 
            
            if strcmpi(strctInputs.m_acInputFromStimulusServer{1},'Flipped')
                g_strctParadigm.m_fMovieStartedTimer = GetSecs();
                fFlipTime = strctInputs.m_acInputFromStimulusServer{2};
                iImageIndex = strctInputs.m_acInputFromStimulusServer{3};
                iImageCounter = strctInputs.m_acInputFromStimulusServer{4};
                g_strctParadigm.m_iLastFlippedImageIndex = iImageIndex;
                fnTsSetVarParadigm('FlipTime', [fFlipTime,iImageIndex,iImageCounter]);
                fnParadigmToKofikoComm('SetParadigmState', sprintf('Image %d / %d displayed (Trigger count is %d), Block %d',iImageCounter,...
                    length(g_strctParadigm.m_strctCurrentRun.m_afDisplayTimeMS),g_strctParadigm.m_iTriggerCounter,g_strctParadigm.m_iCurrentBlock));

            elseif strcmpi(strctInputs.m_acInputFromStimulusServer{1},'FinishedDisplayList')
                fFlipTime = strctInputs.m_acInputFromStimulusServer{2};
                fnTsSetVarParadigm('FlipTime', [fFlipTime,0,0]);
                % Make sure we counted enough triggers?
                g_strctParadigm.m_iLastFlippedImageIndex = [];
                g_strctParadigm.m_iMachineState = 1;
                g_strctParadigm.m_iTriggerCounter = 0;
                fnParadigmToKofikoComm('StopRecording',0);
                              
                [fLocalTime, fServerTime, fJitter] = fnSyncClockWithStimulusServer(100);
                fnTsSetVarParadigm('SyncTime', [fLocalTime,fServerTime,fJitter]);
                
                g_strctParadigm.m_bGetAnotherSyncTimeStamp = true;
                g_strctParadigm.m_bFirstTriggerArrived = false;
                g_strctParadigm.m_iActiveOrder = g_strctParadigm.m_iActiveOrder + 1;
                if (g_strctParadigm.m_iActiveOrder > length(g_strctParadigm.m_strctDesign.m_acBlockOrders))
                    g_strctParadigm.m_iActiveOrder = 1;
                end
                set(g_strctParadigm.m_strctDesignControllers.m_hDesignOrder,'value', g_strctParadigm.m_iActiveOrder);
            end
        end
        
end;

% Handle micro stim events
if g_strctParadigm.m_iMachineState == 3
    % During a run (block is in progress)
    fElapsedTimeSec = fCurrTime - g_strctParadigm.m_fStimulusStartTimer;
    iCurrentBlock = find(g_strctParadigm.m_strctCurrentRun.m_afBlockOnsetTimeSec(1:end-1) <= fElapsedTimeSec & ...
        g_strctParadigm.m_strctCurrentRun.m_afBlockOnsetTimeSec(2:end) >= fElapsedTimeSec,1,'last');
    
    if ~isempty(iCurrentBlock) && iCurrentBlock > 0 && ~isempty(g_strctParadigm.m_strctCurrentRun.m_acMicroStim{iCurrentBlock})
        switch g_strctParadigm.m_strctCurrentRun.m_acMicroStim{iCurrentBlock}.m_strType
            case 'FixedRate'
                if GetSecs()-g_strctParadigm.m_fMicroStimTimer > 1/g_strctParadigm.m_strctCurrentRun.m_acMicroStim{iCurrentBlock}.m_fRateHz
                    
                    iNumChannels = length(g_strctParadigm.m_strctCurrentRun.m_acMicroStim{iCurrentBlock}.m_aiChannels);
                    if iNumChannels > 0
                        clear astrctStimulation
                        for iChannelIter=1:iNumChannels
                            astrctStimulation(iChannelIter).m_iChannel = g_strctParadigm.m_strctCurrentRun.m_acMicroStim{iCurrentBlock}.m_aiChannels(iChannelIter);
                            astrctStimulation(iChannelIter).m_fDelayToTrigMS = 0;
                        end

                        fnParadigmToKofikoComm('MultiChannelStimulation', astrctStimulation);
                        g_strctParadigm.m_fMicroStimTimer = GetSecs();
                    end
                end
        end
    end
end

if g_strctParadigm.m_iMachineState == 2 
    if g_strctParadigm.m_bFixationWhileNotScanning
        fnHandleDynamicJuice(strctInputs);
    end
else
    fnHandleDynamicJuice(strctInputs);
end
strctOutput = strctInputs;
return;


function fnHandleDynamicJuice(strctInputs)
%% Reward related stuff
global g_strctParadigm
fCurrTime = GetSecs;

if g_strctParadigm.m_iMachineState == 0
    return;
end
iGazeBoxPix = g_strctParadigm.GazeBoxPix.Buffer(:,:,g_strctParadigm.GazeBoxPix.BufferIdx);

aiGazeRect = [g_strctParadigm.m_pt2fFixationSpot-iGazeBoxPix,g_strctParadigm.m_pt2fFixationSpot+iGazeBoxPix];

bFixating = strctInputs.m_pt2iEyePosScreen(1) > aiGazeRect(1) && ...
    strctInputs.m_pt2iEyePosScreen(2) > aiGazeRect(2) && ...
    strctInputs.m_pt2iEyePosScreen(1) < aiGazeRect(3) && ...
    strctInputs.m_pt2iEyePosScreen(2) < aiGazeRect(4);

fGazeTimeHighSec = g_strctParadigm.GazeTimeMS.Buffer(g_strctParadigm.GazeTimeMS.BufferIdx) /1000;
fGazeTimeLowSec = g_strctParadigm.GazeTimeLowMS.Buffer(g_strctParadigm.GazeTimeLowMS.BufferIdx) /1000;

fBlinkTimeSec = g_strctParadigm.BlinkTimeMS.Buffer(:,:,g_strctParadigm.BlinkTimeMS.BufferIdx) / 1000;
fPositiveIncrement = g_strctParadigm.PositiveIncrement.Buffer(:,:,g_strctParadigm.PositiveIncrement.BufferIdx);
fMaxFixations = 100 / fPositiveIncrement;

fJuiceTimeLowMS = g_strctParadigm.JuiceTimeMS.Buffer(g_strctParadigm.JuiceTimeMS.BufferIdx);
fJuiceTimeHighMS = g_strctParadigm.JuiceTimeHighMS.Buffer(g_strctParadigm.JuiceTimeHighMS.BufferIdx);

fGazeTimeSec = fGazeTimeLowSec + (fGazeTimeHighSec-fGazeTimeLowSec) * (1- g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter / fMaxFixations);
fJuiceTimeMS =  fJuiceTimeLowMS + (fJuiceTimeHighMS-fJuiceTimeLowMS) * (g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter / fMaxFixations);

switch g_strctParadigm.m_strctDynamicJuice.m_iState
    case 0
        % do nothing
        g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime = 0;
        g_strctParadigm.m_strctDynamicJuice.m_fTotalNonFixationTime = 0;
    case 1
        if bFixating
            g_strctParadigm.m_strctDynamicJuice.m_iState = 2;
            g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime = 0;
            g_strctParadigm.m_strctDynamicJuice.m_fLastKnownFixationTime = fCurrTime;
        else
            % Monkey is not fixating. Stay in this mode until monkey fixates....
            g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;
            g_strctParadigm.m_strctDynamicJuice.m_fLastKnownNonFixationTime = fCurrTime;
        end

    case 2
        % Monkey was fixating last iteration
        if bFixating
            % Good. How long did it pass since the last fixation ?
            g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime = g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime + (fCurrTime-g_strctParadigm.m_strctDynamicJuice.m_fLastKnownFixationTime);
            g_strctParadigm.m_strctDynamicJuice.m_fLastKnownFixationTime = fCurrTime;
            if g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime > fGazeTimeSec
                % Reset Counters
                g_strctParadigm.m_strctDynamicJuice.m_fTotalNonFixationTime = 0;
                g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime = 0;
                % Give Juice!
%                fnParadigmToKofikoComm('DisplayMessage', sprintf('Juice Time = %.2f ,Gaze Time = %.1f',fJuiceTimeMS,fGazeTimeSec*1e3 ) );
                fnParadigmToKofikoComm('Juice',fJuiceTimeMS );
                if g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter < fMaxFixations
                    g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter + 1;
                end;
            end
        else
            g_strctParadigm.m_strctDynamicJuice.m_iState = 3;
            g_strctParadigm.m_strctDynamicJuice.m_fLastKnownNonFixationTime = fCurrTime;
        end
    case 3
        % Monkey was not fixating last iteration
        if bFixating
            g_strctParadigm.m_strctDynamicJuice.m_fLastKnownFixationTime = fCurrTime;
            g_strctParadigm.m_strctDynamicJuice.m_iState = 2;
        else
            g_strctParadigm.m_strctDynamicJuice.m_fTotalNonFixationTime = g_strctParadigm.m_strctDynamicJuice.m_fTotalNonFixationTime + (fCurrTime-g_strctParadigm.m_strctDynamicJuice.m_fLastKnownNonFixationTime);
            g_strctParadigm.m_strctDynamicJuice.m_fLastKnownNonFixationTime = fCurrTime;
            if g_strctParadigm.m_strctDynamicJuice.m_fTotalNonFixationTime > fBlinkTimeSec
                g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime = 0;
                g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter = 0;
            end
    

        end
end

return;