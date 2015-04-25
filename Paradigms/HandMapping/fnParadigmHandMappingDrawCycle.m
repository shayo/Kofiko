function fnParadigmHandMappingDrawCycle(acInputFromKofiko)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

%save('kofikoinput','acInputFromKofiko')
global g_strctPTB g_strctDraw g_strctServerCycle 

fCurrTime = GetSecs();
%disp(acInputFromKofiko)
if ~isempty(acInputFromKofiko)
    strCommand = acInputFromKofiko{1};
    switch strCommand
        case 'ClearMemory'
            fnStimulusServerClearTextureMemory();
        case 'PauseButRecvCommands'
            if g_strctPTB.m_bInStereoMode
                    Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,0); % Left Eye
                    Screen(g_strctPTB.m_hWindow,'FillRect',0);
                    Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,1); % Right Eye
                    Screen(g_strctPTB.m_hWindow,'FillRect',0);
            else
                Screen(g_strctPTB.m_hWindow,'FillRect',0);
            end
            fnFlipWrapper(g_strctPTB.m_hWindow);
            g_strctServerCycle.m_iMachineState = 0;
        case 'LoadImageList'
            acFileNames = acInputFromKofiko{2};
            Screen(g_strctPTB.m_hWindow,'FillRect',1);
            fnFlipWrapper(g_strctPTB.m_hWindow);
            
            fnStimulusServerClearTextureMemory();
            [g_strctDraw.m_ahHandles, g_strctDraw.m_a2iTextureSize,...
                g_strctDraw.m_abIsMovie, g_strctDraw.m_aiApproxNumFrames, Dummy, g_strctDraw.m_acImages] = fnInitializeTexturesAux(acFileNames,false,true);
            
            fnStimulusServerToKofikoParadigm('AllImagesLoaded');
            g_strctServerCycle.m_iMachineState = 0;
        case 'ShowTrial'
            g_strctDraw.m_strctTrial = acInputFromKofiko{2};
			%save('stim_server_inputs','g_strctDraw')
            switch g_strctDraw.m_strctTrial.m_strTrialType
				
				% Parse command type
				case 'Moving Bar'
					g_strctServerCycle.m_iMachineState = 11;
				case 'Plain Bar'
					g_strctServerCycle.m_iMachineState = 11;
				case 'Color Tuning Function'
					g_strctServerCycle.m_iMachineState = 13;
				case 'Orientation Tuning Function'
					g_strctServerCycle.m_iMachineState = 11;
				case 'Position Tuning Function'
					g_strctServerCycle.m_iMachineState = 11;
				case 'Gabor'
					g_strctServerCycle.m_iMachineState = 14;
				case 'Moving Dots' 
					g_strctServerCycle.m_iMachineState = 16;
					
                otherwise
                    assert(false);
            end
    end
end;

switch g_strctServerCycle.m_iMachineState
	% Kept these other command states in in case we want them for mapping at some point
    case 0
        % Do nothing
	case 3
		fnWaitOffPeriod();
	case 11
	%g_strctServerCycle.m_iMachineState = 0;
		fnDisplayMovingBar(); % Can also display static bar, if move_distance is set to zero
	case 12
		fnKeepDisplayingMovingBar();
	case 13
		fnColorTuningFunction();
	case 14
		fnDisplayGabor();
	case 15
		%[g_strctDraw, g_strctPTB, g_strctServerCycle] = fnKeepDisplayingGabor(g_strctDraw, g_strctPTB, g_strctServerCycle); % Not implemented, all gabors are updated every frame atm
	case 16
		fnDisplayMovingDots();
	case 17
		fnKeepDisplayingMovingDots();
end;

return;


function fnWaitOffPeriod()
global g_strctDraw g_strctPTB g_strctServerCycle
fCurrTime  = GetSecs();
if (fCurrTime - g_strctServerCycle.m_fLastFlipTime) > ...
        (g_strctDraw.m_strctTrial.m_fStimulusOFF_MS)/1e3 - (0.2 * (1/g_strctPTB.m_iRefreshRate) )
	fnStimulusServerToKofikoParadigm('TrialFinished');
    g_strctServerCycle.m_iMachineState = 0;
