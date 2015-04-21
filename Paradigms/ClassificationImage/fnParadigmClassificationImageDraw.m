function fnParadigmClassificationImageDraw()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)


global g_strctPTB g_strctParadigm g_strctNoise g_strctPTB


if g_strctParadigm.m_bDoNotDrawThisCycle 
    g_strctParadigm.m_bDoNotDrawThisCycle = false;
    return;
end

strctStimulusParams = fnParadigmClassificationImageStripBuffer();
   aiStimulusScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');

iImageToDisplay = g_strctParadigm.m_strctStimulusParams.CurrStimulusIndex.Buffer(g_strctParadigm.m_strctStimulusParams.CurrStimulusIndex.BufferIdx);
if iImageToDisplay > 0
        
Screen('FillRect',g_strctPTB.m_hWindow, strctStimulusParams.m_afBackgroundColor);
aiFixationRect = [strctStimulusParams.m_pt2fFixationSpotPix-strctStimulusParams.m_fFixationSizePix,...
                  strctStimulusParams.m_pt2fFixationSpotPix+strctStimulusParams.m_fFixationSizePix];

iSizeOnScreen = 2*strctStimulusParams.m_fStimulusSizePix+1;
aiTextureSize = size(g_strctParadigm.m_acImages{iImageToDisplay});
 
fScaleX = iSizeOnScreen / aiTextureSize(1);
fScaleY = iSizeOnScreen / aiTextureSize(2);
        
if fScaleX < fScaleY
    iStartX = strctStimulusParams.m_pt2fStimulusPos(1) - round(aiTextureSize(1) * fScaleX / 2);
    iEndX = strctStimulusParams.m_pt2fStimulusPos(1) + round(aiTextureSize(1) * fScaleX / 2);
    iStartY = strctStimulusParams.m_pt2fStimulusPos(2) - round(aiTextureSize(2) * fScaleX / 2);
    iEndY = strctStimulusParams.m_pt2fStimulusPos(2) + round(aiTextureSize(2) * fScaleX / 2);
else
    iStartX = strctStimulusParams.m_pt2fStimulusPos(1) - round(aiTextureSize(1) * fScaleY / 2);
    iEndX = strctStimulusParams.m_pt2fStimulusPos(1) + round(aiTextureSize(1) * fScaleY / 2);
    iStartY = strctStimulusParams.m_pt2fStimulusPos(2) - round(aiTextureSize(2) * fScaleY / 2);
    iEndY = strctStimulusParams.m_pt2fStimulusPos(2) + round(aiTextureSize(2) * fScaleY / 2);
end

aiStimulusRect = [iStartX,iStartY,iEndX,iEndY];




iSizeOnScreen = 2*strctStimulusParams.m_iImageSizePix+1;
fScaleX = iSizeOnScreen / aiTextureSize(1);
fScaleY = iSizeOnScreen / aiTextureSize(2);
           
if fScaleX < fScaleY
    iStartX = strctStimulusParams.m_pt2fStimulusPos(1) - round(aiTextureSize(1) * fScaleX / 2);
    iEndX = strctStimulusParams.m_pt2fStimulusPos(1) + round(aiTextureSize(1) * fScaleX / 2);
    iStartY = strctStimulusParams.m_pt2fStimulusPos(2) - round(aiTextureSize(2) * fScaleX / 2);
    iEndY = strctStimulusParams.m_pt2fStimulusPos(2) + round(aiTextureSize(2) * fScaleX / 2);
else
    iStartX = strctStimulusParams.m_pt2fStimulusPos(1) - round(aiTextureSize(1) * fScaleY / 2);
    iEndX = strctStimulusParams.m_pt2fStimulusPos(1) + round(aiTextureSize(1) * fScaleY / 2);
    iStartY = strctStimulusParams.m_pt2fStimulusPos(2) - round(aiTextureSize(2) * fScaleY / 2);
    iEndY = strctStimulusParams.m_pt2fStimulusPos(2) + round(aiTextureSize(2) * fScaleY / 2);
end     
aiImageRect = [iStartX+strctStimulusParams.m_iImageOffsetX, ...
    iStartY+strctStimulusParams.m_iImageOffsetY, ...
    iEndX+strctStimulusParams.m_iImageOffsetX, ...
    iEndY+strctStimulusParams.m_iImageOffsetY];




fAlpha = strctStimulusParams.m_fNoiseLevel/100;
a2fNoise = g_strctNoise.m_a2fRand(:,:,strctStimulusParams.m_iCurrNoiseIndex);
a2fNoise = a2fNoise * 128/3.9 + 128;
a2fImage = double(g_strctParadigm.m_acImages{iImageToDisplay});

