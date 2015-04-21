function fnParadigmTouchForceChoiceDraw()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
%
global g_strctPTB g_strctParadigm g_strctDraw
% Do not call Flip, just draw everything to the screen.

acMedia = [];

if fnParadigmToKofikoComm('IsTouchMode')
    if isfield(g_strctDraw,'m_acMedia')
        acMedia = g_strctDraw.m_acMedia;
    end
else
    if isfield(g_strctParadigm,'m_acMedia')
        acMedia = g_strctParadigm.m_acMedia;
    end
end
if ~isempty(acMedia) && ~isempty(g_strctParadigm.m_strctCurrentTrial)
    % Display cue (unless it is a movie) in a small box on the top left
    % corner. 
    if g_strctParadigm.m_iMachineState <= 6
        % Show where the fixation spot is...
        if ~isempty(g_strctParadigm.m_strctCurrentTrial.m_strctPreCueFixation) 
              fnDrawFixationSpot(g_strctPTB.m_hWindow, g_strctParadigm.m_strctCurrentTrial.m_strctPreCueFixation, false,g_strctPTB.m_fScale);
              aiArcBoundingBox =g_strctPTB.m_fScale * [
              g_strctParadigm.m_strctCurrentTrial.m_strctPreCueFixation.m_pt2fFixationPosition(:)'-ones(1,2)*g_strctParadigm.m_strctCurrentTrial.m_strctPreCueFixation.m_fFixationRegionPix,...
              g_strctParadigm.m_strctCurrentTrial.m_strctPreCueFixation.m_pt2fFixationPosition(:)'+ones(1,2)*g_strctParadigm.m_strctCurrentTrial.m_strctPreCueFixation.m_fFixationRegionPix];
             Screen('FrameArc', g_strctPTB.m_hWindow,g_strctParadigm.m_strctCurrentTrial.m_strctPreCueFixation.m_afFixationColor, aiArcBoundingBox,0,360);
  
        end
    else
        if g_strctParadigm.m_iMachineState == 7 && ~isempty(g_strctParadigm.m_strctCurrentTrial.m_strctPreCueFixation)
                fnDrawFixationSpot(g_strctPTB.m_hWindow, g_strctParadigm.m_strctCurrentTrial.m_strctPreCueFixation, false,g_strctPTB.m_fScale);
                aiArcBoundingBox =g_strctPTB.m_fScale * [
                    g_strctParadigm.m_strctCurrentTrial.m_strctPreCueFixation.m_pt2fFixationPosition-ones(1,2)*g_strctParadigm.m_strctCurrentTrial.m_strctPreCueFixation.m_fFixationRegionPix,...
                    g_strctParadigm.m_strctCurrentTrial.m_strctPreCueFixation.m_pt2fFixationPosition+ones(1,2)*g_strctParadigm.m_strctCurrentTrial.m_strctPreCueFixation.m_fFixationRegionPix];
                Screen('FrameArc', g_strctPTB.m_hWindow,g_strctParadigm.m_strctCurrentTrial.m_strctPreCueFixation.m_afFixationColor, aiArcBoundingBox,0,360);
        end
        
        if ~isempty( g_strctParadigm.m_strctCurrentTrial.m_astrctCueMedia)
            % Display cue
            for iCueIter=1:length(g_strctParadigm.m_strctCurrentTrial.m_astrctCueMedia)
                if g_strctParadigm.m_strctCurrentTrial.m_bLoadOnTheFly
                    iLocalMediaIndex = iCueIter;
                else
                    iLocalMediaIndex = g_strctParadigm.m_strctCurrentTrial.m_astrctCueMedia(iCueIter).m_iMediaIndex;
                end
                % Display cue on top left corner...
                
                if acMedia{iLocalMediaIndex}.m_bMovie
                else
                    
                    fDesiredWidth = g_strctPTB.m_aiRect(4) / 8;
                    fScale =  acMedia{iLocalMediaIndex}.m_iHeight/acMedia{iLocalMediaIndex}.m_iWidth;
                    
                    fOffset = 1.1* fDesiredWidth * (iCueIter-1);
                    
                    aiTopLeftCorner = g_strctPTB.m_fScale * [fOffset,50,fOffset+fDesiredWidth,50+fDesiredWidth*fScale];
                    Screen('DrawTexture', g_strctPTB.m_hWindow, acMedia{iLocalMediaIndex}.m_hHandle,[],aiTopLeftCorner, 0);
                    Screen('FrameRect', g_strctPTB.m_hWindow,[255 0 0], aiTopLeftCorner,2);
                end
            end
        end
        
        if ~isempty( g_strctParadigm.m_strctCurrentTrial.m_astrctChoicesMedia)
            iNumChoices = length(g_strctParadigm.m_strctCurrentTrial.m_astrctChoicesMedia);
              fnDisplayChoices(g_strctPTB.m_hWindow, 1:iNumChoices, g_strctParadigm.m_strctCurrentTrial, acMedia,false, false, true,  g_strctPTB.m_fScale,true);
            end
    end
    
end
if 0
% Stat...
iNumTrials = g_strctParadigm.acTrials.BufferIdx-1;
iNumTimeOuts = 0;
iNumCorrect = 0;
iNumIncorrect = 0;
for iTrialIter=1:iNumTrials
    if ~isempty(g_strctParadigm.acTrials.Buffer{iTrialIter}) && isfield(g_strctParadigm.acTrials.Buffer{iTrialIter},'m_strctTrialOutcome')
        switch g_strctParadigm.acTrials.Buffer{iTrialIter}.m_strctTrialOutcome.m_strResult
            case 'Timeout'
                iNumTimeOuts = iNumTimeOuts+1;
            case 'Correct'
                iNumCorrect = iNumCorrect + 1;
            case 'Incorrect'
                iNumIncorrect = iNumIncorrect + 1;
        end
    end
end
aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');

fStartX = 0;    
fStartY = 200;
Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Num Trials   : %d',iNumTrials), fStartX,fStartY+30,[255 255 255]);
Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Num Correct  : %d (%.1f%%)',iNumCorrect,iNumCorrect/iNumTrials*100), fStartX,fStartY+60,[0 255 0]);
Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Num Incorrect: %d (%.1f%%)',iNumIncorrect,iNumIncorrect/iNumTrials*100), fStartX,fStartY+90,[255 0 0]);
Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Num Timeout  : %d (%.1f%%)',iNumTimeOuts,iNumTimeOuts/iNumTrials*100), fStartX,fStartY+120,[255 0 255]);

end
return;
        
aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');

% Prepare the trial structure that is sent to the stimulus server
pt2fFixationSpotPosition = aiScreenSize(3:4)/2;
fChoicesHalfSizePix = fnTsGetVar(g_strctParadigm,'ChoicesHalfSizePix');
if ~isempty(g_strctParadigm.m_ahPTBHandles)
    for k=1:length(g_strctParadigm.m_ahPTBHandles)
        Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctParadigm.m_ahPTBHandles(k),[],  g_strctPTB.m_fScale * g_strctParadigm.m_a2iStimulusRect(k,:));
        
       if k > 1
           pt2fChoiceCenter = pt2fFixationSpotPosition + g_strctParadigm.m_strctTrialToStimulusServer.m_astrctRelevantChoices(k-1).m_pt2fRelativePos;
           fHitRadius = fnTsGetVar(g_strctParadigm,'HitRadius'); 
           aiHitRect = [pt2fChoiceCenter-fHitRadius,pt2fChoiceCenter+fHitRadius];
           if k == 2
               % Correct answer
               Screen('FrameArc', g_strctPTB.m_hWindow, [0 255 0],g_strctPTB.m_fScale * aiHitRect,0,360);
           else
               Screen('FrameArc', g_strctPTB.m_hWindow, [255 255 255],g_strctPTB.m_fScale * aiHitRect,0,360);
           end
           
        else
           % Target Image. Draw noise.
              Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctParadigm.m_hNoiseHandle,[],  g_strctPTB.m_fScale * g_strctParadigm.m_a2iStimulusRect(k,:));
       end
       
       aiTargetRect = g_strctPTB.m_fScale * g_strctParadigm.m_a2iStimulusRect(k,:);
       if g_strctParadigm.m_iMachineState < 8
           for j=1:20:2*fChoicesHalfSizePix+1
               Screen('DrawLine', g_strctPTB.m_hWindow, [200 200 200],aiTargetRect(1),aiTargetRect(2)+j, aiTargetRect(3), aiTargetRect(2)+j);
           end
       end
       if g_strctParadigm.m_iMachineState < 10
           for j=1:20:2*fChoicesHalfSizePix+1
               Screen('DrawLine', g_strctPTB.m_hWindow, [200 200 200],aiTargetRect(1)+j,aiTargetRect(2), aiTargetRect(1)+j, aiTargetRect(4));
           end
       end       
       
    end
