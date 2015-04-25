function fnParadigmHandMappingDraw(bParadigmPaused)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)


global g_strctPTB g_strctParadigm g_strctPlexon
persistent plotCommands
if bParadigmPaused
return;
end

%% Get relevant parameters
aiStimulusScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
pt2iFixationSpot = g_strctParadigm.FixationSpotPix.Buffer(1,:,g_strctParadigm.FixationSpotPix.BufferIdx);
pt2fStimulusPos = g_strctParadigm.StimulusPos.Buffer(1,:,g_strctParadigm.StimulusPos.BufferIdx);



fFixationSizePix = g_strctParadigm.FixationSizePix.Buffer(1,:,g_strctParadigm.FixationSizePix.BufferIdx);
fGazeBoxPix = g_strctParadigm.GazeBoxPix.Buffer(1,:,g_strctParadigm.GazeBoxPix.BufferIdx);
fStimulusSizePix = g_strctParadigm.StimulusSizePix.Buffer(1,:,g_strctParadigm.StimulusSizePix.BufferIdx);
bShowPhotodiodeRect = g_strctParadigm.m_bShowPhotodiodeRect;
iPhotoDiodeWindowPix = g_strctParadigm.m_iPhotoDiodeWindowPix;


%% Clear screen

% We're in hardcore color mode now, we need to convert color lookup information for local display
if ~isempty(g_strctParadigm.m_strctCurrentTrial) && strcmp(g_strctParadigm.m_strctCurrentTrial.m_strTrialType,'Color Tuning Function')
	Screen('FillRect',g_strctPTB.m_hWindow, g_strctParadigm.m_strctCurrentTrial.m_afLocalBackgroundColor,g_strctParadigm.m_aiStimulusRect');
else	
	currentBlockStimBGColorsR = [g_strctParadigm.m_strCurrentlySelectedBlock,'BackgroundRed'];
	currentBlockStimBGColorsG = [g_strctParadigm.m_strCurrentlySelectedBlock,'BackgroundGreen'];
	currentBlockStimBGColorsB = [g_strctParadigm.m_strCurrentlySelectedBlock,'BackgroundBlue'];
	afBackgroundColor = [squeeze(g_strctParadigm.(currentBlockStimBGColorsR).Buffer(1,:,g_strctParadigm.(currentBlockStimBGColorsR).BufferIdx))...
					squeeze(g_strctParadigm.(currentBlockStimBGColorsG).Buffer(1,:,g_strctParadigm.(currentBlockStimBGColorsG).BufferIdx))...
					squeeze(g_strctParadigm.(currentBlockStimBGColorsB).Buffer(1,:,g_strctParadigm.(currentBlockStimBGColorsB).BufferIdx))];
	Screen('FillRect',g_strctPTB.m_hWindow, afBackgroundColor,g_strctPTB.m_fScale *aiStimulusScreenSize);					
end
%if g_strctParadigm.m_strctCurrentTrial.m_bUpdatePolar
	%g_strctParadigm = fnUpdatePolarPlot(g_strctParadigm, g_strctPTB);
	


%end


%% Draw Stimulus
if ~isempty(g_strctParadigm.m_strctCurrentTrial) && g_strctParadigm.m_bStimulusDisplayed && isfield(g_strctParadigm.m_strctCurrentTrial,'m_iStimulusIndex') && ...
        g_strctParadigm.m_iMachineState ~= 6
		
    % Trial exist. Check state and draw either the image g_strctParadigm.m_strctCurrentTrial
    iMediaToDisplay = g_strctParadigm.m_strctCurrentTrial.m_iStimulusIndex;
	
	
	
    switch g_strctParadigm.m_strctCurrentTrial.m_strTrialType
        case 'Image'
            fnDisplayMonocularImageLocally();
        case 'Movie'
            fnDisplayMonocularMovieLocally();
        case 'StereoImage'
            fnDisplayStereoImageLocally();
        case 'StereoMovie'
            fnDisplayStereoMovieLocally();
		case 'Moving Bar'
			fnDisplayMovingBarLocally(); % This is a pretty generic display function, should work for most 8 bit uses
        case 'Plain Bar'
            fnDisplayPlainBarLocally();
		case 'Color Tuning Function'
			fnColorTuningFuncLocal();
		case 'Orientation Tuning Function'
			fnDisplayMovingBarLocally(); 
		case 'Position Tuning Function'
			fnDisplayMovingBarLocally();
		case 'Gabor'	
			fnGaborFuncLocal(g_strctParadigm, g_strctPTB)
		case 'Moving Dots'
			fnDisplayMovingDotsLocal(g_strctParadigm, g_strctPTB)
        otherwise
            assert(false);
    end
end
%% Outline the stimulus area
Screen('FrameRect', g_strctPTB.m_hWindow, [255 255 255], g_strctParadigm.m_aiStimulusRect', 3)
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
aiStimulusRect = aiStimulusScreenSize;

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

% Tuning function crap
plotCommands = {};
if g_strctParadigm.m_bRasterPlot
	plotCommands = {plotCommands,'UpdateRaster'};
end
if g_strctParadigm.m_bHeatPlot
	plotCommands = {plotCommands,'UpdateHeatPlot'};
end
if g_strctParadigm.m_bPolarPlot
	plotCommands = {plotCommands,'UpdatePolar'};
end

if ~isempty(plotCommands)
 %&& GetSecs() - g_strctPTB.m_fLastPolarUpdate > g_strctPTB.m_iPolarUpdateMS

	fnUpdatePlots(plotCommands,1:20,squeeze(g_strctParadigm.TrialsForPlotting.Buffer(1,:,g_strctParadigm.TrialsForPlotting.BufferIdx)));
	%,'UpdatePolar'
	%fnUpdatePlots({'UpdateCounts'},1:20,squeeze(g_strctParadigm.TrialsForPlotting.Buffer(1,:,g_strctParadigm.TrialsForPlotting.BufferIdx)));
	
%,'UpdateHistogram'
	%g_strctPlexon.m_strctLastCheck.m_iTrialStartIndex 
	%g_strctPlexon.m_strctLastCheck.m_iTrialEndIndex
	
	%{
	Screen('FrameOval',g_strctPTB.m_hWindow, g_strctPTB.m_afPolarOutlineColors, g_strctPTB.m_afPolarRect) 
	Screen('FramePoly',g_strctPTB.m_hWindow, g_strctPTB.m_afPolarColors, g_strctPlexon.m_afPolarPlottingArray)
	
	g_strctPlexon.m_aiTrials(g_strctPlexon.m_aiTrialsIteration).spikes = g_strctPlexon.m_strctLastCheck;
	g_strctPlexon.m_aiTrialsIteration = g_strctPlexon.m_aiTrialsIteration + 1;
	g_strctPlexon.m_strctLastCheck.m_aiTrialSpikeEvents
	%g_strctPlexon.m_afPolarPlottingArray
	%}
	%g_strctParadigm.m_bUpdatePolar = 0;
	
	
	%elseif 
	%fnUpdatePlots({'UpdateHistogram'},1:20,squeeze(g_strctParadigm.TrialsForPlotting.Buffer(1,:,g_strctParadigm.TrialsForPlotting.BufferIdx)));
	
	end
	%{
elseif g_strctPlexon.m_bDrawToPTBScreen
	 Screen('FrameOval',g_strctPTB.m_hWindow, g_strctPlexon.m_strctStatistics.m_afPolarOutlineColors, g_strctPlexon.m_strctStatistics.m_afPolarRect) 
     Screen('FramePoly',g_strctPTB.m_hWindow, g_strctPlexon.m_strctStatistics.m_afPolarColors, g_strctPlexon.m_strctStatistics.m_afPolarPlottingArray)
end
%}


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

aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRectFTS(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);


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
        
        hImageID = Screen('MakeTexture', g_strctPTB.m_hWindow,  a2fImage, 0, 0, 1);
        Screen('DrawTexture', g_strctPTB.m_hWindow, hImageID,[],aiStimulusRect, fRotationAngle);
        Screen('Close',hImageID);
		
	% Changelog 10/21/2013 Josh - Added fit to screen 
	
    elseif g_strctParadigm.m_bFitToScreen
		Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctParadigm.m_strctTexturesBuffer.m_ahHandles(hTexturePointer),[],aiStimulusRect);
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
    aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRectFTS(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
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
         aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRectFTS(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);

        hImageID = Screen('MakeTexture', g_strctPTB.m_hWindow,  a2fImage, 0, 0, 1);
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
    aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRectFTS(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
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
        aiStimulusRectLeft = g_strctPTB.m_fScale * fnComputeStimulusRectFTS(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
        Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(1),[],aiStimulusRectLeft, fRotationAngle);
    case 'Right Eye Only'
        %aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointers(2))';
        aiStimulusRectRight = g_strctPTB.m_fScale * fnComputeStimulusRectFTS(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
        Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(2),[],aiStimulusRectRight, fRotationAngle);
    case 'Left & Side by Side (Small)'
%         aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointers(1))';
        aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRectFTS(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
        Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(1),[],aiStimulusRect, fRotationAngle);
        
        aiStimulusRectLeft = g_strctPTB.m_fScale * fnComputeStimulusRectFTS(fStimulusSizePix/4, aiTextureSize, pt2fStimulusPos+[-3*fStimulusSizePix/4,+3*fStimulusSizePix/4]);
        Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(1),[],aiStimulusRectLeft, fRotationAngle);
        Screen('FrameRect', g_strctPTB.m_hWindow, [0 0 255],aiStimulusRectLeft,2);
        
