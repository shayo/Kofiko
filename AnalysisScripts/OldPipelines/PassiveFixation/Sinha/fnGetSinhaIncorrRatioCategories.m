function [astrctCategories, aiCategories, acCatNames] = fnGetSinhaIncorrRatioCategories(strSinhaMat)
strctInfo = load(strSinhaMat);
addpath('D:\Code\Doris\Stimuli_Generating_Code\');

a2iAllPerm = [strctInfo.a2iCorrectPerm;strctInfo.a2iSelectedIncorrectPerm];
[a2bCorrect] = fnIsCorrectPerm2(a2iAllPerm);
a2bCorrect = ~a2bCorrect;

acItemNames = {'Forehead','L Eye','Nose','R Eye','L Cheek','Up Lip','R Cheek','LL Cheek','Mouth','LR Cheek','Chin'};
% Correct edge means a2iCorrectEdges(k,1) < a2iCorrectEdges(k,2)
a2iEdges = [...
    2, 1;
    4, 1;
    2, 5;
    4, 7;
    2, 3;
    4, 3;
    6, 3;
    9, 5;
    9, 7;
    9, 8;
    9, 10;
    9, 11];


for k=1:size(a2iEdges,1)
    
    astrctCategories(k).m_strName = [acItemNames{a2iEdges(k,1)} ' > ',acItemNames{a2iEdges(k,2)}]; %sprintf('%dth Ratio Correct',k);
    astrctCategories(k).m_aiIndices = find(a2bCorrect(:,k)==1);
end;

astrctCategories(13).m_strName = sprintf('No Correct Ratio',k);
astrctCategories(13).m_aiIndices = find(sum(a2bCorrect,2)==0);


for k=1:length(astrctCategories)
    aiCategories(astrctCategories(k).m_aiIndices) = k;
    acCatNames{k} = astrctCategories(k).m_strName;
end;

return;
