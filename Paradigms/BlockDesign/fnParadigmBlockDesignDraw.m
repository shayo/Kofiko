function fnParadigmBlockDesignDraw()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)


global g_strctPTB g_strctParadigm g_strctStimulusServer

pt2iCenter = g_strctStimulusServer.m_aiScreenSize(3:4)/2;

afBackgroundColor = fnTsGetVar(g_strctParadigm, 'BackgroundColor');

Screen('FillRect',g_strctPTB.m_hWindow, afBackgroundColor);
fStimulusSizePix = fnTsGetVar(g_strctParadigm, 'StimulusSizePix');

if ~isempty(g_strctParadigm.m_iLastFlippedImageIndex)
    fRotationAngle = fnTsGetVar(g_strctParadigm, 'RotationAngle');

    iSizeOnScreen = 2*fStimulusSizePix+1;
    aiTextureSize = g_strctParadigm.m_a2iTextureSize(:, g_strctParadigm.m_iLastFlippedImageIndex);

    fScaleX = iSizeOnScreen / aiTextureSize(1);
    fScaleY = iSizeOnScreen / aiTextureSize(2);

    if fScaleX < fScaleY
        iStartX = pt2iCenter(1) - round(aiTextureSize(1) * fScaleX / 2);
        iEndX = pt2iCenter(1) + round(aiTextureSize(1) * fScaleX / 2);
        iStartY = pt2iCenter(2) - round(aiTextureSize(2) * fScaleX / 2);
        iEndY = pt2iCenter(2) + round(aiTextureSize(2) * fScaleX / 2);
    else
        iStartX = pt2iCenter(1) - round(aiTextureSize(1) * fScaleY / 2);
        iEndX = pt2iCenter(1) + round(aiTextureSize(1) * fScaleY / 2);
        iStartY = pt2iCenter(2) - round(aiTextureSize(2) * fScaleY / 2);
        iEndY = pt2iCenter(2) + round(aiTextureSize(2) * fScaleY / 2);
    end

    aiStimulusRect = [iStartX, iStartY, iEndX, iEndY];
    if g_strctParadigm.m_abIsMovie(g_strctParadigm.m_iLastFlippedImageIndex)
        Screen(g_strctPTB.m_hWindow,'DrawText',sprintf('Movie Playing %.1f Sec',GetSecs()-g_strctParadigm.m_fMovieStartedTimer),...
            pt2iCenter(1),pt2iCenter(2),[0 255 0]);
    else
    Screen('DrawTexture', g_strctPTB.m_hWindow, ...
        g_strctParadigm.m_ahHandles(g_strctParadigm.m_iLastFlippedImageIndex),[],...
         g_strctPTB.m_fScale * aiStimulusRect, fRotationAngle);
    end
end


fGazeBoxPix = fnTsGetVar(g_strctParadigm, 'GazeBoxPix');
aiGazeRect = [pt2iCenter-fGazeBoxPix,pt2iCenter+fGazeBoxPix];
Screen('FrameRect',g_strctPTB.m_hWindow,[255 0 0], g_strctPTB.m_fScale * aiGazeRect);

fFixationSizePix = fnTsGetVar(g_strctParadigm, 'FixationSizePix');

aiFixationRect = [pt2iCenter-fFixationSizePix pt2iCenter+fFixationSizePix];
Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], g_strctPTB.m_fScale * aiFixationRect,0,360);

aiStimulusRect = [pt2iCenter-fStimulusSizePix, pt2iCenter+fStimulusSizePix];
Screen('FrameRect',g_strctPTB.m_hWindow,[255 255 0], g_strctPTB.m_fScale * aiStimulusRect);



fGazeTimeHighSec = g_strctParadigm.GazeTimeMS.Buffer(g_strctParadigm.GazeTimeMS.BufferIdx) /1000;
fGazeTimeLowSec = g_strctParadigm.GazeTimeLowMS.Buffer(g_strctParadigm.GazeTimeLowMS.BufferIdx) /1000;
fPositiveIncrement = g_strctParadigm.PositiveIncrement.Buffer(:,:,g_strctParadigm.PositiveIncrement.BufferIdx);
fMaxFixations = 100 / fPositiveIncrement;
fPercCorrect =  min(1,g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter / fMaxFixations);
fGazeTimeSec = fGazeTimeLowSec + (fGazeTimeHighSec-fGazeTimeLowSec) * (1- g_strctParadigm.m_strctDynamicJuice.m_iFixationCounter / fMaxFixations);
fPerc = g_strctParadigm.m_strctDynamicJuice.m_fTotalFixationTime / fGazeTimeSec;

fRadius = 50;
aiJuiceCircle = [10 g_strctPTB.m_aiRect(4)-fRadius-5, 10+fRadius g_strctPTB.m_aiRect(4)-5];
Screen('DrawArc',g_strctPTB.m_hWindow,[255 0 255], aiJuiceCircle,0,360);

aiJuiceCircle2 = [10+1 g_strctPTB.m_aiRect(4)-fRadius-5+1, 10+fRadius-1 g_strctPTB.m_aiRect(4)-5-1];
Screen('FillArc',g_strctPTB.m_hWindow,[128 0 128], aiJuiceCircle2,0,fPerc * 360);

Screen(g_strctPTB.m_hWindow,'DrawText',sprintf('%d%%',round(fPercCorrect*100)),...
    10, g_strctPTB.m_aiRect(4)-fRadius/2-20+1, [0 255 0]);



return;



