function [strctOutput] = fnParadigmForcedChoiceCycle(strctInputs)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm  

fCurrTime = GetSecs();
switch g_strctParadigm.m_iMachineState
    case 0
        fnParadigmToKofikoComm('SetParadigmState','Waiting for user to press Start');
    case 1
        % Make sure everything is ready (lists, etc)

        if ~isempty(g_strctParadigm.m_astrctTrials)
            g_strctParadigm.m_iMachineState = 2;
        else
            fnParadigmToKofikoComm('SetParadigmState','Please load an experiment design file');
        end
    case 2
       
        % Set values for new trial!
        fnParadigmToStimulusServer('ClearScreen');
        % Set ITI value
        fMin = fnTsGetVar(g_strctParadigm,'InterTrialIntervalMinSec');
        fMax = fnTsGetVar(g_strctParadigm,'InterTrialIntervalMaxSec');
        g_strctParadigm.m_fWaitInterval = rand() * (fMax-fMin) + fMin;
        g_strctParadigm.m_fHoldFixationToStartTrialMS = fnTsGetVar(g_strctParadigm,'HoldFixationToStartTrialMS');
        g_strctParadigm.m_fShowObjectsAfterSaccadeSec = fnTsGetVar(g_strctParadigm,'ShowObjectsAfterSaccadeMS')/1e3;        
        g_strctParadigm.m_fTrialTimeoutSec = fnTsGetVar(g_strctParadigm,'TimeoutMS')/1e3;        
        g_strctParadigm.m_fHitRadiusPix = fnTsGetVar(g_strctParadigm,'HitRadius');        
        
        
        g_strctParadigm.m_strctCurrentTrial = [];
        
        % Decide which image to display
        iNumAvailTrials = length(g_strctParadigm.m_astrctTrials);

        if iNumAvailTrials <= 2
            iSelectedTrialAtRandom = round(rand() * (iNumAvailTrials-1))+1;
        else
        if g_strctParadigm.m_iTrialCounter == 1
           % Make a new random sequence of all available trials 
           g_strctParadigm.m_aiRandTrialOrder = randperm(iNumAvailTrials);
        end
        
        iSelectedTrialAtRandom = g_strctParadigm.m_aiRandTrialOrder(g_strctParadigm.m_iTrialCounter);
        end
        
        g_strctParadigm.m_iTrialCounter = g_strctParadigm.m_iTrialCounter + 1;
        if g_strctParadigm.m_iTrialCounter > iNumAvailTrials
            g_strctParadigm.m_iTrialCounter = 1;
            g_strctParadigm.m_iTrialRep = g_strctParadigm.m_iTrialRep + 1; 
        end
        
        g_strctParadigm.m_strctCurrentTrial.m_fFixationTimeOutSec =  fnTsGetVar(g_strctParadigm,'FixationTimeOutMS')/1e3;
        
        g_strctParadigm.m_strctCurrentTrial.m_iTrialDisplayed = iSelectedTrialAtRandom;
        g_strctParadigm.m_strctCurrentTrial.m_fStartChoiceTimer = [];
        g_strctParadigm.m_strctCurrentTrial.m_fTrialOnset_TS_StimulusServer = [];
        g_strctParadigm.m_strctCurrentTrial.m_iNoiseIndex = fnTsGetVar(g_strctParadigm,'NoiseIndex');
        g_strctParadigm.m_strctCurrentTrial.m_fNoiseLevel = fnTsGetVar(g_strctParadigm,'NoiseLevel');
        
        set(g_strctParadigm.m_strctControllers.m_hNoiseIndexEdit,'String',num2str(g_strctParadigm.m_strctCurrentTrial.m_iNoiseIndex));
        set(g_strctParadigm.m_strctControllers.m_hNoiseIndexSlider,'value',g_strctParadigm.m_strctCurrentTrial.m_iNoiseIndex);
        
        if ~isempty( g_strctParadigm.m_strctNoise)
            iNextNoiseIndex = g_strctParadigm.m_strctCurrentTrial.m_iNoiseIndex + 1;
            if iNextNoiseIndex > size(g_strctParadigm.m_strctNoise.a2fRand,3)
                iNextNoiseIndex = 1;
            end
            fnTsSetVarParadigm('NoiseIndex',iNextNoiseIndex);
            
            
        end

        aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
        
        % Prepare the trial structure that is sent to the stimulus server
        strctFixationSpot.m_pt2fPosition = aiScreenSize(3:4)/2;
        strctFixationSpot.m_afBackgroundColor = [0 0 0];
        strctFixationSpot.m_afFixationColor = [255 255 255];
        strctFixationSpot.m_fFixationRadiusPix = 10;
        strctFixationSpot.m_strShape = 'Circle';
        g_strctParadigm.m_strctTrialToStimulusServer = [];
        
        
        g_strctParadigm.m_strctTrialToStimulusServer.m_Image = g_strctParadigm.m_astrctTrials(iSelectedTrialAtRandom).m_Image;
        if isempty( g_strctParadigm.m_strctNoise)
            g_strctParadigm.m_strctTrialToStimulusServer.m_a2fNoise = [];
        else
            g_strctParadigm.m_strctTrialToStimulusServer.m_a2fNoise = g_strctParadigm.m_strctNoise.a2fRand(:,:,g_strctParadigm.m_strctCurrentTrial.m_iNoiseIndex);
        end
        
        g_strctParadigm.m_strctTrialToStimulusServer.m_astrctRelevantChoices = g_strctParadigm.m_astrctChoices(g_strctParadigm.m_astrctTrials(iSelectedTrialAtRandom).m_aiChoices);
        g_strctParadigm.m_strctTrialToStimulusServer.m_fImageHalfSizePix = fnTsGetVar(g_strctParadigm,'ImageHalfSizePix');
        g_strctParadigm.m_strctTrialToStimulusServer.m_fChoicesHalfSizePix = fnTsGetVar(g_strctParadigm,'ChoicesHalfSizePix');
        g_strctParadigm.m_strctTrialToStimulusServer.m_strctFixation = strctFixationSpot;
        g_strctParadigm.m_strctTrialToStimulusServer.m_fDelayBeforeChoicesMS = fnTsGetVar(g_strctParadigm,'DelayBeforeChoicesMS');
        g_strctParadigm.m_strctTrialToStimulusServer.m_fMemoryIntervalMS = fnTsGetVar(g_strctParadigm,'MemoryIntervalMS');
        g_strctParadigm.m_strctTrialToStimulusServer.m_fNoiseLevel =  g_strctParadigm.m_strctCurrentTrial.m_fNoiseLevel;
        
        fnReleaseMemoryAndAllocatePTBTextures(g_strctParadigm.m_strctTrialToStimulusServer);
        
        g_strctParadigm.m_fTimer1 = fCurrTime;
        g_strctParadigm.m_iMachineState = 3;
    case 3
        % Wait the inter trial interval
        if fCurrTime - g_strctParadigm.m_fTimer1 > g_strctParadigm.m_fWaitInterval
            g_strctParadigm.m_iMachineState = 4;
        else
            fnParadigmToKofikoComm('SetParadigmState', sprintf('Next Trial Starts In %.2f Sec',...
                g_strctParadigm.m_fWaitInterval-(fCurrTime - g_strctParadigm.m_fTimer1)));
        end
    case 4        
        % Show fixation spot 
        
        aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
        strctFixationSpot.m_pt2fPosition = aiScreenSize(3:4)/2;
        strctFixationSpot.m_afBackgroundColor = [0 0 0];
        strctFixationSpot.m_afFixationColor = [255 255 255];
        strctFixationSpot.m_fFixationRadiusPix = 10;
        strctFixationSpot.m_strShape = 'Circle';
        
        %g_strctParadigm.m_strctCurrentTrial.m_strctFixationSpot = strctFixationSpot;
        fnParadigmToStimulusServer('ShowFixationSpot', strctFixationSpot);
        fnParadigmToKofikoComm('SetParadigmState','Waiting for fixation spot to appear');
        
        g_strctParadigm.m_fFixationRadiusPix = fnTsGetVar(g_strctParadigm,'FixationRadiusPix');
        g_strctParadigm.m_iMachineState = 5;
        
        fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialStartCode);
        fnParadigmToKofikoComm('TrialStart',g_strctParadigm.m_strctCurrentTrial.m_iTrialDisplayed); % send trial type code
    case 5
        
        % Wait until monkey we get the OK from the stimulus server that
        % fixation spot appeared
        if ~isempty(strctInputs.m_acInputFromStimulusServer)
            if strcmpi(strctInputs.m_acInputFromStimulusServer{1},'FixationAppear')
                g_strctParadigm.m_strctCurrentTrial.m_fTrialOnset_TS_StimulusServer = strctInputs.m_acInputFromStimulusServer{2};
                g_strctParadigm.m_fTimer1p5 = GetSecs();
                fnParadigmToKofikoComm('SetParadigmState','Waiting for monkey hold fixation');
            end
        end
        
        if ~isempty(g_strctParadigm.m_strctCurrentTrial.m_fTrialOnset_TS_StimulusServer) %Fixation spot is on screen
            % Wait until monkey fixates for X ms
            fDistanceFromFixationSpot = norm(strctInputs.m_pt2iEyePosScreen-g_strctParadigm.m_pt2fFixationSpot);
            if fDistanceFromFixationSpot < g_strctParadigm.m_fFixationRadiusPix
                g_strctParadigm.m_fTimer2 = fCurrTime;
                g_strctParadigm.m_iMachineState = 6;
            else
                fnParadigmToKofikoComm('SetParadigmState', sprintf('Waiting for monkey hold fixation for %.2f sec', ...
                    g_strctParadigm.m_fHoldFixationToStartTrialMS/1e3));

                if (fCurrTime-g_strctParadigm.m_fTimer1p5 > g_strctParadigm.m_strctCurrentTrial.m_fFixationTimeOutSec)
                   % Monkey did not fixate the needed time. Trial timeout
                   fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialOutcomesCodes(1));
                   fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialEndCode);
                   
                    % Punish with long inter trial interval
                    g_strctParadigm.m_strctCurrentTrial.m_strResult = 'BreakFix';
                    g_strctParadigm.m_iMachineState = 13;
                   
                end
            end
              
        end
        
    case 6
        fDistanceFromFixationSpot = norm(strctInputs.m_pt2iEyePosScreen-g_strctParadigm.m_pt2fFixationSpot);
        
       fnParadigmToKofikoComm('SetParadigmState', sprintf('Waiting for monkey hold fixation for %.2f more sec', ...
           g_strctParadigm.m_fHoldFixationToStartTrialMS/1e3 - (fCurrTime-g_strctParadigm.m_fTimer2)));
        
        if fDistanceFromFixationSpot > g_strctParadigm.m_fFixationRadiusPix
            g_strctParadigm.m_iMachineState = 5; % monkey broke fixation
        else
            if fCurrTime-g_strctParadigm.m_fTimer2 > g_strctParadigm.m_fHoldFixationToStartTrialMS/1e3
                g_strctParadigm.m_iMachineState = 7; % Continue with trial 
            end
        end
    case 7
        % Monkey has fixated for X ms. Now display center image.
        fnParadigmToKofikoComm('SetParadigmState','Waiting for stimulus to appear');
        fnParadigmToStimulusServer('ShowTrial',g_strctParadigm.m_strctTrialToStimulusServer);
        fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialAlignCode); % Align trials statistics to stimulus onset
        g_strctParadigm.m_strctCurrentTrial.m_fTrialStartTimeLocal = fCurrTime;
        g_strctParadigm.m_iMachineState = 8;
      case 8
       % Wait until we get accurate flip TS from stimulus server
       if ~isempty(strctInputs.m_acInputFromStimulusServer)
            if strcmpi(strctInputs.m_acInputFromStimulusServer{1},'StimulusTS')
                g_strctParadigm.m_strctCurrentTrial.m_fTrialOnset_TS_StimulusServer = strctInputs.m_acInputFromStimulusServer{2};
                g_strctParadigm.m_strctCurrentTrial.m_fStartChoiceTimer = fCurrTime;
                fnParadigmToKofikoComm('SetParadigmState','Waiting for monkey to decide');
                
                       
                g_strctParadigm.m_iMachineState = 10;
            end
       end
       
       fDistanceFromFixationSpot = norm(strctInputs.m_pt2iEyePosScreen-g_strctParadigm.m_pt2fFixationSpot);
       if fDistanceFromFixationSpot > g_strctParadigm.m_fFixationRadiusPix && g_strctParadigm.m_strctTrialToStimulusServer.m_fDelayBeforeChoicesMS > 0
           % Trial ends. monkey broke fixation
           fnParadigmToStimulusServer('AbortTrial');
           fnParadigmToKofikoComm('TrialEnd',false);
           g_strctParadigm.m_iMachineState = 13;

           fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialOutcomesCodes(1));
           fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialEndCode);
           
           g_strctParadigm.m_strctCurrentTrial.m_strResult = 'ShortHold';
           g_strctParadigm.m_strctCurrentTrial.m_fTrialEndTimeLocal = fCurrTime;
           fnTsSetVarParadigm('acTrials', g_strctParadigm.m_strctCurrentTrial);
           g_strctParadigm.m_strctStatistics.m_iNumShortHold = g_strctParadigm.m_strctStatistics.m_iNumShortHold + 1;
           
       end
     
    case 10
         % Wait until monkey makes a saccade to a choice or trial timeout.
         if fCurrTime - g_strctParadigm.m_strctCurrentTrial.m_fStartChoiceTimer > g_strctParadigm.m_fTrialTimeoutSec
             % Trial Ends. Timeout!
             g_strctParadigm.m_strctCurrentTrial.m_strResult = 'Timeout';
             g_strctParadigm.m_strctCurrentTrial.m_fTrialEndTimeLocal = fCurrTime;
             fnTsSetVarParadigm('acTrials', g_strctParadigm.m_strctCurrentTrial);
             g_strctParadigm.m_strctStatistics.m_iNumTimeout = g_strctParadigm.m_strctStatistics.m_iNumTimeout +1;
             g_strctParadigm.m_iMachineState = 13; 
             
             fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialOutcomesCodes(4));
             fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialEndCode);
                
             fnParadigmToKofikoComm('TrialEnd',false);
         else
            fnParadigmToKofikoComm('SetParadigmState', sprintf('Waiting for monkey to decide. Timeout in %.2f Sec', ...
                g_strctParadigm.m_fTrialTimeoutSec - (fCurrTime - g_strctParadigm.m_strctCurrentTrial.m_fStartChoiceTimer)));
         end
         
         iNumChoices = length(g_strctParadigm.m_strctTrialToStimulusServer.m_astrctRelevantChoices);
         for k=1:iNumChoices
             % Test whether monkey saccade to this choice
             pt2fTargerCenterPos = g_strctParadigm.m_strctTrialToStimulusServer.m_strctFixation.m_pt2fPosition + ...
                 g_strctParadigm.m_strctTrialToStimulusServer.m_astrctRelevantChoices(k).m_pt2fRelativePos;
             fDistanceFromChoice = norm(strctInputs.m_pt2iEyePosScreen-pt2fTargerCenterPos);
             if  fDistanceFromChoice <  g_strctParadigm.m_fHitRadiusPix
                 
                 if g_strctParadigm.m_bExtinguishObjectsAfterSaccade
                        % Tell stimulus server to extinguish stuff
                    %    fnParadigmToStimulusServer('ShowChoice',g_strctParadigm.m_astrctChoices();
                    fnParadigmToStimulusServer('ShowChoice',g_strctParadigm.m_strctTrialToStimulusServer.m_astrctRelevantChoices(k),...
                       g_strctParadigm.m_strctTrialToStimulusServer.m_strctFixation, ...
                       g_strctParadigm.m_strctTrialToStimulusServer.m_fChoicesHalfSizePix);
                 end
              
                 % Monkey  saccaded to this choice
                 % If this is the first choice, it is the correct one.
                 g_strctParadigm.m_strctCurrentTrial.m_iMonkeySaccadeToTargetIndex = k;
                 g_strctParadigm.m_iMachineState = 11;
                 
                 if k == 1
                    % Correct Trial. Give Juice.
                    g_strctParadigm.m_strctCurrentTrial.m_strResult = 'Correct';
                    g_strctParadigm.m_strctCurrentTrial.m_fTrialEndTimeLocal = fCurrTime;
                    fnTsSetVarParadigm('acTrials', g_strctParadigm.m_strctCurrentTrial);
                    g_strctParadigm.m_strctStatistics.m_iNumCorrect = g_strctParadigm.m_strctStatistics.m_iNumCorrect + 1;
                    fnParadigmToKofikoComm('SetParadigmState','Correct Trial. Giving Reward.');
                    fJuiceTimeMS = fnTsGetVar(g_strctParadigm,'JuiceTimeMS');
                    fnParadigmToKofikoComm('Juice',fJuiceTimeMS );
                    
                    
                    fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialOutcomesCodes(3));
                    fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialEndCode);
                    
                    fnParadigmToKofikoComm('TrialEnd',true);
                    
                    % Staircase adjustment
                    
                    iNumStepsDown = fnTsGetVar(g_strctParadigm, 'StairCaseDown');
                    if iNumStepsDown > 0
                        fPercDown = iNumStepsDown*fnTsGetVar(g_strctParadigm, 'StairCaseStepPerc');
                        fNewNoiseLevel = min(100, max(0, (1+fPercDown/100) * g_strctParadigm.m_strctCurrentTrial.m_fNoiseLevel));
                        fnTsSetVarParadigm('NoiseLevel',fNewNoiseLevel);
                        % Update GUI
                        set(g_strctParadigm.m_strctControllers.m_hNoiseLevelEdit,'String',sprintf('%.2f',fNewNoiseLevel));
                        set(g_strctParadigm.m_strctControllers.m_hNoiseLevelSlider,'value',fNewNoiseLevel);
                    end
                    
                 else
                    % Incorrect trial
                    g_strctParadigm.m_strctCurrentTrial.m_strResult = 'Incorrect';
                    g_strctParadigm.m_strctCurrentTrial.m_fTrialEndTimeLocal = fCurrTime;
                    fnTsSetVarParadigm('acTrials', g_strctParadigm.m_strctCurrentTrial);
                    g_strctParadigm.m_strctStatistics.m_iNumIncorrect = g_strctParadigm.m_strctStatistics.m_iNumIncorrect + 1;
                    fnParadigmToKofikoComm('SetParadigmState','Incorrect Trial.');
                    
                    
                    iNumStepsUp = fnTsGetVar(g_strctParadigm, 'StairCaseUp');
                    if iNumStepsUp > 0
                        fPercUp = iNumStepsUp*fnTsGetVar(g_strctParadigm, 'StairCaseStepPerc');
                        fNewNoiseLevel = min(100, max(0, (1-fPercUp/100) * g_strctParadigm.m_strctCurrentTrial.m_fNoiseLevel));
                        fnTsSetVarParadigm('NoiseLevel',fNewNoiseLevel);
                        % Update GUI
                        set(g_strctParadigm.m_strctControllers.m_hNoiseLevelEdit,'String',sprintf('%.2f',fNewNoiseLevel));
                        set(g_strctParadigm.m_strctControllers.m_hNoiseLevelSlider,'value',fNewNoiseLevel);
                    end
                    
                    fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialOutcomesCodes(2));
                    fnDAQWrapper('StrobeWord', g_strctParadigm.m_strctStatServerDesign.TrialEndCode);
                    
                    fnParadigmToKofikoComm('TrialEnd',false);
                    
                 end
                 break;
             end

         end
    case 11
 
        g_strctParadigm.m_fShowObjectsAfterSaccadeSec = fnTsGetVar(g_strctParadigm,'ShowObjectsAfterSaccadeMS') / 1e3;
        if g_strctParadigm.m_fShowObjectsAfterSaccadeSec > 0
            g_strctParadigm.m_fShowAfterTimer = fCurrTime;
            g_strctParadigm.m_iMachineState = 12;
        else
            g_strctParadigm.m_iMachineState = 13;
        end
    case 12
        % Show images for some time
        if fCurrTime - g_strctParadigm.m_fShowAfterTimer > g_strctParadigm.m_fShowObjectsAfterSaccadeSec 
            g_strctParadigm.m_iMachineState = 13;
        else
            fnParadigmToKofikoComm('SetParadigmState', sprintf('Persisting Images for %.2f Sec',...
                g_strctParadigm.m_fShowObjectsAfterSaccadeSec - (fCurrTime - g_strctParadigm.m_fShowAfterTimer )));
        end
        
    case 13
        % If this was incorrect trial. Add punishment delay
        g_strctParadigm.m_fIncorrectTrialDelaySec = fnTsGetVar(g_strctParadigm,'IncorrectTrialDelayMS')/1e3;
        if ~strcmp(g_strctParadigm.m_strctCurrentTrial.m_strResult,'Correct') && g_strctParadigm.m_fIncorrectTrialDelaySec > 0
            fnParadigmToStimulusServer('ClearScreen');
            g_strctParadigm.m_fIncorrectDelayTimer = fCurrTime;
            g_strctParadigm.m_iMachineState = 14;
        else
            g_strctParadigm.m_iMachineState = 1;
        end
    case 14
        if fCurrTime - g_strctParadigm.m_fIncorrectDelayTimer > g_strctParadigm.m_fIncorrectTrialDelaySec
            g_strctParadigm.m_iMachineState = 1;
        else
            fnParadigmToKofikoComm('SetParadigmState', sprintf('Delaying after %s. Resume in %.2f Sec',...
               g_strctParadigm.m_strctCurrentTrial.m_strResult,g_strctParadigm.m_fIncorrectTrialDelaySec-(fCurrTime - g_strctParadigm.m_fIncorrectDelayTimer ))); 
        end
