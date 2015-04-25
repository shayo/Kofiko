function fnParadigmPassiveFixationDrawNew()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)


global g_strctPTB g_strctParadigm


%% Get relevant parameters
aiStimulusScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
pt2iFixationSpot = g_strctParadigm.FixationSpotPix.Buffer(1,:,g_strctParadigm.FixationSpotPix.BufferIdx);
pt2fStimulusPos = g_strctParadigm.StimulusPos.Buffer(1,:,g_strctParadigm.StimulusPos.BufferIdx);
afBackgroundColor = squeeze(g_strctParadigm.BackgroundColor.Buffer(1,:,g_strctParadigm.BackgroundColor.BufferIdx));
fFixationSizePix = g_strctParadigm.FixationSizePix.Buffer(1,:,g_strctParadigm.FixationSizePix.BufferIdx);
fGazeBoxPix = g_strctParadigm.GazeBoxPix.Buffer(1,:,g_strctParadigm.GazeBoxPix.BufferIdx);
fStimulusSizePix = g_strctParadigm.StimulusSizePix.Buffer(1,:,g_strctParadigm.StimulusSizePix.BufferIdx);
fRotationAngle = g_strctParadigm.RotationAngle.Buffer(1,:,g_strctParadigm.RotationAngle.BufferIdx);
bShowPhotodiodeRect = g_strctParadigm.m_bShowPhotodiodeRect;
iPhotoDiodeWindowPix = g_strctParadigm.m_iPhotoDiodeWindowPix;

%% Clear screen
Screen('FillRect',g_strctPTB.m_hWindow, afBackgroundColor);

%% Draw Stimulus
if ~isempty(g_strctParadigm.m_strctCurrentTrial) && g_strctParadigm.m_bStimulusDisplayed && isfield(g_strctParadigm.m_strctCurrentTrial,'m_iStimulusIndex') && ...
        g_strctParadigm.m_iMachineState ~= 6
    % Trial exist. Check state and draw either the image g_strctParadigm.m_strctCurrentTrial
    iMediaToDisplay = g_strctParadigm.m_strctCurrentTrial.m_iStimulusIndex;
    switch g_strctParadigm.m_strctDesign.m_astrctMedia(iMediaToDisplay).m_strMediaType
        case 'Image'
            fnDisplayMonocularImageLocally();
        case 'Movie'
            fnDisplayMonocularMovieLocally();
        case 'StereoImage'
            fnDisplayStereoImageLocally();
        case 'StereoMovie'
            fnDisplayStereoMovieLocally();
        otherwise
            assert(false);
    end
end

%% Photodiode Crap
if bShowPhotodiodeRect && ~isempty(g_strctParadigm.m_strctCurrentTrial) && ...
        isfield(g_strctParadigm.m_strctCurrentTrial,'m_bIsMovie') && ~g_strctParadigm.m_strctCurrentTrial.m_bIsMovie
    bStimulusOFF_MS = g_strctParadigm.StimulusOFF_MS.Buffer(1,:,g_strctParadigm.StimulusOFF_MS.BufferIdx) > 0;

    aiPhotoDiodeRect = g_strctPTB.m_fScale * [aiStimulusScreenSize(3)-iPhotoDiodeWindowPix ...
        aiStimulusScreenSize(4)-iPhotoDiodeWindowPix ...
        aiStimulusScreenSize(3) aiStimulusScreenSize(4)];
    
    if g_strctParadigm.m_bStimulusDisplayed
            Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], aiPhotoDiodeRect);
    elseif ~g_strctParadigm.m_bStimulusDisplayed && bStimulusOFF_MS
            Screen('FillRect',g_strctPTB.m_hWindow,[0 0 0], aiPhotoDiodeRect);
    end
end
    
%% Draw Fixation Rect and Reward Rect and Stimulus Rect
aiFixationRect = [pt2iFixationSpot-fFixationSizePix, pt2iFixationSpot+fFixationSizePix];
aiRewardRect = [pt2iFixationSpot-fGazeBoxPix,pt2iFixationSpot+fGazeBoxPix];

% Changelog 10/22/2013 Josh - adding FitToScreen support. Working on control computer but not stimulus server...

