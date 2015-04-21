function fnParadigmForcedChoiceDraw()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
%
global g_strctPTB g_strctParadigm
% Do not call Flip, just draw everything to the screen.

        
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