end
return;













% Excerpted code from passive fixation paradigm
%
% ---------------------------------------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------------------------------------


function fnDisplayMovingBar()
global g_strctPTB g_strctDraw g_strctServerCycle 

fCurrTime  = GetSecs();

% Show a moving bar using the PTB draw functions
% Get the trial parameters from the imported struct
aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
    g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];
g_strctDraw.m_iFrameCounter = 1;

if g_strctDraw.m_strctTrial.m_bColorUpdated; 
	disp('clut updated')
	BitsPlusSetClut(g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.Clut);
	g_strctDraw.m_strctTrial.m_bColorUpdated = 0;
end

Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
if ~g_strctDraw.m_strctTrial.m_bBlur
	for iNumOfBars = 1:g_strctDraw.m_strctTrial.m_iNumberOfBars
		Screen('FillPoly',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_aiStimColor,...
			horzcat(g_strctDraw.m_strctTrial.coordinatesX(1:4,1,iNumOfBars),g_strctDraw.m_strctTrial.coordinatesY(1:4,1,iNumOfBars)),0)
	end
else
	for iNumOfBars = 1:g_strctDraw.m_strctTrial.m_iNumberOfBars
		for iBlurStep = 1:g_strctDraw.m_strctTrial.numberBlurSteps
			Screen('FillPoly',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.blurStepHolder(:,iBlurStep),...
				horzcat(g_strctDraw.m_strctTrial.coordinatesX(1:4,g_strctDraw.m_iFrameCounter,iNumOfBars,iBlurStep),...
				g_strctDraw.m_strctTrial.coordinatesY(1:4,g_strctDraw.m_iFrameCounter,iNumOfBars,iBlurStep)),0)
		end
	end
end
	
% Fixation point last so it's on top

%Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
Screen('FillArc',g_strctPTB.m_hWindow,g_strctDraw.m_strctTrial.m_iFixationColor, aiFixationRect,0,360);
if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
	Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], ...
		[g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
		g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
		g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
end

m_fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow); % Time onset of trial, blocking 



fnStimulusServerToKofikoParadigm('FlipON',fCurrTime,g_strctDraw.m_strctTrial.m_iStimulusIndex); 

% Update the machine
if g_strctDraw.m_strctTrial.numFrames > 1
	% Go and display the rest of the frames in this trial
	g_strctServerCycle.m_iMachineState = 12;
	
	g_strctDraw.m_a2fFrameFlipTS = NaN*ones(2,g_strctDraw.m_strctTrial.numFrames); % allocate the trial timing array
g_strctDraw.m_a2fFrameFlipTS(1,g_strctDraw.m_iFrameCounter) = m_fLastFlipTime;   % First frame
g_strctDraw.m_a2fFrameFlipTS(2,g_strctDraw.m_iFrameCounter) = m_fLastFlipTime; % Actual Flip Time
else
	% Do nothing? Kofiko will supply the next frame when it updates
	g_strctServerCycle.m_iMachineState = 0;
	fnStimulusServerToKofikoParadigm('FlipOFF',m_fLastFlipTime);
end

return;

% ---------------------------------------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------------------------------------


function fnKeepDisplayingMovingBar()
global g_strctPTB g_strctDraw g_strctServerCycle 

fCurrTime  = GetSecs();
aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
    g_strctDraw.m_strctTrial.m_pt2iFixationSpot + g_strctDraw.m_strctTrial.m_fFixationSizePix];
% check if there are more frames to display

