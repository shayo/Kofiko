function fnParadigmTargetDetectionDraw()
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
%
global g_strctPTB g_strctParadigm
% Do not call Flip, just draw everything to the screen.

fHitRadius = fnTsGetVar(g_strctParadigm,'HitRadius');


if isfield(g_strctParadigm,'m_strctCurrentTrial') && ~isempty(g_strctParadigm.m_strctCurrentTrial) && isfield(g_strctParadigm.m_strctCurrentTrial,'m_fObjectHalfSizePix')
    
    strctCurrentTrial = g_strctParadigm.m_strctCurrentTrial;
    % Draw Objects on screen
    for k=1:length( strctCurrentTrial.m_aiSelectedObjects)
        iObjectIndex = strctCurrentTrial.m_aiSelectedObjects(k);
        
        if isfield(g_strctParadigm.m_strctObjects,'m_acImages') && ~isempty(g_strctParadigm.m_strctObjects.m_acImages)
            % Textres are allocated and released in real time...
            aiSize = size(g_strctParadigm.m_strctObjects.m_acImages{iObjectIndex});
            aiStimulusRect = fnComputeStimulusRect(strctCurrentTrial.m_fObjectHalfSizePix,...
                aiSize([2,1]),...
                strctCurrentTrial.m_apt2fPos(:,k));
            
            if strcmp(class(g_strctParadigm.m_strctObjects.m_acImages{iObjectIndex}),'uint8')
                hHandle = Screen('MakeTexture', g_strctPTB.m_hWindow,  g_strctParadigm.m_strctObjects.m_acImages{iObjectIndex});
            else
                hHandle = Screen('MakeTexture', g_strctPTB.m_hWindow,  g_strctParadigm.m_strctObjects.m_acImages{iObjectIndex}*255);
            end
            
            Screen('DrawTexture', g_strctPTB.m_hWindow, hHandle,[],g_strctPTB.m_fScale * aiStimulusRect);
            Screen('Close',hHandle);
        else
            % Textures are pre-allocated
            aiStimulusRect = fnComputeStimulusRect(strctCurrentTrial.m_fObjectHalfSizePix,...
                g_strctParadigm.m_strctObjects.m_a2iImageSize(:,iObjectIndex),...
                strctCurrentTrial.m_apt2fPos(:,k));
            
            Screen('DrawTexture', g_strctPTB.m_hWindow, g_strctParadigm.m_strctObjects.m_ahPTBHandles(iObjectIndex),[],g_strctPTB.m_fScale * aiStimulusRect);
            
                  
        end
        
    end
    
    if ~isempty(g_strctParadigm.m_strctCurrentTrial.m_pt2fHoldPos)
        aiHitRect = [g_strctParadigm.m_strctCurrentTrial.m_pt2fHoldPos'-1.5*fHitRadius,g_strctParadigm.m_strctCurrentTrial.m_pt2fHoldPos'+1.5*fHitRadius];
        
        Screen('FrameArc', g_strctPTB.m_hWindow, [0 0 255],g_strctPTB.m_fScale * aiHitRect,0,360);
        
    end
end


iNumTargets = fnTsGetVar(g_strctParadigm,'NumTargets');
iNumNonTargets = fnTsGetVar(g_strctParadigm,'NumNonTargets');
fObjectHalfSizePix = fnTsGetVar(g_strctParadigm,'ObjectHalfSizePix');
aiScreenSize = fnParadigmToKofikoComm('GetStimulusServerScreenSize');
fFixationRadiusPix = fnTsGetVar(g_strctParadigm,'FixationRadiusPix');

aiFixationRect = [aiScreenSize(3:4)/2 - fFixationRadiusPix,aiScreenSize(3:4)/2 + fFixationRadiusPix];
Screen('FrameArc', g_strctPTB.m_hWindow, [150 150 150],g_strctPTB.m_fScale * aiFixationRect,0,360);

if isfield(g_strctParadigm,'m_strctCurrentTrial') && ~isempty(g_strctParadigm.m_strctCurrentTrial) && isfield(g_strctParadigm.m_strctCurrentTrial,'m_apt2fPos')
    [apt2fPos] = g_strctParadigm.m_strctCurrentTrial.m_apt2fPos;
else
    [apt2fPos] = fnGetObjectPosition(iNumTargets+iNumNonTargets);
end

for k=1:iNumTargets+iNumNonTargets
    aiHitRect = [apt2fPos(:,k)'-fHitRadius,apt2fPos(:,k)'+fHitRadius];
    aiTargetRect = g_strctPTB.m_fScale * [apt2fPos(:,k)'-fObjectHalfSizePix,apt2fPos(:,k)'+fObjectHalfSizePix];
    Screen('FrameArc', g_strctPTB.m_hWindow, [255 255 255],g_strctPTB.m_fScale * aiHitRect,0,360);
    if k > iNumTargets
        Screen('FrameRect', g_strctPTB.m_hWindow, [255 255 255],aiTargetRect);
    else
        Screen('FrameRect', g_strctPTB.m_hWindow, [0 255 0],aiTargetRect,2);
    end
    
    if g_strctParadigm.m_iMachineState < 8
        for j=1:20:2*fObjectHalfSizePix+1
            Screen('DrawLine', g_strctPTB.m_hWindow, [200 200 200],aiTargetRect(1),aiTargetRect(2)+j, aiTargetRect(3), aiTargetRect(2)+j);
        end
    end
    
end


iNumTrials = g_strctParadigm.m_strctStatistics.m_iNumCorrect + ...
    g_strctParadigm.m_strctStatistics.m_iNumIncorrect + ...
    g_strctParadigm.m_strctStatistics.m_iNumTimeout + ...
    g_strctParadigm.m_strctStatistics.m_iNumShortHold;

fStartX = 400;
fStartY = 20;
if iNumTrials > 0
    Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Num Trials : %d',iNumTrials), fStartX,fStartY,[255 255 255]);
    Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Correct    : %d (%.1f%%, %.1f%%)',...
        g_strctParadigm.m_strctStatistics.m_iNumCorrect,g_strctParadigm.m_strctStatistics.m_iNumCorrect/iNumTrials*1e2,...
        g_strctParadigm.m_strctStatistics.m_iNumCorrect/(g_strctParadigm.m_strctStatistics.m_iNumCorrect+g_strctParadigm.m_strctStatistics.m_iNumIncorrect)*1e2), fStartX,fStartY+30,[0 255 0]);
    Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Incorrect  : %d (%.1f%%)',...
        g_strctParadigm.m_strctStatistics.m_iNumIncorrect,g_strctParadigm.m_strctStatistics.m_iNumIncorrect/iNumTrials*1e2), fStartX,fStartY+60,[255 0 0]);
    Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Timeout    : %d (%.1f%%)',...
        g_strctParadigm.m_strctStatistics.m_iNumTimeout,g_strctParadigm.m_strctStatistics.m_iNumTimeout/iNumTrials*1e2), fStartX,fStartY+90,[255 0 255]);
    Screen(g_strctPTB.m_hWindow,'DrawText', sprintf('Short Hold : %d (%.1f%%)',...
        g_strctParadigm.m_strctStatistics.m_iNumShortHold,g_strctParadigm.m_strctStatistics.m_iNumShortHold/iNumTrials*1e2), fStartX,fStartY+120,[255 255 0]);
    
end
fnDrawRunningPerformance();
return;