if ~g_strctParadigm.m_bFitToScreen
	aiStimulusRect = [pt2fStimulusPos-fStimulusSizePix, pt2fStimulusPos+fStimulusSizePix];
else
	aiStimulusRect = aiStimulusScreenSize;
end
% End Changelog -------------------------------------------------------------------------------------------------

Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], g_strctPTB.m_fScale * aiFixationRect,0,360);
Screen('FrameRect',g_strctPTB.m_hWindow,[255 0 0], g_strctPTB.m_fScale * aiRewardRect);
Screen('FrameRect',g_strctPTB.m_hWindow,[255 255 0], g_strctPTB.m_fScale * aiStimulusRect);


%% Juice Related drawing
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

% Screen(g_strctPTB.m_hWindow,'DrawText',sprintf('%d%%',round(fPercCorrect*100)),...
%     10, g_strctPTB.m_aiRect(4)-fRadius/2-20+1, [0 255 0]);

%%
if g_strctParadigm.m_iMachineState == 0 && g_strctParadigm.m_bPausedDueToMotion
    Screen(g_strctPTB.m_hWindow,'DrawText', 'Paused due to monkey motion. Waiting for motion to stop...',...
        g_strctPTB.m_aiRect(1),g_strctPTB.m_aiRect(2)+20, [0 255 0]);
end

return;


function fnDisplayMonocularImageLocally()
global g_strctParadigm g_strctPTB 

pt2fStimulusPos =g_strctParadigm.m_strctCurrentTrial.m_pt2fStimulusPos;
fStimulusSizePix =g_strctParadigm.m_strctCurrentTrial.m_fStimulusSizePix;
fRotationAngle = g_strctParadigm.m_strctCurrentTrial.m_fRotationAngle;

hTexturePointer = g_strctParadigm.m_strctDesign.m_astrctMedia(g_strctParadigm.m_strctCurrentTrial.m_iStimulusIndex).m_aiMediaToHandleIndexInBuffer(1);

aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,hTexturePointer)';
aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);


if g_strctParadigm.m_bDisplayStimuliLocally
    if g_strctParadigm.m_strctCurrentTrial.m_bNoiseOverlay
        % Overlay image with noise...will be slower (!)
        
        a2fImage = g_strctParadigm.m_strctTexturesBuffer.m_acImages{hTexturePointer};
        if size(a2fImage,3) == 3
            % Modify the image....
            I = a2fImage(:,:,1);
            a2bMask = I == 255;
            [a2fX,a2fY] = meshgrid(linspace(1,  size(g_strctParadigm.m_strctCurrentTrial.m_a2fNoisePattern,2), size(a2fImage,2)),...
                linspace(1,  size(g_strctParadigm.m_strctCurrentTrial.m_a2fNoisePattern,1), size(a2fImage,1)));
            a2fNoiseResamples = fnFastInterp2(g_strctParadigm.m_strctCurrentTrial.m_a2fNoisePattern, a2fX(:),a2fY(:));
            I(a2bMask) = a2fNoiseResamples(a2bMask)*255;
            a2fImage = I;
        end
        
        hImageID = Screen('MakeTexture', g_strctPTB.m_hWindow,  a2fImage);
        Screen('DrawTexture', g_strctPTB.m_hWindow, hImageID,[],aiStimulusRect, fRotationAngle);
        Screen('Close',hImageID);
		
	% Changelog 10/21/2013 Josh - Added fit to screen 
	
    elseif g_strctParadigm.m_bFitToScreen
		Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer),[]);
	% End Changelog
	
    else
        % Default presentation mode of images...
        Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer),[],aiStimulusRect, fRotationAngle);
    end
    
    
else
    Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Image %d (%s)',g_strctParadigm.m_strctCurrentTrial.m_iStimulusIndex,...
        g_strctParadigm.m_strctDesign.m_astrctMedia(g_strctParadigm.m_strctCurrentTrial.m_iStimulusIndex).m_strName), pt2fStimulusPos(1),pt2fStimulusPos(2), [0 255 0]);
end

return;

function fnDisplayMonocularMovieLocally()
global g_strctParadigm g_strctPTB 

