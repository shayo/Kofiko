strRootLocal = 'D:\Data\Doris\Stimuli\OddOneOut\FourCategories\';
acCaltech2 = fnGetAllFilesRecursive(strRootLocal,'.jpg');

acFilesNames = acCaltech2;
acCategories = {};
iNumFiles = length(acFilesNames);
aiFileToCategory = zeros(1,iNumFiles);
for iFileIter=1:iNumFiles
    acFilesNames{iFileIter} = acFilesNames{iFileIter}(length(strRootLocal)+1:end);
    [strPath,strFile,strExt] = fileparts(acFilesNames{iFileIter});
    iIndex = find(ismember(acCategories,strPath));
    if isempty(iIndex)
        acCategories(end+1) = {strPath};
        aiFileToCategory(iFileIter) = length(acCategories);
    else
        aiFileToCategory(iFileIter) = iIndex;
    end
end
iNumCategories = length(acCategories);
aiNumImagesInEachCategory = hist(aiFileToCategory,1:iNumCategories);

% acCatToFileIndex = cell(1,iNumCategories);
% for iCatIter=1:iNumCategories
%     acCatToFileIndex{iCatIter} = find(aiFileToCategory == iCatIter);
% end

%% Generate design for odd one out

strRootFolder = '\\Touch\Shay\Data\StimulusSet\Caltech256\';
save('OddOneOut4','acCategories','aiFileToCategory','strRootFolder','aiNumImagesInEachCategory','acFilesNames')


%%
% Randomly pick two categoreies
iCat1 = 1+round(rand() * (iNumCategories-1));
iCat2 = 1+round(rand() * (iNumCategories-1));

bDuplicate = true;

iNumCat1 = 3;
% Randomly pick images for category 1
aiSelectedImagesCat1 = 1+round(rand(1,iNumCat1) * (aiNumImagesInEachCategory(iCat1)-1));
if bDuplicate
    aiSelectedImagesCat1(2:end) = aiSelectedImagesCat1(1);
end
iSelectedImagesCat2 =1+round(rand(1) * (aiNumImagesInEachCategory(iCat2)-1));

aiCat1 = find(aiFileToCategory == iCat1);
aiCat2 = find(aiFileToCategory == iCat2);

acImages = cell(1,iNumCat1+1);
for iImageIter=1:iNumCat1
    acImages{iImageIter}=imread(acFilesNames{aiCat1(aiSelectedImagesCat1(iImageIter))});
end
acImages{iNumCat1+1} = imread(acFilesNames{aiCat2(iSelectedImagesCat2)});

figure(10);
clf;
for k=1:4
    subplot(2,2,k);
    imshow(acImages{k});
end;
%%

