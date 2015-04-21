function [astrctCategories, aiCategories, acCatNames] = fnGetSinhaCategories(strSinhaMat)
strctInfo = load(strSinhaMat);
addpath('D:\Code\Doris\Stimuli\');

a2iAllPerm = [strctInfo.a2iCorrectPerm;strctInfo.a2iSelectedIncorrectPerm];
[abCorrect, aiNumWrongRatios] = fnIsCorrectPerm(a2iAllPerm);

%[a2bCorrect] = fnIsCorrectPerm2(a2iAllPerm);


aiUniqueCat = unique(aiNumWrongRatios);
for k=1:length(aiUniqueCat)
    astrctCategories(k).m_strName = sprintf('%d Incorrect',aiUniqueCat(k));
    astrctCategories(k).m_aiIndices = find(aiNumWrongRatios==aiUniqueCat(k));
end;


for k=1:length(astrctCategories)
    aiCategories(astrctCategories(k).m_aiIndices) = k;
    acCatNames{k} = astrctCategories(k).m_strName;
end;

return;