if g_strctParadigm.m_bDisplayStimuliLocally
    fStimulusSizePix = g_strctParadigm.StimulusSizePix.Buffer(1,:,g_strctParadigm.StimulusSizePix.BufferIdx);
    hTexturePointer = g_strctParadigm.m_strctCurrentTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer(1);
    pt2fStimulusPos =g_strctParadigm.m_strctCurrentTrial.m_pt2fStimulusPos;
    aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,hTexturePointer)';
    aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
    fRotationAngle = g_strctParadigm.RotationAngle.Buffer(1,:,g_strctParadigm.RotationAngle.BufferIdx);

    if ~g_strctParadigm.m_bMovieInitialized 
        % First time draw is called and a movie needs to be played...
        hTexturePointer = g_strctParadigm.m_strctCurrentTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer(1);
        Screen('PlayMovie', g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer), 1,0,1);
        Screen('SetMovieTimeIndex',g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer),0);
        g_strctParadigm.m_bMovieInitialized  = true;
        g_strctParadigm.m_fApproxMovieStartTS = GetSecs();
        [hFrameTexture, fTimeToFlip] = Screen('GetMovieImage', g_strctPTB.m_hWindow, g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer),1);
        Screen('DrawTexture', g_strctPTB.m_hWindow, hFrameTexture,[],aiStimulusRect, fRotationAngle);
        Screen('Close', hFrameTexture);
    else
        [hFrameTexture, fTimeToFlip] = Screen('GetMovieImage', g_strctPTB.m_hWindow, g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer),1);
        if hFrameTexture > 0
            Screen('DrawTexture', g_strctPTB.m_hWindow, hFrameTexture,[],aiStimulusRect, fRotationAngle);
            Screen('Close', hFrameTexture);
        else
            % No more frames to display....
            g_strctParadigm.m_bMovieInitialized  = false;
        end
    end
    
else
    if ~g_strctParadigm.m_bMovieInitialized 
        g_strctParadigm.m_bMovieInitialized  = true;
        g_strctParadigm.m_fApproxMovieStartTS = GetSecs();
    end
        
          % Will not play movie, but just draw a text saying that this
        % time has elapsed since movie onset...
        fTimeElapsed = GetSecs() - g_strctParadigm.m_fApproxMovieStartTS;
        pt2fStimulusPos =g_strctParadigm.m_strctCurrentTrial.m_pt2fStimulusPos;
        Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Movie Playing %.1f Sec', fTimeElapsed),...
            pt2fStimulusPos(1),pt2fStimulusPos(2), [0 255 0]);
end

return;




function fnDisplayStereoImageLocally()
global g_strctParadigm g_strctPTB 

pt2fStimulusPos =g_strctParadigm.m_strctCurrentTrial.m_pt2fStimulusPos;
fStimulusSizePix =g_strctParadigm.m_strctCurrentTrial.m_fStimulusSizePix;
fRotationAngle = g_strctParadigm.m_strctCurrentTrial.m_fRotationAngle;

ahTexturePointers = g_strctParadigm.m_strctDesign.m_astrctMedia(g_strctParadigm.m_strctCurrentTrial.m_iStimulusIndex).m_aiMediaToHandleIndexInBuffer;

%%

if g_strctParadigm.m_bDisplayStimuliLocally
    if g_strctParadigm.m_strctCurrentTrial.m_bNoiseOverlay
        % Overlay image with nosie...will be slower (!)
        a2fImage = g_strctParadigm.m_strctTexturesBuffer.m_acImages{ahTexturePointers(1)};
        if size(a2fImage,3) == 3
            % Modify the image....
            I = a2fImage(:,:,1);
            a2bMask = I == 255;
            [a2fX,a2fY] = meshgrid(linspace(1,  size(g_strctParadigm.m_strctCurrentTrial.m_a2fNoisePattern,2), size(a2fImage,2)),...
                linspace(1,  size(g_strctParadigm.m_strctCurrentTrial.m_a2fNoisePattern,1), size(a2fImage,1)));
            a2fNoiseResamples = fnFastInterp2(g_strctParadigm.m_strctCurrentTrial.m_a2fNoisePattern, a2fX(:),a2fY(:));
            I(a2bMask) = a2fNoiseResamples(a2bMask)*255;
            a2fImage = I;
        end
         aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointers(1))';
         aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);

        hImageID = Screen('MakeTexture', g_strctPTB.m_hWindow,  a2fImage);
        Screen('DrawTexture', g_strctPTB.m_hWindow, hImageID,[],aiStimulusRect, fRotationAngle);
        Screen('Close',hImageID);
    else
        % Default presentation mode of images...
        aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointers(1))';
        ahTexturePointersInBuffer = g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(ahTexturePointers);
        fnDrawStereoLocallyAux(ahTexturePointersInBuffer,aiTextureSize);
   
    end
    
    
