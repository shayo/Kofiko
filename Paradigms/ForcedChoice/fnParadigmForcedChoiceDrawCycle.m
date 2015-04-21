function fnParadigmForcedChoiceDrawCycle(acInputFromKofiko)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)



global g_strctPTB g_strctDraw g_strctNet g_strctServerCycle

if ~isempty(acInputFromKofiko)
    strCommand = acInputFromKofiko{1};
    switch strCommand

        case 'ShowFixationSpot'
            strctFixationSpot = acInputFromKofiko{2};
            fnDrawFixationSpot(strctFixationSpot,true);
 
            fFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow); % Blocking !
            fnStimulusServerToKofikoParadigm('FixationAppear',fFlipTime);
            
        case 'ClearMemory'
        case 'AbortTrial'
            g_strctServerCycle.m_iMachineState = 0;
            Screen('FillRect',g_strctPTB.m_hWindow, [0 0 0]);
            fnFlipWrapper(g_strctPTB.m_hWindow);
            
            if isfield(g_strctDraw,'m_hStimulusHandle') && ~isempty(g_strctDraw.m_hStimulusHandle)
                Screen('Close',g_strctDraw.m_hStimulusHandle);
                g_strctDraw.m_hStimulusHandle = [];
            end
            
            if isfield(g_strctDraw,'m_ahChoicesHandles') && ~isempty(g_strctDraw.m_ahChoicesHandles)
                for k=1:length(g_strctDraw.m_ahChoicesHandles)
                    Screen('Close',g_strctDraw.m_ahChoicesHandles(k));
                end;
                g_strctDraw.m_ahChoicesHandles = [];
            end;
            
        case 'ShowChoice'
            strctChoice = acInputFromKofiko{2};
            strctFixation = acInputFromKofiko{3};
            fChoicesHalfSizePix = acInputFromKofiko{4};
            
            aiChoicesRect = fnComputeStimulusRect(fChoicesHalfSizePix, ...
                [size(strctChoice.m_Image,2), size(strctChoice.m_Image,1)], ...
                strctFixation.m_pt2fPosition + strctChoice.m_pt2fRelativePos);

            if strcmp(class(strctChoice.m_Image),'uint8')
                hChoicesHandle = Screen('MakeTexture', g_strctPTB.m_hWindow,  strctChoice.m_Image);
            else
                hChoicesHandle = Screen('MakeTexture', g_strctPTB.m_hWindow,  strctChoice.m_Image*255);
            end

            
            Screen('DrawTexture', g_strctPTB.m_hWindow, hChoicesHandle,[], aiChoicesRect); % Choices
            fnFlipWrapper(g_strctPTB.m_hWindow); % Blocking !
            Screen('Close', hChoicesHandle);
        case 'ShowTrial'
            strctCurrentTrial = acInputFromKofiko{2};
            g_strctDraw.m_strctFixation = strctCurrentTrial.m_strctFixation;
            % Generate Textures
            g_strctDraw.m_aiStimulusRect = fnComputeStimulusRect(strctCurrentTrial.m_fImageHalfSizePix, ...
                [size(strctCurrentTrial.m_Image,2), size(strctCurrentTrial.m_Image,1)], strctCurrentTrial.m_strctFixation.m_pt2fPosition);
            
            if strcmp(class(strctCurrentTrial.m_Image),'uint8')
                g_strctDraw.m_hStimulusHandle = Screen('MakeTexture', g_strctPTB.m_hWindow,  strctCurrentTrial.m_Image);
            else
                g_strctDraw.m_hStimulusHandle = Screen('MakeTexture', g_strctPTB.m_hWindow,  strctCurrentTrial.m_Image*255);
            end

            
            fAlpha = strctCurrentTrial.m_fNoiseLevel/100;
            a3iNoiseMask = uint8(strctCurrentTrial.m_a2fNoise * 128/3.9 + 128);
            a3iNoiseMask(:,:,2) = round(fAlpha * 255);
            g_strctDraw.m_hNoiseHandle = Screen('MakeTexture', g_strctPTB.m_hWindow,  a3iNoiseMask);
            
            iNumChoices = length(strctCurrentTrial.m_astrctRelevantChoices);
            
            g_strctDraw.m_a2iChoicesRect = zeros(iNumChoices,4);
            g_strctDraw.m_ahChoicesHandles = zeros(1,iNumChoices);
            for k=1:iNumChoices
                strctChoice = strctCurrentTrial.m_astrctRelevantChoices(k);
                g_strctDraw.m_a2iChoicesRect(k,:) = fnComputeStimulusRect(strctCurrentTrial.m_fChoicesHalfSizePix, ...
                    [size(strctChoice.m_Image,2), size(strctChoice.m_Image,1)], strctCurrentTrial.m_strctFixation.m_pt2fPosition + strctChoice.m_pt2fRelativePos);

                if strcmp(class(strctChoice.m_Image),'uint8')
                    g_strctDraw.m_ahChoicesHandles(k) = Screen('MakeTexture', g_strctPTB.m_hWindow,  strctChoice.m_Image);
                else
                    g_strctDraw.m_ahChoicesHandles(k) = Screen('MakeTexture', g_strctPTB.m_hWindow,  strctChoice.m_Image*255);
                end
            end

            
            if strctCurrentTrial.m_fDelayBeforeChoicesMS > 0
                % Trial Type I (delay before choices)
                Screen('FillRect', g_strctPTB.m_hWindow, strctCurrentTrial.m_strctFixation.m_afBackgroundColor);
                Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctDraw.m_hStimulusHandle,[], g_strctDraw.m_aiStimulusRect); % Image
                Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctDraw.m_hNoiseHandle,[], g_strctDraw.m_aiStimulusRect); % Noise
                fnDrawFixationSpot(strctCurrentTrial.m_strctFixation, false);
                g_strctDraw.m_fFlipTime1 = fnFlipWrapper(g_strctPTB.m_hWindow); % Blocking !
                g_strctServerCycle.m_iMachineState = 1;
                g_strctDraw.m_fDelayBeforeChoicesSec =  strctCurrentTrial.m_fDelayBeforeChoicesMS/1e3;
                g_strctDraw.m_fMemoryIntervalSec =strctCurrentTrial.m_fMemoryIntervalMS / 1e3;
            else
                % Trial Type II (choices appear with center image)
                % Draw and release.
            
                Screen('FillRect', g_strctPTB.m_hWindow, strctCurrentTrial.m_strctFixation.m_afBackgroundColor);
                Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctDraw.m_hStimulusHandle,[], g_strctDraw.m_aiStimulusRect); % Image
                Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctDraw.m_hNoiseHandle,[], g_strctDraw.m_aiStimulusRect); % Noise
                for k=1:iNumChoices
                    Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctDraw.m_ahChoicesHandles(k),[], g_strctDraw.m_a2iChoicesRect(k,:)); % Choices
                end
                fnDrawFixationSpot(strctCurrentTrial.m_strctFixation, false);
                fFlipTime1 = fnFlipWrapper(g_strctPTB.m_hWindow); % Blocking !
                fnStimulusServerToKofikoParadigm('StimulusTS', [fFlipTime1,fFlipTime1]);   
                % Release Textures
                Screen('Close', g_strctDraw.m_hStimulusHandle);
                Screen('Close',g_strctDraw.m_hNoiseHandle);
                for k=1:iNumChoices
                    Screen('Close', g_strctDraw.m_ahChoicesHandles(k));
                end
                g_strctDraw.m_hStimulusHandle = [];
                g_strctDraw.m_ahChoicesHandles = [];
                g_strctDraw.m_hNoiseHandle = [];
            end
            
           
    end