end

fFixationRadiusPix = fnTsGetVar(g_strctParadigm,'FixationRadiusPix');
aiFixationArea = [g_strctParadigm.m_pt2fFixationSpot - fFixationRadiusPix,g_strctParadigm.m_pt2fFixationSpot + fFixationRadiusPix];
Screen('FrameArc', g_strctPTB.m_hWindow, [255 255 255],g_strctPTB.m_fScale * aiFixationArea,0,360);


iNumTrials = g_strctParadigm.m_strctStatistics.m_iNumCorrect+g_strctParadigm.m_strctStatistics.m_iNumIncorrect+...
    g_strctParadigm.m_strctStatistics.m_iNumTimeout + g_strctParadigm.m_strctStatistics.m_iNumShortHold;
fStartX = g_strctPTB.m_aiRect(3)-370;
fStartY = 20;
Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Num Trials : %d',iNumTrials), fStartX,fStartY,[255 255 255]);
if iNumTrials > 0
if g_strctParadigm.m_strctStatistics.m_iNumCorrect+g_strctParadigm.m_strctStatistics.m_iNumIncorrect > 0
    
Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Correct    : %d (%.1f%%, %.1f%%)',...
    g_strctParadigm.m_strctStatistics.m_iNumCorrect,100*g_strctParadigm.m_strctStatistics.m_iNumCorrect/iNumTrials, ...
    100*g_strctParadigm.m_strctStatistics.m_iNumCorrect / (g_strctParadigm.m_strctStatistics.m_iNumCorrect+g_strctParadigm.m_strctStatistics.m_iNumIncorrect)), fStartX,fStartY+30,[0 255 0]);