else
    Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Image %d (%s)',g_strctParadigm.m_strctCurrentTrial.m_iStimulusIndex,...
        g_strctParadigm.m_strctDesign.m_astrctMedia(g_strctParadigm.m_strctCurrentTrial.m_iStimulusIndex).m_strName), pt2fStimulusPos(1),pt2fStimulusPos(2), [0 255 0]);
end

return;




function fnDisplayStereoMovieLocally()
global g_strctParadigm g_strctPTB 

if g_strctParadigm.m_bDisplayStimuliLocally
    fStimulusSizePix = g_strctParadigm.StimulusSizePix.Buffer(1,:,g_strctParadigm.StimulusSizePix.BufferIdx);
    hTexturePointer = g_strctParadigm.m_strctCurrentTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer(1);
    pt2fStimulusPos =g_strctParadigm.m_strctCurrentTrial.m_pt2fStimulusPos;
    aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,hTexturePointer)';
    aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
    fRotationAngle = g_strctParadigm.RotationAngle.Buffer(1,:,g_strctParadigm.RotationAngle.BufferIdx);

    if ~g_strctParadigm.m_bMovieInitialized 
        % First time draw is called and a movie needs to be played...
        
        
        
        ahFrameTexture = zeros(1,2);
        for iHandleIter=1:2
            hTexturePointer = g_strctParadigm.m_strctCurrentTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer(iHandleIter);
            Screen('PlayMovie', g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer), 1,0,1);
            Screen('SetMovieTimeIndex',g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer),0);
            [ahFrameTexture(iHandleIter), fTimeToFlip] = Screen('GetMovieImage', g_strctPTB.m_hWindow, g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer),1);
        end
        
        g_strctParadigm.m_fApproxMovieStartTS = GetSecs();
        aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,hTexturePointer)';
        fnDrawStereoLocallyAux(ahFrameTexture,aiTextureSize);
        Screen('Close', ahFrameTexture);
        
        g_strctParadigm.m_bMovieInitialized  = true;
    else
        ahFrameTexture = zeros(1,2);
        for iHandleIter=1:2
            hTexturePointer = g_strctParadigm.m_strctCurrentTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer(iHandleIter);
            [ahFrameTexture(iHandleIter), fTimeToFlip] = Screen('GetMovieImage', g_strctPTB.m_hWindow, g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer),1);
        end
        if all(ahFrameTexture > 0)
            fnDrawStereoLocallyAux(ahFrameTexture,aiTextureSize);
            Screen('Close', ahFrameTexture);
        else
            % No more frames to display....
            g_strctParadigm.m_bMovieInitialized  = false;
        end
    end
    
else
    if ~g_strctParadigm.m_bMovieInitialized
        g_strctParadigm.m_bMovieInitialized  = true;
        g_strctParadigm.m_fApproxMovieStartTS = GetSecs();
    end
          % Will not play movie, but just draw a text saying that this
        % time has elapsed since movie onset...
        fTimeElapsed = GetSecs() - g_strctParadigm.m_fApproxMovieStartTS;
        pt2fStimulusPos =g_strctParadigm.m_strctCurrentTrial.m_pt2fStimulusPos;
        Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Movie Playing %.1f Sec', fTimeElapsed),...
            pt2fStimulusPos(1),pt2fStimulusPos(2), [0 255 0]);
end
return;






function fnDrawStereoLocallyAux(ahTexturePointersInBuf,aiTextureSize)
global g_strctParadigm  g_strctPTB
% Couple of ways to present stereo images...
% If they are gray scale, we can generate a red/blue presentation
% of them....

