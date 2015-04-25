function fnParadigmPassiveFixationDrawCycleNew(acInputFromKofiko)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)


global g_strctPTB g_strctDraw g_strctServerCycle 

fCurrTime = GetSecs();

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
            Screen(g_strctPTB.m_hWindow,'FillRect',0);
            fnFlipWrapper(g_strctPTB.m_hWindow);
            
            fnStimulusServerClearTextureMemory();
            [g_strctDraw.m_ahHandles,g_strctDraw.m_a2iTextureSize,...
                g_strctDraw.m_abIsMovie,g_strctDraw.m_aiApproxNumFrames,Dummy, g_strctDraw.m_acImages] = fnInitializeTexturesAux(acFileNames,false,true);
            
            fnStimulusServerToKofikoParadigm('AllImagesLoaded');
            g_strctServerCycle.m_iMachineState = 0;
        case 'ShowTrial'
            g_strctDraw.m_strctTrial = acInputFromKofiko{2};
			switch g_strctDraw.m_strctTrial.m_strctMedia.m_strMediaType
                case 'Image'
                    if g_strctPTB.m_bInStereoMode
                        % If we are already in stereo mode and a monocular image is to be presented, just duplicate the
                        % image across the two channels....
                        g_strctDraw.m_strctTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer = ones(1,2) * g_strctDraw.m_strctTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer;
                        g_strctServerCycle.m_iMachineState = 6;
                    else
                        g_strctServerCycle.m_iMachineState = 1;
                    end
                case 'Movie'
                    if g_strctPTB.m_bInStereoMode
                        % If we are already in stereo mode and a monocular image is to be presented, just duplicate the
                        % image across the two channels....
                        g_strctDraw.m_strctTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer = ones(1,2) * g_strctDraw.m_strctTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer;
                        g_strctServerCycle.m_iMachineState = 9;
                    else
                        g_strctServerCycle.m_iMachineState = 4;
                    end
                case 'StereoImage'
                    g_strctServerCycle.m_iMachineState = 6;
                case 'StereoMovie'
                    g_strctServerCycle.m_iMachineState = 9;
                otherwise
                    assert(false);
            end
    end
end;

switch g_strctServerCycle.m_iMachineState
    case 0
        % Do nothing
    case 1
        fnDisplayMonocularImage();
    case 2
        fnWaitMonocularImageONPeriod();
    case 3
        fnWaitMonocularImageOFFPeriod();
    case 4
        fnDisplayMonocularMovie();
    case 5
        fnKeepPlayingMonocularMovie();
    case 6
        fnDisplayStereoImage();
    case 7
        fnWaitStereoImageONPeriod();
    case 8
        fnWaitStereoImageOFFPeriod();
    case 9
        fnDisplayStereoMovie();
    case 10
        fnKeepPlayingStereoMovie();
end;

return;


function fnDisplayMonocularImage()
global g_strctDraw g_strctPTB g_strctServerCycle
fCurrTime  = GetSecs();

Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
    g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];

hTexturePointer = g_strctDraw.m_strctTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer(1);
aiTextureSize = g_strctDraw.m_a2iTextureSize(:, hTexturePointer);
aiStimulusRect = fnComputeStimulusRectFTS(g_strctDraw.m_strctTrial.m_fStimulusSizePix,aiTextureSize, ...
    g_strctDraw.m_strctTrial.m_pt2fStimulusPos);



if g_strctDraw.m_strctTrial.m_bNoiseOverlay
    a2fImage = g_strctDraw.m_acImages{hTexturePointer};
    if size(a2fImage,3) == 3
        % Modify the image....
        I = a2fImage(:,:,1);
        a2bMask = I == 255;
        [a2fX,a2fY] = meshgrid(linspace(1,  size(g_strctDraw.m_strctTrial.m_a2fNoisePattern,2), size(a2fImage,2)),...
            linspace(1,  size(g_strctDraw.m_strctTrial.m_a2fNoisePattern,1), size(a2fImage,1)));
        a2fNoiseResamples = fnFastInterp2(g_strctDraw.m_strctTrial.m_a2fNoisePattern, a2fX(:),a2fY(:));
        I(a2bMask) = a2fNoiseResamples(a2bMask)*255;
        a2fImage = I;
    end
    
    hImageID = Screen('MakeTexture', g_strctPTB.m_hWindow,  a2fImage);
    Screen('DrawTexture', g_strctPTB.m_hWindow, hImageID,[],aiStimulusRect, g_strctDraw.m_strctTrial.m_fRotationAngle);
    Screen('Close',hImageID);
    
