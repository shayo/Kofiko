function [strctOutput] = fnParadigmTouchScreenCycle(strctInputs)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm  g_strctStimulusServer



% 0: wait until user click start
% 1: decide trial parameters (where next point is going to appear, etc)
% 2: monkey initiates trials version: wait until monkey touch the screen
% 3: monkey initiates trials version: wait until monkey releases touch
% 4: Display dot on screen
% 5: wait until timeout or monkey touches the screen, give juice if correct
% 7: wait until monkey releases touch



fCurrTime = GetSecs();
switch g_strctParadigm.m_iMachineState
    case 0
        if ~isfield(g_strctStimulusServer,'m_hWindow')
            fnParadigmToKofikoComm('SetParadigmState','This paradigm is coded for a single computer setup');
        else
            fnParadigmToKofikoComm('SetParadigmState','Waiting for user to press Start');
        end
        
    case 1
        % Clear Stimulus Screen
       fnFlipWrapper(g_strctStimulusServer.m_hWindow, 0, 0, 2); % Non blocking flip

        
        % Set ITI value
        fMin = fnTsGetVar(g_strctParadigm,'InterTrialIntervalMinSec');
        fMax = fnTsGetVar(g_strctParadigm,'InterTrialIntervalMaxSec');
        g_strctParadigm.m_fWaitInterval = rand() * (fMax-fMin) + fMin;
        g_strctParadigm.m_fTimer1 = fCurrTime;
        % Set Next Touch Position
        aiStimulusScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
        fSpotSizePix = fnTsGetVar(g_strctParadigm,'SpotRadius');
        fSpotX = fSpotSizePix + rand()*(aiStimulusScreenSize(3)-2*fSpotSizePix);
        fSpotY = fSpotSizePix + rand()*(aiStimulusScreenSize(4)-2*fSpotSizePix);
         
        g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos = [fSpotX,fSpotY];
        g_strctParadigm.m_strctCurrentTrial.m_fSpotRad = fSpotSizePix;
       

        if ~g_strctParadigm.m_bMonkeyInitiatesTrials
             g_strctParadigm.m_iMachineState = 4;
        else
             g_strctParadigm.m_iMachineState = 2;
             g_strctParadigm.m_fWaitInterval = 0;
             g_strctParadigm.m_fMin = fnTsGetVar(g_strctParadigm,'InterTrialIntervalMinSec');
        end
    case 2
        
        % Monkey initiates trials. Wait until he presses a key.
        if fCurrTime - g_strctParadigm.m_fTimer1 < g_strctParadigm.m_fMin
            fnParadigmToKofikoComm('SetParadigmState', sprintf('Intertrial wait (%d) sec',round(g_strctParadigm.m_fMin- (fCurrTime - g_strctParadigm.m_fTimer1))));
        else
            fnParadigmToKofikoComm('SetParadigmState', 'Waiting for monkey to initiate trial');
        end
       
        if strctInputs.m_abMouseButtons(1)
             g_strctParadigm.m_iMachineState = 3;
             fnParadigmToKofikoComm('SetParadigmState', 'Waiting for monkey release');
               
        end
        
    case 3
        if ~strctInputs.m_abMouseButtons(1)
            g_strctParadigm.m_iMachineState = 4;
        end
    case 4
        if fCurrTime - g_strctParadigm.m_fTimer1 > g_strctParadigm.m_fWaitInterval
        % Trial Started
          g_strctParadigm.m_strctStatistics.m_iNumTrials = g_strctParadigm.m_strctStatistics.m_iNumTrials + 1;
          
          % Send a command to display the spot on the stimulus server
          fFlipTime = fnDrawSpotOnStimulusScreen(g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos, ...
                                     g_strctParadigm.m_strctCurrentTrial.m_fSpotRad,[255 255 255]);
                                 
           g_strctParadigm.m_strctCurrentTrial.m_fSpotOnset_TS = fFlipTime;
           fnParadigmToKofikoComm('CriticalSectionOn');
          % Play trial onset
           if g_strctParadigm.m_bPlayTrialOnset
              wavplay(g_strctParadigm.m_afTrialOnsetSound, g_strctParadigm.m_fAudioSamplingRate,'async');
          end
          
          g_strctParadigm.m_fTimer2 = fCurrTime;
          g_strctParadigm.m_iMachineState = 5;  
        else
            % Still in Inter Trial Interval. If monkey press the screen,
            % reset the ITI timer.
            if strctInputs.m_abMouseButtons(1)
                g_strctParadigm.m_fTimer1 = fCurrTime;
            else
                fnParadigmToKofikoComm('SetParadigmState',...
                    sprintf('Next trial starts in %d sec',round(g_strctParadigm.m_fWaitInterval - (fCurrTime - g_strctParadigm.m_fTimer1) )));
            end
        end
    case 5
        fTimeout = fnTsGetVar(g_strctParadigm,'TrialTimeOutSec');
        if fCurrTime - g_strctParadigm.m_fTimer2 > fTimeout
            % Timeout!
            g_strctParadigm.m_strctCurrentTrial.m_strResult = 'TimeOut';
            g_strctParadigm.m_strctStatistics.m_iNumTimeout = g_strctParadigm.m_strctStatistics.m_iNumTimeout +1;
            g_strctParadigm.m_strctCurrentTrial.m_fTrialEnd_TS = fCurrTime;
            fnTsSetVarParadigm('acTrials', g_strctParadigm.m_strctCurrentTrial);
            
            % Play trial timeout
            if g_strctParadigm.m_bPlayTrialOnset
                wavplay(g_strctParadigm.m_afTrialOnsetSound, g_strctParadigm.m_fAudioSamplingRate,'async');
            end
            % Goto 1
            fnParadigmToKofikoComm('CriticalSectionOff');
            g_strctParadigm.m_iMachineState = 1;
        else
            fnParadigmToKofikoComm('SetParadigmState',...
            sprintf('Waiting for response. Timeout in %d sec',round(fTimeout - (fCurrTime - g_strctParadigm.m_fTimer2))));
            if strctInputs.m_abMouseButtons(1) 
                
                % Monkey touched the screen
                fDistTouchToSpot = sqrt(sum((strctInputs.m_pt2iEyePosScreen - g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos).^2));
                fCorrectDist = fnTsGetVar(g_strctParadigm, 'CorrectDistancePix');
                
                g_strctParadigm.m_strctCurrentTrial.m_fMonkeyTouch_TS = fCurrTime;
                g_strctParadigm.m_strctCurrentTrial.m_pt2fMonkeyTouchPos = strctInputs.m_pt2iEyePosScreen;
                 
                if fDistTouchToSpot < fCorrectDist
                    g_strctParadigm.m_strctCurrentTrial.m_strResult = 'Correct';
                    g_strctParadigm.m_strctCurrentTrial.m_fTrialEnd_TS = fCurrTime;
                    fnTsSetVarParadigm('acTrials', g_strctParadigm.m_strctCurrentTrial);
                    % Correct trial
                    if g_strctParadigm.m_bPlayCorrect
                        wavplay(g_strctParadigm.m_afCorrectSound, g_strctParadigm.m_fAudioSamplingRate,'async');
                    end
                    g_strctParadigm.m_strctStatistics.m_iNumCorrect  = g_strctParadigm.m_strctStatistics.m_iNumCorrect  + 1;
                    fnParadigmToKofikoComm('SetParadigmState', 'Correct Trial. Waiting for release');
                    % Show OK to release stimulus
                    fnDrawSpotOnStimulusScreen(g_strctParadigm.m_strctCurrentTrial.m_pt2fSpotPos, ...
                                     g_strctParadigm.m_strctCurrentTrial.m_fSpotRad,[0 255 0]);
                      
                    fJuiceTimeMS = fnTsGetVar(g_strctParadigm, 'JuiceTimeMS');
                    fnParadigmToKofikoComm('Juice',  fJuiceTimeMS);
                    g_strctParadigm.m_iMachineState = 7; % Wait for monkey release                    
                else
                    
                    if ~g_strctParadigm.m_bMultipleAttempts
              
                        % inCorrect trial
                        if g_strctParadigm.m_bPlayIncorrect
                            wavplay(g_strctParadigm.m_afIncorrectTrialSound, g_strctParadigm.m_fAudioSamplingRate,'async');
                        end
                        g_strctParadigm.m_strctStatistics.m_iNumIncorrect=g_strctParadigm.m_strctStatistics.m_iNumIncorrect+1;      
                        
                        g_strctParadigm.m_strctCurrentTrial.m_strResult = 'Incorrect';
                        fnTsSetVarParadigm('acTrials', g_strctParadigm.m_strctCurrentTrial);
                        g_strctParadigm.m_iMachineState = 1;
                        fnParadigmToKofikoComm('CriticalSectionOff');
                    end
                    
                end
            end
        end
                    
    case 7
         if ~strctInputs.m_abMouseButtons(1)
             g_strctParadigm.m_iMachineState = 1; % Start a new trial
             fnParadigmToKofikoComm('CriticalSectionOff');
         end
        
end;


strctOutput = strctInputs;
return;

function fFlipTime = fnDrawSpotOnStimulusScreen(pt2iSpot,fSpotSizePix,aiColor)
global g_strctStimulusServer
aiTouchSpotRect = [pt2iSpot(:)-fSpotSizePix;pt2iSpot(:)+fSpotSizePix];
Screen(g_strctStimulusServer.m_hWindow,'FillArc',aiColor, aiTouchSpotRect,0,360);
fFlipTime = fnFlipWrapper( g_strctStimulusServer.m_hWindow);%, 0, 0, 1); % Non blocking flip
return;


