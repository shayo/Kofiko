function fnParadigmBlockDesignNewDrawCycle(acInputFromKofiko)
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
        case 'LoadImageList'
            fnStimulusServerClearTextureMemory();
            acFileNames = acInputFromKofiko{2};
            [g_strctDraw.m_ahHandles,g_strctDraw.m_a2iTextureSize,g_strctDraw.m_abIsMovie,...
                g_strctDraw.m_aiApproxNumFrames, g_strctDraw.m_afMovieLengthSec] = ...
                fnInitializeTexturesAux(acFileNames);
            g_strctServerCycle.m_iMachineState = 0;
        case 'ClearMemory'
            fnStimulusServerClearTextureMemory();            
        case 'DisplayList'
            g_strctDraw.m_aiImageList = acInputFromKofiko{2};
            g_strctDraw.m_iNumImages = length(g_strctDraw.m_aiImageList);
            g_strctDraw.m_afImagePresentationTimeMS = acInputFromKofiko{3};
            g_strctDraw.m_afImageTimerSec = ...
                [0,cumsum(g_strctDraw.m_afImagePresentationTimeMS)/1e3];
            g_strctDraw.m_fFixationSizePix = acInputFromKofiko{4};
            g_strctDraw.m_fStimulusSizePix = acInputFromKofiko{5};
            g_strctDraw.m_fRotationAngle = acInputFromKofiko{6};
            g_strctDraw.m_afBackgroundColor = acInputFromKofiko{7};
            g_strctDraw.m_afFixationColor = acInputFromKofiko{8};
            
            g_strctServerCycle.m_iMachineState = 1;
            g_strctDraw.m_iCounter = 1;
        case 'UpdateFixationSize'
            g_strctDraw.m_fFixationSizePix = acInputFromKofiko{2};
        case 'UpdateStimulusSize'
            g_strctDraw.m_fStimulusSizePix = acInputFromKofiko{2};
        case 'UpdateRotationAngle'
            g_strctDraw.m_fRotationAngle = acInputFromKofiko{2};
            
        case 'AbortRun'
            Screen('FillRect',g_strctPTB.m_hWindow, 0);
            fnFlipWrapper(g_strctPTB.m_hWindow);
            g_strctServerCycle.m_iMachineState = 0;
        case 'ShowFixation'
            fFixationSize = acInputFromKofiko{2};
            afBackgroundColor = acInputFromKofiko{3};
            afFixationSpotColor = acInputFromKofiko{4};
            pt2iScreenCenter = g_strctPTB.m_aiScreenRect(3:4) / 2;
            aiFixationRect = [pt2iScreenCenter - fFixationSize,...
                pt2iScreenCenter+fFixationSize];
            Screen('FillRect',g_strctPTB.m_hWindow, afBackgroundColor);
            % Draw Fixation spot
            Screen('FillArc',g_strctPTB.m_hWindow,afFixationSpotColor, aiFixationRect,0,360);
            fnFlipWrapper(g_strctPTB.m_hWindow);
            
        case 'StopDisplay'
            g_strctServerCycle.m_iMachineState = 0;
    end
end;