else
    Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctDraw.m_ahHandles(hTexturePointer),[],aiStimulusRect, g_strctDraw.m_strctTrial.m_fRotationAngle);
end

if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
    Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], ...
        [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
        g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
        g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
end

% Draw Fixation spot
Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);

g_strctServerCycle.m_fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow); % This would block the server until the next flip.
fnStimulusServerToKofikoParadigm('FlipON',g_strctServerCycle.m_fLastFlipTime,g_strctDraw.m_strctTrial.m_iStimulusIndex);
g_strctServerCycle.m_iMachineState = 2;
return;


function fnWaitMonocularImageONPeriod()
global g_strctDraw g_strctPTB g_strctServerCycle
fCurrTime  = GetSecs();

if (fCurrTime - g_strctServerCycle.m_fLastFlipTime) > g_strctDraw.m_strctTrial.m_fStimulusON_MS/1e3 - (0.2 * (1/g_strctPTB.m_iRefreshRate) )
    % Turn stimulus off
    if g_strctDraw.m_strctTrial.m_fStimulusOFF_MS > 0
        Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
        
        aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
            g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];
        
        Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
        
        if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
            
            Screen('FillRect',g_strctPTB.m_hWindow,[0 0 0], ...
                [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
                g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
                g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
        end
        
        g_strctServerCycle.m_fLastFlipTime = fnFlipWrapper( g_strctPTB.m_hWindow); % Block.
        fnStimulusServerToKofikoParadigm('FlipOFF',g_strctServerCycle.m_fLastFlipTime);
        g_strctServerCycle.m_iMachineState = 3;
    else
        fnStimulusServerToKofikoParadigm('TrialFinished');
        g_strctServerCycle.m_iMachineState = 0;
    end
end

return;


function fnWaitMonocularImageOFFPeriod
global g_strctDraw g_strctPTB g_strctServerCycle
fCurrTime  = GetSecs();

if (fCurrTime - g_strctServerCycle.m_fLastFlipTime) > ...
        (g_strctDraw.m_strctTrial.m_fStimulusOFF_MS)/1e3 - (0.2 * (1/g_strctPTB.m_iRefreshRate) )
    fnStimulusServerToKofikoParadigm('TrialFinished');
    g_strctServerCycle.m_iMachineState = 0;
end
return;

function fnDisplayMonocularMovie()
global g_strctDraw g_strctPTB g_strctServerCycle
fCurrTime  = GetSecs();
hTexturePointer = g_strctDraw.m_strctTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer(1);

% Start playing movie
Screen('PlayMovie', g_strctDraw.m_ahHandles(hTexturePointer), 1,0,1);
Screen('SetMovieTimeIndex',g_strctDraw.m_ahHandles(hTexturePointer),0);
g_strctDraw.m_fMovieOnset = GetSecs();
% Show first frame and go to state 5

Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
    g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];

aiTextureSize = g_strctDraw.m_a2iTextureSize(:, hTexturePointer);
g_strctDraw.m_aiStimulusRect = fnComputeStimulusRectFTS(g_strctDraw.m_strctTrial.m_fStimulusSizePix,aiTextureSize, ...
    g_strctDraw.m_strctTrial.m_pt2fStimulusPos);


[hFrameTexture, fTimeToFlip] = Screen('GetMovieImage', g_strctPTB.m_hWindow, ...
    g_strctDraw.m_ahHandles(hTexturePointer),1);

% Assume there is at least one frame in this movie... otherwise this
% will crash...

Screen('DrawTexture', g_strctPTB.m_hWindow, hFrameTexture,[],g_strctDraw.m_aiStimulusRect, g_strctDraw.m_strctTrial.m_fRotationAngle);
Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);


if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
    Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], ...
        [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
        g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
        g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
end


fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow); % This would block the server until the next flip.
Screen('Close', hFrameTexture);
fnStimulusServerToKofikoParadigm('FlipON',g_strctDraw.m_fMovieOnset,g_strctDraw.m_strctTrial.m_iStimulusIndex);

iApproxNumFrames = g_strctDraw.m_aiApproxNumFrames(hTexturePointer);
g_strctDraw.m_iFrameCounter = 1;
g_strctDraw.m_a2fFrameFlipTS = NaN*ones(2,iApproxNumFrames);
g_strctDraw.m_a2fFrameFlipTS(1,g_strctDraw.m_iFrameCounter) = fTimeToFlip;   % Relative to movie onset
g_strctDraw.m_a2fFrameFlipTS(2,g_strctDraw.m_iFrameCounter) = fLastFlipTime; % Actual Flip Time

g_strctServerCycle.m_iMachineState = 5;
return;