%         aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointers(2))';
         aiStimulusRectRight = g_strctPTB.m_fScale * fnComputeStimulusRectFTS(fStimulusSizePix/4, aiTextureSize, pt2fStimulusPos+[3*fStimulusSizePix/4,+3*fStimulusSizePix/4]);
        Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(2),[],aiStimulusRectRight, fRotationAngle);
        Screen('FrameRect', g_strctPTB.m_hWindow, [255 0 0],aiStimulusRectRight,2);
    case 'Side by Side (Large)'
%         aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointers(1))';
        aiStimulusRectLeft = g_strctPTB.m_fScale * fnComputeStimulusRectFTS(fStimulusSizePix, aiTextureSize, pt2fStimulusPos+[-fStimulusSizePix,+0]);
        Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(1),[],aiStimulusRectLeft, fRotationAngle);
        Screen('FrameRect', g_strctPTB.m_hWindow, [0 0 255],aiStimulusRectLeft,2);
        
%         aiTextureSize = g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize(:,ahTexturePointersInBuf(2))';
        aiStimulusRectRight = g_strctPTB.m_fScale * fnComputeStimulusRectFTS(fStimulusSizePix, aiTextureSize, pt2fStimulusPos+[fStimulusSizePix,+0]);
        Screen('DrawTexture', g_strctPTB.m_hWindow, ahTexturePointersInBuf(2),[],aiStimulusRectRight, fRotationAngle);
        Screen('FrameRect', g_strctPTB.m_hWindow, [255 0 0],aiStimulusRectRight,2);
    case 'Left: Red, Right: Blue'
        % Slower. Need to generate textures on the
        % fly.....Let's assume also the the size of both images
        % is the same, otherwise this can crash....
         aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRectFTS(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);
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
        aiStimulusRect = g_strctPTB.m_fScale * fnComputeStimulusRectFTS(fStimulusSizePix, aiTextureSize, pt2fStimulusPos);

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


