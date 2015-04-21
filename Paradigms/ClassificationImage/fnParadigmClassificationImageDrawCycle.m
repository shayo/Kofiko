function fnParadigmClassificationImageDrawCycle(acInputFromKofiko)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)


global g_strctPTB g_strctDraw g_strctNet g_strctServerCycle

fCurrTime = GetSecs();

if ~isempty(acInputFromKofiko)
    strCommand = acInputFromKofiko{1};
    switch strCommand
        case 'UpdateDrawParams'
            g_strctServerCycle.m_strctDrawParams = acInputFromKofiko{2};

        case 'PauseButRecvCommands'
            Screen(g_strctPTB.m_hWindow,'FillRect',0);
            fnFlipWrapper(g_strctPTB.m_hWindow);

            g_strctServerCycle.m_iMachineState = 0;
        case 'Display'
            g_strctDraw.m_a2iImage = uint8(acInputFromKofiko{2});
            g_strctDraw.m_a2iNoise = acInputFromKofiko{3};
            g_strctDraw.m_fAlpha = acInputFromKofiko{4};
            g_strctServerCycle.m_iMachineState = 1;
    end
end;



switch g_strctServerCycle.m_iMachineState
    case 0
        % Do nothing
    case 1
        fnStimulusServerToKofikoParadigm('DisplayStarted');
        Screen('FillRect',g_strctPTB.m_hWindow, g_strctServerCycle.m_strctDrawParams.m_afBackgroundColor);
        aiFixationRect = [g_strctServerCycle.m_strctDrawParams.m_pt2fFixationSpotPix-g_strctServerCycle.m_strctDrawParams.m_fFixationSizePix,...
            g_strctServerCycle.m_strctDrawParams.m_pt2fFixationSpotPix+g_strctServerCycle.m_strctDrawParams.m_fFixationSizePix];

        iSizeOnScreen = 2*g_strctServerCycle.m_strctDrawParams.m_fStimulusSizePix+1;
        %aiTextureSize = size(g_strctPTB.m_acImages{g_strctDraw.m_iNextImageToShow});
        aiTextureSize = size(g_strctDraw.m_a2iImage);

        fScaleX = iSizeOnScreen / aiTextureSize(1);
        fScaleY = iSizeOnScreen / aiTextureSize(2);

        if fScaleX < fScaleY
            iStartX = g_strctServerCycle.m_strctDrawParams.m_pt2fStimulusPos(1) - round(aiTextureSize(1) * fScaleX / 2);
            iEndX = g_strctServerCycle.m_strctDrawParams.m_pt2fStimulusPos(1) + round(aiTextureSize(1) * fScaleX / 2);
            iStartY = g_strctServerCycle.m_strctDrawParams.m_pt2fStimulusPos(2) - round(aiTextureSize(2) * fScaleX / 2);
            iEndY = g_strctServerCycle.m_strctDrawParams.m_pt2fStimulusPos(2) + round(aiTextureSize(2) * fScaleX / 2);
        else
            iStartX = g_strctServerCycle.m_strctDrawParams.m_pt2fStimulusPos(1) - round(aiTextureSize(1) * fScaleY / 2);
            iEndX = g_strctServerCycle.m_strctDrawParams.m_pt2fStimulusPos(1) + round(aiTextureSize(1) * fScaleY / 2);
            iStartY = g_strctServerCycle.m_strctDrawParams.m_pt2fStimulusPos(2) - round(aiTextureSize(2) * fScaleY / 2);
            iEndY = g_strctServerCycle.m_strctDrawParams.m_pt2fStimulusPos(2) + round(aiTextureSize(2) * fScaleY / 2);
        end


        aiStimulusRect = [iStartX, iStartY, iEndX, iEndY];
        
        
        

        iSizeOnScreen = 2*g_strctServerCycle.m_strctDrawParams.m_iImageSizePix+1;
        fScaleX = iSizeOnScreen / aiTextureSize(1);
        fScaleY = iSizeOnScreen / aiTextureSize(2);
        if fScaleX < fScaleY
            iStartX = g_strctServerCycle.m_strctDrawParams.m_pt2fStimulusPos(1) - round(aiTextureSize(1) * fScaleX / 2);
            iEndX = g_strctServerCycle.m_strctDrawParams.m_pt2fStimulusPos(1) + round(aiTextureSize(1) * fScaleX / 2);
            iStartY = g_strctServerCycle.m_strctDrawParams.m_pt2fStimulusPos(2) - round(aiTextureSize(2) * fScaleX / 2);
            iEndY = g_strctServerCycle.m_strctDrawParams.m_pt2fStimulusPos(2) + round(aiTextureSize(2) * fScaleX / 2);
        else
            iStartX = g_strctServerCycle.m_strctDrawParams.m_pt2fStimulusPos(1) - round(aiTextureSize(1) * fScaleY / 2);
            iEndX = g_strctServerCycle.m_strctDrawParams.m_pt2fStimulusPos(1) + round(aiTextureSize(1) * fScaleY / 2);
            iStartY = g_strctServerCycle.m_strctDrawParams.m_pt2fStimulusPos(2) - round(aiTextureSize(2) * fScaleY / 2);
            iEndY = g_strctServerCycle.m_strctDrawParams.m_pt2fStimulusPos(2) + round(aiTextureSize(2) * fScaleY / 2);
        end        
        aiImageRect = [iStartX+g_strctServerCycle.m_strctDrawParams.m_iImageOffsetX, ...
                        iStartY+g_strctServerCycle.m_strctDrawParams.m_iImageOffsetY, ...
                        iEndX+g_strctServerCycle.m_strctDrawParams.m_iImageOffsetX, ...
                        iEndY+g_strctServerCycle.m_strctDrawParams.m_iImageOffsetY];
       
        
        %I = g_strctPTB.m_acImages{g_strctDraw.m_iNextImageToShow};
        %I = uint8(min(255,max(0,double(I) + randn(size(I)) * g_strctServerCycle.m_strctDrawParams.m_fNoiseLevel)));
        

        a3iNoiseMask = uint8(g_strctDraw.m_a2iNoise);
        a3iNoiseMask(:,:,2) = round(g_strctDraw.m_fAlpha * 255);

        hImageID = Screen('MakeTexture', g_strctPTB.m_hWindow,  g_strctDraw.m_a2iImage);
        hNoiseID = Screen('MakeTexture', g_strctPTB.m_hWindow,  a3iNoiseMask);
        Screen('DrawTexture', g_strctPTB.m_hWindow, hImageID,[],aiImageRect, g_strctServerCycle.m_strctDrawParams.m_fRotationAngle);
        Screen('DrawTexture', g_strctPTB.m_hWindow, hNoiseID,[],aiStimulusRect, g_strctServerCycle.m_strctDrawParams.m_fRotationAngle);
        Screen('Close',hImageID);
        Screen('Close',hNoiseID);
     
        
