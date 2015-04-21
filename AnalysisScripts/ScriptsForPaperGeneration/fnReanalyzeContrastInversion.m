strRoot = 'D:\Data\Doris\Data For Publications\Sinha\ContrastInversion\';
iNumCells = 44;
clear a2cData
a2cData = cell(iNumCells,3);
for iIter=1:iNumCells
    strSubFolder= sprintf('%sUnit%d\\',strRoot,iIter);
    astrctFiles = dir([strSubFolder,'*.mat']);
    for j=1:length(astrctFiles)
        strctTmp = load([strSubFolder, astrctFiles(j).name]);
        switch strctTmp.strctUnit.m_strImageListDescrip
            case 'StandardFOB_v4_Inv_Cropped'
                a2cData{iIter,1} = strctTmp.strctUnit;
            case 'StandardFOB_v5_Inv_Edges'
                a2cData{iIter,2} = strctTmp.strctUnit;
            case 'StandardFOB_v4_Inv_Cropped_HistEq'
                a2cData{iIter,3} = strctTmp.strctUnit;
        end
    end
end

%%
clear a2fAvgFaceCroppedInvRes a2fAvgFaceCroppedRes a2fAvgFaceInvRes a2fAvgFaceRes afFSI
iCounter= 1;
for iIter=1:iNumCells
    if isempty(a2cData{iIter,1})
        continue;
    end
    
   a2fFullNormal = a2cData{iIter,2}.m_a2fAvgFirintRate_Stimulus(1:96,:); % Full, normal contrast
   a2fFullInverted = a2cData{iIter,2}.m_a2fAvgFirintRate_Stimulus(106:201,:); % Full, inverted contrast
   a2fCroppedNormal = a2cData{iIter,1}.m_a2fAvgFirintRate_Stimulus(1:96,:); % Cropped, normal contrast
   a2fCroppedInverted = a2cData{iIter,1}.m_a2fAvgFirintRate_Stimulus(106:201,:); % Cropped, inverted contrast
   % Normalize 
   fMax = max([a2fFullNormal(:);a2fFullInverted(:);a2fCroppedNormal(:);a2fCroppedInverted(:)]);
   a2fFullNormal_Norm = a2fFullNormal / fMax;
   a2fFullInverted_Norm = a2fFullInverted / fMax;
   a2fCroppedNormal_Norm = a2fCroppedNormal / fMax;
   a2fCroppedInverted_Norm = a2fCroppedInverted / fMax;
   

   afFullNormal_Norm = mean(a2fFullNormal_Norm(:,240:440),2);
   afFullInverted_Norm = mean(a2fFullInverted_Norm(:,240:440),2);
   afCroppedNormal_Norm = mean(a2fCroppedNormal_Norm(:,240:440),2);
   afCroppedInverted_Norm = mean(a2fCroppedInverted_Norm(:,240:440),2);
   
   a2fAvgFaceRes(iCounter,:) = mean(a2fFullNormal_Norm(1:16,:));
   a2fAvgFaceInvRes(iCounter,:) = mean(a2fFullInverted_Norm(1:16,:));
   a2fAvgFaceCroppedRes(iCounter,:) = mean(a2fCroppedNormal_Norm(1:16,:));
   a2fAvgFaceCroppedInvRes(iCounter,:) =    mean(a2fCroppedInverted_Norm(1:16,:));
   
   fFaceRes = mean(afFullNormal_Norm(1:16));
   fObjRes = mean(afFullNormal_Norm(17:96));
    afFSI(iCounter) = (fFaceRes-fObjRes)/(fFaceRes+fObjRes);
   
   iCounter=iCounter+1;
end

aiRelevant = afFSI > 0.3;

figure(10);
clf;hold on;
plot(-200:500,mean(a2fAvgFaceRes(aiRelevant,:)));
plot(-200:500,mean(a2fAvgFaceInvRes(aiRelevant,:)),'r');
plot(-200:500,mean(a2fAvgFaceCroppedRes(aiRelevant,:)),'g');
plot(-200:500,mean(a2fAvgFaceCroppedInvRes(aiRelevant,:)),'c');
legend('Normal Full','Inverted Full','Normal Cropped','Inverted Cropped');


