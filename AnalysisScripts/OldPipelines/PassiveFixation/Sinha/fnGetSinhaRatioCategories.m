function [a2bStimulusCategory, acCatNames,strctAdditionalInfo] = fnGetSinhaRatioCategories(strSinhaMat)

if ~exist(strSinhaMat,'file')
    if exist('SelectedPerm.mat')
        strctInfo = load('SelectedPerm.mat');
    else
        strctInfo = load('\\kofiko\StimulusSet\Sinha_randbackAndControl\128x128\SelectedPerm.mat');
    end;
else
    strctInfo = load(strSinhaMat);    
end
%addpath('D:\Code\Doris\Stimuli_Generating_Code\');

if isfield(strctInfo,'a2iCorrectPerm')
    a2iAllPerm = [strctInfo.a2iCorrectPerm;strctInfo.a2iSelectedIncorrectPerm];
else
    a2iAllPerm=strctInfo.a2iAllPerm;
end


%[a2bCorrect] = fnIsCorrectPerm2(a2iAllPerm); % This returns a matrix of N x 12, telling if each one
% of the edge relationship holds or not.

acItemNames = {'Forehead','L Eye','Nose','R Eye','L Cheek','Up Lip','R Cheek','LL Cheek','Mouth','LR Cheek','Chin'};


strctAdditionalInfo.m_a2iContrastPerm = a2iAllPerm;
strctAdditionalInfo.m_acPartsName = acItemNames;

% Correct edge means a2iCorrectEdges(k,1) < a2iCorrectEdges(k,2)

% These are the ones that sinha proposed....

% a2iEdges = [...
%     2, 1;
%     4, 1;
%     2, 5;
%     4, 7;
%     2, 3;
%     4, 3;
%     6, 3;
%     9, 5;
%     9, 7;
%     9, 8;
%     9, 10;
%     9, 11];

a2iEdges = nchoosek(1:11,2);

iNumCategories = 2*size(a2iEdges,1)+2; %; % 12*2 + 3
iNumStimuli = 255;
a2bStimulusCategory = zeros(iNumStimuli,iNumCategories) > 0;
acCatNames = cell(1,iNumCategories);

for k=1:size(a2iEdges,1)
    iPart1 = a2iEdges(k,1);
    iPart2 = a2iEdges(k,2);    
    % Find all permutations such that intensity of part1 is larger than
    % part 2
    a2bStimulusCategory(a2iAllPerm(:,iPart1) > a2iAllPerm(:,iPart2),k) = 1;
    a2bStimulusCategory(a2iAllPerm(:,iPart1) < a2iAllPerm(:,iPart2),k+size(a2iEdges,1)) = 1;
    acCatNames{k} = [acItemNames{a2iEdges(k,1)} ' > ',acItemNames{a2iEdges(k,2)}];
    acCatNames{k+size(a2iEdges,1)} = [acItemNames{a2iEdges(k,1)} ' < ',acItemNames{a2iEdges(k,2)}];
end;

    
%    a2bStimulusCategory(find(a2bCorrect(:,k)==1), k) = 1;    % 
%    a2bStimulusCategory(find(a2bCorrect(:,k)==0), 12+k) = 1;
%    acCatNames{k} = [acItemNames{a2iEdges(k,1)} ' < ',acItemNames{a2iEdges(k,2)}];
%    acCatNames{12+k} = [acItemNames{a2iEdges(k,1)} ' > ',acItemNames{a2iEdges(k,2)}];

%a2bStimulusCategory( find(sum(a2bCorrect,2)==0), 25) = 1;
%acCatNames{25} = 'No Correct Ratio';

a2bStimulusCategory(243:252,iNumCategories-1) = 1;
acCatNames{iNumCategories-1} = 'Scrambled';

a2bStimulusCategory(253:255,iNumCategories) = 1;
acCatNames{iNumCategories} = 'Background';

return;