function fnKeepPlayingMonocularMovie()
global g_strctDraw g_strctPTB g_strctServerCycle
fCurrTime  = GetSecs();

% Movie is playing... Fetch frame and display it
hTexturePointer = g_strctDraw.m_strctTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer(1);

[hFrameTexture, fTimeToFlip] = Screen('GetMovieImage', g_strctPTB.m_hWindow, ...
    g_strctDraw.m_ahHandles(hTexturePointer),1);

if hFrameTexture == -1
    % End of movie
    % Flip background color and fixation spot for one frame to
    % clear the last frame
    
    Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
    aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
        g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];
    
    Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
    fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow);  % Block (!)
    
    g_strctDraw.m_a2fFrameFlipTS = g_strctDraw.m_a2fFrameFlipTS(:,1:g_strctDraw.m_iFrameCounter-1);
    fnStimulusServerToKofikoParadigm('TrialFinished',g_strctDraw.m_a2fFrameFlipTS,fLastFlipTime );
    g_strctServerCycle.m_iMachineState = 0;
else
    % Still have frames
%     if fTimeToFlip == g_strctDraw.m_a2fFrameFlipTS(1,g_strctDraw.m_iFrameCounter)
%         % This frame HAS been displayed yet.
%         % Don't do anything. (it should still be on the screen...)
%         Screen('Close', hFrameTexture);
%         
%     else
        Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
        aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
            g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];
        
        Screen('DrawTexture', g_strctPTB.m_hWindow, hFrameTexture,[],g_strctDraw.m_aiStimulusRect, g_strctDraw.m_strctTrial.m_fRotationAngle);
        Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);

        if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
            Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], ...
                [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
                g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
                g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
        end
        
        
        fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow, g_strctDraw.m_fMovieOnset+fTimeToFlip);  % Block (!)
        Screen('Close', hFrameTexture);
        
        g_strctDraw.m_iFrameCounter = g_strctDraw.m_iFrameCounter + 1;
        g_strctDraw.m_a2fFrameFlipTS(1,g_strctDraw.m_iFrameCounter) = fTimeToFlip;   % Relative to movie onset
        g_strctDraw.m_a2fFrameFlipTS(2,g_strctDraw.m_iFrameCounter) = fLastFlipTime; % Actual Flip Time
%     end
end
return;




function fnDisplayStereoImage()
global g_strctDraw g_strctPTB g_strctServerCycle
fCurrTime  = GetSecs();


aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
    g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];

ahTexturePointers = g_strctDraw.m_strctTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer; % LeftEye, RightEye

aiTextureSizeLeft = g_strctDraw.m_a2iTextureSize(:, ahTexturePointers(1));
aiTextureSizeRight = g_strctDraw.m_a2iTextureSize(:, ahTexturePointers(2));
aiStimulusRectLeft = fnComputeStimulusRectFTS(g_strctDraw.m_strctTrial.m_fStimulusSizePix,aiTextureSizeLeft, g_strctDraw.m_strctTrial.m_pt2fStimulusPos);
aiStimulusRectRight = fnComputeStimulusRectFTS(g_strctDraw.m_strctTrial.m_fStimulusSizePix,aiTextureSizeRight, g_strctDraw.m_strctTrial.m_pt2fStimulusPos);
a2iStimuliRect =[ aiStimulusRectLeft;aiStimulusRectRight];
%{
if g_strctDraw.m_strctTrial.m_bNoiseOverlay
    % NOT supported under stereo....
    %}


for iBuffer=0:1
    Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,iBuffer); % Left Eye
    
    
    Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
    Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,iBuffer); % Left Eye
    
    Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,iBuffer); % Left Eye
    
    Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctDraw.m_ahHandles(ahTexturePointers(1+iBuffer)),[],a2iStimuliRect(iBuffer+1,:), g_strctDraw.m_strctTrial.m_fRotationAngle);

    if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
        if iBuffer == 0
            Screen('FillRect',g_strctPTB.m_hWindow,[0 0 255], ...
                [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
                g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix-10 ...
                g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix/2 g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix]);
        else
            Screen('FillRect',g_strctPTB.m_hWindow,[255  0 0], ...
                [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix/2 ...
                g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix-10 ...
                g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix]);
            
        end
        
        Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], ...
            [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
            g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
            g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
    end
    
    Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,iBuffer); % Left Eye
    
    % Draw Fixation spot
    Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
end
fprintf('\n');
g_strctServerCycle.m_fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow); % This would block the server until the next flip.
fnStimulusServerToKofikoParadigm('FlipON',g_strctServerCycle.m_fLastFlipTime,g_strctDraw.m_strctTrial.m_iStimulusIndex);
g_strctServerCycle.m_iMachineState = 7;
return;