function fnDisplayPlainBarLocally()
global g_strctParadigm g_strctPTB

% Show a moving bar using the PTB draw functions
% Get the trial parameters from the imported struct

StimServerScreenRect = [0 0 g_strctPTB.m_fScale*g_strctParadigm.g_strctStimulusServer.m_aiScreenSize(3),...
        g_strctParadigm.g_strctStimulusServer.m_aiScreenSize(4)];

Screen('FillRect',g_strctPTB.m_hWindow, g_strctParadigm.m_strctCurrentTrial.m_afBackgroundColor, StimServerScreenRect);

if g_strctParadigm.m_strctCurrentTrial.m_iMoveDistance
	Screen('DrawLine',g_strctPTB.m_hWindow, [255 255 255], g_strctParadigm.m_strctCurrentTrial.m_iLineBegin(1),g_strctParadigm.m_strctCurrentTrial.m_iLineBegin(2),...
                                                g_strctParadigm.m_strctCurrentTrial.m_iLineEnd(1),g_strctParadigm.m_strctCurrentTrial.m_iLineEnd(2));

end
if ~g_strctParadigm.m_strctCurrentTrial.m_bBlur	
	Screen('FillPoly',g_strctPTB.m_hWindow, g_strctParadigm.m_strctCurrentTrial.BarColor,...
		 horzcat(g_strctParadigm.m_strctCurrentTrial.coordinatesX(1:4,1),g_strctParadigm.m_strctCurrentTrial.coordinatesY(1:4,1)),0)
else
	for iNumOfBars = 1:g_strctParadigm.m_strctCurrentTrial.m_iNumberOfBars
		for iBlurStep = 1:g_strctParadigm.m_strctCurrentTrial.numberBlurSteps
		
			Screen('FillPoly',g_strctPTB.m_hWindow, g_strctParadigm.m_strctCurrentTrial.blurStepHolder(:,iBlurStep),...
						horzcat(g_strctParadigm.m_strctCurrentTrial.coordinatesX(1:4,1,iNumOfBars,iBlurStep),...
						g_strctParadigm.m_strctCurrentTrial.coordinatesY(1:4,1,iNumOfBars,iBlurStep)),0)
                    
                    
            %{ 
                    for console testing
                    iNumOfBars = 1;
                    iBlurStep = 1;
                    strctTrial.blurStepHolder(:,iBlurStep),...
						horzcat(strctTrial.coordinatesX(1:4,1,iNumOfBars,iBlurStep),...
						strctTrial.coordinatesY(1:4,1,iNumOfBars,iBlurStep))
                    iBlurStep = iBlurStep + 1;
            %}
		end
	end
