function fnParadigmFiveDotDraw()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
%
global g_strctPTB g_strctParadigm
% Do not call Flip, just draw everything to the screen.


afBackgroundColor = ...
    squeeze(g_strctParadigm.m_strctStimulusParams.BackgroundColor.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.BackgroundColor.BufferIdx));
pt2fFixationSpotPix = ...
    g_strctParadigm.m_strctStimulusParams.FixationSpotPix.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.FixationSpotPix.BufferIdx);

fFixationSizePix = ...
    g_strctParadigm.m_strctStimulusParams.FixationSizePix.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.FixationSizePix.BufferIdx);

Screen('FillRect',g_strctPTB.m_hWindow, afBackgroundColor, g_strctPTB.m_aiRect);
aiFixationSpot =  g_strctPTB.m_fScale*[...
    pt2fFixationSpotPix(1) - fFixationSizePix,...
    pt2fFixationSpotPix(2) - fFixationSizePix,...
    pt2fFixationSpotPix(1) + fFixationSizePix,...
    pt2fFixationSpotPix(2) + fFixationSizePix];

Screen(g_strctPTB.m_hWindow,'FillArc',[255 255 255], aiFixationSpot,0,360);


aiStimulusScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
pt2iCenter = aiStimulusScreenSize(3:4)/2;
 

 fSpreadPix = ...
     g_strctParadigm.m_strctStimulusParams.SpreadPix.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.SpreadPix.BufferIdx);


apt2iFixationSpots =  [pt2iCenter;
    pt2iCenter + [-fSpreadPix,-fSpreadPix];
    pt2iCenter + [fSpreadPix,-fSpreadPix];
    pt2iCenter + [-fSpreadPix,fSpreadPix];
    pt2iCenter + [fSpreadPix,fSpreadPix]; ];

for k=1:5
    pt2iFixationPosTmp = apt2iFixationSpots(k,:);
    % Draw fixation spot
    aiFixationSpot =  g_strctPTB.m_fScale *[...
        pt2iFixationPosTmp(1) - fFixationSizePix,...
        pt2iFixationPosTmp(2) - fFixationSizePix,...
        pt2iFixationPosTmp(1) + fFixationSizePix,...
        pt2iFixationPosTmp(2) + fFixationSizePix];
    Screen(g_strctPTB.m_hWindow,'DrawArc',[0 100 100], aiFixationSpot,0,360);
end


fGazeBoxPix = ...
    g_strctParadigm.m_strctStimulusParams.GazeBoxPix.Buffer(1,:,g_strctParadigm.m_strctStimulusParams.GazeBoxPix.BufferIdx);


aiGazeRect =  g_strctPTB.m_fScale *[pt2fFixationSpotPix(1)-fGazeBoxPix,...
    pt2fFixationSpotPix(2)-fGazeBoxPix,...
    pt2fFixationSpotPix(1)+fGazeBoxPix,...
    pt2fFixationSpotPix(2)+fGazeBoxPix];

Screen(g_strctPTB.m_hWindow,'FrameRect',[255 0 0], aiGazeRect);


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