function fnWaitStereoImageONPeriod()
global g_strctDraw g_strctPTB g_strctServerCycle
fCurrTime  = GetSecs();

if (fCurrTime - g_strctServerCycle.m_fLastFlipTime) > g_strctDraw.m_strctTrial.m_fStimulusON_MS/1e3 - (0.2 * (1/g_strctPTB.m_iRefreshRate) )
    % Turn stimulus off
    if g_strctDraw.m_strctTrial.m_fStimulusOFF_MS > 0
        
        for iBufferIter=0:1
            Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,iBufferIter);
            
            Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
            
            aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
                g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];
            
            Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
            
            if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
                
                Screen('FillRect',g_strctPTB.m_hWindow,[0 0 0], ...
                    [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
                    g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
                    g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
            end
        end
        g_strctServerCycle.m_fLastFlipTime = fnFlipWrapper( g_strctPTB.m_hWindow); % Block.
        fnStimulusServerToKofikoParadigm('FlipOFF',g_strctServerCycle.m_fLastFlipTime);
        
        g_strctServerCycle.m_iMachineState = 8;
    else
        fnStimulusServerToKofikoParadigm('TrialFinished');
        g_strctServerCycle.m_iMachineState = 0;
    end
end
return;


function fnWaitStereoImageOFFPeriod()
global g_strctDraw g_strctPTB g_strctServerCycle
fCurrTime  = GetSecs();

if (fCurrTime - g_strctServerCycle.m_fLastFlipTime) > ...
        (g_strctDraw.m_strctTrial.m_fStimulusOFF_MS)/1e3 - (0.2 * (1/g_strctPTB.m_iRefreshRate) )
    fnStimulusServerToKofikoParadigm('TrialFinished');
    g_strctServerCycle.m_iMachineState = 0;
end

return;




function  fnDisplayStereoMovie()
global g_strctDraw g_strctPTB g_strctServerCycle
fCurrTime  = GetSecs();
ahTexturePointers = g_strctDraw.m_strctTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer;

% Start playing movie
Screen('PlayMovie', g_strctDraw.m_ahHandles(ahTexturePointers(1)), 1,0,1);
Screen('SetMovieTimeIndex',g_strctDraw.m_ahHandles(ahTexturePointers(1)),0);
if ahTexturePointers(1) ~= ahTexturePointers(2)
    Screen('PlayMovie', g_strctDraw.m_ahHandles(ahTexturePointers(2)), 1,0,1);
    Screen('SetMovieTimeIndex',g_strctDraw.m_ahHandles(ahTexturePointers(2)),0);
end
g_strctDraw.m_fMovieOnset = GetSecs();
% Show first frame and go to state 10
for iBufferIter=0:1
    Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,iBufferIter);
    
    Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
    aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
        g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];
    
    aiTextureSize = g_strctDraw.m_a2iTextureSize(:, ahTexturePointers(iBufferIter+1));
    g_strctDraw.m_a2iStimulusRect(iBufferIter+1,:) = fnComputeStimulusRectFTS(g_strctDraw.m_strctTrial.m_fStimulusSizePix,aiTextureSize,g_strctDraw.m_strctTrial.m_pt2fStimulusPos);
    [hFrameTexture, fTimeToFlip] = Screen('GetMovieImage', g_strctPTB.m_hWindow, g_strctDraw.m_ahHandles(ahTexturePointers(iBufferIter+1)),1);
    % Assume there is at least one frame in this movie... otherwise this
    % will crash...
    Screen('DrawTexture', g_strctPTB.m_hWindow, hFrameTexture,[],g_strctDraw.m_a2iStimulusRect(iBufferIter+1,:), g_strctDraw.m_strctTrial.m_fRotationAngle);
    Screen('Close', hFrameTexture);
    % Draw fixation spot
    Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
    
    
  if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
        if iBufferIter == 0
            Screen('FillRect',g_strctPTB.m_hWindow,[0 0 255], ...
                [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
                g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix-10 ...
                g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix/2 g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix]);
        else
            Screen('FillRect',g_strctPTB.m_hWindow,[255  0 0], ...
                [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix/2 ...
                g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix-10 ...
                g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix]);
            
        end
        
        Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], ...
            [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
            g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
            g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
    end    
    
end



  



fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow); % This would block the server until the next flip.

fnStimulusServerToKofikoParadigm('FlipON',g_strctDraw.m_fMovieOnset,g_strctDraw.m_strctTrial.m_iStimulusIndex);