end
return;




function fnDisplayMovingBarLocally()
global g_strctParadigm g_strctPTB

% Show a moving bar using the PTB draw functions
% Get the trial parameters from the imported struct
%ahTexturePointers = g_strctParadigm.m_strctCurrentTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer;
%fCurrTime  = GetSecs();
StimServerScreenRect = [0 0 g_strctPTB.m_fScale*g_strctParadigm.g_strctStimulusServer.m_aiScreenSize(3),...
        g_strctParadigm.g_strctStimulusServer.m_aiScreenSize(4)];
Screen('FillRect',g_strctPTB.m_hWindow, g_strctParadigm.m_strctCurrentTrial.m_afBackgroundColor,StimServerScreenRect);
if g_strctParadigm.m_iMachineState == 5 | g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter > g_strctParadigm.m_strctCurrentTrial.numFrames  %#ok<OR2>
	% Trial's over, or we've somehow gone over the number of frames in the trial. Bail out.
	return;
end
if ~g_strctParadigm.m_strctCurrentTrial.m_bBlur
	for iNumOfBars = 1:g_strctParadigm.m_strctCurrentTrial.m_iNumberOfBars
		Screen('FillPoly',g_strctPTB.m_hWindow, g_strctParadigm.m_strctCurrentTrial.m_aiStimColor,...
			 horzcat(g_strctParadigm.m_strctCurrentTrial.coordinatesX(1:4,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,iNumOfBars),...
				g_strctParadigm.m_strctCurrentTrial.coordinatesY(1:4,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,iNumOfBars)),0)
	end
	
else

	for iNumOfBars = 1:g_strctParadigm.m_strctCurrentTrial.m_iNumberOfBars
		for iBlurStep = 1:g_strctParadigm.m_strctCurrentTrial.numberBlurSteps
		
			Screen('FillPoly',g_strctPTB.m_hWindow, g_strctParadigm.m_strctCurrentTrial.blurStepHolder(:,iBlurStep),...
						horzcat(g_strctParadigm.m_strctCurrentTrial.coordinatesX(1:4,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,iNumOfBars,iBlurStep),...
						g_strctParadigm.m_strctCurrentTrial.coordinatesY(1:4,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,iNumOfBars,iBlurStep)),0)
		end
	end
end
return;


function fnColorTuningFuncLocal()
global g_strctParadigm g_strctPTB

StimServerScreenRect = [0 0 g_strctPTB.m_fScale*g_strctParadigm.g_strctStimulusServer.m_aiScreenSize(3),...
        g_strctParadigm.g_strctStimulusServer.m_aiScreenSize(4)];


Screen('FillRect',g_strctPTB.m_hWindow, g_strctParadigm.m_strctCurrentTrial.m_afLocalBackgroundColor,StimServerScreenRect );
if g_strctParadigm.m_iMachineState == 5
	% Trial's over, bail out.
	return;
end
% I don't think we'll have more than one bar, but you never know
for iNumOfBars = 1:g_strctParadigm.m_strctCurrentTrial.m_iNumberOfBars
	Screen('FillPoly',g_strctPTB.m_hWindow, g_strctParadigm.m_strctCurrentTrial.m_afLocalBarColor,...
			horzcat(g_strctParadigm.m_strctCurrentTrial.coordinatesX(1:4,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,iNumOfBars),...
			g_strctParadigm.m_strctCurrentTrial.coordinatesY(1:4,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,iNumOfBars)),0)
end

return;






function fnGaborFuncLocal(g_strctParadigm, g_strctPTB)


StimServerScreenRect = [0 0 g_strctPTB.m_fScale*g_strctParadigm.g_strctStimulusServer.m_aiScreenSize(3),...
        g_strctParadigm.g_strctStimulusServer.m_aiScreenSize(4)];
