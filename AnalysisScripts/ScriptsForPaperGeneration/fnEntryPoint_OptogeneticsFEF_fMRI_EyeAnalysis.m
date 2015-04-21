 astrctRuns = fnExtractRunInformation('D:\Data\Doris\Planner\Bert\120613-14Bert - ChR2 and Electrical\Kofiko')

 % Extract 2D eye position Histograms for each of the three conditions...
 iNumRuns = length(astrctRuns);
a2fOpt = [];
a2fElec = [];
a2fBoth = [];
for iRunIter=1:iNumRuns 
    abOpticalRange = (astrctRuns(iRunIter).m_afEyeSampleTime >= 40 & astrctRuns(iRunIter).m_afEyeSampleTime <= 80) | ...
    (astrctRuns(iRunIter).m_afEyeSampleTime >= 360 & astrctRuns(iRunIter).m_afEyeSampleTime <= 400);
    afXRaw = astrctRuns(iRunIter).m_afEyeXpix(abOpticalRange);
    afYRaw = astrctRuns(iRunIter).m_afEyeYpix(abOpticalRange);
    abValid = afXRaw < 2500 & afYRaw > -1500;
    a2fOpt = [a2fOpt,[afXRaw(abValid);afYRaw(abValid)]];
    
    
    abElectricalRange = (astrctRuns(iRunIter).m_afEyeSampleTime >= 120 & astrctRuns(iRunIter).m_afEyeSampleTime <= 160) | ...
    (astrctRuns(iRunIter).m_afEyeSampleTime >= 280 & astrctRuns(iRunIter).m_afEyeSampleTime <= 320);
    afXRaw = astrctRuns(iRunIter).m_afEyeXpix(abElectricalRange);
    afYRaw = astrctRuns(iRunIter).m_afEyeYpix(abElectricalRange);
    abValid = afXRaw < 2500 & afYRaw > -1500;
    a2fElec = [a2fElec,[afXRaw(abValid);afYRaw(abValid)]];
    
    abBothRange = (astrctRuns(iRunIter).m_afEyeSampleTime >= 200 & astrctRuns(iRunIter).m_afEyeSampleTime <= 240 ) | ...
    (astrctRuns(iRunIter).m_afEyeSampleTime >= 440 & astrctRuns(iRunIter).m_afEyeSampleTime <= 480);
    afXRaw = astrctRuns(iRunIter).m_afEyeXpix(abBothRange);
    afYRaw = astrctRuns(iRunIter).m_afEyeYpix(abBothRange);
    abValid = afXRaw < 2500 & afYRaw > -1500;
    a2fBoth = [a2fBoth,[afXRaw(abValid);afYRaw(abValid)]];
     
end
afXRange = -1000:30:2000;
afYRange = -1000:30:2000;
a2fHistOpt=fnNewHist2(round(a2fOpt(1,:)),round(a2fOpt(2,:)),afXRange,afYRange);
a2fHistElc=fnNewHist2(round(a2fElec(1,:)),round(a2fElec(2,:)),afXRange,afYRange);
a2fHistBoth = fnNewHist2(round(a2fBoth(1,:)),round(a2fBoth(2,:)),afXRange,afYRange);

a2fHistOptNorm = a2fHistOpt / sum(a2fHistOpt(:));
a2fHistElcNorm = a2fHistElc / sum(a2fHistElc(:));
a2fHistBothNorm = a2fHistBoth / sum(a2fHistBoth(:));

[p,h]=ranksum(a2fHistBothNorm(:),a2fHistElcNorm(:))
figure;
hist(a2fHistBothNorm(:)-a2fHistElcNorm(:),500)

figure;imagesc()

figure(2);clf;
tightsubplot(1,3,1,'Spacing',0.05);
imagesc(afXRange,afYRange,a2fHistOpt,[0 1000]);axis off
colormap jet
tightsubplot(1,3,2,'Spacing',0.05);
imagesc(afXRange,afYRange,a2fHistElc,[0 1000]);axis off
colormap jet
tightsubplot(1,3,3,'Spacing',0.05);
imagesc(afXRange,afYRange,a2fHistBoth,[0 1000]);axis off
colormap jet

