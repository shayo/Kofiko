function [strctOutput] = fnParadigmFiveDotCycle(strctInputs)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm g_strctStimulusServer g_strctPTB

fCurrTime = GetSecs();
switch g_strctParadigm.m_iMachineState
    case 0
        fnParadigmToKofikoComm('SetParadigmState','Waiting for user to press Start');
    
    case 1

        if g_strctParadigm.m_bUpdateFixationSpot
            pt2iNextFixationSpot = g_strctParadigm.m_pt2iUserDefinedSpot;
        else
            iNewStimulusIndex =  round(rand() * 4) + 1;
            iSpreadPix = g_strctParadigm.m_strctStimulusParams.SpreadPix.Buffer(g_strctParadigm.m_strctStimulusParams.SpreadPix.BufferIdx);
            pt2iCenter = g_strctStimulusServer.m_aiScreenSize(3:4)/2;
            apt2iFixationSpots = [pt2iCenter;
                pt2iCenter + [-iSpreadPix,-iSpreadPix];
                pt2iCenter + [iSpreadPix,-iSpreadPix];
                pt2iCenter + [-iSpreadPix,iSpreadPix];
                pt2iCenter + [iSpreadPix,iSpreadPix]; ];
            pt2iNextFixationSpot = apt2iFixationSpots(iNewStimulusIndex,:);
        end

        fnTsSetVarParadigm('m_strctStimulusParams.FixationSpotPix',pt2iNextFixationSpot);
        fnParadigmToKofikoComm('SetFixationPosition', pt2iNextFixationSpot);

        afBackgroundColor = ...
            squeeze(g_strctParadigm.m_strctStimulusParams.BackgroundColor.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.BackgroundColor.BufferIdx));
        iFixationSpotRad = g_strctParadigm.m_strctStimulusParams.FixationSizePix.Buffer(g_strctParadigm.m_strctStimulusParams.FixationSizePix.BufferIdx);
        
        fnParadigmToStimulusServer('Display',pt2iNextFixationSpot, iFixationSpotRad,afBackgroundColor);
        
        fnDAQWrapper('StrobeWord', 1);
        fnParadigmToKofikoComm('SetParadigmState','Running...');

        g_strctParadigm.m_iMachineState = 2;
        g_strctParadigm.m_fStimulusOnTimer = fCurrTime;
    case 2
        m_iStimulusON_MS = g_strctParadigm.m_strctStimulusParams.StimulusON_MS.Buffer(g_strctParadigm.m_strctStimulusParams.StimulusON_MS.BufferIdx);
        if fCurrTime-g_strctParadigm.m_fStimulusOnTimer > (m_iStimulusON_MS / 1000)
                g_strctParadigm.m_iMachineState = 1;
        end;
          
end;


%% Mouse related activity 
% These events cannot be handled by the callback function since the mouse
% events are not registered as matlab events.
if g_strctParadigm.m_bUpdateFixationSpot && strctInputs.m_abMouseButtons(1) && strctInputs.m_bMouseInPTB
    g_strctParadigm.m_pt2iUserDefinedSpot = 1/g_strctPTB.m_fScale * strctInputs.m_pt2iMouse;
    if fCurrTime - g_strctParadigm.m_fMouseTimer > 100/1000
          g_strctParadigm.m_iMachineState = 1;
          g_strctParadigm.m_fMouseTimer  = fCurrTime;
    end;
end;


fnHandleDynamicJuice(strctInputs)
strctOutput = strctInputs;
return;



function fnHandleDynamicJuice(strctInputs)
%% Reward related stuff
global g_strctParadigm
fCurrTime = GetSecs;

if g_strctParadigm.m_iMachineState == 0
    return;
end

pt2iFixationSpotPix = g_strctParadigm.m_strctStimulusParams.FixationSpotPix.Buffer(:,:,g_strctParadigm.m_strctStimulusParams.FixationSpotPix.BufferIdx);
iGazeBoxPix = g_strctParadigm.m_strctStimulusParams.GazeBoxPix.Buffer(:,:,g_strctParadigm.m_strctStimulusParams.GazeBoxPix.BufferIdx);

aiGazeRect = [pt2iFixationSpotPix-iGazeBoxPix,pt2iFixationSpotPix+iGazeBoxPix];

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