function fChoicesOnsetTS = fnDisplayChoices(hPTBWindow, aiChoices, strctCurrentTrial, acMedia,bFlip,bClear,bHighlightRewardedChoices,fScale, bDrawResponseRegion)
global  g_strctPTB
% Clear screen
if bClear
    Screen('FillRect',hPTBWindow, strctCurrentTrial.m_strctChoices.m_afBackgroundColor);
end


for iChoiceIter=aiChoices
    if strctCurrentTrial.m_bLoadOnTheFly
        iLocalMediaIndex = 1+iChoiceIter;
    else
        iLocalMediaIndex = strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_iMediaIndex;
    end
    
    aiTextureSize = [ acMedia{iLocalMediaIndex}.m_iWidth,acMedia{iLocalMediaIndex}.m_iHeight];
    
    aiStimulusRect = fnComputeStimulusRect(strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_fSizePix,aiTextureSize, ...
        strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_pt2fPosition);
    
    Screen('DrawTexture', hPTBWindow, acMedia{iLocalMediaIndex}.m_hHandle,[],fScale*aiStimulusRect, 0);
    
    if bHighlightRewardedChoices
        if strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_bJuiceReward
            Screen('FrameRect', hPTBWindow, [0 255 0],fScale*aiStimulusRect,3);
        end
        if bDrawResponseRegion
            aiResponseRect = [strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_pt2fPosition(:)'-ones(1,2)*strctCurrentTrial.m_strctChoices.m_fInsideChoiceRegionSize,...
                                             strctCurrentTrial.m_astrctChoicesMedia(iChoiceIter).m_pt2fPosition(:)'+ones(1,2)*strctCurrentTrial.m_strctChoices.m_fInsideChoiceRegionSize];
            switch lower(strctCurrentTrial.m_strctChoices.m_strInsideChoiceRegionType)
                case 'rect'
                              Screen('FrameRect', hPTBWindow, [255 255 255],fScale*aiResponseRect);
                case 'circular'
                              Screen('FrameArc', hPTBWindow, [255 255 255],fScale*aiResponseRect,0,360);
                    
            end
        end
        
        
    end
    
end

if  strctCurrentTrial.m_strctChoices.m_bShowFixationSpot
      fnDrawFixationSpot(hPTBWindow, strctCurrentTrial.m_strctChoices, false, fScale);
end


if bFlip
    fChoicesOnsetTS =fnFlipWrapper(hPTBWindow); % This would block the server until the next flip.
    if ~g_strctPTB.m_bRunningOnStimulusServer
        fChoicesOnsetTS =  GetSecs(); % Don't trust TS obtained from flip on touch mode
    end
else
    fChoicesOnsetTS =  NaN;
end

return;