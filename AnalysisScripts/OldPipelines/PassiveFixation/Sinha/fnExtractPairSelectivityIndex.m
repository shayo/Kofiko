load('D:\Code\Doris\Stimuli_Generating_Code\CBCL\CBCL_For_Electrophsy_Data.mat');

% 
%     load('a3bPartMasks.mat');
%     a2iParts = zeros(size(a3bPartMasks,1),size(a3bPartMasks,2));
% 
%     iNumParts = 11;
%     for k=1:iNumParts
%         P = a3bPartMasks(:,:,k);
%         a2iParts(P) = k;
%     end
%     T=padarray(a2iParts,[0 (613-427)/2],'both');
% 
% 
%     pt2iTemplateLeftEyePos = [220, 268];
%     pt2iTemplateRightEyePos = [379, 268];
%     pt2iTemplateMouth = [306, 452];
%     %
%     % figure(1);
%     % clf;
%     % imshow(T,[]);
%     acPartCoords = cell(1,iNumParts);
%     acPartBoundary = cell(1,iNumParts);
%     for k=1:iNumParts
%         [aiY,aiX] = find(T==k);
%         X=  bwboundaries(T==k);
%         acPartBoundary{k} = [X{1}(:,2) - pt2iTemplateLeftEyePos(1), X{1}(:,1) - pt2iTemplateLeftEyePos(2)];
%         acPartCoords{k} = [aiX-pt2iTemplateLeftEyePos(1),aiY-pt2iTemplateLeftEyePos(2)];
%     end
% 
% 
%     iTemplateImageEyeEyeDist = pt2iTemplateRightEyePos(1)-pt2iTemplateLeftEyePos(1);
%     iTemplateImageEyeMouthDist = pt2iTemplateMouth(2) - pt2iTemplateRightEyePos(2);
% 
% 
% 
%     %load('CBCL_Training');
%     %load('CBCL_Testing');
%     strCBCL_Folder_Train_Face = 'D:\Courses\Caltech\CNS186\Project\Images\CMU_CBCL\face.train.tar\train\face\';
%     strCBCL_Folder_Train_NonFace = 'D:\Courses\Caltech\CNS186\Project\Images\CMU_CBCL\face.train.tar\train\non-face\';
% 
%     [a2fAvgIntTrainFace,a2fMedIntTrainFace, a3fTrainFace] = fnReadImagesAndComputePartResponse(strCBCL_Folder_Train_Face,iTemplateImageEyeEyeDist,iTemplateImageEyeMouthDist,acPartCoords);
%     [a2fAvgIntTrainNonFace,a2fMedIntTrainNonFace, a3fTrainNonFace] = fnReadImagesAndComputePartResponse(strCBCL_Folder_Train_NonFace,iTemplateImageEyeEyeDist,iTemplateImageEyeMouthDist,acPartCoords);
% 
% 
%     a2iPartRatio = nchoosek(1:11,2);
% 
% 
%     a2iCorrectEdges = [...
%         2, 1;
%         4, 1;
%         2, 5;
%         4, 7;
%         2, 3;
%         4, 3;
%         6, 3;
%         9, 5;
%         9, 7;
%         9, 8;
%         9, 10;
%         9, 11];
% 
%     aiSinhaRatio = zeros(1,12);
%     for k=1:12
%         aiSinhaRatio(k) = find(a2iPartRatio(:,1) == a2iCorrectEdges(k,1) & a2iPartRatio(:,2) == a2iCorrectEdges(k,2) | ...
%             a2iPartRatio(:,1) == a2iCorrectEdges(k,2) & a2iPartRatio(:,2) == a2iCorrectEdges(k,1));
%     end

    
afSumTrainFaceAvg = sum(a2fAvgIntTrainFace(:,a2iCorrectEdges(:,1)) < a2fAvgIntTrainFace(:,a2iCorrectEdges(:,2)), 2);
afSumTrainNonFaceAvg = sum(a2fAvgIntTrainNonFace(:,a2iCorrectEdges(:,1)) < a2fAvgIntTrainNonFace(:,a2iCorrectEdges(:,2)), 2);

iNumSubset = size(a2fAvgIntTrainFace,1);
a2iPairs = nchoosek(1:iNumParts,2);
iNumPairs = size(a2iPairs,1);
a2bALargerB = zeros(iNumSubset,iNumPairs);

for k=1:iNumSubset
    afIntensities = a2fAvgIntTrainFace(k,:);
    for iRatioIter=1:iNumPairs
        iPartA = a2iPairs(iRatioIter,1);
        iPartB = a2iPairs(iRatioIter,2);
        a2bALargerB(k,iRatioIter) = afIntensities(iPartA) > afIntensities(iPartB);
    end
end


afHistPos = sum(a2bALargerB == 1,1);
afHistNeg = sum(a2bALargerB == 0,1);
aiSelectivityIndex = (afHistPos-afHistNeg)./(afHistPos+afHistNeg);
figure(1);
clf;
subplot(2,1,1);
hold on;
bar(1:55, afHistPos);
bar(1:55, -afHistNeg,'facecolor','r');
ylabel('Number of images');
title('Contrast Polarity Histogram');
xlabel('Pairs');

subplot(2,1,2);
bar(1:55,aiSelectivityIndex);

fThreshold = 0.7;
hold on;
plot([1 55],[fThreshold fThreshold],'c');
plot([1 55],-[fThreshold fThreshold],'c')
title('Pair Selectivity Index');
ylabel('Index');
xlabel('Pairs');
aiInvarianceRatios = find(abs(aiSelectivityIndex) > fThreshold);
fprintf('%d pairs survived the thresholding\n', length(aiInvarianceRatios))
aiPos = find(aiSelectivityIndex > fThreshold);
aiNeg = find(aiSelectivityIndex < -fThreshold);

subplot(2,1,2);
bar(aiPos, ones(1,length(aiPos)),'edgecolor','g','facecolor','none','linewidth',2);
bar(aiNeg, -ones(1,length(aiNeg)),'edgecolor','g','facecolor','none','linewidth',2);


% 
% for k=1:length(aiInvarianceRatios)
%     strPartA = acPartNames{a2iPairs(aiInvarianceRatios(k),1)};
%     strPartB = acPartNames{a2iPairs(aiInvarianceRatios(k),2)};
%     if aiSelectivityIndex(aiInvarianceRatios(k)) > 0
%         fprintf('[%s > %s]\n',strPartA, strPartB);
%     else
%         fprintf('[%s > %s]\n',strPartB, strPartA);
%     end
%         
% end
% fprintf('\n\n');


%% Sinha proposed ratios
a2iCorrectPairALargerB = [...
    1, 2;
    1, 4;
    5, 2;
    7, 4;
    3, 2;
    3, 4;
    3, 6;
    5, 9;
    7, 9;
    8, 9;
    10, 9;
    11, 9];

aiSinhaRatios = zeros(1,size(a2iCorrectPairALargerB,1));
for j=1:size(a2iCorrectPairALargerB,1)
    aiSinhaRatios(j)= find(...
    (a2iPairs(:,1) == a2iCorrectPairALargerB(j,1) & a2iPairs(:,2) == a2iCorrectPairALargerB(j,2)) | ...
    (a2iPairs(:,2) == a2iCorrectPairALargerB(j,1) & a2iPairs(:,1) == a2iCorrectPairALargerB(j,2)));
end


%%
save('SinhaPairSelectivityIndex','aiSelectivityIndex','aiSinhaRatio');

%intersect(aiInvarianceRatios, aiSinhaRatio)
