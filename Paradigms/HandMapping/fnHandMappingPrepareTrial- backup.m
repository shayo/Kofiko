function strctTrial = fnHandMappingPrepareTrial()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
global g_strctParadigm g_strctPTB
%fCurrTime = GetSecs;

% Give Kofiko something to chew on later
iNewStimulusIndex = 1;
strctTrial.m_strTrialType = g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(g_strctParadigm.m_iCurrentBlockIndexInOrderList).m_strBlockName;
strctTrial.m_iStimulusIndex = iNewStimulusIndex;
strctTrial.m_strctMedia = g_strctParadigm.m_strctDesign.m_astrctMedia(iNewStimulusIndex);
strctTrial.m_pt2iFixationSpot = g_strctParadigm.FixationSpotPix.Buffer(1,:,g_strctParadigm.FixationSpotPix.BufferIdx);
strctTrial.m_pt2fStimulusPos = g_strctParadigm.StimulusPos.Buffer(1,:,g_strctParadigm.StimulusPos.BufferIdx);
strctTrial.m_fFixationSizePix = g_strctParadigm.FixationSizePix.Buffer(1,:,g_strctParadigm.FixationSizePix.BufferIdx);
strctTrial.m_fGazeBoxPix = g_strctParadigm.GazeBoxPix.Buffer(1,:,g_strctParadigm.GazeBoxPix.BufferIdx);
strctTrial.m_fStimulusSizePix = g_strctParadigm.StimulusSizePix.Buffer(1,:,g_strctParadigm.StimulusSizePix.BufferIdx);
strctTrial.m_bShowPhotodiodeRect = g_strctParadigm.m_bShowPhotodiodeRect;
%strctTrial.m_bRandomStimulusPosition = g_strctParadigm.m_bRandomStimulusPosition;
strctTrial.m_bUseStrobes = 0; % Default to no strobewords




switch strctTrial.m_strTrialType
	case 'Plain Bar'
		[strctTrial] = fnPreparePlainBarTrial(g_strctParadigm, g_strctPTB, strctTrial);
	case 'Moving Bar'
		[strctTrial] = fnPrepareMovingBarTrial(g_strctParadigm, g_strctPTB, strctTrial);
	case 'Color Tuning Function'
		[g_strctParadigm, strctTrial] = fnPrepareColorTuningFunctionTrial(g_strctParadigm, g_strctPTB, strctTrial);
	case 'Orientation Tuning Function'
		[g_strctParadigm, strctTrial] = fnPrepareOrientationFunctionTrial(g_strctParadigm, g_strctPTB, strctTrial);
end

return;


% ------------------------------------------------------------------------------------------------------------------------

function [strctTrial] = fnPreparePlainBarTrial(g_strctParadigm, g_strctPTB, strctTrial)

strctTrial.Length = squeeze(g_strctParadigm.Length.Buffer(1,:,g_strctParadigm.Length.BufferIdx));
strctTrial.Width = squeeze(g_strctParadigm.Width.Buffer(1,:,g_strctParadigm.Width.BufferIdx));
strctTrial.fRotationAngle = squeeze(g_strctParadigm.Orientation.Buffer(1,:,g_strctParadigm.Orientation.BufferIdx));

strctTrial.m_fStimulusON_MS = 0;
strctTrial.m_fStimulusOFF_MS = 0;
strctTrial.numFrames = 1;

%Override the number of bars if this paradigm is selected. Might change this later.
strctTrial.NumberOfBars = 1;
g_strctParadigm.m_bRandomStimulusPosition = 0;

strctTrial.moveDistance = 0;

strctTrial.location_x(1) = g_strctParadigm.m_bCenterOfStimulus(1);
strctTrial.location_y(1) = g_strctParadigm.m_bCenterOfStimulus(2);
strctTrial.bar_rect(1,1:4) = [(g_strctParadigm.m_bCenterOfStimulus(1) - strctTrial.Length/2), (g_strctParadigm.m_bCenterOfStimulus(2) - strctTrial.Width/2), ...
    (g_strctParadigm.m_bCenterOfStimulus(1) + strctTrial.Length/2), (g_strctParadigm.m_bCenterOfStimulus(2) + strctTrial.Width/2)];

strctTrial.BarColor = [squeeze(g_strctParadigm.BarRed.Buffer(1,:,g_strctParadigm.BarRed.BufferIdx)), ...
    squeeze(g_strctParadigm.BarGreen.Buffer(1,:,g_strctParadigm.BarGreen.BufferIdx)),...
    squeeze(g_strctParadigm.BarBlue.Buffer(1,:,g_strctParadigm.BarBlue.BufferIdx))];
    
    % Background color
strctTrial.m_afBackgroundColor = [squeeze(g_strctParadigm.BackgroundRed.Buffer(1,:,g_strctParadigm.BackgroundRed.BufferIdx))...
    squeeze(g_strctParadigm.BackgroundGreen.Buffer(1,:,g_strctParadigm.BackgroundGreen.BufferIdx))...
    squeeze(g_strctParadigm.BackgroundBlue.Buffer(1,:,g_strctParadigm.BackgroundBlue.BufferIdx))];

	

