%strctTmp=load('E:\Data\Doris\Electrophys\Spiderman\ML_AL_Project\140207\RAW\..\Processed\SingleUnitDataEntries\Spiderman_2014-02-07_10-57-46_Exp_NaN_Ch_017_Unit_050_Passive_Fixation_New_ReducedFOB.mat');
strctTmp=load('E:\Data\Doris\Electrophys\Spiderman\ML_AL_Project\140207\RAW\..\Processed\SingleUnitDataEntries\Spiderman_2014-02-07_10-57-46_Exp_NaN_Ch_017_Unit_052_Passive_Fixation_New_ReducedFOB.mat');
strctUnit = strctTmp.strctUnit;
a2fTimes = [cat(1,strctUnit.m_astrctRaster.m_fON_MS),cat(1,strctUnit.m_astrctRaster.m_fOFF_MS)];
% Ave
for k=1:5
figure(1+k);
clf;
imagesc(strctUnit.m_astrctRaster(k).m_aiTimeRange,1:36, strctUnit.m_astrctRaster(k).m_a2fAvgFirintRate_Stimulus);
title(sprintf('ON %d',a2fTimes(k,1)));
end

for k=1:5
    afFaces = mean(strctUnit.m_astrctRaster(k).m_a2fAvgFirintRate_Stimulus(1:16,:),1);
    afNonFaces = mean(strctUnit.m_astrctRaster(k).m_a2fAvgFirintRate_Stimulus(17:end,:),1);
figure(1+k);
clf;hold on;
plot(strctUnit.m_astrctRaster(k).m_aiTimeRange, afFaces,'r');
plot(strctUnit.m_astrctRaster(k).m_aiTimeRange, afNonFaces,'b');
title(sprintf('ON %d',a2fTimes(k,1)));
end

for k=1:10
    aiStimulusInd = find(strctUnit.m_aiStimulusIndexValid == k);
    [aiUnique, ~,aiMappingToUnique]=unique(strctUnit.m_strctStimulusParams.m_afStimulusON_MS(aiStimulusInd));
    aiCount = histc(aiMappingToUnique,1:length(aiUnique));
    aiCountStart = cumsum([1,aiCount]);
    
    a2bR = zeros(length(aiStimulusInd), size(strctUnit.m_a2bRaster_Valid,2));
    for j=1:length(aiUnique)
        a2bR(aiCountStart(j):aiCountStart(j+1)-1,:) = strctUnit.m_a2bRaster_Valid(aiStimulusInd(aiMappingToUnique==j),:);
    end
    a2bRsmooth = a2bR;%conv2(a2bR,fspecial('gaussian',[1 20],2),'same');
    figure(k);clf;
    imagesc(strctUnit.m_aiPeriStimulusRangeMS,1:size(a2bR,1),a2bRsmooth);
    colormap gray;
    hold on;
     for j=1:length(aiUnique)
        plot(strctUnit.m_aiPeriStimulusRangeMS([1,end]),[aiCountStart(j) aiCountStart(j)]-0.5,'g');
    end
    set(gca,'xlim',[-100 500]);