end

strctOutput = strctInputs;
return;

function fnReleaseMemoryAndAllocatePTBTextures(strctCurrentTrial)
global g_strctParadigm g_strctPTB

% Release existing handles if they exist
if ~isempty(g_strctParadigm.m_ahPTBHandles)
    Screen('Close',g_strctParadigm.m_ahPTBHandles);
    g_strctParadigm.m_ahPTBHandles = [];
end
if ~isempty(g_strctParadigm.m_hNoiseHandle)
    Screen('Close',g_strctParadigm.m_hNoiseHandle);
    g_strctParadigm.m_hNoiseHandle = [];
end

% Allocate new ones for next trial
iNumChoices = length(strctCurrentTrial.m_astrctRelevantChoices);        
g_strctParadigm.m_ahPTBHandles = zeros(1, 1+iNumChoices);
g_strctParadigm.m_a2iStimulusRect = zeros(iNumChoices+1,4);

g_strctParadigm.m_a2iStimulusRect(1,:) = fnComputeStimulusRect(strctCurrentTrial.m_fImageHalfSizePix, ...
    [size(strctCurrentTrial.m_Image,2), size(strctCurrentTrial.m_Image,1)], strctCurrentTrial.m_strctFixation.m_pt2fPosition);

if strcmp(class(strctCurrentTrial.m_Image),'uint8')
    g_strctParadigm.m_ahPTBHandles(1) = Screen('MakeTexture', g_strctPTB.m_hWindow,  strctCurrentTrial.m_Image);
