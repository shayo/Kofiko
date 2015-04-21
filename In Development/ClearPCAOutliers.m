iIndex = find(cat(1,astrctUnitIntervals.m_iUniqueID) == 5);

iUnitOfInterest = 5;
acUnitAssociation = getappdata(handles.figure1,'acUnitAssociation');
aiAss = acUnitAssociation{end};
a2fPCA = getappdata(handles.figure1,'a2fPCA');

a2fSortedAllWaveForms = getappdata(handles.figure1,'a2fSortedAllWaveForms');

aiRelevantSpikes = find(aiAss == iUnitOfInterest);
a2fWaves = a2fSortedAllWaveForms(aiRelevantSpikes,:);
% Remove outliers from waves to get a cleaner PCA space?
iNumWaves = size(a2fWaves,1);
afMedian = median(a2fWaves,1);
afStd = mad(a2fWaves,1);

figure(2);
clf;
plot(a2fWaves','k');
hold on;
plot(afMedian,'r');
plot(afMedian+4*afStd,'r--');
plot(afMedian-4*afStd,'r--');

a2bValid = ...
a2fWaves >= repmat(afMedian-4*afStd,iNumWaves,1) & ...
a2fWaves <= repmat(afMedian+4*afStd,iNumWaves,1) ;

abValid = all(a2bValid,2);

a2fValidWaves = a2fWaves(abValid,:);

a2fSortedAllWaveFormsZeroMean = bsxfun(@minus,a2fValidWaves,mean(a2fValidWaves,1));
[coeff,ignore] = eig(a2fSortedAllWaveFormsZeroMean'*a2fSortedAllWaveFormsZeroMean);
%afLoads = flipud(diag(ignore));
a2fPCACoeff = fliplr(coeff);
a2fPCA = a2fSortedAllWaveFormsZeroMean*a2fPCACoeff(:,1:2);

figure;
plot(a2fPCA(:,1),a2fPCA(:,2),'b.');
[xi, yi, placement_cancelled] = fnCreateWaitModePolygon(gca,'Finish')