%I = uint8(min(255,max(0,(1-fAlpha) * a2fImage + (fAlpha) * a2fNoise)));
%hTextureID = Screen('MakeTexture', g_strctPTB.m_hWindow,  I);
%Screen('DrawTexture', g_strctPTB.m_hWindow, hTextureID,[],aiStimulusRect, strctStimulusParams.m_fRotationAngle);
%Screen('Close',hTextureID);

%hTextureID = Screen('MakeTexture', g_strctPTB.m_hWindow,  I);

a3fNoiseMask = a2fNoise;
a3fNoiseMask(:,:,2) = (fAlpha) * 255;

hImageID = Screen('MakeTexture', g_strctPTB.m_hWindow,  uint8(min(255,max(0,round(a2fImage)))));
hNoiseID = Screen('MakeTexture', g_strctPTB.m_hWindow,  uint8(min(255,max(0,round(a3fNoiseMask)))));
Screen('DrawTexture', g_strctPTB.m_hWindow, hImageID,[],g_strctPTB.m_fScale * aiImageRect, strctStimulusParams.m_fRotationAngle);
Screen('DrawTexture', g_strctPTB.m_hWindow, hNoiseID,[],g_strctPTB.m_fScale * aiStimulusRect, strctStimulusParams.m_fRotationAngle);
Screen('Close',hImageID);
Screen('Close',hNoiseID);


Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], ...
    g_strctPTB.m_fScale * [aiStimulusScreenSize(3)-strctStimulusParams.m_iPhotoDiodeWindowPix ...
    aiStimulusScreenSize(4)-strctStimulusParams.m_iPhotoDiodeWindowPix ...
    aiStimulusScreenSize(3) aiStimulusScreenSize(4)]);


Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], g_strctPTB.m_fScale*aiFixationRect,0,360);
else

            Screen('FillRect',g_strctPTB.m_hWindow, strctStimulusParams.m_afBackgroundColor);

            aiFixationRect = [strctStimulusParams.m_pt2fFixationSpotPix-strctStimulusParams.m_fFixationSizePix,...
                              strctStimulusParams.m_pt2fFixationSpotPix+strctStimulusParams.m_fFixationSizePix];

            Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255],g_strctPTB.m_fScale* aiFixationRect,0,360);
            
            Screen('FillRect',g_strctPTB.m_hWindow,[0 0 0], ...
                g_strctPTB.m_fScale*[aiStimulusScreenSize(3)-strctStimulusParams.m_iPhotoDiodeWindowPix ...
                aiStimulusScreenSize(4)-strctStimulusParams.m_iPhotoDiodeWindowPix ...
                aiStimulusScreenSize(3) aiStimulusScreenSize(4)]);
            
            
            
            
            
end

if isfield(g_strctParadigm,'m_afNeurometricCurve')
    aiRect = [680 450 950 600];
    afAxis = fnPlotPTB(g_strctParadigm.m_afNeurometricCurveSamplePoints, g_strctParadigm.m_afNeurometricCurve, aiRect, [100 0 200]);
    fnPlotPTB([strctStimulusParams.m_fNoiseLevel-1 strctStimulusParams.m_fNoiseLevel],[min(g_strctParadigm.m_afNeurometricCurve) max(g_strctParadigm.m_afNeurometricCurve)], aiRect, [200 0 100],afAxis);    
%    fnPlotPTB([g_strctParadigm.m_fLowNoiseLevel-1 g_strctParadigm.m_fLowNoiseLevel],[min(g_strctParadigm.m_afNeurometricCurve) max(g_strctParadigm.m_afNeurometricCurve)], aiRect, [200 0 100],afAxis);
%    fnPlotPTB([g_strctParadigm.m_fHighNoiseLevel-1 g_strctParadigm.m_fHighNoiseLevel],[min(g_strctParadigm.m_afNeurometricCurve) max(g_strctParadigm.m_afNeurometricCurve) ], aiRect, [200 0 100],afAxis);
end

Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], g_strctPTB.m_fScale * aiFixationRect,0,360);

aiGazeRect = [strctStimulusParams.m_pt2fFixationSpotPix-strctStimulusParams.m_fGazeBoxPix,...
    strctStimulusParams.m_pt2fFixationSpotPix+strctStimulusParams.m_fGazeBoxPix];

Screen('FrameRect',g_strctPTB.m_hWindow,[255 0 0], g_strctPTB.m_fScale * aiGazeRect);


aiStimulusRect = [strctStimulusParams.m_pt2fFixationSpotPix-strctStimulusParams.m_fStimulusSizePix,...
    strctStimulusParams.m_pt2fFixationSpotPix+strctStimulusParams.m_fStimulusSizePix];

Screen('FrameRect',g_strctPTB.m_hWindow,[255 255 0], g_strctPTB.m_fScale * aiStimulusRect);


return;