if g_strctDraw.m_iFrameCounter >= g_strctDraw.m_strctTrial.numFrames; % we shouldn't be able to get larger than this number, but just in case
	
	% Clear the screen
	Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
	%Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
	Screen('FillArc',g_strctPTB.m_hWindow,g_strctDraw.m_strctTrial.m_iFixationColor, aiFixationRect,0,360);
	
	if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
		Screen('FillRect',g_strctPTB.m_hWindow,[0 0 0], ...
			[g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
			g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
			g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
	end	
	
	g_strctServerCycle.m_fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow);
	% Set the machine to the wait off period and send the flip off command
	
	g_strctServerCycle.m_iMachineState = 3;
	fnStimulusServerToKofikoParadigm('FlipOFF',g_strctServerCycle.m_fLastFlipTime);

else
	% Display the next frame of the bar
	g_strctDraw.m_iFrameCounter = g_strctDraw.m_iFrameCounter + 1;
	fnStimulusServerToKofikoParadigm('UpdateFrameCounter',g_strctDraw.m_iFrameCounter)
	Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
	
	if ~g_strctDraw.m_strctTrial.m_bBlur
		for iNumBars = 1:g_strctDraw.m_strctTrial.m_iNumberOfBars
			Screen('FillPoly',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_aiStimColor,...
				 horzcat(g_strctDraw.m_strctTrial.coordinatesX(1:4,g_strctDraw.m_iFrameCounter,iNumBars),g_strctDraw.m_strctTrial.coordinatesY(1:4,g_strctDraw.m_iFrameCounter,iNumBars)),0)
		end
	else
		for iNumOfBars = 1:g_strctDraw.m_strctTrial.m_iNumberOfBars
			for iBlurStep = 1:g_strctDraw.m_strctTrial.numberBlurSteps
				Screen('FillPoly',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.blurStepHolder(:,iBlurStep),...%,g_strctDraw.m_strctTrial.blurStepHolder(2,iBlurStep),g_strctDraw.m_strctTrial.blurStepHolder(3,iBlurStep)] ,...
					horzcat(g_strctDraw.m_strctTrial.coordinatesX(1:4,g_strctDraw.m_iFrameCounter,iNumOfBars,iBlurStep),...
					g_strctDraw.m_strctTrial.coordinatesY(1:4,g_strctDraw.m_iFrameCounter,iNumOfBars,iBlurStep)),0)
			end
		
		end
	end
	% Fixation point last so it's on top
	Screen('FillArc',g_strctPTB.m_hWindow,g_strctDraw.m_strctTrial.m_iFixationColor, aiFixationRect,0,360);
	%Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
	if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
		Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], ...
			[g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
			g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
			g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
	end	
		
	m_fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow); % Time onset of trial, blocking
		
	% Update information
	g_strctDraw.m_a2fFrameFlipTS(1,g_strctDraw.m_iFrameCounter) = ...
		g_strctDraw.m_a2fFrameFlipTS(1,1) + (g_strctDraw.m_iFrameCounter*(1000/g_strctPTB.m_iRefreshRate));   % How long has it been since we started this presentation, estimated
	g_strctDraw.m_a2fFrameFlipTS(2,g_strctDraw.m_iFrameCounter) = m_fLastFlipTime; % What is the actual time, so we can compare with the estimated if necessary
	
end
return;

% ---------------------------------------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------------------------------------


function fnColorTuningFunction()

global g_strctDraw g_strctPTB g_strctServerCycle
fCurrTime  = GetSecs();

% Show a moving bar using the PTB draw functions
% Get the trial parameters from the imported struct
%ahTexturePointers = g_strctDraw.m_strctTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer;
aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
    g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];
g_strctDraw.m_iFrameCounter = 1;

% Do the actual drawing

Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);


for iNumOfBars = 1:g_strctDraw.m_strctTrial.m_iNumberOfBars
	Screen('FillPoly',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_aiStimColor,...
		 horzcat(g_strctDraw.m_strctTrial.coordinatesX(1:4,1,iNumOfBars),g_strctDraw.m_strctTrial.coordinatesY(1:4,1,iNumOfBars)),0)
end




	 %Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctPTB.m_hOffscreenWindow, g_strctPTB.m_hoffRect, ...
%	[], g_strctDraw.m_acImages{1,g_strctDraw.m_strctTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer}.commandParameters.rotationAngle)
	
% Fixation point last so it's on top

Screen('FillArc',g_strctPTB.m_hWindow,g_strctDraw.m_strctTrial.m_iFixationColor, aiFixationRect,0,360);
if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
	Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], ...
		[g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
		g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
		g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
end
% Update the color lookup table for bits ++
% takes 3-10 ms. Ouch.


BitsPlusSetClut(g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.Clut)

m_fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow); % Time onset of trial, blocking 