Screen('FillRect',g_strctPTB.m_hWindow, g_strctParadigm.m_strctCurrentTrial.m_afLocalBackgroundColor,StimServerScreenRect);

Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctParadigm.m_hGabortex, [], g_strctParadigm.m_strctCurrentTrial.m_afDestRectangle, g_strctParadigm.m_strctCurrentTrial.m_fRotationAngle, [], [], g_strctParadigm.m_strctCurrentTrial.m_aiStimulusColor, [],...
 kPsychDontDoRotation, [g_strctParadigm.m_strctCurrentTrial.m_fGaborPhase+180, g_strctParadigm.m_strctCurrentTrial.m_iGaborFreq, g_strctParadigm.m_strctCurrentTrial.m_iSigma, g_strctParadigm.m_strctCurrentTrial.m_iContrast,...
g_strctParadigm.m_strctCurrentTrial.AspectRatio, 0, 0, 0]); % The three zeros are placeholders... this function requires it



return;


function fnDisplayMovingDotsLocal(g_strctParadigm, g_strctPTB)

StimServerScreenRect = [0 0 g_strctPTB.m_fScale*g_strctParadigm.g_strctStimulusServer.m_aiScreenSize(3),...
        g_strctParadigm.g_strctStimulusServer.m_aiScreenSize(4)];
Screen('FillRect',g_strctPTB.m_hWindow, g_strctParadigm.m_strctCurrentTrial.m_afBackgroundColor,StimServerScreenRect);
numDots = g_strctParadigm.m_strctCurrentTrial.NumberOfDots;
%Rect = zeros(4,numDots);
% reallign the rect so it is in the left, top, right, bottom order required by the filloval command
%{
for iNumOfDots = 1:numDots
	% Reshape the coordinates. Draw oval requires that they be in left, top, right, bottom order
	% This is sloppy since we're still piggybacking on the rectangle code
	Rect(1,iNumOfDots) =  min(g_strctParadigm.m_strctCurrentTrial.coordinatesX(:,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,iNumOfDots));
	Rect(2,iNumOfDots) =  min(g_strctParadigm.m_strctCurrentTrial.coordinatesY(:,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,iNumOfDots));
	Rect(3,iNumOfDots) =  max(g_strctParadigm.m_strctCurrentTrial.coordinatesX(:,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,iNumOfDots));
	Rect(4,iNumOfDots) =  max(g_strctParadigm.m_strctCurrentTrial.coordinatesY(:,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,iNumOfDots));

end
%}
%Screen('FillOval', g_strctPTB.m_hWindow, g_strctParadigm.m_strctCurrentTrial.m_afLocalBarColor, Rect);


	Screen('FillOval', g_strctPTB.m_hWindow, g_strctParadigm.m_strctCurrentTrial.m_afLocalBarColor,  squeeze([g_strctParadigm.m_strctCurrentTrial.m_aiCoordinates(1, g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter, :),... left
																				 g_strctParadigm.m_strctCurrentTrial.m_aiCoordinates(2, g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter, :),... top
																				 g_strctParadigm.m_strctCurrentTrial.m_aiCoordinates(3, g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter, :),... right
																				 g_strctParadigm.m_strctCurrentTrial.m_aiCoordinates(4, g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter, :)])); % bottom
	


%{
backup
Screen('FillOval', g_strctPTB.m_hWindow, g_strctParadigm.m_strctCurrentTrial.m_afLocalBarColor, squeeze([g_strctParadigm.m_strctCurrentTrial.coordinatesX(1,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,:),...
                                                                                                        g_strctParadigm.m_strctCurrentTrial.coordinatesY(1,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,:),...
                                                                                                        g_strctParadigm.m_strctCurrentTrial.coordinatesX(3,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,:),...
                                                                                                        g_strctParadigm.m_strctCurrentTrial.coordinatesY(2,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,:)]));
Rect(1,iNumOfDots) =  min(g_strctParadigm.m_strctCurrentTrial.coordinatesX(1,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,iNumOfDots),g_strctParadigm.m_strctCurrentTrial.coordinatesX(3,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,iNumOfDots));
	Rect(2,iNumOfDots) =  min(g_strctParadigm.m_strctCurrentTrial.coordinatesY(1,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,iNumOfDots),g_strctParadigm.m_strctCurrentTrial.coordinatesY(2,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,iNumOfDots));
	Rect(3,iNumOfDots) =  max(g_strctParadigm.m_strctCurrentTrial.coordinatesX(1,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,iNumOfDots),g_strctParadigm.m_strctCurrentTrial.coordinatesX(3,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,iNumOfDots));
	Rect(4,iNumOfDots) =  max(g_strctParadigm.m_strctCurrentTrial.coordinatesY(1,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,iNumOfDots),g_strctParadigm.m_strctCurrentTrial.coordinatesY(2,g_strctParadigm.m_strctCurrentTrial.m_iLocalFrameCounter,iNumOfDots));

%}
return;