pt2fStimulusPos =g_strctParadigm.m_strctCurrentTrial.m_pt2fStimulusPos;
fStimulusSizePix =g_strctParadigm.m_strctCurrentTrial.m_fStimulusSizePix;
fRotationAngle = g_strctParadigm.m_strctCurrentTrial.m_fRotationAngle;

switch g_strctParadigm.m_strLocalStereoMode
    case 'Left Eye Only'
        %aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointers(1))';
        aiStimulusRectLeft = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
        Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(1),[],aiStimulusRectLeft, fRotationAngle);
    case 'Right Eye Only'
        %aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointers(2))';
        aiStimulusRectRight = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
        Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(2),[],aiStimulusRectRight, fRotationAngle);
    case 'Left & Side by Side (Small)'
%         aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointers(1))';
        aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
        Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(1),[],aiStimulusRect, fRotationAngle);
        
        aiStimulusRectLeft = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix/4, aiTextureSize, pt2fStimulusPos+[-3*fStimulusSizePix/4,+3*fStimulusSizePix/4]);
        Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(1),[],aiStimulusRectLeft, fRotationAngle);
        Screen('FrameRect', g_strctPTB.m_hWindow, [0 0 255],aiStimulusRectLeft,2);
        
%         aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointers(2))';
         aiStimulusRectRight = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix/4, aiTextureSize, pt2fStimulusPos+[3*fStimulusSizePix/4,+3*fStimulusSizePix/4]);
        Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(2),[],aiStimulusRectRight, fRotationAngle);
        Screen('FrameRect', g_strctPTB.m_hWindow, [255 0 0],aiStimulusRectRight,2);
    case 'Side by Side (Large)'
%         aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointers(1))';
        aiStimulusRectLeft = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos+[-fStimulusSizePix,+0]);
        Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(1),[],aiStimulusRectLeft, fRotationAngle);
        Screen('FrameRect', g_strctPTB.m_hWindow, [0 0 255],aiStimulusRectLeft,2);
        
%         aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointersInBuf(2))';
        aiStimulusRectRight = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos+[fStimulusSizePix,+0]);
        Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(2),[],aiStimulusRectRight, fRotationAngle);
        Screen('FrameRect', g_strctPTB.m_hWindow, [255 0 0],aiStimulusRectRight,2);
    case 'Left: Red, Right: Blue'
        % Slower. Need to generate textures on the
        % fly.....Let's assume also the the size of both images
        % is the same, otherwise this can crash....
         aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
        a2fLeft = Screen('GetImage',ahTexturePointersInBuf(1));
        a2fRight = Screen('GetImage',ahTexturePointersInBuf(2));

        
        a3fNewImage = zeros([size(a2fLeft,1),size(a2fLeft,2),3]);
        a3fNewImage(:,:,1) = a2fLeft(:,:,1);
        a3fNewImage(:,:,3) = a2fRight(:,:,1);
        
        hImageID = Screen('MakeTexture', g_strctPTB.m_hWindow,  a3fNewImage);
        Screen('DrawTexture', g_strctPTB.m_hWindow, hImageID,[],aiStimulusRect, fRotationAngle);
        Screen('Close',hImageID);
    case 'Left: Blue, Right: Red'
        % Slower. Need to generate textures on the
        % fly.....Let's assume also the the size of both images
        % is the same, otherwise this can crash....
        aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRect(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);

          a2fLeft = Screen('GetImage',ahTexturePointersInBuf(1));
        a2fRight = Screen('GetImage',ahTexturePointersInBuf(2));
        
        a3fNewImage = zeros([size(a2fLeft,1),size(a2fLeft,2),3]);
        a3fNewImage(:,:,1) = a2fRight(:,:,1);
        a3fNewImage(:,:,3) = a2fLeft(:,:,1);
        
        hImageID = Screen('MakeTexture', g_strctPTB.m_hWindow,  a3fNewImage);
        Screen('DrawTexture', g_strctPTB.m_hWindow, hImageID,[],aiStimulusRect, fRotationAngle);
        Screen('Close',hImageID);
end

return;
