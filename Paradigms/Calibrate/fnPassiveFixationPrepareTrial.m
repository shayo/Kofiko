function strctTrial = fnPassiveFixationPrepareTrial()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
global g_strctParadigm
g_strctParadigm.m_bMovieInitialized  = false;

if isempty(g_strctParadigm.m_strctDesign)
    strctTrial = [];
    return;
end;

if g_strctParadigm.m_bParameterSweep
   [iNewStimulusIndex,iSelectedBlock] =  fnSelectNextStimulusUsingParameterSweep();
else
   [iNewStimulusIndex,iSelectedBlock] = fnSelectNextStimulus();
end

strctTrial.m_strctMicroStim = fnMicroStimThisTrial(iNewStimulusIndex,iSelectedBlock);

%% Noise ?
bOverlayNoise = g_strctParadigm.NoiseOverlayActive.Buffer(1,:,g_strctParadigm.NoiseOverlayActive.BufferIdx);
if bOverlayNoise &&  g_strctParadigm.m_strctNoiseOverlay.m_iNumNoisePatterns  > 0
    strctTrial.m_bNoiseOverlay = true;
    g_strctParadigm.m_strctNoiseOverlay.m_iNoiseIndex=g_strctParadigm.m_strctNoiseOverlay.m_iNoiseIndex+1;
    if g_strctParadigm.m_strctNoiseOverlay.m_iNoiseIndex >  g_strctParadigm.m_strctNoiseOverlay.m_iNumNoisePatterns 
        g_strctParadigm.m_strctNoiseOverlay.m_iNoiseIndex  = 1;
    end
    strctTrial.m_iNoiseIndex = g_strctParadigm.m_strctNoiseOverlay.m_iNoiseIndex;
    strctTrial.m_a2fNoisePattern = g_strctParadigm.m_a3fRandPatterns(:,:,strctTrial.m_iNoiseIndex);
else
    strctTrial.m_iNoiseIndex = 0;
    strctTrial.m_bNoiseOverlay = false;
    strctTrial.m_a2fNoisePattern =  [];
end

%% Select new fixation and stimulus positions
if g_strctParadigm.m_bRandFixPos
    aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
    g_strctParadigm.m_iRandFixCounter = g_strctParadigm.m_iRandFixCounter + 1;
    if g_strctParadigm.m_iRandFixCounter >= g_strctParadigm.m_iRandFixCounterMax
        g_strctParadigm.m_iRandFixCounter = 0;
        g_strctParadigm.m_iRandFixCounterMax = g_strctParadigm.m_fRandFixPosMin + round(rand() * (g_strctParadigm.m_fRandFixPosMax-g_strctParadigm.m_fRandFixPosMin));
        pt2iCenter = aiScreenSize(3:4)/2;
        pt2iNewFixationSpot = 2*(rand(1,2)-0.5) * g_strctParadigm.m_fRandFixRadius + pt2iCenter;
        % set a new random position for fixation point
        fnTsSetVarParadigm('FixationSpotPix',pt2iNewFixationSpot);
        fnParadigmToKofikoComm('SetFixationPosition',pt2iNewFixationSpot);
        if g_strctParadigm.m_bRandFixSyncStimulus
            fnTsSetVarParadigm('StimulusPos',pt2iNewFixationSpot);
        end
    end;
end;
 

% Faster access than fnTsGetVar...
strctTrial.m_iStimulusIndex = iNewStimulusIndex;
strctTrial.m_strctMedia = g_strctParadigm.m_strctDesign.m_astrctMedia(iNewStimulusIndex);

strctTrial.m_pt2iFixationSpot = g_strctParadigm.FixationSpotPix.Buffer(1,:,g_strctParadigm.FixationSpotPix.BufferIdx);
strctTrial.m_pt2fStimulusPos = g_strctParadigm.StimulusPos.Buffer(1,:,g_strctParadigm.StimulusPos.BufferIdx);
strctTrial.m_afBackgroundColor = squeeze(g_strctParadigm.BackgroundColor.Buffer(1,:,g_strctParadigm.BackgroundColor.BufferIdx));
strctTrial.m_fFixationSizePix = g_strctParadigm.FixationSizePix.Buffer(1,:,g_strctParadigm.FixationSizePix.BufferIdx);
strctTrial.m_fGazeBoxPix = g_strctParadigm.GazeBoxPix.Buffer(1,:,g_strctParadigm.GazeBoxPix.BufferIdx);
strctTrial.m_fStimulusSizePix = g_strctParadigm.StimulusSizePix.Buffer(1,:,g_strctParadigm.StimulusSizePix.BufferIdx);