end;

switch g_strctServerCycle.m_iMachineState
    case 0
        % Do nothing
    case 1
        if g_strctDraw.m_fMemoryIntervalSec > 0
            % wait, while showing center image, then show only fixation
            % spot, then show choices
            if GetSecs() - g_strctDraw.m_fFlipTime1 > g_strctDraw.m_fDelayBeforeChoicesSec - (0.3 * (1/g_strctPTB.m_iRefreshRate) )
                fnDrawFixationSpot(g_strctDraw.m_strctFixation, true);
                g_strctDraw.m_fFlipTime2 = fnFlipWrapper( g_strctPTB.m_hWindow, g_strctDraw.m_fFlipTime1 + g_strctDraw.m_fDelayBeforeChoicesSec); % Blocking !
                g_strctServerCycle.m_iMachineState = 2;
            end
            
        else
            % Wait, while showing center image, then flip choices
            if GetSecs() - g_strctDraw.m_fFlipTime1 > g_strctDraw.m_fDelayBeforeChoicesSec - (0.3 * (1/g_strctPTB.m_iRefreshRate) )
                Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctDraw.m_hStimulusHandle,[], g_strctDraw.m_aiStimulusRect); % Image
                Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctDraw.m_hNoiseHandle,[], g_strctDraw.m_aiStimulusRect); % Noise
                for k=1:length(g_strctDraw.m_ahChoicesHandles)
                    Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctDraw.m_ahChoicesHandles(k),[], g_strctDraw.m_a2iChoicesRect(k,:)); % Choices
                end
                fnDrawFixationSpot(g_strctDraw.m_strctFixation, false);
                g_strctDraw.m_fFlipTime2 = fnFlipWrapper( g_strctPTB.m_hWindow, g_strctDraw.m_fFlipTime1 + g_strctDraw.m_fDelayBeforeChoicesSec); % Blocking !

                fnStimulusServerToKofikoParadigm('StimulusTS', [g_strctDraw.m_fFlipTime1, g_strctDraw.m_fFlipTime2]);
                g_strctServerCycle.m_iMachineState = 4;
            end
        end
        
    case 2
        if GetSecs() - g_strctDraw.m_fFlipTime2 > g_strctDraw.m_fMemoryIntervalSec - (0.3 * (1/g_strctPTB.m_iRefreshRate) )
                for k=1:length(g_strctDraw.m_ahChoicesHandles)
                    Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctDraw.m_ahChoicesHandles(k),[], g_strctDraw.m_a2iChoicesRect(k,:)); % Choices
                end
             g_strctDraw.m_fFlipTime3 = fnFlipWrapper( g_strctPTB.m_hWindow, g_strctDraw.m_fFlipTime1 +  g_strctDraw.m_fMemoryIntervalSec+g_strctDraw.m_fDelayBeforeChoicesSec); % Blocking !
               fnStimulusServerToKofikoParadigm('StimulusTS', [g_strctDraw.m_fFlipTime1, g_strctDraw.m_fFlipTime2, g_strctDraw.m_fFlipTime3]);
                g_strctServerCycle.m_iMachineState = 4;
                
        end
        
    case 4
        
        % Release Textures
        Screen('Close', g_strctDraw.m_hStimulusHandle);
        Screen('Close',g_strctDraw.m_hNoiseHandle);
        for k=1:length(g_strctDraw.m_ahChoicesHandles)
            Screen('Close', g_strctDraw.m_ahChoicesHandles(k));
        end
        g_strctDraw.m_hStimulusHandle = [];
        g_strctDraw.m_ahChoicesHandles = [];
        g_strctDraw.m_hNoiseHandle = [];
        g_strctServerCycle.m_iMachineState = 0;
end

return;


function fnDrawFixationSpot(strctFixationSpot, bClear)
global g_strctPTB
if bClear
    Screen('FillRect',g_strctPTB.m_hWindow, strctFixationSpot.m_afBackgroundColor);
end
switch strctFixationSpot.m_strShape
    case 'Circle';

        aiFixationSpot = [...
            strctFixationSpot.m_pt2fPosition(1) - strctFixationSpot.m_fFixationRadiusPix,...
            strctFixationSpot.m_pt2fPosition(2) - strctFixationSpot.m_fFixationRadiusPix,...
            strctFixationSpot.m_pt2fPosition(1) + strctFixationSpot.m_fFixationRadiusPix,...
            strctFixationSpot.m_pt2fPosition(2) + strctFixationSpot.m_fFixationRadiusPix];

        Screen(g_strctPTB.m_hWindow,'FrameArc',strctFixationSpot.m_afFixationColor, aiFixationSpot,0,360);
        
end
