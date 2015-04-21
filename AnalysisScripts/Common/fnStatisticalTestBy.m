function a2fPValue = fnStatisticalTestBy(a2bRaster, aiStimulusIndex, a2bStimulusCategory, ...
    iStartAvg, iEndAvg, iStartBaselineAvg, iEndBaselineAvg)

%iNumStimuli = size(a2bStimulusCategory,1);
iNumCategories = size(a2bStimulusCategory,2);
afAvgFiringCatBaseline = 1e3*mean(a2bRaster(:, iStartBaselineAvg:iEndBaselineAvg),2);

if iNumCategories == 1
    % Compare against baseline...
    abSamplesCat1 = ismember(aiStimulusIndex, find(a2bStimulusCategory(:, 1)));
    afAvgFiringCat1 = 1e3*mean(a2bRaster(abSamplesCat1, iStartAvg:iEndAvg),2);
    a2fPValue = ranksum(afAvgFiringCat1,afAvgFiringCatBaseline);
    return;    
end;

%iNumComparisons = iNumCategories*(iNumCategories-1)/2;
% if bBonferroniCorrection
%     fSignificanceLevel = fSignificanceLevel / iNumComparisons; % Bonferroni correction
% end;

a2fPValue = zeros(iNumCategories+1,iNumCategories+1); % Last one is baseline
warning off

for iCat1=1:iNumCategories
    abSamplesCat1 = ismember(aiStimulusIndex, find(a2bStimulusCategory(:, iCat1)));
    afAvgFiringCat1 = 1e3*mean(a2bRaster(abSamplesCat1, iStartAvg:iEndAvg),2);
    if isempty(afAvgFiringCat1)
        continue;
    end;
    
    for iCat2=iCat1+1:iNumCategories
        % Find all stimuli that fit a certain category
        abSamplesCat2 = ismember(aiStimulusIndex, find(a2bStimulusCategory(:, iCat2)));
        afAvgFiringCat2 = 1e3*mean(a2bRaster(abSamplesCat2, iStartAvg:iEndAvg),2);
        if isempty(afAvgFiringCat2)
            continue;
        end;
        
        [p] = ranksum(afAvgFiringCat1,afAvgFiringCat2);
        a2fPValue(iCat1,iCat2) = p;
        a2fPValue(iCat2,iCat1) = p;        
    end;
    
    % Compare against baseline...
    [p] = ranksum(afAvgFiringCat1,afAvgFiringCatBaseline);
    a2fPValue(iCat1,end) = p;
    a2fPValue(end,iCat1) = p;
    
end;
warning on
return;
