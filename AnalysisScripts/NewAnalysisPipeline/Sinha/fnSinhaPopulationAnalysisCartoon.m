iNumDataEntries = length(acData);
abUse = zeros(1,iNumDataEntries) > 0;
for iUnitIter=1:iNumDataEntries
    strctUnit = acData{iUnitIter}.strctUnit;
    afFSI(iUnitIter) = strctUnit.m_strctFaceSelectivity.m_fFaceSelectivityIndex;
    afdPrime(iUnitIter) = strctUnit.m_strctFaceSelectivity.m_fdPrime;
    
    abUse(iUnitIter) = ~isempty(strctUnit.m_strctContrastPair11Parts) & afFSI(iUnitIter) > 0.3;
end
    
acUnits = acData(abUse);
iNumUnits = length(acUnits);


%% Plot the sinha tuning matrix.
iCounter = 1;
a2fTuning = zeros(iNumUnits,55);
for iUnitIter=1:iNumUnits
      strctUnit = acUnits{iUnitIter}.strctUnit;
    a2fTuning(iUnitIter,:) = strctUnit.m_strctContrastPair11Parts.m_afTuning;
end

fPThres=1e-5;
for iIter=1:iNumUnits
    a2fPValue(iIter,:) = acUnits{iIter}.strctUnit.m_strctContrastPair11Parts.m_afPvalue;
    abLarger = acUnits{iIter}.strctUnit.m_strctContrastPair11Parts.m_a2fAvgFiring(:,1) > acUnits{iIter}.strctUnit.m_strctContrastPair11Parts.m_a2fAvgFiring(:,2) ;
    afTuning = zeros(1,55);
    afTuning(abLarger' & a2fPValue(iIter,:)<fPThres) = 1;
    afTuning(~abLarger' & a2fPValue(iIter,:)<fPThres) = 0.5;
    a2fTmp(iIter,:) = afTuning;
end



figure(4);
imagesc(a2fTmp);
colormap hot
xlabel('Significant tuning for contrast features');
ylabel('Units');




figure(41);clf;
subplot(2,1,1);
hold on;
bar(1:55,sum(a2fTmp == 1,1),'b');
bar(1:55,-sum(a2fTmp == 0.5,1),'r');
axis([0 55 -12 12]);
box on
set(gca,'xtick',1:1:55);
ylabel('Number of cells');
acPartNames11 = {'Forehead','Left Eye','Nose','Right Eye','Left Cheek','Upper Lip','Right Cheek','Lower Left Cheek','Mouth','Lower Right Cheek','Chin'};

a2bParts = zeros(11,55);
a2iPairs11 = nchoosek(1:11,2);
for k=1:55
    a2bParts(a2iPairs11(k,1),k) = 1;
    a2bParts(a2iPairs11(k,2),k) = 1;
end
subplot(2,1,2);
imagesc(a2bParts);
colormap gray
set(gca,'ytick',1:11);
set(gca,'yticklabel',acPartNames11);
set(gca,'xtick',1:1:55);
clear a2fNorm

%% FSI ?



%% Now, look at cartoons
iNumContinuousBinsForSignificanceTuning = 15;

iNumFeatures = 21;
a2bSignificantTuning = zeros(iNumUnits, iNumFeatures);
for iUnitIter=1:iNumUnits
    strctUnit = acUnits{iUnitIter}.strctUnit;
    
        a2bAboveShufflePredicator = strctUnit.m_strctCartoonTuning.m_a2fHetroNoShuffle > strctUnit.m_strctCartoonTuning.m_a2fHetroThreshold;
        afMaxNumTimeBinsAbovePredicator = zeros(1,iNumFeatures);
        for iFeatureIter=1:iNumFeatures
            astrctIntervals = fnGetIntervals(a2bAboveShufflePredicator(iFeatureIter,:));
            if ~isempty(astrctIntervals)
                afMaxNumTimeBinsAbovePredicator(iFeatureIter) = max( cat(1,astrctIntervals.m_iLength));
            end
        end
        a2bSignificantTuning(iUnitIter,:) = afMaxNumTimeBinsAbovePredicator > iNumContinuousBinsForSignificanceTuning;
end

figure(19);
imagesc(a2bSignificantTuning');
colormap gray

a2bSigTuningSinha = a2fPValue<1e-5;

aiNumTunedSinha = sum(a2bSigTuningSinha,2)
aiNumTunedCartoon = sum(a2bSignificantTuning,2)
sum(aiNumTunedSinha == 0 & aiNumTunedCartoon == 0)

sum(aiNumTunedSinha == 0 & aiNumTunedCartoon > 0)
sum(aiNumTunedSinha > 0 & aiNumTunedCartoon == 0)
sum(aiNumTunedSinha > 0 & aiNumTunedCartoon > 0)

% Display example cell
acFeatureNames = {'Aspect Ratio','Face Direction','Assembly Height Height','Inter Eye Distance','Eye Eccentricity','Eye Size','Pupil Size','Gaze Direction','Face roundness','Eyebrow slant','Angle of eyebrows',...
    'Width of eyebrows','Eyebrows Vertical Offset','Nose Base','Nose Altitude','Mouth Size','Mouth Top','Mouth Bottom','Mouth To Nose Distance','Hair Thickness','Hair Length'};
xlabel('Cells');
ylabel('Feature Dimension');
set(gca,'ytick',1:iNumFeatures,'yticklabel',acFeatureNames);
set(gca,'xtick',1:iNumUnits);

figure(20);
imagesc(a2fTmp');
colormap hot
set(gca,'xtick',1:iNumUnits);
xlabel('Cells');
ylabel('Contrast Features');


    figure(10);clf;
    for iFeatureIter=1:iNumFeatures
        a2fTuning = squeeze(strctUnit.m_strctCartoonTuning.m_a3fTuningNoShift(iFeatureIter,:,:));
        subplot(5,5,iFeatureIter);
        imagesc(a2fTuning);
    end
% 
%     figure(11);clf;
%     for iFeatureIter=1:iNumFeatures
%         subplot(5,5,iFeatureIter);
%         plot(strctUnit.m_strctCartoonTuning.m_a2fHetroNoShuffle(iFeatureIter,:));
%         hold on;
%         plot(strctUnit.m_strctCartoonTuning.m_a2fHetroThreshold(iFeatureIter,:),'r');
%         set(gca,'xlim',[0 300]);
%         % Significant tuning? Passing X ms 
%    end
    
