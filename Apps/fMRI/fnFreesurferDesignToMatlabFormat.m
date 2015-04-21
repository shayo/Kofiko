function strctDesign = fnFreesurferDesignToMatlabFormat(Tmp)
% Tmp: [StartTime, Condition Number, Duration, Condition Name]
% Assume fixed block design....
aiConditionNumbers = unique(Tmp{2});
iNumCond = length(aiConditionNumbers);
for iCondIter=1:iNumCond
    abConditionON = (Tmp{2} == aiConditionNumbers(iCondIter));
    strctDesign.m_astrctCond(iCondIter).m_strName = Tmp{4}{find(abConditionON,1,'first')};
    strctDesign.m_astrctCond(iCondIter).m_afStartTime = Tmp{1}(abConditionON);
    strctDesign.m_astrctCond(iCondIter).m_afDuration = Tmp{3}(abConditionON);
    % Squeeze times (in case sebastian-style list is loaded)
    iNumAppearances = length(strctDesign.m_astrctCond(iCondIter).m_afStartTime);
    bChanged = true;
    while (1)
        bChanged = false;
        for k=1:iNumAppearances-1
            if  strctDesign.m_astrctCond(iCondIter).m_afStartTime(k)+strctDesign.m_astrctCond(iCondIter).m_afDuration(k) == strctDesign.m_astrctCond(iCondIter).m_afStartTime(k+1)
                strctDesign.m_astrctCond(iCondIter).m_afDuration(k) = strctDesign.m_astrctCond(iCondIter).m_afDuration(k) + strctDesign.m_astrctCond(iCondIter).m_afDuration(k+1);
                strctDesign.m_astrctCond(iCondIter).m_afDuration(k+1) = [];
                strctDesign.m_astrctCond(iCondIter).m_afStartTime(k+1) = [];
                iNumAppearances = length(strctDesign.m_astrctCond(iCondIter).m_afStartTime);
                bChanged = true;
                break;
            end
        end
        if ~bChanged
            break;
        end;
    end
    
end
return;