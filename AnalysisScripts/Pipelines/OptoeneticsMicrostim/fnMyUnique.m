function [afUniqueValues, aiMappingToUnique, aiCount] = fnMyUnique(afValues, fMergeDistance)
afUniqueValues(1) = afValues(1);
iNumValues = length(afValues);
aiMappingToUnique = zeros(1,iNumValues);
aiMappingToUnique(1) = 1;
aiCount(1) = 1;
for k=2:length(afValues)
    % Compute distance to current unique values
    [fMinDist, iUniqueIndex] = min( abs(afValues(k) - afUniqueValues));
    if fMinDist > fMergeDistance
        afUniqueValues = [afUniqueValues, afValues(k)];
        aiMappingToUnique(k) = length(afUniqueValues);
        aiCount(length(afUniqueValues)) = 1;
    else
        aiMappingToUnique(k) = iUniqueIndex;
        aiCount(iUniqueIndex) = aiCount(iUniqueIndex) + 1;
    end
end

for k=1:length(afUniqueValues)
   afUniqueValues(k) = median( afValues(aiMappingToUnique==k));
end