%        hTextureID = Screen('MakeTexture', g_strctPTB.m_hWindow,  g_strctDraw.m_a2iImage); % I
%        Screen('DrawTexture', g_strctPTB.m_hWindow, hTextureID,[],aiStimulusRect, g_strctServerCycle.m_strctDrawParams.m_fRotationAngle);
%        Screen('Close',hTextureID);

        Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], ...
            [g_strctPTB.m_aiRect(3)-g_strctServerCycle.m_strctDrawParams.m_iPhotoDiodeWindowPix ...
            g_strctPTB.m_aiRect(4)-g_strctServerCycle.m_strctDrawParams.m_iPhotoDiodeWindowPix ...
            g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);

        % Draw Fixation spot
        Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);

        

        g_strctServerCycle.m_fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow); % This would block the server until the next flip.
        fnStimulusServerToKofikoParadigm('FlipON',g_strctServerCycle.m_fLastFlipTime);
        g_strctServerCycle.m_iMachineState = 2;
    case 2
        if (fCurrTime - g_strctServerCycle.m_fLastFlipTime) > g_strctServerCycle.m_strctDrawParams.m_fStimulusON_MS/1e3 - (0.2 * (1/g_strctPTB.m_iRefreshRate) )
            % Turn stimulus off
            if g_strctServerCycle.m_strctDrawParams.m_fStimulusOFF_MS > 0
                Screen('FillRect',g_strctPTB.m_hWindow, g_strctServerCycle.m_strctDrawParams.m_afBackgroundColor);

                aiFixationRect = [g_strctServerCycle.m_strctDrawParams.m_pt2fFixationSpotPix-g_strctServerCycle.m_strctDrawParams.m_fFixationSizePix,...
                    g_strctServerCycle.m_strctDrawParams.m_pt2fFixationSpotPix+g_strctServerCycle.m_strctDrawParams.m_fFixationSizePix];

                Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);

                Screen('FillRect',g_strctPTB.m_hWindow,[0 0 0], ...
                    [g_strctPTB.m_aiRect(3)-g_strctServerCycle.m_strctDrawParams.m_iPhotoDiodeWindowPix ...
                    g_strctPTB.m_aiRect(4)-g_strctServerCycle.m_strctDrawParams.m_iPhotoDiodeWindowPix ...
                    g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
                g_strctServerCycle.m_fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow); % This would block the server until the next flip.
                fnStimulusServerToKofikoParadigm('FlipOFF',g_strctServerCycle.m_fLastFlipTime);
                
                g_strctServerCycle.m_iMachineState = 3;
            else
                fnStimulusServerToKofikoParadigm('DisplayFinished',GetSecs());
                g_strctServerCycle.m_iMachineState = 0;
                
            end
        end
    case 3
        if (fCurrTime - g_strctServerCycle.m_fLastFlipTime) > ...
                (g_strctServerCycle.m_strctDrawParams.m_fStimulusOFF_MS)/1e3 - (0.2 * (1/g_strctPTB.m_iRefreshRate) )
                fnStimulusServerToKofikoParadigm('DisplayFinished',GetSecs());
            
            g_strctServerCycle.m_iMachineState = 0;
        end
end;

return;



