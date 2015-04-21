function [strctOutput] = fnParadigmTargetDetectionCycle(strctInputs)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm g_strctStimulusServer g_strctPTB

if g_strctParadigm.m_bExtinguishObjectsAfterSaccade
    if ~isempty(strctInputs.m_acInputFromStimulusServer)
        if strcmpi(strctInputs.m_acInputFromStimulusServer{1},'StimulusON')
            g_strctParadigm.m_strctCurrentTrial.m_fFlipExtinguish_TS_StimulusServer = strctInputs.m_acInputFromStimulusServer{2};
        end
    end
end


fCurrTime = GetSecs();
switch g_strctParadigm.m_iMachineState
    case 0
        fnParadigmToKofikoComm('SetParadigmState','Waiting for user to press Start');
    case 1
        % Make sure everything is ready (lists, etc)
        iNumTargets = fnTsGetVar(g_strctParadigm,'NumTargets');
        iNumNonTargets = fnTsGetVar(g_strctParadigm,'NumNonTargets');
        
        iNumAvailTargets = sum(g_strctParadigm.m_strctObjects.m_aiGroup == 1);
        iNumAvailNonTargets = sum(g_strctParadigm.m_strctObjects.m_aiGroup == 0);
        if iNumTargets > iNumAvailTargets 
            fnParadigmToKofikoComm('SetParadigmState','Cannot start. Avail targets < Required targets');
        elseif iNumNonTargets > iNumAvailNonTargets 
            fnParadigmToKofikoComm('SetParadigmState','Cannot start. Avail non-targets < Required non-targets');
        else
            g_strctParadigm.m_iMachineState = 2;
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
        
        iNumTargets = fnTsGetVar(g_strctParadigm,'NumTargets');
        iNumNonTargets = fnTsGetVar(g_strctParadigm,'NumNonTargets');
        iNumAvailTargets = sum(g_strctParadigm.m_strctObjects.m_aiGroup == 1);
        iNumAvailNonTargets = sum(g_strctParadigm.m_strctObjects.m_aiGroup == 0);
        
        aiTargets = find(g_strctParadigm.m_strctObjects.m_aiGroup == 1);
        aiNonTargets = find(g_strctParadigm.m_strctObjects.m_aiGroup == 0);
        % Set Number of targets, non targets and their position....
        % Randomly select the target/non targets
        
        g_strctParadigm.m_strctCurrentTrial = [];
        g_strctParadigm.m_strctCurrentTrial.m_aiSelectedTargets = aiTargets(1+round(rand(1,iNumTargets) * (iNumAvailTargets-1)));
        g_strctParadigm.m_strctCurrentTrial.m_aiSelectedNonTargets = aiNonTargets(1+round(rand(1,iNumNonTargets) * (iNumAvailNonTargets-1)));
        
        g_strctParadigm.m_strctCurrentTrial.m_aiSelectedObjects = [g_strctParadigm.m_strctCurrentTrial.m_aiSelectedTargets,...
            g_strctParadigm.m_strctCurrentTrial.m_aiSelectedNonTargets];
        apt2fPos = fnGetObjectPosition(iNumTargets+iNumNonTargets);
         
        if iNumTargets+iNumNonTargets == 2 && g_strctParadigm.m_bEmulatorON
            % Do something more sophisticated?
            [aiResponsesOcc,afImmediateHistory] = fnComputeResponseOccurences();
            if isempty(aiResponsesOcc)
                aiOrder = randperm(iNumTargets+iNumNonTargets);
            else
                [fDummy,iSelectedOppositeResponse] = min(aiResponsesOcc);
                if iSelectedOppositeResponse == 1
                    fnParadigmToKofikoComm('DisplayMessage','Predicting Left');
                    aiOrder = [1,2];
                else
                    fnParadigmToKofikoComm('DisplayMessage','Predicting Right');
                    aiOrder = [2,1];
                end
            end
        else
            aiOrder = randperm(iNumTargets+iNumNonTargets);
        end
        g_strctParadigm.m_strctCurrentTrial.m_aiOrderOnScreen = aiOrder;
        g_strctParadigm.m_strctCurrentTrial.m_apt2fPos = apt2fPos(:,aiOrder);
        
        if isfield(g_strctParadigm.m_strctObjects,'m_acImages') && ~isempty(g_strctParadigm.m_strctObjects.m_acImages)
            % Transmit images over the network. Stimulus server has no
            % list. Textures are generated and released in real time
            g_strctParadigm.m_strctCurrentTrial.m_acImages = g_strctParadigm.m_strctObjects.m_acImages(g_strctParadigm.m_strctCurrentTrial.m_aiSelectedObjects);
        end
        
        g_strctParadigm.m_strctCurrentTrial.m_fTrialOnset_TS_StimulusServer = [];
        g_strctParadigm.m_strctCurrentTrial.m_fFlipStimulusON_TS_StimulusServer = [];
        g_strctParadigm.m_strctCurrentTrial.m_fFlipExtinguish_TS_StimulusServer = [];
        g_strctParadigm.m_strctCurrentTrial.m_pt2fHoldPos = [];
        g_strctParadigm.m_strctCurrentTrial.m_bMicroStimulation = fnTsGetVar(g_strctParadigm,'StimulationON');
        g_strctParadigm.m_strctCurrentTrial.m_fMicroStimulationOffsetMS = fnTsGetVar(g_strctParadigm,'StimulationOffsetMS');
        g_strctParadigm.m_bMicroStimDone = false;
        
        g_strctParadigm.m_strctCurrentTrial.m_fTimeOutSec = fnTsGetVar(g_strctParadigm,'TimeoutMS')/1e3;
        g_strctParadigm.m_strctCurrentTrial.m_fHitRadius = fnTsGetVar(g_strctParadigm,'HitRadius');
        g_strctParadigm.m_strctCurrentTrial.m_fObjectHalfSizePix = fnTsGetVar(g_strctParadigm,'ObjectHalfSizePix');
        g_strctParadigm.m_strctCurrentTrial.m_fHoldTimeSec = fnTsGetVar(g_strctParadigm,'HoldFixationAtTargetMS')/1e3;
        
        
        
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
        
        g_strctParadigm.m_strctCurrentTrial.m_strctFixationSpot = strctFixationSpot;
        fnParadigmToStimulusServer('ShowFixationSpot', strctFixationSpot);
        fnParadigmToKofikoComm('SetParadigmState','Waiting for fixation spot to appear');
        
        g_strctParadigm.m_fFixationRadiusPix = fnTsGetVar(g_strctParadigm,'FixationRadiusPix');
        g_strctParadigm.m_iMachineState = 5;
        fnParadigmToKofikoComm('TrialStart',1);
        
    case 5
        
        % Wait until monkey has we get the OK from the stimulus server that
        % fixation spot appeared
        if ~isempty(strctInputs.m_acInputFromStimulusServer)
            if strcmpi(strctInputs.m_acInputFromStimulusServer{1},'FixationAppear')
                g_strctParadigm.m_strctCurrentTrial.m_fTrialOnset_TS_StimulusServer = strctInputs.m_acInputFromStimulusServer{2};
                fnParadigmToKofikoComm('SetParadigmState','Waiting for monkey hold fixation');
            end
        end
        
        if ~isempty(g_strctParadigm.m_strctCurrentTrial.m_fTrialOnset_TS_StimulusServer) %Fixation spot is on screen
            % Wait until monkey fixates for X ms
            fDistanceFromFixationSpot = norm(strctInputs.m_pt2iEyePosScreen-g_strctParadigm.m_pt2fFixationSpot);
            if fDistanceFromFixationSpot < g_strctParadigm.m_fFixationRadiusPix
                g_strctParadigm.m_fTimer2 = fCurrTime; % Timer 2 is when the monkey started fixating
                g_strctParadigm.m_iMachineState = 6;
                g_strctParadigm.m_bMicroStimInitiated = false;
            else
                fnParadigmToKofikoComm('SetParadigmState', sprintf('Waiting for monkey hold fixation for %.2f sec', ...
                    g_strctParadigm.m_fHoldFixationToStartTrialMS/1e3));

            end
              
        end
        
    case 6
        fDistanceFromFixationSpot = norm(strctInputs.m_pt2iEyePosScreen-g_strctParadigm.m_pt2fFixationSpot);
        
       fnParadigmToKofikoComm('SetParadigmState', sprintf('Waiting for monkey hold fixation for %.2f more sec', ...
           g_strctParadigm.m_fHoldFixationToStartTrialMS/1e3 - (fCurrTime-g_strctParadigm.m_fTimer2)));
        
        if fDistanceFromFixationSpot > g_strctParadigm.m_fFixationRadiusPix
            g_strctParadigm.m_iMachineState = 5;
        else
            if fCurrTime-g_strctParadigm.m_fTimer2 > g_strctParadigm.m_fHoldFixationToStartTrialMS/1e3
                g_strctParadigm.m_iMachineState = 7;
            end
        end
        
        % Micro stim
        if g_strctParadigm.m_strctCurrentTrial.m_bMicroStimulation && g_strctParadigm.m_strctCurrentTrial.m_fMicroStimulationOffsetMS < 0 && ...
                ~g_strctParadigm.m_bMicroStimInitiated
            if fCurrTime - g_strctParadigm.m_fTimer2 > (g_strctParadigm.m_fHoldFixationToStartTrialMS/1e3 + g_strctParadigm.m_strctCurrentTrial.m_fMicroStimulationOffsetMS/1e3)
                g_strctParadigm.m_fMicroStimulationTimer = GetSecs();
                g_strctParadigm.m_bMicroStimInitiated = true;
                fnParadigmToKofikoComm('StimulationTTL');
            end
        end
        
        
    case 7
        % Monkey has fixated for X ms. Now display targets.
        fnParadigmToKofikoComm('SetParadigmState','Waiting for stimulus to appear');
        fnParadigmToStimulusServer('ShowTrial', g_strctParadigm.m_strctCurrentTrial);
        g_strctParadigm.m_strctCurrentTrial.m_fTrialStartTimeLocal = fCurrTime;
        g_strctParadigm.m_iMachineState = 8;
       
        
    case 8
        if ~isempty(strctInputs.m_acInputFromStimulusServer)
            if strcmpi(strctInputs.m_acInputFromStimulusServer{1},'StimulusON')
                g_strctParadigm.m_strctCurrentTrial.m_fFlipStimulusON_TS_StimulusServer = strctInputs.m_acInputFromStimulusServer{2};
                g_strctParadigm.m_strctCurrentTrial.m_fFlipStimulusON_TS_Local = fCurrTime;
                fnParadigmToKofikoComm('SetParadigmState','Waiting for monkey to decide');
                if g_strctParadigm.m_strctCurrentTrial.m_bMicroStimulation && g_strctParadigm.m_strctCurrentTrial.m_fMicroStimulationOffsetMS == 0
                    fnParadigmToKofikoComm('StimulationTTL');
                    g_strctParadigm.m_bMicroStimInitiated = true;
                end
            end
        end
        if ~isempty(g_strctParadigm.m_strctCurrentTrial.m_fFlipStimulusON_TS_StimulusServer)
             
            
            % Wait until monkey gaze leaves fixation area and lands on
            % target/non-target
            if fCurrTime-g_strctParadigm.m_strctCurrentTrial.m_fFlipStimulusON_TS_Local > g_strctParadigm.m_strctCurrentTrial.m_fTimeOutSec
                 % Timeout!
                 
                g_strctParadigm.m_strctCurrentTrial.m_strResult = 'Timeout';
                g_strctParadigm.m_strctCurrentTrial.m_fTrialEndTimeLocal = fCurrTime;
                fnTsSetVarParadigm('acTrials', g_strctParadigm.m_strctCurrentTrial);
                fnParadigmToKofikoComm('TrialEnd',false);
                g_strctParadigm.m_strctStatistics.m_iNumTimeout = g_strctParadigm.m_strctStatistics.m_iNumTimeout +1;


                 g_strctParadigm.m_iMachineState = 15;
            else
                fnParadigmToKofikoComm('SetParadigmState', sprintf('Waiting for monkey to decide. %.2f Sec Left',...
                    g_strctParadigm.m_strctCurrentTrial.m_fTimeOutSec-(fCurrTime-g_strctParadigm.m_strctCurrentTrial.m_fFlipStimulusON_TS_Local) ));
            end
            
            for k=1:length(g_strctParadigm.m_strctCurrentTrial.m_aiSelectedObjects)
                fDistToObject = norm(strctInputs.m_pt2iEyePosScreen-g_strctParadigm.m_strctCurrentTrial.m_apt2fPos(:,k)');
                if (fDistToObject < g_strctParadigm.m_strctCurrentTrial.m_fHitRadius)
                    g_strctParadigm.m_strctCurrentTrial.m_fSaccadeToObjectTSLocal = fCurrTime;
                    g_strctParadigm.m_strctCurrentTrial.m_iGazedAtObject  = g_strctParadigm.m_strctCurrentTrial.m_aiSelectedObjects(k);
                    g_strctParadigm.m_strctCurrentTrial.m_iPositionIndex = g_strctParadigm.m_strctCurrentTrial.m_aiOrderOnScreen(k);
                    g_strctParadigm.m_strctCurrentTrial.m_pt2fHoldPos = g_strctParadigm.m_strctCurrentTrial.m_apt2fPos(:,k)';                    
                    g_strctParadigm.m_fTimer3 = fCurrTime;
                    
                    if g_strctParadigm.m_bExtinguishObjectsAfterSaccade
                      strctOnlyOneObject =  g_strctParadigm.m_strctCurrentTrial;
                      strctOnlyOneObject.m_aiSelectedObjects = g_strctParadigm.m_strctCurrentTrial.m_iGazedAtObject;
                      if isfield(g_strctParadigm.m_strctObjects,'m_acImages') && ~isempty(g_strctParadigm.m_strctObjects.m_acImages)
                        strctOnlyOneObject.m_aiSelectedObjects = 1;
                        strctOnlyOneObject.m_acImages = g_strctParadigm.m_strctObjects.m_acImages(g_strctParadigm.m_strctCurrentTrial.m_iGazedAtObject);
                      end
                      
                      strctOnlyOneObject.m_apt2fPos = g_strctParadigm.m_strctCurrentTrial.m_apt2fPos(:,k);
                      strctOnlyOneObject.m_strctFixationSpot = [];
                      fnParadigmToStimulusServer('ShowTrial', strctOnlyOneObject);
                    end
                    
                    fnParadigmToKofikoComm('SetParadigmState','Waiting to hold fixation at object');                    
                    
                    g_strctParadigm.m_iMachineState = 9;
                    
                end
            end
            
        end
    case 9
        
        
        
            % Monkey saccaded to a "target"/"non-target"
            % If monkey fixates this object for X ms, give reward
            % Otherwise, trial is aborted
            fDistToHoldPos= norm(strctInputs.m_pt2iEyePosScreen-g_strctParadigm.m_strctCurrentTrial.m_pt2fHoldPos);
            if (fDistToHoldPos < g_strctParadigm.m_strctCurrentTrial.m_fHitRadius) || g_strctParadigm.m_strctCurrentTrial.m_fHoldTimeSec == 0
                if fCurrTime-g_strctParadigm.m_fTimer3>=g_strctParadigm.m_strctCurrentTrial.m_fHoldTimeSec
                    % Correct Trial
                    bTarget = g_strctParadigm.m_strctObjects.m_aiGroup( g_strctParadigm.m_strctCurrentTrial.m_iGazedAtObject ) == 1;
                    if bTarget
                        g_strctParadigm.m_strctCurrentTrial.m_strResult = 'Correct';
                        g_strctParadigm.m_strctCurrentTrial.m_fTrialEndTimeLocal = fCurrTime;
                        fnTsSetVarParadigm('acTrials', g_strctParadigm.m_strctCurrentTrial);
                        g_strctParadigm.m_strctStatistics.m_iNumCorrect = g_strctParadigm.m_strctStatistics.m_iNumCorrect + 1;
                        fnParadigmToKofikoComm('SetParadigmState','Saccade To Target. Giving Reward.');
                        fnParadigmToKofikoComm('TrialEnd',true);
                            
                    else
                        g_strctParadigm.m_strctCurrentTrial.m_strResult = 'Incorrect';
                        g_strctParadigm.m_strctCurrentTrial.m_fTrialEndTimeLocal = fCurrTime;
                        fnTsSetVarParadigm('acTrials', g_strctParadigm.m_strctCurrentTrial);

                        fnParadigmToKofikoComm('TrialEnd',false);
                        
                        g_strctParadigm.m_strctStatistics.m_iNumIncorrect = g_strctParadigm.m_strctStatistics.m_iNumIncorrect + 1;
                        fnParadigmToKofikoComm('SetParadigmState','Saccade To Non-Target.');
                    end
                    g_strctParadigm.m_iMachineState = 10;
                    
                end
            else
                % Monkey saccade outside his initial decision object
                % Incorrect trial!
                % Show images for additional X ms and start a new trial

                g_strctParadigm.m_strctCurrentTrial.m_strResult = 'ShortHold';
                g_strctParadigm.m_strctCurrentTrial.m_fTrialEndTimeLocal = fCurrTime;
                fnTsSetVarParadigm('acTrials', g_strctParadigm.m_strctCurrentTrial);
                g_strctParadigm.m_strctStatistics.m_iNumShortHold = g_strctParadigm.m_strctStatistics.m_iNumShortHold + 1;
                
                fnParadigmToKofikoComm('TrialEnd',false);
                
                if g_strctParadigm.m_fShowObjectsAfterSaccadeSec == 0
                    g_strctParadigm.m_iMachineState = 15;
                else
                    g_strctParadigm.m_fTimer5 = fCurrTime;
                    g_strctParadigm.m_iMachineState = 13;
                end
                
            end
%        end
                  
    case 10
        fJuiceWeight = g_strctParadigm.m_strctObjects.m_afWeights(g_strctParadigm.m_strctCurrentTrial.m_iGazedAtObject);
        if fJuiceWeight > 0
            fJuiceTimeMS = fnTsGetVar(g_strctParadigm,'JuiceTimeMS');
            if g_strctParadigm.m_bJuicePulses 
                g_strctParadigm.m_iJuicePulsesLeft = fJuiceWeight-1;
                fnParadigmToKofikoComm('Juice',fJuiceTimeMS);
                g_strctParadigm.m_iMachineState = 11;
            else
                fnParadigmToKofikoComm('Juice',ceil(fJuiceWeight* fJuiceTimeMS));
                g_strctParadigm.m_fTimer5 = fCurrTime;
                g_strctParadigm.m_iMachineState = 13;
            end
        else
                g_strctParadigm.m_fTimer5 = fCurrTime;
                g_strctParadigm.m_iMachineState = 13;
        end
        
    case 11
        if g_strctParadigm.m_iJuicePulsesLeft <= 0
                g_strctParadigm.m_fTimer5 = fCurrTime;
                g_strctParadigm.m_iMachineState = 13;
        else
            if fnParadigmToKofikoComm('IsJuiceOn') == 0
                g_strctParadigm.m_iMachineState = 12;  
                g_strctParadigm.m_fTimer4 = fCurrTime;
            end
        end
    case 12
        if (fCurrTime-g_strctParadigm.m_fTimer4 > 80/1e3)
            fJuiceTimeMS = fnTsGetVar(g_strctParadigm,'JuiceTimeMS');
            fnParadigmToKofikoComm('Juice',fJuiceTimeMS);
            g_strctParadigm.m_iJuicePulsesLeft =  g_strctParadigm.m_iJuicePulsesLeft - 1;
            g_strctParadigm.m_iMachineState = 11;
        end
        
        
    case 13
        % Monkey saccaded outside his decision object before the desired
        % time. However, we still show the images for X MS before starting
        % a new trial
        if fCurrTime-g_strctParadigm.m_fTimer5 > g_strctParadigm.m_fShowObjectsAfterSaccadeSec
            if strcmp(g_strctParadigm.m_strctCurrentTrial.m_strResult,'Incorrect');
               fnParadigmToStimulusServer('ClearScreen');
               g_strctParadigm.m_fTimer6 = fCurrTime;
               g_strctParadigm.m_fIncorrectTrialDelaySec = fnTsGetVar(g_strctParadigm,'IncorrectTrialDelayMS')/1e3;
                g_strctParadigm.m_iMachineState = 14;
            else
                g_strctParadigm.m_iMachineState = 15;
            end
        else
            fnParadigmToKofikoComm('SetParadigmState',sprintf('Showing Images for %.2f sec',g_strctParadigm.m_fShowObjectsAfterSaccadeSec - (fCurrTime-g_strctParadigm.m_fTimer5) ));
        end
    case 14
        if fCurrTime-g_strctParadigm.m_fTimer6 > g_strctParadigm.m_fIncorrectTrialDelaySec
              g_strctParadigm.m_iMachineState = 15;
        else
       fnParadigmToKofikoComm('SetParadigmState',sprintf('Incorrect Delay for %.2f sec',g_strctParadigm.m_fIncorrectTrialDelaySec - (fCurrTime-g_strctParadigm.m_fTimer6) ));
              
        end
    case 15
        % make sure we got the  m_fFlipExtinguish_TS_StimulusServer value
        if ~g_strctParadigm.m_bExtinguishObjectsAfterSaccade
            g_strctParadigm.m_iMachineState = 1; 
        end
        
        if g_strctParadigm.m_bExtinguishObjectsAfterSaccade && ~isempty(g_strctParadigm.m_strctCurrentTrial.m_fFlipExtinguish_TS_StimulusServer)
           g_strctParadigm.m_iMachineState = 1; 
        end

end

% Stimulation related
if g_strctParadigm.m_iMachineState >= 8 && g_strctParadigm.m_strctCurrentTrial.m_bMicroStimulation && g_strctParadigm.m_strctCurrentTrial.m_fMicroStimulationOffsetMS > 0 && ...
        ~g_strctParadigm.m_bMicroStimInitiated && isfield(g_strctParadigm.m_strctCurrentTrial,'m_fFlipStimulusON_TS_Local') && ...
        fCurrTime-g_strctParadigm.m_strctCurrentTrial.m_fFlipStimulusON_TS_Local > g_strctParadigm.m_strctCurrentTrial.m_fMicroStimulationOffsetMS/1e3
    fnParadigmToKofikoComm('StimulationTTL');
    g_strctParadigm.m_bMicroStimInitiated = true;
end

strctOutput = strctInputs;
return;



function [aiResponsesOcc,afImmediateHistory] = fnComputeResponseOccurences()
global g_strctParadigm
iNumTrials = g_strctParadigm.acTrials.BufferIdx ;
iHistory = 2; % Use previous two trials
% Extract responses from all available trials
afResponses = NaN*ones(1,iNumTrials);
afImmediateHistory = [];
for iTrialIter=1:iNumTrials
    if ~isempty(g_strctParadigm.acTrials.Buffer{iTrialIter}) && ...
            (strcmpi(g_strctParadigm.acTrials.Buffer{iTrialIter}.m_strResult,'Correct') || strcmpi(g_strctParadigm.acTrials.Buffer{iTrialIter}.m_strResult,'Incorrect'))
        afResponses(iTrialIter) = g_strctParadigm.acTrials.Buffer{iTrialIter}.m_iPositionIndex;
    end
end
afResponses = afResponses(~isnan(afResponses));
if length(afResponses) <= iHistory+1
    aiResponsesOcc = [];
else
    % compute probabilities using some history
    iMaxRes = max(afResponses);
    acArray = cell(1,iHistory);
    for k=1:iHistory
        acArray{k} = 1:iMaxRes;
    end
    a2iAllResComb = fnGenComb(acArray);
    iNumCombinations = size(a2iAllResComb,1);
    a2iOcc = zeros(iNumCombinations, iMaxRes);
    iNumRes = length(afResponses);
    for iResIter=1:iNumRes-iHistory
        afHistory = afResponses(iResIter:iResIter+iHistory-1);
        [fDummy,iCombinationIndex]=  min(sum((repmat(afHistory,iNumCombinations,1) - a2iAllResComb).^2,2));
        
        iResponse = afResponses(iResIter+iHistory);
        a2iOcc(iCombinationIndex,iResponse) = a2iOcc(iCombinationIndex,iResponse) + 1;
    end
    
    afImmediateHistory = afResponses(end-iHistory+1:end);
    [fDummy,iCombinationIndex]=  min(sum((repmat(afImmediateHistory,iNumCombinations,1) - a2iAllResComb).^2,2));
    aiResponsesOcc = a2iOcc(iCombinationIndex,:);
    
end