else
Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Correct    : %d (%.1f%%)',...
    g_strctParadigm.m_strctStatistics.m_iNumCorrect,100*g_strctParadigm.m_strctStatistics.m_iNumCorrect/iNumTrials), fStartX,fStartY+30,[0 255 0]);
    
end

Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Incorrect  : %d (%.1f%%)',...
    g_strctParadigm.m_strctStatistics.m_iNumIncorrect,100*g_strctParadigm.m_strctStatistics.m_iNumIncorrect/iNumTrials), fStartX,fStartY+60,[255 0 0]);
Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Timeout    : %d (%.1f%%)',...
    g_strctParadigm.m_strctStatistics.m_iNumTimeout,100*g_strctParadigm.m_strctStatistics.m_iNumTimeout/iNumTrials), fStartX,fStartY+90,[255 0 255]);
Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Short Hold : %d (%.1f%%)',...
    g_strctParadigm.m_strctStatistics.m_iNumShortHold,100*g_strctParadigm.m_strctStatistics.m_iNumShortHold/iNumTrials), fStartX,fStartY+120,[255 255 0]);

Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Trial %d/%d Rep %d',...
    g_strctParadigm.m_iTrialCounter,length(g_strctParadigm.m_astrctTrials) ,g_strctParadigm.m_iTrialRep), fStartX,fStartY+150,[0 255 255]);


end
return;

