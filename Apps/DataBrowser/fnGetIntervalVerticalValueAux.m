function aiUnitVertical = fnGetIntervalVerticalValueAux(astrctUnitIntervals)
aiUnitVertical = [];

% Determine the vertical value for each unit...
MaxUnitsAtSameTimePoints = 20;
abVerticalOccupied = zeros(1,MaxUnitsAtSameTimePoints)> 0;
iNumUnitIntervals = length(astrctUnitIntervals);
aiUnitVertical = zeros(1,iNumUnitIntervals);
a2fIntervals = cat(1,astrctUnitIntervals.m_afInterval);
if isempty(a2fIntervals)
    return;
end;
afAllStart = a2fIntervals(:,1);
afAllEnd = a2fIntervals(:,2);
[afTimeSteps,aiUnitInd] = sort( [afAllStart;afAllEnd]);

for iTimeStepIter=1:length(afTimeSteps);
    iInterval = aiUnitInd(iTimeStepIter);
    bStart = true;
    if iInterval > iNumUnitIntervals
        iInterval=iInterval-iNumUnitIntervals;
        bStart = false;
    end
    % Find the first empty slot
    if bStart
        iVerticalIndex = find(abVerticalOccupied == false,1,'first');
        aiUnitVertical(iInterval) = iVerticalIndex;
        abVerticalOccupied(iVerticalIndex) = true;
    else
        iVerticalIndex = aiUnitVertical(iInterval);
        abVerticalOccupied(iVerticalIndex) = false;
    end
    
    
end
return;