switch g_strctServerCycle.m_iMachineState
    case 0
        % Do nothing
    case 1
        iIndexToDisplay = g_strctDraw.m_aiImageList(g_strctDraw.m_iCounter);
        g_strctDraw.m_fFirstFlip = fnDrawImageAux(iIndexToDisplay,0,1, g_strctDraw.m_afBackgroundColor);
        fnStimulusServerToKofikoParadigm('Flipped',g_strctDraw.m_fFirstFlip, iIndexToDisplay,g_strctDraw.m_iCounter);
        g_strctServerCycle.m_iMachineState = 2;
    case 2
        if (fCurrTime - g_strctDraw.m_fFirstFlip) > ...
                g_strctDraw.m_afImageTimerSec(g_strctDraw.m_iCounter+1) - (0.3 * (1/g_strctPTB.m_iRefreshRate) )

            g_strctDraw.m_iCounter = g_strctDraw.m_iCounter + 1;
            if g_strctDraw.m_iCounter >  g_strctDraw.m_iNumImages
                % Turn off screen
                 Screen('FillRect',g_strctPTB.m_hWindow, 0);
                 fFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow);
                 g_strctServerCycle.m_iMachineState = 0;
                 fnStimulusServerToKofikoParadigm('FinishedDisplayList',fFlipTime);                
            else
                % Display image "iCounter"
                fFlipTime = fnDrawImageAux(g_strctDraw.m_aiImageList(g_strctDraw.m_iCounter),...
                    g_strctDraw.m_fFirstFlip+g_strctDraw.m_afImageTimerSec(g_strctDraw.m_iCounter),1,g_strctDraw.m_afBackgroundColor);
                fnStimulusServerToKofikoParadigm('Flipped',fFlipTime, g_strctDraw.m_aiImageList(g_strctDraw.m_iCounter),g_strctDraw.m_iCounter,g_strctDraw.m_afBackgroundColor);
            end
        else
            if g_strctDraw.m_abIsMovie(g_strctDraw.m_aiImageList(g_strctDraw.m_iCounter) )
                % Display next frame...
                fnDrawImageAux(g_strctDraw.m_aiImageList(g_strctDraw.m_iCounter),0,0,g_strctDraw.m_afBackgroundColor);
            end
        end
end;

return;


function fFlipTime = fnDrawImageAux(iImageIndex, fFlipTime,bPlayMovie,afBackground)
global g_strctPTB  g_strctDraw
pt2iScreenCenter = g_strctPTB.m_aiScreenRect(3:4) / 2;

Screen('FillRect',g_strctPTB.m_hWindow, afBackground);
aiFixationRect = [pt2iScreenCenter - g_strctDraw.m_fFixationSizePix,...
                  pt2iScreenCenter+g_strctDraw.m_fFixationSizePix];

iSizeOnScreen = 2*g_strctDraw.m_fStimulusSizePix+1;
aiTextureSize = g_strctDraw.m_a2iTextureSize(:,iImageIndex);

fScaleX = iSizeOnScreen / aiTextureSize(1);
fScaleY = iSizeOnScreen / aiTextureSize(2);

if fScaleX < fScaleY
    iStartX = pt2iScreenCenter(1) - round(aiTextureSize(1) * fScaleX / 2);
    iEndX = pt2iScreenCenter(1) + round(aiTextureSize(1) * fScaleX / 2);
    iStartY = pt2iScreenCenter(2) - round(aiTextureSize(2) * fScaleX / 2);
    iEndY = pt2iScreenCenter(2) + round(aiTextureSize(2) * fScaleX / 2);
else
    iStartX = pt2iScreenCenter(1) - round(aiTextureSize(1) * fScaleY / 2);
    iEndX = pt2iScreenCenter(1) + round(aiTextureSize(1) * fScaleY / 2);
    iStartY = pt2iScreenCenter(2) - round(aiTextureSize(2) * fScaleY / 2);
    iEndY = pt2iScreenCenter(2) + round(aiTextureSize(2) * fScaleY / 2);
end


aiStimulusRect = [iStartX, iStartY, iEndX, iEndY];

if g_strctDraw.m_abIsMovie(iImageIndex)
    % Start playing movie...
    if bPlayMovie
        Screen('PlayMovie', g_strctDraw.m_ahHandles(iImageIndex), 1,0,1);
        Screen('SetMovieTimeIndex',g_strctDraw.m_ahHandles(iImageIndex),0);
    end
        hFrameTexture = Screen('GetMovieImage', g_strctPTB.m_hWindow, ...
            g_strctDraw.m_ahHandles(iImageIndex),1);
    Screen('DrawTexture', g_strctPTB.m_hWindow, hFrameTexture,[],aiStimulusRect, g_strctDraw.m_fRotationAngle);
    Screen('Close',hFrameTexture);    
else
    Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctDraw.m_ahHandles(iImageIndex),[],aiStimulusRect, ...
        g_strctDraw.m_fRotationAngle);
end

% Draw Fixation spot
Screen('FillArc',g_strctPTB.m_hWindow,g_strctDraw.m_afFixationColor, aiFixationRect,0,360);

fFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow,fFlipTime);

return;


