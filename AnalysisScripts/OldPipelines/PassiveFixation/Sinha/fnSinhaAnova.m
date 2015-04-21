function strctStat = fnSinhaAnova(strctUnit,strctConfig,a2iPerm)
aiInd = find( (strctUnit.m_aiStimulusIndexValid >= 97 & strctUnit.m_aiStimulusIndexValid <= 528) | ...
              (strctUnit.m_aiStimulusIndexValid >= 534 & strctUnit.m_aiStimulusIndexValid <= 544) );
if isempty(aiInd)
    strctStat = [];
    return;
end;

afFiringRateCropped = strctUnit.m_afStimulusResponseMinusBaseline(aiInd);
         
aiStimuliIndex = strctUnit.m_aiStimulusIndexValid(aiInd);
aiStimuliIndex(aiStimuliIndex >= 97 & aiStimuliIndex <= 528) = aiStimuliIndex(aiStimuliIndex >= 97 & aiStimuliIndex <= 528) - 96; 
aiStimuliIndex(aiStimuliIndex >= 534 & aiStimuliIndex <= 544) = aiStimuliIndex(aiStimuliIndex >= 534 & aiStimuliIndex <= 544) - 533 + 432; 
% append last ones
for k=1:11
    a2iPerm(432+k,:) = k;
end

a2iIntensityLevels = a2iPerm(aiStimuliIndex,:);

acAllPartGroups = cell(1,11);
for k=1:11
    acAllPartGroups{k} = a2iIntensityLevels(:,k)';
end

% Now, prepare the "levels" for each "factor"          
[strctAnova.m_afP, strctAnova.m_acTable,strctAnova.m_strctStat] = anovan(afFiringRateCropped, acAllPartGroups,'display','off');
% pthres = 0.05;
% % How much variance is explaiend by the significant factors ?
% aiSigParts = find(p < pthres);
% fPartVariance = sum(cat(1,strctAnova.m_acTable{1+aiSigParts ,2}));
% fTotalVariance = strctAnova.m_acTable{end,2};
% fFractionExplainedSig= fPartVariance/fTotalVariance * 100;
% fFractionExplainedAll=  sum(cat(1,strctAnova.m_acTable{2:end-1 ,2}))/fTotalVariance * 100;

% Run pair-wise 2-way anova
a2iSigPairs = nchoosek(1:11,2);
for iPairIter=1:55
   iPartA =a2iSigPairs(  iPairIter,1);
   iPartB =a2iSigPairs(  iPairIter,2);
   % Run 2-way anova with 11 levels and model interaction
   
    acGroups = cell(1,2);
    acGroups{1} = a2iIntensityLevels(:,iPartA)';
    acGroups{2} = a2iIntensityLevels(:,iPartB)';
    [astrctPairwiseAnova(iPairIter).m_afP,...
        astrctPairwiseAnova(iPairIter).m_acTable] = ...
        anovan(afFiringRateCropped, acGroups,'display','off','model','interaction');
end

strctStat.m_strctAnova = strctAnova;
strctStat.m_astrctPairwiseAnova = astrctPairwiseAnova;


return;