fnStimulusServerToKofikoParadigm('FlipON',fCurrTime,g_strctDraw.m_strctTrial.m_iStimulusIndex); 

% Update the machine
if g_strctDraw.m_strctTrial.numFrames > 1
	% Go and display the rest of the frames in this trial
	g_strctServerCycle.m_iMachineState = 12;
	
	g_strctDraw.m_a2fFrameFlipTS = NaN*ones(2,g_strctDraw.m_strctTrial.numFrames); % allocate the trial timing array
	g_strctDraw.m_a2fFrameFlipTS(1,g_strctDraw.m_iFrameCounter) = m_fLastFlipTime;   % First frame
	g_strctDraw.m_a2fFrameFlipTS(2,g_strctDraw.m_iFrameCounter) = m_fLastFlipTime; % Actual Flip Time
else
	% Do nothing? Kofiko will supply the next frame when it updates
	g_strctServerCycle.m_iMachineState = 0;
	fnStimulusServerToKofikoParadigm('FlipOFF',m_fLastFlipTime);
end

return;

% ---------------------------------------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------------------------------------

function fnDisplayGabor()
global g_strctPTB g_strctDraw g_strctServerCycle 
fCurrTime  = GetSecs();

g_strctDraw.m_iFrameCounter = 1;


Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor );


% g_strctServerCycle.m_hGabortex = Screen('MakeTexture', g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.gaborArray);

Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctServerCycle.m_hGabortex, [], g_strctDraw.m_strctTrial.m_afDestRectangle, g_strctDraw.m_strctTrial.m_fRotationAngle, [], [], g_strctDraw.m_strctTrial.m_aiStimulusColor, [],...
 kPsychDontDoRotation, [g_strctDraw.m_strctTrial.m_fGaborPhase+180, g_strctDraw.m_strctTrial.m_iGaborFreq, g_strctDraw.m_strctTrial.m_iSigma, g_strctDraw.m_strctTrial.m_iContrast,...
g_strctDraw.m_strctTrial.AspectRatio, 0, 0, 0]);


m_fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow); % Time onset of trial, blocking 



fnStimulusServerToKofikoParadigm('FlipON',fCurrTime,g_strctDraw.m_strctTrial.m_iStimulusIndex); 


if g_strctDraw.m_strctTrial.numFrames > 1
	% Go and display the rest of the frames in this trial
	g_strctServerCycle.m_iMachineState = 15;
	
	g_strctDraw.m_a2fFrameFlipTS = NaN*ones(2,g_strctDraw.m_strctTrial.numFrames); % allocate the trial timing array
	g_strctDraw.m_a2fFrameFlipTS(1,g_strctDraw.m_iFrameCounter) = m_fLastFlipTime;   % First frame
	g_strctDraw.m_a2fFrameFlipTS(2,g_strctDraw.m_iFrameCounter) = m_fLastFlipTime; % Actual Flip Time
else
	% Do nothing? Kofiko will supply the next frame when it updates
	g_strctServerCycle.m_iMachineState = 3;

	fnStimulusServerToKofikoParadigm('FlipOFF',m_fLastFlipTime);
	
end

return;

% --------------------------------------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------------------------------------

function fnDisplayMovingDots()
global g_strctPTB g_strctDraw g_strctServerCycle 



fCurrTime  = GetSecs();
g_strctDraw.m_iFrameCounter = 1;
%fnStimulusServerToKofikoParadigm('UpdateFrameCounter',g_strctDraw.m_iFrameCounter); % Update the control computer's frame counter

aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
    g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];

Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor ); % This will blank the screen if the trial is over