iApproxNumFrames = min(g_strctDraw.m_aiApproxNumFrames(ahTexturePointers)); % Shorter movie set the length!
g_strctDraw.m_iFrameCounter = 1;
g_strctDraw.m_a2fFrameFlipTS = NaN*ones(2,iApproxNumFrames);
g_strctDraw.m_a2fFrameFlipTS(1,g_strctDraw.m_iFrameCounter) = fTimeToFlip;   % Relative to movie onset
g_strctDraw.m_a2fFrameFlipTS(2,g_strctDraw.m_iFrameCounter) = fLastFlipTime; % Actual Flip Time


g_strctServerCycle.m_iMachineState = 10;
return;




function fnKeepPlayingStereoMovie()
global g_strctDraw g_strctPTB g_strctServerCycle
fCurrTime  = GetSecs();

% Movie is playing... Fetch frame and display it
ahTexturePointers = g_strctDraw.m_strctTrial.m_strctMedia.m_aiMediaToHandleIndexInBuffer;
for iBufferIter=0:1
    Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,iBufferIter);
    
    [hFrameTexture, fTimeToFlip] = Screen('GetMovieImage', g_strctPTB.m_hWindow, g_strctDraw.m_ahHandles(ahTexturePointers(iBufferIter+1)),1);
    
    if hFrameTexture == -1
        % End of movie
        % Flip background color and fixation spot for one frame to
        % clear the last frame
        for iIter=0:1
            Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,iIter);
            Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
            aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
                g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];
            
            Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
        end
        fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow);  % Block (!)
        g_strctDraw.m_a2fFrameFlipTS = g_strctDraw.m_a2fFrameFlipTS(:,1:g_strctDraw.m_iFrameCounter-1);
        fnStimulusServerToKofikoParadigm('TrialFinished',g_strctDraw.m_a2fFrameFlipTS,fLastFlipTime );
        g_strctServerCycle.m_iMachineState = 0;
        return;
    else
        % Still have frames
%         if fTimeToFlip == g_strctDraw.m_a2fFrameFlipTS(1,g_strctDraw.m_iFrameCounter)
%             % This frame HAS been displayed yet.
%             % Don't do anything. (it should still be on the screen...)
%             Screen('Close', hFrameTexture);
%         else
            Screen('SelectStereoDrawBuffer', g_strctPTB.m_hWindow,iBufferIter);
  
            Screen('FillRect',g_strctPTB.m_hWindow, g_strctDraw.m_strctTrial.m_afBackgroundColor);
            aiFixationRect = [g_strctDraw.m_strctTrial.m_pt2iFixationSpot-g_strctDraw.m_strctTrial.m_fFixationSizePix,...
                g_strctDraw.m_strctTrial.m_pt2iFixationSpot+g_strctDraw.m_strctTrial.m_fFixationSizePix];
            
            Screen('DrawTexture', g_strctPTB.m_hWindow, hFrameTexture,[],g_strctDraw.m_a2iStimulusRect(iBufferIter+1,:), g_strctDraw.m_strctTrial.m_fRotationAngle);
            Screen('FillArc',g_strctPTB.m_hWindow,[255 255 255], aiFixationRect,0,360);
            Screen('Close', hFrameTexture);
            
            
  if g_strctDraw.m_strctTrial.m_bShowPhotodiodeRect
        if iBufferIter == 0
            Screen('FillRect',g_strctPTB.m_hWindow,[0 0 255], ...
                [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
                g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix-10 ...
                g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix/2 g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix]);
        else
            Screen('FillRect',g_strctPTB.m_hWindow,[255  0 0], ...
                [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix/2 ...
                g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix-10 ...
                g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix]);
            
        end
        
        Screen('FillRect',g_strctPTB.m_hWindow,[255 255 255], ...
            [g_strctPTB.m_aiRect(3)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
            g_strctPTB.m_aiRect(4)-g_strctDraw.m_strctTrial.m_iPhotoDiodeWindowPix ...
            g_strctPTB.m_aiRect(3) g_strctPTB.m_aiRect(4)]);
    end            
            
            
%         end
    end
end

fLastFlipTime = fnFlipWrapper(g_strctPTB.m_hWindow, g_strctDraw.m_fMovieOnset+fTimeToFlip);  % Block (!)

g_strctDraw.m_iFrameCounter = g_strctDraw.m_iFrameCounter + 1;
g_strctDraw.m_a2fFrameFlipTS(1,g_strctDraw.m_iFrameCounter) = fTimeToFlip;   % Relative to movie onset
g_strctDraw.m_a2fFrameFlipTS(2,g_strctDraw.m_iFrameCounter) = fLastFlipTime; % Actual Flip Time

return;