if strcmpi(strctTrial.m_strctMedia.m_strMediaType,'Movie') || strcmpi(strctTrial.m_strctMedia.m_strMediaType,'StereoMovie') 
     strctTrial.m_fStimulusON_MS = 0;
     strctTrial.m_fStimulusOFF_MS = 0;
else
    strctTrial.m_fStimulusON_MS = g_strctParadigm.StimulusON_MS.Buffer(1,:,g_strctParadigm.StimulusON_MS.BufferIdx);
    strctTrial.m_fStimulusOFF_MS = g_strctParadigm.StimulusOFF_MS.Buffer(1,:,g_strctParadigm.StimulusOFF_MS.BufferIdx);
end

strctTrial.m_fRotationAngle = g_strctParadigm.RotationAngle.Buffer(1,:,g_strctParadigm.RotationAngle.BufferIdx);
strctTrial.m_bShowPhotodiodeRect = g_strctParadigm.m_bShowPhotodiodeRect;
strctTrial.m_iPhotoDiodeWindowPix = g_strctParadigm.m_iPhotoDiodeWindowPix;

return;

function strctMicroStim = fnMicroStimThisTrial(iNewStimulusIndex,iSelectedBlock)
global g_strctParadigm
strctMicroStim.m_bStimulation = false;
if g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(iSelectedBlock).m_bMicroStim
   % Check if media file has the required attributes for stimulation
   iNumRequiredAttributes = length(g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(iSelectedBlock).m_acMicroStimAttributes);
   iNumFoundAttributes = length(intersect(g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(iSelectedBlock).m_acMicroStimAttributes,...
    g_strctParadigm.m_strctDesign.m_astrctMedia(iNewStimulusIndex).m_acAttributes));
    if iNumRequiredAttributes == iNumFoundAttributes
        strctMicroStim.m_bStimulation = true;
        strctMicroStim.m_aiChannels = g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(iSelectedBlock).m_aiMicroStimChannels;
    end
    % TODO: Add micro stim preset and parameters here...
end
return;


function [iNewStimulusIndex,iSelectedBlock]=  fnSelectNextStimulusUsingParameterSweep()
global g_strctParadigm
aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
iSelectedBlock = [];

iNewStimulusIndex = g_strctParadigm.m_a2fParamSpace(g_strctParadigm.m_strctParamSweep.m_iParamSweepIndex,1);
fX = g_strctParadigm.m_a2fParamSpace(g_strctParadigm.m_strctParamSweep.m_iParamSweepIndex,2);
fY = g_strctParadigm.m_a2fParamSpace(g_strctParadigm.m_strctParamSweep.m_iParamSweepIndex,3);
fSize = g_strctParadigm.m_a2fParamSpace(g_strctParadigm.m_strctParamSweep.m_iParamSweepIndex,4);
fTheta = g_strctParadigm.m_a2fParamSpace(g_strctParadigm.m_strctParamSweep.m_iParamSweepIndex,5);

pt2fStimulusPosition = aiScreenSize(3:4)/2 + [fX,fY];

fnTsSetVarParadigm('StimulusPos',pt2fStimulusPosition);
fnTsSetVarParadigm('RotationAngle',fTheta);
fnTsSetVarParadigm('StimulusSizePix',fSize);

g_strctParadigm.m_strctParamSweep.m_iParamSweepIndex = g_strctParadigm.m_strctParamSweep.m_iParamSweepIndex + 1;
if g_strctParadigm.m_strctParamSweep.m_iParamSweepIndex > size(g_strctParadigm.m_a2fParamSpace,1)
    fnInitializeParameterSweep();
    g_strctParadigm.m_iRepeatitionCount = g_strctParadigm.m_iRepeatitionCount + 1;
end
return;


function [iNewStimulusIndex,iSelectedBlock] = fnSelectNextStimulus()
global g_strctParadigm
iSelectedBlock = g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(g_strctParadigm.m_iCurrentOrder).m_aiBlockIndexOrder(g_strctParadigm.m_iCurrentBlockIndexInOrderList);
iNumMediaInBlock = length(g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(iSelectedBlock).m_aiMedia);
iNewStimulusIndex =g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(iSelectedBlock).m_aiMedia( g_strctParadigm.m_aiCurrentRandIndices(g_strctParadigm.m_iCurrentMediaIndexInBlockList));