g_strctDraw.m_strctTrial.m_aiRect = zeros(4,g_strctDraw.m_strctTrial.NumberOfDots);
% reallign the rect so it is in the left, top, right, bottom order required by the filloval command
%{
for iNumOfDots = 1:g_strctDraw.m_strctTrial.NumberOfDots
	% Reshape the coordinates. Draw oval requires that they be in left, top, right, bottom order
	% This is sloppy since we're still piggybacking on the rectangle code
	g_strctDraw.m_strctTrial.m_aiRect(1,iNumOfDots) =  min(g_strctDraw.m_strctTrial.coordinatesX(1,g_strctDraw.m_iFrameCounter,iNumOfDots),g_strctDraw.m_strctTrial.coordinatesX(3,g_strctDraw.m_iFrameCounter,iNumOfDots));
	g_strctDraw.m_strctTrial.m_aiRect(2,iNumOfDots) =  min(g_strctDraw.m_strctTrial.coordinatesY(1,g_strctDraw.m_iFrameCounter,iNumOfDots),g_strctDraw.m_strctTrial.coordinatesY(2,g_strctDraw.m_iFrameCounter,iNumOfDots));
	g_strctDraw.m_strctTrial.m_aiRect(3,iNumOfDots) =  max(g_strctDraw.m_strctTrial.coordinatesX(1,g_strctDraw.m_iFrameCounter,iNumOfDots),g_strctDraw.m_strctTrial.coordinatesX(3,g_strctDraw.m_iFrameCounter,iNumOfDots));
	g_strctDraw.m_strctTrial.m_aiRect(4,iNumOfDots) =  max(g_strctDraw.m_strctTrial.coordinatesY(1,g_strctDraw.m_iFrameCounter,iNumOfDots),g_strctDraw.m_strctTrial.coordinatesY(2,g_strctDraw.m_iFrameCounter,iNumOfDots));

end
	%}




	Screen('FillOval', g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_aiStimColor,  squeeze([g_strctDraw.m_strctTrial.m_aiCoordinates(1, g_strctDraw.m_iFrameCounter, :),... left
																				 g_strctDraw.m_strctTrial.m_aiCoordinates(2, g_strctDraw.m_iFrameCounter, :),... top
																				 g_strctDraw.m_strctTrial.m_aiCoordinates(3, g_strctDraw.m_iFrameCounter, :),... right
																				 g_strctDraw.m_strctTrial.m_aiCoordinates(4, g_strctDraw.m_iFrameCounter, :)])); % bottom

												
%{ 
Backup
Screen('FillOval', g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_aiStimColor, squeeze([g_strctDraw.m_strctTrial.coordinatesX(1, g_strctDraw.m_iFrameCounter, :),... left
																				 g_strctDraw.m_strctTrial.coordinatesY(1, g_strctDraw.m_iFrameCounter, :),... top
																				 g_strctDraw.m_strctTrial.coordinatesX(3, g_strctDraw.m_iFrameCounter, :),... right
																				 g_strctDraw.m_strctTrial.coordinatesY(2, g_strctDraw.m_iFrameCounter, :)])); % bottom
%}
												
																				 
g_strctServerCycle.m_fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow);
fnStimulusServerToKofikoParadigm('FlipON',fCurrTime,g_strctDraw.m_strctTrial.m_iStimulusIndex); 
		
if g_strctDraw.m_strctTrial.numFrames > 1
	g_strctServerCycle.m_iMachineState = 17;
else 
	g_strctServerCycle.m_iMachineState = 0;
	fnStimulusServerToKofikoParadigm('FlipOFF',g_strctServerCycle.m_fLastFlipTime);
	fnStimulusServerToKofikoParadigm('TrialFinished');
end
	
	
return;			

															 
% --------------------------------------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------------------------------------																				 

function fnKeepDisplayingMovingDots()
global g_strctPTB g_strctDraw g_strctServerCycle 


fCurrTime  = GetSecs();




aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
    g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];


