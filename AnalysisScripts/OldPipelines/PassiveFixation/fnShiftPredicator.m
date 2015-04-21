function a3fIntensityResponseShiftPredicator = fnShiftPredicator(a2iPerm,aiShiftPredicators,strctUnit,iStartAvg,iEndAvg,a2fRasterSmooth)
iNumParts = 11;
iNumIntensities = 11;
iStimulusOffset = 96;
iNumShiftPredicators = length(aiShiftPredicators);
a3fIntensityResponseShiftPredicator = zeros(iNumParts, iNumIntensities, iNumShiftPredicators);

a2iShifted = zeros(iNumShiftPredicators, sum(strctUnit.m_aiStimulusIndexValid > iStimulusOffset));
for iShiftPredicatorIter=aiShiftPredicators
    aiSinhaIndShifted = circshift(strctUnit.m_aiStimulusIndexValid(strctUnit.m_aiStimulusIndexValid > iStimulusOffset), iShiftPredicatorIter);
    a2iShifted(iShiftPredicatorIter,:) = aiSinhaIndShifted;
end

% Compute Shift Predicators
for iPartIter=1:iNumParts
    for iIntensityIter=1:iNumIntensities
        aiInd = find(a2iPerm(:,iPartIter) == iIntensityIter);
        if ~isempty(aiInd)
            for iShiftPredicatorIter=aiShiftPredicators
                  
                aiStimulusIndexShifted = strctUnit.m_aiStimulusIndexValid;
                aiStimulusIndexShifted(strctUnit.m_aiStimulusIndexValid > iStimulusOffset) = a2iShifted(iShiftPredicatorIter,:);
                 a3fIntensityResponseShiftPredicator(iPartIter, iIntensityIter,iShiftPredicatorIter) = ...
                    mean( mean(a2fRasterSmooth(ismember(aiStimulusIndexShifted,iStimulusOffset+aiInd),iStartAvg:iEndAvg),2));
            end
        end
    end
end

return;