% Increase counters
g_strctParadigm.m_iCurrentMediaIndexInBlockList = g_strctParadigm.m_iCurrentMediaIndexInBlockList + 1;
if g_strctParadigm.m_iCurrentMediaIndexInBlockList  > iNumMediaInBlock
    % Yey! We finished displaying a block!
    % Reset and increase counters accordingly!
    g_strctParadigm.m_iCurrentMediaIndexInBlockList = 1;
    % Generate a new random indices for the media in this block!
    if g_strctParadigm.m_bRandom
                [fDummy,g_strctParadigm.m_aiCurrentRandIndices] = sort(rand(1,iNumMediaInBlock));
    else
        g_strctParadigm.m_aiCurrentRandIndices = 1:iNumMediaInBlock;
    end
    
    g_strctParadigm.m_iNumTimesBlockShown = g_strctParadigm.m_iNumTimesBlockShown + 1;
    
    % How many times do we need to display this block ?
    iNumTimesToShowBlock = g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(g_strctParadigm.m_iCurrentOrder).m_aiBlockRepitition(g_strctParadigm.m_iCurrentBlockIndexInOrderList);
    iNumBlockOrder = length(g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(g_strctParadigm.m_iCurrentOrder).m_aiBlockRepitition);
    iNumOrders = length(g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder);
    
    if g_strctParadigm.m_iNumTimesBlockShown >= iNumTimesToShowBlock && ~g_strctParadigm.m_bBlockLooping
        % Time to move on to next block.
        g_strctParadigm.m_iNumTimesBlockShown = 0;
        g_strctParadigm.m_iCurrentBlockIndexInOrderList = g_strctParadigm.m_iCurrentBlockIndexInOrderList + 1;
        if g_strctParadigm.m_iCurrentBlockIndexInOrderList > iNumBlockOrder
            % We finished displaying everything according to the desired order. What's next?
            % 1. Reset and Stop
            % 2. Stop but increase current order (fMRI Style?)
            % 3. Continue, by starting all over again using the same order
            % 4. Continue, by starting all over again using the next order
            switch g_strctParadigm.m_strBlockDoneAction
                case 'Reset And Stop'
                    g_strctParadigm.m_iCurrentBlockIndexInOrderList = 1;
                    g_strctParadigm.m_iCurrentMediaIndexInBlockList = 1;
                    g_strctParadigm.m_iMachineState = 0;
                case 'Set Next Order But Do not Start'
                    g_strctParadigm.m_iCurrentBlockIndexInOrderList = 1;
                    g_strctParadigm.m_iCurrentMediaIndexInBlockList = 1;
                    g_strctParadigm.m_iMachineState = 0;
                    g_strctParadigm.m_iCurrentOrder = g_strctParadigm.m_iCurrentOrder + 1;
                    if g_strctParadigm.m_iCurrentOrder > iNumOrders
                        g_strctParadigm.m_iCurrentOrder = 1;
                    end
                case 'Repeat Same Order'
                    g_strctParadigm.m_iCurrentBlockIndexInOrderList = 1;
                    g_strctParadigm.m_iCurrentMediaIndexInBlockList = 1;
                case 'Set Next Order and Start'
                    g_strctParadigm.m_iCurrentBlockIndexInOrderList = 1;
                    g_strctParadigm.m_iCurrentMediaIndexInBlockList = 1;
                    g_strctParadigm.m_iCurrentOrder = g_strctParadigm.m_iCurrentOrder + 1;
                    if g_strctParadigm.m_iCurrentOrder > iNumOrders
                        g_strctParadigm.m_iCurrentOrder = 1;
                    end
                otherwise
                    assert(false);
            end
        end
        
        set(g_strctParadigm.m_strctControllers.m_hBlockLists,'value',g_strctParadigm.m_iCurrentBlockIndexInOrderList);

        iSelectedBlockNext = g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(g_strctParadigm.m_iCurrentOrder).m_aiBlockIndexOrder(g_strctParadigm.m_iCurrentBlockIndexInOrderList);
        iNumMediaInBlock = length(g_strctParadigm.m_strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(iSelectedBlockNext).m_aiMedia);
        if g_strctParadigm.m_bRandom
                    [fDummy,g_strctParadigm.m_aiCurrentRandIndices] = sort(rand(1,iNumMediaInBlock));
        else
            g_strctParadigm.m_aiCurrentRandIndices = 1:iNumMediaInBlock;
        end
        
    end
    
end