[strctTrial.point1(1,1), strctTrial.point1(2,1)] = fnRotateAroundPoint(strctTrial.bar_rect(1,1),strctTrial.bar_rect(1,2),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
[strctTrial.point2(1,1), strctTrial.point2(2,1)] = fnRotateAroundPoint(strctTrial.bar_rect(1,1),strctTrial.bar_rect(1,4),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
[strctTrial.point3(1,1), strctTrial.point3(2,1)] = fnRotateAroundPoint(strctTrial.bar_rect(1,3),strctTrial.bar_rect(1,4),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
[strctTrial.point4(1,1), strctTrial.point4(2,1)] = fnRotateAroundPoint(strctTrial.bar_rect(1,3),strctTrial.bar_rect(1,2),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
[strctTrial.bar_starting_point(1,1),strctTrial.bar_starting_point(2,1)] = fnRotateAroundPoint(strctTrial.location_x(1),(strctTrial.location_y(1) - strctTrial.moveDistance/2),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
[strctTrial.bar_ending_point(1,1),strctTrial.bar_ending_point(2,1)] = fnRotateAroundPoint(strctTrial.location_x(1),(strctTrial.location_y(1) + strctTrial.moveDistance/2),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);

[strctTrial.coordinatesX, strctTrial.coordinatesY]  = deal(zeros(4, strctTrial.numFrames, strctTrial.NumberOfBars));

strctTrial.coordinatesX(1:4,:) = [strctTrial.point1(1), strctTrial.point2(1), strctTrial.point3(1),strctTrial.point4(1)];
strctTrial.coordinatesY(1:4,:) = [strctTrial.point1(2), strctTrial.point2(2), strctTrial.point3(2),strctTrial.point4(2)];
return;


% ------------------------------------------------------------------------------------------------------------------------
function [strctTrial] = fnPrepareMovingBarTrial(g_strctParadigm, g_strctPTB, strctTrial)

strctTrial.Length = squeeze(g_strctParadigm.Length.Buffer(1,:,g_strctParadigm.Length.BufferIdx));
strctTrial.Width = squeeze(g_strctParadigm.Width.Buffer(1,:,g_strctParadigm.Width.BufferIdx));
strctTrial.NumberOfBars = squeeze(g_strctParadigm.NumberOfBars.Buffer(1,:,g_strctParadigm.NumberOfBars.BufferIdx));
strctTrial.m_fStimulusON_MS = g_strctParadigm.StimulusON_MS.Buffer(1,:,g_strctParadigm.StimulusON_MS.BufferIdx);
strctTrial.m_fStimulusOFF_MS = g_strctParadigm.StimulusOFF_MS.Buffer(1,:,g_strctParadigm.StimulusOFF_MS.BufferIdx);

strctTrial.numFrames = round(strctTrial.m_fStimulusON_MS / (g_strctPTB.g_strctStimulusServer.m_RefreshRateMS));
strctTrial.moveDistance = squeeze(g_strctParadigm.MoveDistance.Buffer(1,:,g_strctParadigm.MoveDistance.BufferIdx));


strctTrial.BarColor = [squeeze(g_strctParadigm.BarRed.Buffer(1,:,g_strctParadigm.BarRed.BufferIdx)), ...
    squeeze(g_strctParadigm.BarGreen.Buffer(1,:,g_strctParadigm.BarGreen.BufferIdx)),...
    squeeze(g_strctParadigm.BarBlue.Buffer(1,:,g_strctParadigm.BarBlue.BufferIdx))];
    
    % Background color
strctTrial.m_afBackgroundColor = [squeeze(g_strctParadigm.BackgroundRed.Buffer(1,:,g_strctParadigm.BackgroundRed.BufferIdx))...
    squeeze(g_strctParadigm.BackgroundGreen.Buffer(1,:,g_strctParadigm.BackgroundGreen.BufferIdx))...
    squeeze(g_strctParadigm.BackgroundBlue.Buffer(1,:,g_strctParadigm.BackgroundBlue.BufferIdx))];


if g_strctParadigm.m_bRandomStimulusOrientation 
    strctTrial.fRotationAngle = round(19.*rand(1,1) + 1) * 18;
    
else
    strctTrial.fRotationAngle = squeeze(g_strctParadigm.Orientation.Buffer(1,:,g_strctParadigm.Orientation.BufferIdx));
end


if g_strctParadigm.m_bRandomStimulusPosition
	for iNumBars = 1 : strctTrial.NumberOfBars
        % Random center points
        strctTrial.location_x(iNumBars) = g_strctParadigm.m_bStimulusRect(1)+ round(rand*range([g_strctParadigm.m_bStimulusRect(1),g_strctParadigm.m_bStimulusRect(3)]));
        strctTrial.location_y(iNumBars) = g_strctParadigm.m_bStimulusRect(2)+ round(rand*range([g_strctParadigm.m_bStimulusRect(2),g_strctParadigm.m_bStimulusRect(4)]));
        strctTrial.bar_rect(iNumBars,1:4) = [(strctTrial.location_x(iNumBars) - strctTrial.Length/2), (strctTrial.location_y(iNumBars)  - strctTrial.Width/2), ...
            (strctTrial.location_x(iNumBars) + strctTrial.Length/2), (strctTrial.location_y(iNumBars) + strctTrial.Width/2)];
        
    end
else
    strctTrial.location_x(1) = g_strctParadigm.m_bCenterOfStimulus(1);
    strctTrial.location_y(1) = g_strctParadigm.m_bCenterOfStimulus(2);
    strctTrial.bar_rect(1,1:4) = [(g_strctParadigm.m_bCenterOfStimulus(1) - strctTrial.Length/2), (g_strctParadigm.m_bCenterOfStimulus(2) - strctTrial.Width/2), ...
        (g_strctParadigm.m_bCenterOfStimulus(1) + strctTrial.Length/2), (g_strctParadigm.m_bCenterOfStimulus(2) + strctTrial.Width/2)];
end







if strctTrial.NumberOfBars == 1
    [strctTrial.point1(1,1), strctTrial.point1(2,1)] = fnRotateAroundPoint(strctTrial.bar_rect(1,1),strctTrial.bar_rect(1,2),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
    [strctTrial.point2(1,1), strctTrial.point2(2,1)] = fnRotateAroundPoint(strctTrial.bar_rect(1,1),strctTrial.bar_rect(1,4),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
    [strctTrial.point3(1,1), strctTrial.point3(2,1)] = fnRotateAroundPoint(strctTrial.bar_rect(1,3),strctTrial.bar_rect(1,4),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
    [strctTrial.point4(1,1), strctTrial.point4(2,1)] = fnRotateAroundPoint(strctTrial.bar_rect(1,3),strctTrial.bar_rect(1,2),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
    [strctTrial.bar_starting_point(1,1),strctTrial.bar_starting_point(2,1)] = fnRotateAroundPoint(strctTrial.location_x(1),(strctTrial.location_y(1) - strctTrial.moveDistance/2),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
    [strctTrial.bar_ending_point(1,1),strctTrial.bar_ending_point(2,1)] = fnRotateAroundPoint(strctTrial.location_x(1),(strctTrial.location_y(1) + strctTrial.moveDistance/2),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
else
    for iNumOfBars = 1:strctTrial.NumberOfBars
        [strctTrial.point1(1,iNumOfBars), strctTrial.point1(2,iNumOfBars)] = fnRotateAroundPoint(strctTrial.bar_rect(iNumOfBars,1),strctTrial.bar_rect(iNumOfBars,2),strctTrial.location_x(iNumOfBars),strctTrial.location_y(iNumOfBars),strctTrial.fRotationAngle);
        [strctTrial.point2(1,iNumOfBars), strctTrial.point2(2,iNumOfBars)] = fnRotateAroundPoint(strctTrial.bar_rect(iNumOfBars,1),strctTrial.bar_rect(iNumOfBars,4),strctTrial.location_x(iNumOfBars),strctTrial.location_y(iNumOfBars),strctTrial.fRotationAngle);
        [strctTrial.point3(1,iNumOfBars), strctTrial.point3(2,iNumOfBars)] = fnRotateAroundPoint(strctTrial.bar_rect(iNumOfBars,3),strctTrial.bar_rect(iNumOfBars,4),strctTrial.location_x(iNumOfBars),strctTrial.location_y(iNumOfBars),strctTrial.fRotationAngle);
        [strctTrial.point4(1,iNumOfBars), strctTrial.point4(2,iNumOfBars)] = fnRotateAroundPoint(strctTrial.bar_rect(iNumOfBars,3),strctTrial.bar_rect(iNumOfBars,2),strctTrial.location_x(iNumOfBars),strctTrial.location_y(iNumOfBars),strctTrial.fRotationAngle);
        [strctTrial.bar_starting_point(1,iNumOfBars),strctTrial.bar_starting_point(2,iNumOfBars)] = fnRotateAroundPoint(strctTrial.location_x(iNumOfBars),(strctTrial.location_y(iNumOfBars) - strctTrial.moveDistance/2),strctTrial.location_x(iNumOfBars),strctTrial.location_y(iNumOfBars),strctTrial.fRotationAngle);
        [strctTrial.bar_ending_point(1,iNumOfBars),strctTrial.bar_ending_point(2,iNumOfBars)] = fnRotateAroundPoint(strctTrial.location_x(iNumOfBars),(strctTrial.location_y(iNumOfBars) + strctTrial.moveDistance/2),strctTrial.location_x(iNumOfBars),strctTrial.location_y(iNumOfBars),strctTrial.fRotationAngle);
        
        
        % Calculate center points for all the bars based on random generation of coordinates inside the stimulus area, and generate the appropriate point list
    end
end



[strctTrial.coordinatesX, strctTrial.coordinatesY]  = deal(zeros(4, strctTrial.numFrames, strctTrial.NumberOfBars));

% Check if the trial has more than 1 frame in it, so we can plan the trial
if strctTrial.numFrames > 1
    for iNumOfBars = 1:strctTrial.NumberOfBars
        % Calculate coordinates for every frame
        
        strctTrial.coordinatesX(1:4,:,iNumOfBars) = vertcat(round(linspace(strctTrial.point1(1,iNumOfBars) - (strctTrial.location_x(iNumOfBars) - strctTrial.bar_starting_point(1,iNumOfBars)),strctTrial.point1(1,iNumOfBars)-(strctTrial.location_x(iNumOfBars) - strctTrial.bar_ending_point(1,iNumOfBars)),strctTrial.numFrames)),...
            round(linspace(strctTrial.point2(1,iNumOfBars) - (strctTrial.location_x(iNumOfBars) - strctTrial.bar_starting_point(1,iNumOfBars)),strctTrial.point2(1,iNumOfBars) - (strctTrial.location_x(iNumOfBars) - strctTrial.bar_ending_point(1,iNumOfBars)),strctTrial.numFrames)),...
            round(linspace(strctTrial.point3(1,iNumOfBars) - (strctTrial.location_x(iNumOfBars) - strctTrial.bar_starting_point(1,iNumOfBars)),strctTrial.point3(1,iNumOfBars) - (strctTrial.location_x(iNumOfBars) - strctTrial.bar_ending_point(1,iNumOfBars)),strctTrial.numFrames)),...
            round(linspace(strctTrial.point4(1,iNumOfBars) - (strctTrial.location_x(iNumOfBars) - strctTrial.bar_starting_point(1,iNumOfBars)),strctTrial.point4(1,iNumOfBars) - (strctTrial.location_x(iNumOfBars) - strctTrial.bar_ending_point(1,iNumOfBars)),strctTrial.numFrames)));
        strctTrial.coordinatesY(1:4,:,iNumOfBars) = vertcat(round(linspace(strctTrial.point1(2,iNumOfBars) - (strctTrial.location_y(iNumOfBars) - strctTrial.bar_starting_point(2,iNumOfBars)),strctTrial.point1(2,iNumOfBars)-(strctTrial.location_y(iNumOfBars) - strctTrial.bar_ending_point(2,iNumOfBars)),strctTrial.numFrames)),...
            round(linspace(strctTrial.point2(2,iNumOfBars) - (strctTrial.location_y(iNumOfBars) - strctTrial.bar_starting_point(2,iNumOfBars)),strctTrial.point2(2,iNumOfBars) - (strctTrial.location_y(iNumOfBars) - strctTrial.bar_ending_point(2,iNumOfBars)),strctTrial.numFrames)),...
            round(linspace(strctTrial.point3(2,iNumOfBars) - (strctTrial.location_y(iNumOfBars) - strctTrial.bar_starting_point(2,iNumOfBars)),strctTrial.point3(2,iNumOfBars) - (strctTrial.location_y(iNumOfBars) - strctTrial.bar_ending_point(2,iNumOfBars)),strctTrial.numFrames)),...
            round(linspace(strctTrial.point4(2,iNumOfBars) - (strctTrial.location_y(iNumOfBars) - strctTrial.bar_starting_point(2,iNumOfBars)),strctTrial.point4(2,iNumOfBars) - (strctTrial.location_y(iNumOfBars) - strctTrial.bar_ending_point(2,iNumOfBars)),strctTrial.numFrames)));
    end
else
    for iNumOfBars = 1:strctTrial.NumberOfBars
        % Only one frame, so the coordinates are static
        
        strctTrial.coordinatesX(1:4,:,iNumOfBars) = [strctTrial.point1(1,iNumOfBars), strctTrial.point2(1,iNumOfBars), strctTrial.point3(1,iNumOfBars),strctTrial.point4(1,iNumOfBars)];
        strctTrial.coordinatesY(1:4,:,iNumOfBars) = [strctTrial.point1(2,iNumOfBars), strctTrial.point2(2,iNumOfBars), strctTrial.point3(2,iNumOfBars),strctTrial.point4(2,iNumOfBars)];
    end
end



return;


% ------------------------------------------------------------------------------------------------------------------------



function [g_strctParadigm, strctTrial] = fnPrepareColorTuningFunctionTrial(g_strctParadigm, g_strctPTB, strctTrial)


strctTrial.m_bUseStrobes = 1;

strctTrial.NumberOfBars = 1;
strctTrial.moveDistance = g_strctParadigm.m_strctTuningFunctionParams.m_fMoveDistance;

strctTrial.numFrames = g_strctParadigm.m_strctTuningFunctionParams.m_fNumFrames;
strctTrial.m_fStimulusON_MS = g_strctParadigm.m_strctTuningFunctionParams.m_fStimulusOnTime;
strctTrial.m_fStimulusOFF_MS = g_strctParadigm.m_strctTuningFunctionParams.m_fStimulusOffTime;
strctTrial.location_x(1) = g_strctParadigm.m_strctTuningFunctionParams.m_afCenterOfStimulus(1);
strctTrial.location_y(1) = g_strctParadigm.m_strctTuningFunctionParams.m_afCenterOfStimulus(2);
strctTrial.bar_rect(1,1:4) = [(g_strctParadigm.m_strctTuningFunctionParams.m_afCenterOfStimulus(1) - g_strctParadigm.m_strctTuningFunctionParams.m_fLength/2),...
								(g_strctParadigm.m_strctTuningFunctionParams.m_afCenterOfStimulus(2) - g_strctParadigm.m_strctTuningFunctionParams.m_fWidth/2), ...
								(g_strctParadigm.m_strctTuningFunctionParams.m_afCenterOfStimulus(1) + g_strctParadigm.m_strctTuningFunctionParams.m_fLength/2),...
								(g_strctParadigm.m_strctTuningFunctionParams.m_afCenterOfStimulus(2) + g_strctParadigm.m_strctTuningFunctionParams.m_fWidth/2)];



    
strctTrial.fRotationAngle = g_strctParadigm.m_strctTuningFunctionParams.m_fTheta;




% Always set to this so the Clut is accurate
strctTrial.BarColor = [2 2 2]; 
% Background color
strctTrial.m_afBackgroundColor = [1 1 1]; % ditto
	
[g_strctParadigm, strctTrial] = fnChooseColor(g_strctParadigm, strctTrial);
    





[strctTrial.point1(1,1), strctTrial.point1(2,1)] = fnRotateAroundPoint(strctTrial.bar_rect(1,1),strctTrial.bar_rect(1,2),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
[strctTrial.point2(1,1), strctTrial.point2(2,1)] = fnRotateAroundPoint(strctTrial.bar_rect(1,1),strctTrial.bar_rect(1,4),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
[strctTrial.point3(1,1), strctTrial.point3(2,1)] = fnRotateAroundPoint(strctTrial.bar_rect(1,3),strctTrial.bar_rect(1,4),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
[strctTrial.point4(1,1), strctTrial.point4(2,1)] = fnRotateAroundPoint(strctTrial.bar_rect(1,3),strctTrial.bar_rect(1,2),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
[strctTrial.bar_starting_point(1,1),strctTrial.bar_starting_point(2,1)] = fnRotateAroundPoint(strctTrial.location_x(1),(strctTrial.location_y(1) - strctTrial.moveDistance/2),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
[strctTrial.bar_ending_point(1,1),strctTrial.bar_ending_point(2,1)] = fnRotateAroundPoint(strctTrial.location_x(1),(strctTrial.location_y(1) + strctTrial.moveDistance/2),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);


% clear this or if the stimulus on time is changed it will break the array and crash kofiko
[strctTrial.coordinatesX, strctTrial.coordinatesY]  = deal(zeros(4, strctTrial.numFrames, strctTrial.NumberOfBars));

% Check if the trial has more than 1 frame in it, so we can plan the trial
if strctTrial.numFrames > 1
        % Calculate coordinates for every frame
        
        strctTrial.coordinatesX(1:4,:,strctTrial.NumberOfBars) = vertcat(round(linspace(strctTrial.point1(1,strctTrial.NumberOfBars) - (strctTrial.location_x(strctTrial.NumberOfBars) - strctTrial.bar_starting_point(1,strctTrial.NumberOfBars)),strctTrial.point1(1,strctTrial.NumberOfBars)-(strctTrial.location_x(strctTrial.NumberOfBars) - strctTrial.bar_ending_point(1,strctTrial.NumberOfBars)),strctTrial.numFrames)),...
            round(linspace(strctTrial.point2(1,strctTrial.NumberOfBars) - (strctTrial.location_x(strctTrial.NumberOfBars) - strctTrial.bar_starting_point(1,strctTrial.NumberOfBars)),strctTrial.point2(1,strctTrial.NumberOfBars) - (strctTrial.location_x(strctTrial.NumberOfBars) - strctTrial.bar_ending_point(1,strctTrial.NumberOfBars)),strctTrial.numFrames)),...
            round(linspace(strctTrial.point3(1,strctTrial.NumberOfBars) - (strctTrial.location_x(strctTrial.NumberOfBars) - strctTrial.bar_starting_point(1,strctTrial.NumberOfBars)),strctTrial.point3(1,strctTrial.NumberOfBars) - (strctTrial.location_x(strctTrial.NumberOfBars) - strctTrial.bar_ending_point(1,strctTrial.NumberOfBars)),strctTrial.numFrames)),...
            round(linspace(strctTrial.point4(1,strctTrial.NumberOfBars) - (strctTrial.location_x(strctTrial.NumberOfBars) - strctTrial.bar_starting_point(1,strctTrial.NumberOfBars)),strctTrial.point4(1,strctTrial.NumberOfBars) - (strctTrial.location_x(strctTrial.NumberOfBars) - strctTrial.bar_ending_point(1,strctTrial.NumberOfBars)),strctTrial.numFrames)));
        strctTrial.coordinatesY(1:4,:,strctTrial.NumberOfBars) = vertcat(round(linspace(strctTrial.point1(2,strctTrial.NumberOfBars) - (strctTrial.location_y(strctTrial.NumberOfBars) - strctTrial.bar_starting_point(2,strctTrial.NumberOfBars)),strctTrial.point1(2,strctTrial.NumberOfBars)-(strctTrial.location_y(strctTrial.NumberOfBars) - strctTrial.bar_ending_point(2,strctTrial.NumberOfBars)),strctTrial.numFrames)),...
            round(linspace(strctTrial.point2(2,strctTrial.NumberOfBars) - (strctTrial.location_y(strctTrial.NumberOfBars) - strctTrial.bar_starting_point(2,strctTrial.NumberOfBars)),strctTrial.point2(2,strctTrial.NumberOfBars) - (strctTrial.location_y(strctTrial.NumberOfBars) - strctTrial.bar_ending_point(2,strctTrial.NumberOfBars)),strctTrial.numFrames)),...
            round(linspace(strctTrial.point3(2,strctTrial.NumberOfBars) - (strctTrial.location_y(strctTrial.NumberOfBars) - strctTrial.bar_starting_point(2,strctTrial.NumberOfBars)),strctTrial.point3(2,strctTrial.NumberOfBars) - (strctTrial.location_y(strctTrial.NumberOfBars) - strctTrial.bar_ending_point(2,strctTrial.NumberOfBars)),strctTrial.numFrames)),...
            round(linspace(strctTrial.point4(2,strctTrial.NumberOfBars) - (strctTrial.location_y(strctTrial.NumberOfBars) - strctTrial.bar_starting_point(2,strctTrial.NumberOfBars)),strctTrial.point4(2,strctTrial.NumberOfBars) - (strctTrial.location_y(strctTrial.NumberOfBars) - strctTrial.bar_ending_point(2,strctTrial.NumberOfBars)),strctTrial.numFrames)));
else
        strctTrial.coordinatesX(1:4,:) = [strctTrial.point1(1), strctTrial.point2(1), strctTrial.point3(1),strctTrial.point4(1)];
        strctTrial.coordinatesY(1:4,:) = [strctTrial.point1(2), strctTrial.point2(2), strctTrial.point3(2),strctTrial.point4(2)];
end


return;
% ------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------

function [g_strctParadigm, strctTrial] = fnPrepareOrientationFunctionTrial(g_strctParadigm, g_strctPTB, strctTrial)


strctTrial.m_bUseStrobes = 1;

strctTrial.NumberOfBars = 1;
strctTrial.moveDistance = g_strctParadigm.m_strctOrientationFunctionParams.m_fMoveDistance;

strctTrial.numFrames = g_strctParadigm.m_strctOrientationFunctionParams.m_fNumFrames;
strctTrial.m_fStimulusON_MS = g_strctParadigm.m_strctOrientationFunctionParams.m_fStimulusOnTime;
strctTrial.m_fStimulusOFF_MS = g_strctParadigm.m_strctOrientationFunctionParams.m_fStimulusOffTime;
strctTrial.location_x(1) = g_strctParadigm.m_strctOrientationFunctionParams.m_afCenterOfStimulus(1);
strctTrial.location_y(1) = g_strctParadigm.m_strctOrientationFunctionParams.m_afCenterOfStimulus(2);
strctTrial.m_afBackgroundColor = g_strctParadigm.m_afBackgroundColor;
strctTrial.BarColor = g_strctParadigm.m_afBarColor;



strctTrial.bar_rect(1,1:4) = [(g_strctParadigm.m_strctOrientationFunctionParams.m_afCenterOfStimulus(1) - g_strctParadigm.m_strctOrientationFunctionParams.m_fLength/2),...
								(g_strctParadigm.m_strctOrientationFunctionParams.m_afCenterOfStimulus(2) - g_strctParadigm.m_strctOrientationFunctionParams.m_fWidth/2), ...
								(g_strctParadigm.m_strctOrientationFunctionParams.m_afCenterOfStimulus(1) + g_strctParadigm.m_strctOrientationFunctionParams.m_fLength/2),...
								(g_strctParadigm.m_strctOrientationFunctionParams.m_afCenterOfStimulus(2) + g_strctParadigm.m_strctOrientationFunctionParams.m_fWidth/2)];


[g_strctParadigm, strctTrial] = fnChooseOrientation(g_strctParadigm, strctTrial);



[strctTrial.point1(1,1), strctTrial.point1(2,1)] = fnRotateAroundPoint(strctTrial.bar_rect(1,1),strctTrial.bar_rect(1,2),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
[strctTrial.point2(1,1), strctTrial.point2(2,1)] = fnRotateAroundPoint(strctTrial.bar_rect(1,1),strctTrial.bar_rect(1,4),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
[strctTrial.point3(1,1), strctTrial.point3(2,1)] = fnRotateAroundPoint(strctTrial.bar_rect(1,3),strctTrial.bar_rect(1,4),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
[strctTrial.point4(1,1), strctTrial.point4(2,1)] = fnRotateAroundPoint(strctTrial.bar_rect(1,3),strctTrial.bar_rect(1,2),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
[strctTrial.bar_starting_point(1,1),strctTrial.bar_starting_point(2,1)] = fnRotateAroundPoint(strctTrial.location_x(1),(strctTrial.location_y(1) - strctTrial.moveDistance/2),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
[strctTrial.bar_ending_point(1,1),strctTrial.bar_ending_point(2,1)] = fnRotateAroundPoint(strctTrial.location_x(1),(strctTrial.location_y(1) + strctTrial.moveDistance/2),strctTrial.location_x(1),strctTrial.location_y(1),strctTrial.fRotationAngle);
% clear this or if the stimulus on time is changed it will break the array and crash kofiko
[strctTrial.coordinatesX, strctTrial.coordinatesY]  = deal(zeros(4, strctTrial.numFrames, strctTrial.NumberOfBars));

% Check if the trial has more than 1 frame in it, so we can plan the trial
if strctTrial.numFrames > 1
        % Calculate coordinates for every frame
        
        strctTrial.coordinatesX(1:4,:,strctTrial.NumberOfBars) = vertcat(round(linspace(strctTrial.point1(1,strctTrial.NumberOfBars) - (strctTrial.location_x(strctTrial.NumberOfBars) - strctTrial.bar_starting_point(1,strctTrial.NumberOfBars)),strctTrial.point1(1,strctTrial.NumberOfBars)-(strctTrial.location_x(strctTrial.NumberOfBars) - strctTrial.bar_ending_point(1,strctTrial.NumberOfBars)),strctTrial.numFrames)),...
            round(linspace(strctTrial.point2(1,strctTrial.NumberOfBars) - (strctTrial.location_x(strctTrial.NumberOfBars) - strctTrial.bar_starting_point(1,strctTrial.NumberOfBars)),strctTrial.point2(1,strctTrial.NumberOfBars) - (strctTrial.location_x(strctTrial.NumberOfBars) - strctTrial.bar_ending_point(1,strctTrial.NumberOfBars)),strctTrial.numFrames)),...
            round(linspace(strctTrial.point3(1,strctTrial.NumberOfBars) - (strctTrial.location_x(strctTrial.NumberOfBars) - strctTrial.bar_starting_point(1,strctTrial.NumberOfBars)),strctTrial.point3(1,strctTrial.NumberOfBars) - (strctTrial.location_x(strctTrial.NumberOfBars) - strctTrial.bar_ending_point(1,strctTrial.NumberOfBars)),strctTrial.numFrames)),...
            round(linspace(strctTrial.point4(1,strctTrial.NumberOfBars) - (strctTrial.location_x(strctTrial.NumberOfBars) - strctTrial.bar_starting_point(1,strctTrial.NumberOfBars)),strctTrial.point4(1,strctTrial.NumberOfBars) - (strctTrial.location_x(strctTrial.NumberOfBars) - strctTrial.bar_ending_point(1,strctTrial.NumberOfBars)),strctTrial.numFrames)));
        strctTrial.coordinatesY(1:4,:,strctTrial.NumberOfBars) = vertcat(round(linspace(strctTrial.point1(2,strctTrial.NumberOfBars) - (strctTrial.location_y(strctTrial.NumberOfBars) - strctTrial.bar_starting_point(2,strctTrial.NumberOfBars)),strctTrial.point1(2,strctTrial.NumberOfBars)-(strctTrial.location_y(strctTrial.NumberOfBars) - strctTrial.bar_ending_point(2,strctTrial.NumberOfBars)),strctTrial.numFrames)),...
            round(linspace(strctTrial.point2(2,strctTrial.NumberOfBars) - (strctTrial.location_y(strctTrial.NumberOfBars) - strctTrial.bar_starting_point(2,strctTrial.NumberOfBars)),strctTrial.point2(2,strctTrial.NumberOfBars) - (strctTrial.location_y(strctTrial.NumberOfBars) - strctTrial.bar_ending_point(2,strctTrial.NumberOfBars)),strctTrial.numFrames)),...
            round(linspace(strctTrial.point3(2,strctTrial.NumberOfBars) - (strctTrial.location_y(strctTrial.NumberOfBars) - strctTrial.bar_starting_point(2,strctTrial.NumberOfBars)),strctTrial.point3(2,strctTrial.NumberOfBars) - (strctTrial.location_y(strctTrial.NumberOfBars) - strctTrial.bar_ending_point(2,strctTrial.NumberOfBars)),strctTrial.numFrames)),...
            round(linspace(strctTrial.point4(2,strctTrial.NumberOfBars) - (strctTrial.location_y(strctTrial.NumberOfBars) - strctTrial.bar_starting_point(2,strctTrial.NumberOfBars)),strctTrial.point4(2,strctTrial.NumberOfBars) - (strctTrial.location_y(strctTrial.NumberOfBars) - strctTrial.bar_ending_point(2,strctTrial.NumberOfBars)),strctTrial.numFrames)));
else
        strctTrial.coordinatesX(1:4,:) = [strctTrial.point1(1), strctTrial.point2(1), strctTrial.point3(1),strctTrial.point4(1)];
        strctTrial.coordinatesY(1:4,:) = [strctTrial.point1(2), strctTrial.point2(2), strctTrial.point3(2),strctTrial.point4(2)];
end
return;

% ------------------------------------------------------------------------------------------------------------------------

function [g_strctParadigm, strctTrial] = fnChooseColor(g_strctParadigm, strctTrial)

strctTrial.m_iSelectedColor = g_strctParadigm.m_iSelectedColor;

% Random order?
if g_strctParadigm.m_strctTuningFunctionParams.m_bRandomColorOrder
    strctTrial.m_iSelectedColor = ceil(rand*size(g_strctParadigm.m_strctCurrentSaturation,1));
        if strctTrial.m_iSelectedColor == 0
            strctTrial.m_iSelectedColor = 1;
        end
elseif g_strctParadigm.m_strctTuningFunctionParams.m_bReverseColorOrder
    if strctTrial.m_iSelectedColor == 1
        strctTrial.m_iSelectedColor = size(g_strctParadigm.m_strctCurrentSaturation,1);
    else
        strctTrial.m_iSelectedColor = strctTrial.m_iSelectedColor-1;
    end
    
else
    if strctTrial.m_iSelectedColor == size(g_strctParadigm.m_strctCurrentSaturation,1)
        strctTrial.m_iSelectedColor = 1;
    else
        strctTrial.m_iSelectedColor = strctTrial.m_iSelectedColor + 1;
    end
end

	strctTrial.Clut = g_strctParadigm.m_strctTuningFunctionParams.m_afMasterClut;
	strctTrial.Clut(1,:) = [0,0,0];
	strctTrial.Clut(2,:) = g_strctParadigm.m_strctMasterColorTable.(g_strctParadigm.m_strctTuningFunctionParams.m_strBGColor).RGB...
																	(g_strctParadigm.m_strctTuningFunctionParams.m_iBGColorRGBIndex,:);
    strctTrial.Clut(3,:) = g_strctParadigm.m_strctCurrentSaturation(strctTrial.m_iSelectedColor,:);
	strctTrial.Clut(256,:) = [65535, 65535, 65535];



% Prepare colors for local machine   

strctTrial.m_afLocalBarColor = round([(([strctTrial.Clut(strctTrial.BarColor(1),1),...
										strctTrial.Clut(strctTrial.BarColor(2),2)...
										strctTrial.Clut(strctTrial.BarColor(3),3)]/65535)*255)]);
strctTrial.m_afLocalBackgroundColor = round([(([strctTrial.Clut(strctTrial.m_afBackgroundColor(1),1),...
										strctTrial.Clut(strctTrial.m_afBackgroundColor(2),2)...
										strctTrial.Clut(strctTrial.m_afBackgroundColor(3),3)]/65535)*255)]);
										
g_strctParadigm.m_iSelectedColor = strctTrial.m_iSelectedColor;
g_strctParadigm.m_iTrialStrobeID = g_strctParadigm.m_iSelectedColor;
return;

function [g_strctParadigm, strctTrial] = fnChooseOrientation(g_strctParadigm, strctTrial)

strctTrial.OrientationID = g_strctParadigm.m_strctOrientationFunctionParams.fOrientationID;

% Random order?
if g_strctParadigm.m_strctOrientationFunctionParams.m_bRandomOrientation
	strctTrial.OrientationID = ceil(rand*g_strctParadigm.m_strctOrientationFunctionParams.m_iNumberOfOrientationsToTest);
	%(360/g_strctParadigm.m_strctOrientationFunctionParams.m_iNumberOfOrientationsToTest).*ceil(rand*g_strctParadigm.m_strctOrientationFunctionParams.m_iNumberOfOrientationsToTest);
	
elseif g_strctParadigm.m_strctOrientationFunctionParams.m_bReverseOrientationOrder
    if strctTrial.OrientationID == 1
        strctTrial.OrientationID = g_strctParadigm.m_strctOrientationFunctionParams.m_iNumberOfOrientationsToTest;
    else
        strctTrial.OrientationID = strctTrial.OrientationID-1;
    end
    
else
    if strctTrial.OrientationID == g_strctParadigm.m_strctOrientationFunctionParams.m_iNumberOfOrientationsToTest
        strctTrial.OrientationID = 1;
    else
        strctTrial.OrientationID = strctTrial.OrientationID + 1;
    end
end
strctTrial.fRotationAngle = round(strctTrial.OrientationID * 360/g_strctParadigm.m_strctOrientationFunctionParams.m_iNumberOfOrientationsToTest);
g_strctParadigm.m_strctOrientationFunctionParams.fOrientationID = strctTrial.OrientationID;
g_strctParadigm.m_iTrialStrobeID = g_strctParadigm.m_strctOrientationFunctionParams.fOrientationID;
return;



function [newX, newY] = fnRotateAroundPoint(x ,y , centerX, centerY, angle_of_rotation)

% Helper function. Rotates stuff for dynamic presentations
% takes 11 microseconds
s = sin(degtorad(angle_of_rotation));
c = cos(degtorad(angle_of_rotation));
x = x - centerX;
y = y - centerY;

newX = x * c - y * s;
newY = x * s + y * c;
newX = round(newX + centerX);
newY = round(newY + centerY);

return;