else
    g_strctParadigm.m_ahPTBHandles(1) = Screen('MakeTexture', g_strctPTB.m_hWindow,  strctCurrentTrial.m_Image*255);
end


for k=1:iNumChoices
    strctChoice = strctCurrentTrial.m_astrctRelevantChoices(k);
    g_strctParadigm.m_a2iStimulusRect(k+1,:) = fnComputeStimulusRect(strctCurrentTrial.m_fChoicesHalfSizePix, ...
        [size(strctChoice.m_Image,2), size(strctChoice.m_Image,1)], strctCurrentTrial.m_strctFixation.m_pt2fPosition + strctChoice.m_pt2fRelativePos);

    if strcmp(class(strctChoice.m_Image),'uint8')
         g_strctParadigm.m_ahPTBHandles(k+1)  = Screen('MakeTexture', g_strctPTB.m_hWindow,  strctChoice.m_Image);
    else
         g_strctParadigm.m_ahPTBHandles(k+1)  = Screen('MakeTexture', g_strctPTB.m_hWindow,  strctChoice.m_Image*255);
    end
end

fAlpha = strctCurrentTrial.m_fNoiseLevel/100;
warning off
a3iNoiseMask = uint8(min(255,max(0,strctCurrentTrial.m_a2fNoise * 128/3.9 + 128)));
a3iNoiseMask(:,:,2) = round(fAlpha * 255);
warning on
g_strctParadigm.m_hNoiseHandle = Screen('MakeTexture', g_strctPTB.m_hWindow,  a3iNoiseMask);


return;


