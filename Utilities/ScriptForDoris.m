% Const
strDataLocation = 'D:\Data\Temp\';
aiResponseInterval = [150,300];
iGaussianAveragingMS = 10;
aiFaceImages = 1:16;
aiNonFaceImages = 17:80;
aiScrambled = 81:96;
%
astrctRoccoData = dir([strDataLocation,'*.mat']);
iNumEntries = length(astrctRoccoData);

a2fStatistics = zeros(iNumEntries,6+6); % [Six Highest Faces, Three highest non-Faces, three lowest non-faces]
aiFaceSelectivityIndex = zeros(1,iNumEntries);
for iIter=1:iNumEntries
    strFileName = fullfile(strDataLocation,astrctRoccoData(iIter).name);
    fprintf('Loading %d out of %d (%s)\n',iIter,iNumEntries,strFileName);
    Tmp = load(strFileName);
    strctUnit = Tmp.strctUnit;
    
    
    iStartRespondInd = find(strctUnit.m_aiPeriStimulusRangeMS >= aiResponseInterval(1),1,'first');
    iEndRespondInd = find(strctUnit.m_aiPeriStimulusRangeMS <= aiResponseInterval(2),1,'last');
    aiFobImagesInd = find(strctUnit.m_aiStimulusIndexValid <= 96);
    aiFOBImageIndex = strctUnit.m_aiStimulusIndexValid(aiFobImagesInd);
    
    a2bRasterFOB = strctUnit.m_a2bRaster_Valid(aiFobImagesInd,:);
    % The a2bRasterFOB holds all data (response of individual presentations).
    % Each row corresponds to the stimulus that is specified in aiFOBImageIndex
    % i.e., size(a2bRasterFOB,1) == length(aiFOBImageIndex(
    
    a2fSmoothPSTH = fnAverageBy(a2bRasterFOB, aiFOBImageIndex, diag(1:96), iGaussianAveragingMS, true)*1e2;
    afAverageResponse = nanmean(a2fSmoothPSTH(:,iStartRespondInd:iEndRespondInd),2);
    fFaceResponse = nanmean(afAverageResponse(1:16));
    fNonFaceResponse = nanmean(afAverageResponse(17:end));
    
    aiFaceSelectivityIndex(iIter) = (fFaceResponse-fNonFaceResponse)/(fFaceResponse+fNonFaceResponse);
    % Plot PSTH
    figure(2);
    clf;
    imagesc(strctUnit.m_aiPeriStimulusRangeMS,1:96,a2fSmoothPSTH);
    % Compute average bar graphs
    afSortedFaceResponses = sort(afAverageResponse(aiFaceImages),'descend');
    afSortedObjectRespones = sort(afAverageResponse(aiNonFaceImages),'descend');
    afSortedFaceResponses=afSortedFaceResponses(~isnan(afSortedFaceResponses));
    afSortedObjectRespones=afSortedObjectRespones(~isnan(afSortedObjectRespones));
    
    a2fStatistics(iIter,1:6) = afSortedFaceResponses (1:6);
    a2fStatistics(iIter,7:9) = afSortedObjectRespones(1:3);
    a2fStatistics(iIter,10:12) = afSortedObjectRespones(end-2:end);
end

% Look only at "face-selective" cells

figure(3);
clf;
imagesc(a2fStatistics(aiFaceSelectivityIndex>0.3,:));

