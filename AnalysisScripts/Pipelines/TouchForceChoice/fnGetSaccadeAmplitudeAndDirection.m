function [afAmplitude, a2fDirection]= fnGetSaccadeAmplitudeAndDirection(astrctIntervals, afX, afY,iAveragingInterval)
iNumIntervals = length(astrctIntervals);
afAmplitude = zeros(1,iNumIntervals);
a2fDirection = zeros(2,iNumIntervals);
 for k=1:iNumIntervals
        % sample eye position just before and just after the saccade.
        aiJustBeforeInd = max(1, astrctIntervals(k).m_iStart-iAveragingInterval:astrctIntervals(k).m_iStart);
        aiJustAfterInd = min(length(afX), astrctIntervals(k).m_iEnd:astrctIntervals(k).m_iEnd+iAveragingInterval);
        
        pt2fAvgEyePosBeforeSaccade = [median(afX(aiJustBeforeInd)), median(afY( aiJustBeforeInd))];
        pt2fAvgEyePosAfterSaccade = [median(afX(aiJustAfterInd)), median(afY( aiJustAfterInd))];
        afAmplitude(k) = norm(pt2fAvgEyePosBeforeSaccade-pt2fAvgEyePosAfterSaccade);
        a2fDirection(:,k) = (pt2fAvgEyePosAfterSaccade-pt2fAvgEyePosBeforeSaccade) ./ afAmplitude(k);
 end
return;