if g_strctDraw.m_iFrameCounter < g_strctDraw.m_strctTrial.numFrames
	 % at least 1 more frame in this trial, continue displaying
	g_strctDraw.m_iFrameCounter = g_strctDraw.m_iFrameCounter  + 1;
	fnStimulusServerToKofikoParadigm('UpdateFrameCounter',g_strctDraw.m_iFrameCounter); % Update the control computer's frame counter


	% This next part is a bit funky, as we're using the rectangle creation math, which creates 4 xy coordinates, to populate 
	% the filloval array, which only needs 2 x and 2 y coordinates (the bounds of the oval)

	% Per the filloval help: Instead of filling one oval, you can also specify a list of multiple ovals to be
	% filled - this is much faster when you need to draw many ovals per frame. To fill
	% n ovals, provide "rect" as a 4 rows by n columns matrix, each column specifying
	% one oval, e.g., rect(1,5)=left border of 5th oval, rect(2,5)=top border of 5th
	% oval, rect(3,5)=right border of 5th oval, rect(4,5)=bottom border of 5th oval.
	% If the ovals should have different colors, then provide "color" as a 3 or 4 row
	% by n column matrix, the i'th column specifiying the color of the i'th oval.

	g_strctDraw.m_strctTrial.m_aiRect = zeros(4,g_strctDraw.m_strctTrial.NumberOfDots);
	%{
for iNumOfDots = 1:g_strctDraw.m_strctTrial.NumberOfDots
	% Reshape the coordinates. Draw oval requires that they be in left, top, right, bottom order
	% This is sloppy since we're still piggybacking on the rectangle code
	g_strctDraw.m_strctTrial.m_aiRect(1,iNumOfDots) =  min(g_strctDraw.m_strctTrial.coordinatesX(1,g_strctDraw.m_iFrameCounter,iNumOfDots),g_strctDraw.m_strctTrial.coordinatesX(3,g_strctDraw.m_iFrameCounter,iNumOfDots));
	g_strctDraw.m_strctTrial.m_aiRect(2,iNumOfDots) =  min(g_strctDraw.m_strctTrial.coordinatesY(1,g_strctDraw.m_iFrameCounter,iNumOfDots),g_strctDraw.m_strctTrial.coordinatesY(2,g_strctDraw.m_iFrameCounter,iNumOfDots));
	g_strctDraw.m_strctTrial.m_aiRect(3,iNumOfDots) =  max(g_strctDraw.m_strctTrial.coordinatesX(1,g_strctDraw.m_iFrameCounter,iNumOfDots),g_strctDraw.m_strctTrial.coordinatesX(3,g_strctDraw.m_iFrameCounter,iNumOfDots));
	g_strctDraw.m_strctTrial.m_aiRect(4,iNumOfDots) =  max(g_strctDraw.m_strctTrial.coordinatesY(1,g_strctDraw.m_iFrameCounter,iNumOfDots),g_strctDraw.m_strctTrial.coordinatesY(2,g_strctDraw.m_iFrameCounter,iNumOfDots));

end
%}
	% Rectangle coordinates are filled in the following order: top left, bottom left, bottom right, top right
	

	Screen('FillOval', g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_aiStimColor,  squeeze([g_strctDraw.m_strctTrial.m_aiCoordinates(1, g_strctDraw.m_iFrameCounter, :),... left
																				 g_strctDraw.m_strctTrial.m_aiCoordinates(2, g_strctDraw.m_iFrameCounter, :),... top
																				 g_strctDraw.m_strctTrial.m_aiCoordinates(3, g_strctDraw.m_iFrameCounter, :),... right
																				 g_strctDraw.m_strctTrial.m_aiCoordinates(4, g_strctDraw.m_iFrameCounter, :)])); % bottom

			
	
	
	%{
	Screen('FillOval', g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_aiStimColor,  squeeze([g_strctDraw.m_strctTrial.coordinatesX(1, g_strctDraw.m_iFrameCounter, :),... left
																				 g_strctDraw.m_strctTrial.coordinatesY(1, g_strctDraw.m_iFrameCounter, :),... top
																				 g_strctDraw.m_strctTrial.coordinatesX(3 ,g_strctDraw.m_iFrameCounter, :),... right
																				 g_strctDraw.m_strctTrial.coordinatesY(2 ,g_strctDraw.m_iFrameCounter, :)])); % bottom
	
	%}
 % Time onset of trial, blocking 
	g_strctServerCycle.m_fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow);





else 
	% We just showed the last frame, end the trial
	g_strctServerCycle.m_iMachineState = 3;
	g_strctServerCycle.m_fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow);
	fnStimulusServerToKofikoParadigm('FlipOFF',g_strctServerCycle.m_fLastFlipTime);
	return;
end


return;


return;



