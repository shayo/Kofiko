strctTmp=load('D:\Data\Doris\Electrophys\Bert\Optogenetics\111216\RAW\..\Processed\Optogenetic_Analysis\Bert-111216_161304_OptogeneticsMicrostim_Channel_1_Interval14_Trigger_Grass1.mat')

figure(9);clf;
plot(strctTmp.strctUnitInterval.m_astrctTrain(1).m_aiPeriStimulusRangeMS, sum(strctTmp.strctUnitInterval.m_astrctTrain(1).m_a2bRaster,1))
axis([-100 1200 0 25])

figure(10);
imagesc(strctTmp.strctUnitInterval.m_astrctTrain(1).m_aiPeriStimulusRangeMS, 1:size(strctTmp.strctUnitInterval.m_astrctTrain(1).m_a2bRaster,1), strctTmp.strctUnitInterval.m_astrctTrain(1).m_a2bRaster)
axis([-10 60 1 24])
colormap gray

strctTmp=load('D:\Data\Doris\Electrophys\Bert\Optogenetics\111216\RAW\..\Processed\Optogenetic_Analysis\Bert-111216_161304_OptogeneticsMicrostim_Channel_1_Interval17_Trigger_Grass1.mat')


figure(9);clf;
plot(strctTmp.strctUnitInterval.m_astrctTrain(1).m_aiPeriStimulusRangeMS, sum(strctTmp.strctUnitInterval.m_astrctTrain(1).m_a2bRaster,1))
axis([-100 1200 0 50])

figure(10);
imagesc(strctTmp.strctUnitInterval.m_astrctTrain(1).m_aiPeriStimulusRangeMS, 1:size(strctTmp.strctUnitInterval.m_astrctTrain(1).m_a2bRaster,1), strctTmp.strctUnitInterval.m_astrctTrain(1).m_a2bRaster)
axis([-10 60 1 50])
colormap gray


D:\Data\Doris\Electrophys\Bert\Optogenetics\111216\RAW\..\Processed\Optogenetic_Analysis\Bert-111216_161304_OptogeneticsMicrostim_Channel_1_Interval23_Trigger_Grass1.mat
D:\Data\Doris\Electrophys\Bert\Optogenetics\111216\RAW\..\Processed\Optogenetic_Analysis\Bert-111216_161304_OptogeneticsMicrostim_Channel_1_Interval33_Trigger_Grass1.mat