% hold on;
% figure(11);
% clf;
% plot(a2fOpt(1,:),a2fOpt(2,:))
% 
% 
% a2fAvgDist = cat(1,astrctRuns.m_afAverageFixationDist)
% 
% afMeanDistToFixationSpot = mean(a2fAvgDist,1);
% afMedianDistToFixationSpot = median(a2fAvgDist,1);
% afEyeSignal = afMedianDistToFixationSpot;
% %%
% aiInterval = -3:40;
% 
% afResponseOptical = (afMeanDistToFixationSpot(aiInterval + 20) + afMeanDistToFixationSpot(aiInterval + 180))/2; 
% afResponseElectrical = (afMeanDistToFixationSpot(aiInterval + 60) + afMeanDistToFixationSpot(aiInterval + 140))/2;
% afResponseCombined = (afMeanDistToFixationSpot(aiInterval + 100) + afMeanDistToFixationSpot(aiInterval + 220))/2;
% % afBoldResponseOptical=afBoldResponseOptical-mean(afBoldResponseOptical(1:3));
% % afBoldResponseElectrical=afBoldResponseElectrical-mean(afBoldResponseElectrical(1:3));
% % afBoldResponseCombined=afBoldResponseCombined-mean(afBoldResponseCombined(1:3));
% 
% % afBoldResponseGray = afMeanBoldResponse(1:20) ;
% % 
% % afSEMOptical =  (afSEMBoldResponse(aiInterval + 20) + afSEMBoldResponse(aiInterval + 180))/2; 
% % afSEMElectrical =  (afSEMBoldResponse(aiInterval + 60) + afSEMBoldResponse(aiInterval + 140))/2; 
% % afSEMBoth =  (afSEMBoldResponse(aiInterval + 100) + afSEMBoldResponse(aiInterval + 220))/2; 
% 
% % afAllValues = [afBoldResponseElectrical+afSEMElectrical;afBoldResponseElectrical-afSEMElectrical;afBoldResponseOptical+afSEMOptical;afBoldResponseOptical-afSEMOptical;afBoldResponseCombined+afSEMBoth;afBoldResponseCombined-afSEMBoth];
% 
% aiIntervalTime = 2*aiInterval;
% figure(21);
% clf;hold on;
% plot(aiIntervalTime,afResponseElectrical,'k','LineWidth',2)
% plot(aiIntervalTime,afResponseOptical,'r','LineWidth',2)
% plot(aiIntervalTime,afResponseCombined,'b','LineWidth',2)
% % plot(aiIntervalTimeGray,afBoldResponseGray,'color',[0.5 0.5 0.5],'LineWidth',2);
% % plot(aiIntervalTimeGray,afBoldResponseGray+afSEMGray,'color',[0.5 0.5 0.5],'linestyle','--');
% % plot(aiIntervalTimeGray,afBoldResponseGray-afSEMGray,'color',[0.5 0.5 0.5],'linestyle','--')
% % 
% axis([-5 80 fMin fMax])


a2fOpt(1,:)', 
M=min(size(a2fBoth,2),size(a2fElec,2));
anova1([a2fBoth(1,1:M)',a2fElec(1,1:M)',a2fOpt(1,1:M)' ])

anova1([a2fBoth(2,1:M)',a2fElec(2,1:M)',a2fOpt(2,1:M)' ])

figure;
hist(a2fBoth(1,1:M),100)

mean(a2fBoth(1,1:M))
mean(a2fElec(1,1:M))
mean(a2fOpt(1,1:M))

mean(a2fBoth(2,1:M))
mean(a2fElec(2,1:M))
mean(a2fOpt(2,1:M))

 We performed a  one-way ANOVA on eye 
position (x and y), saccade rate and fixation during each experiment (Table S2).  
None  of these measures were significantly different (p > 0.05) between epochs in the 
interaction comparison (VEM and F versus V and EM, experiment two; VDEM and V 
versus VEM and VD, experiment four), specificity comparison (VEM versus VEM-I, 
experiment three) or the luminance contrast comparison (VEM versus V, experiment 
five)