function [fDprime,fAreaUnderROC,fTwoSidedpValue] = fnDPrimeROC(afResPos, afResNeg, bPermutationTest)
afResNeg=afResNeg(~isnan(afResNeg));
afResPos=afResPos(~isnan(afResPos));
afAllRes = unique([afResNeg(:)' ,afResPos(:)']);

afHitRate = zeros(1,length(afAllRes));
afFA_Rate = zeros(1,length(afAllRes));
for j=1:length(afAllRes)
    Thres = afAllRes(j);
    afHitRate(j) = sum(afResPos >= Thres)/length(afResPos);
    afFA_Rate(j) = sum(afResNeg >= Thres)/length(afResNeg);
end
fAreaUnderROC = -trapz(afFA_Rate,afHitRate);
if fAreaUnderROC < 0.5
    fAreaUnderROC = 1-fAreaUnderROC;
end
fDprime = sqrt(2)*norminv(min(1-eps,fAreaUnderROC));

if ~exist('bPermutationTest','var')
    bPermutationTest = false;
end
if bPermutationTest
    % Permutation test?
    afAllResponses = [afResPos(:); afResNeg(:)]';
    
    m = length(afAllResponses);
    N = 1000; % Number of permutation tests...
    
    a2fTmp = rand(N,m);
    [a2fDummy, a2iSortInd]=sort(a2fTmp,2);
    a2fRandomizedResponses = reshape(afAllResponses(a2iSortInd),size(a2iSortInd));
    iNumPos = length(afResPos);
    iNumNeg = length(afResNeg);
    
    a2fPos = a2fRandomizedResponses(:,1:iNumPos);
    a2fNeg = a2fRandomizedResponses(:,iNumPos+1:end);
    afAreaUnderROC = zeros(1,N);
    for iPermutationTestIter=1:N
        afHitRatePerm = zeros(1,length(afAllRes));
        afFA_RatePerm = zeros(1,length(afAllRes));
        for j=1:length(afAllRes)
            Thres = afAllRes(j);
            afHitRatePerm(j) = sum(a2fPos(iPermutationTestIter,:) >= Thres)/iNumPos;
            afFA_RatePerm(j) = sum(a2fNeg(iPermutationTestIter,:) >= Thres)/iNumNeg;
        end
        afAreaUnderROC(iPermutationTestIter) = -trapz(afFA_RatePerm,afHitRatePerm);
    end
    
    fTwoSidedpValue = sum(afAreaUnderROC > fAreaUnderROC | afAreaUnderROC < 1-fAreaUnderROC) / N;
else
    fTwoSidedpValue = NaN;
end

return;

