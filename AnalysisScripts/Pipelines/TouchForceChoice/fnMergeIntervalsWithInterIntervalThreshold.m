function astrctIntervals = fnMergeIntervalsWithInterIntervalThreshold(astrctIntervals,fDistance, afSpeed)
% Merge stable intervals if the advancer did not move more than iDistance
% during inter-intervals....
iStartK = 1;
while 1
    bMerged = false;
    
    for k=iStartK:length(astrctIntervals)-1
        fTravelledDistance = sum(afSpeed(astrctIntervals(k).m_iEnd :astrctIntervals(k+1).m_iStart));
        if fTravelledDistance < fDistance 
            astrctIntervals(k).m_iEnd = astrctIntervals(k+1).m_iEnd;
            astrctIntervals(k).m_iLength = astrctIntervals(k).m_iEnd-astrctIntervals(k).m_iStart+1;
            astrctIntervals(k+1) = [];
            iStartK = k;
            bMerged = true;
            break;
        end;
    end;
    
    if ~bMerged
        break;
    end;
end;

return;
