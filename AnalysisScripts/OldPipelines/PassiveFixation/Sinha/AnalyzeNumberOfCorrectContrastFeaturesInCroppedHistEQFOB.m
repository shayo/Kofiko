astrctFiles = dir('D:\Data\Doris\Stimuli\Monkey_Bodyparts\CroppedHistFaces\*.bmp');
for k=1:length(astrctFiles)
    I(:,:,k) =imread(['D:\Data\Doris\Stimuli\Monkey_Bodyparts\CroppedHistFaces\',astrctFiles(k).name]);
end;
J = I(29:74,31:71,:);
pt2iLeftEye = [11,14.8];
pt2iRightEye = [31.5,14.8];
pt2iMouth = [20.8,38.3];




load('D:\Code\Doris\Stimuli_Generating_Code\CBCL\a3bPartMasks.mat');
a2iParts = zeros(size(a3bPartMasks,1),size(a3bPartMasks,2));

iNumParts = 11;
for k=1:iNumParts
    P = a3bPartMasks(:,:,k);
    a2iParts(P) = k;
end
T=padarray(a2iParts,[0 (613-427)/2],'both');


pt2iTemplateLeftEyePos = [220, 268];
pt2iTemplateRightEyePos = [379, 268];
pt2iTemplateMouth = [306, 452];

acPartCoords = cell(1,iNumParts);
acPartBoundary = cell(1,iNumParts);
for k=1:iNumParts
    [aiY,aiX] = find(T==k);
    X=  bwboundaries(T==k);
    acPartBoundary{k} = [X{1}(:,2) - pt2iTemplateLeftEyePos(1), X{1}(:,1) - pt2iTemplateLeftEyePos(2)];
    acPartCoords{k} = [aiX-pt2iTemplateLeftEyePos(1),aiY-pt2iTemplateLeftEyePos(2)];
end


iTemplateImageEyeEyeDist = pt2iTemplateRightEyePos(1)-pt2iTemplateLeftEyePos(1);
iTemplateImageEyeMouthDist = pt2iTemplateMouth(2) - pt2iTemplateRightEyePos(2);

%%
iTestImageEyeEyeDist = pt2iRightEye(1)-pt2iLeftEye(1);
iTestImageEyeMouthDist = pt2iMouth(2) - pt2iRightEye(2);
fScaleX = 0.9*iTestImageEyeEyeDist / iTemplateImageEyeEyeDist;
fScaleY = iTestImageEyeMouthDist / iTemplateImageEyeMouthDist;
iNumParts = length(acPartCoords);
acPartCoordsResized = cell(1,iNumParts);
acPartBoundaryResized = cell(1,iNumParts);
for k=1:iNumParts
    acPartCoordsResized{k} = [acPartCoords{k}(:,1) * fScaleX + pt2iLeftEye(1),acPartCoords{k}(:,2) * fScaleY + pt2iLeftEye(2)];
    acPartBoundaryResized{k} = [acPartBoundary{k}(:,1) * fScaleX + pt2iLeftEye(1),acPartBoundary{k}(:,2) * fScaleY + pt2iLeftEye(2)];
end

figure(2);
clf;
imagesc(mean(double(J),3));
colormap gray;
hold on;
for k=1:11
    plot(acPartBoundaryResized{k}(:,1),acPartBoundaryResized{k}(:,2),'b');
end
plot(pt2iLeftEye(1),pt2iLeftEye(2),'r+');
plot(pt2iRightEye(1),pt2iRightEye(2),'r+');
plot(pt2iMouth(1),pt2iMouth(2),'g+');

%%
iNumTrainingFiles = 16;

% Read values
a2fAvgInt= zeros(iNumTrainingFiles,iNumParts);
a2fMedInt= zeros(iNumTrainingFiles,iNumParts);
a2fStdInt = zeros(iNumTrainingFiles,iNumParts);
for iImageIter=1:iNumTrainingFiles
     for k=1:iNumParts
        afX = acPartCoordsResized{k}(:,1);
        afY = acPartCoordsResized{k}(:,2);
        afV = interp2(double(double(J(:,:,iImageIter)))/255, afX, afY);
        a2fMedInt(iImageIter,k) = median(afV(~isnan(afV)));
        a2fAvgInt(iImageIter,k) = mean(afV(~isnan(afV)));
        a2fStdInt(iImageIter,k) = std(afV(~isnan(afV)));
    end
end



a2iPartRatio = nchoosek(1:11,2);
a2iCorrectEdges = [...
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
aiNumCorrectSinha = (sum(a2fAvgInt(:,a2iCorrectEdges(:,1)) < a2fAvgInt(:,a2iCorrectEdges(:,2)),2));

aiFOBCorrectFeatureNumber = [12     9    12    12    10    11    12    12    10     7    11    11     8    11    11    12];
