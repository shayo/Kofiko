function [a2fFirstOrder,a3fSecondOrder,a2fDiff] = fnReconstructContrastCurve(a2iPerm, afPredictedResponse)
a2iPartRatio = nchoosek(1:11,2);
a3fSecondOrder = ones(11,11,55)*NaN;
a2fFirstOrder = ones(11,11);
a2fDiff = NaN*ones(55,21);


for k=1:11
    for iIntIter=1:11
        aiInd = find(a2iPerm(:,k) == iIntIter);
        a2fFirstOrder(k,iIntIter) =nanmean(afPredictedResponse(aiInd));
    end
end


for k=1:55
    iPartA = a2iPartRatio(k,1);
    iPartB = a2iPartRatio(k,2);
    for iIntIter1=1:11
        for iIntIter2=1:11
            aiStimuli = find( a2iPerm(:,iPartA) == iIntIter1 & a2iPerm(:,iPartB) == iIntIter2 );
            if ~isempty(aiStimuli)
                a3fSecondOrder(iIntIter1,iIntIter2,k) = nanmean(afPredictedResponse(aiStimuli));
            end
        end
    end
end


for k=1:55
    iPartA = a2iPartRatio(k,1);
    iPartB = a2iPartRatio(k,2);
    for iIntDiff=-10:10
        aiStimuli = find( a2iPerm(:,iPartA) -a2iPerm(:,iPartB) == iIntDiff);
        if ~isempty(aiStimuli)
           a2fDiff(k, iIntDiff+11) =  nanmean(afPredictedResponse(aiStimuli));
        end
    end
end

return;