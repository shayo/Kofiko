function [abCorrect, aiNumWrongRatios] = fnIsCorrectPerm3(a2iPerm, a2iCorrectPairALargerB)
iNumPerm = size(a2iPerm,1);
aiNumWrongRatios = zeros(iNumPerm,1,'uint8');
for iEdgeIter=1:size(a2iCorrectPairALargerB,1)
    aiNumWrongRatios = aiNumWrongRatios + ...
        uint8(a2iPerm(:, a2iCorrectPairALargerB(iEdgeIter,1)) < a2iPerm(:,a2iCorrectPairALargerB(iEdgeIter,2)));
end;

abCorrect = aiNumWrongRatios == 0;

return;