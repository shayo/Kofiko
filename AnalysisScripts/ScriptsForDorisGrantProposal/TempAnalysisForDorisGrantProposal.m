acFiles = {
    {'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_018_Unit_013_Passive_Fixation_New_FOB.mat',...
     'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_018_Unit_013_Passive_Fixation_New_FOB_Microstim.mat'},

{'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_018_Unit_016_Passive_Fixation_New_FOB.mat',...
'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_018_Unit_016_Passive_Fixation_New_FOB_Microstim.mat'},

{'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_018_Unit_019_Passive_Fixation_New_FOB.mat',...
'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_018_Unit_019_Passive_Fixation_New_FOB_Microstim.mat'},

{'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_018_Unit_021_Passive_Fixation_New_FOB.mat',...
'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_018_Unit_021_Passive_Fixation_New_FOB_Microstim.mat'}};

figure(12);
clf;hold on

for iSelectedUnit = 1:4

strctTmp= load(acFiles{iSelectedUnit}{2});
strctUnit = strctTmp.strctUnit;
a2fSubset = strctUnit.m_a2fAvgFirintRate_Stimulus([1:4,17:end-1],:);

aiFaceInd = [1:4];
aiNonFaceInd = [5:24];
aiStimFaceInd = [ 25:28];
aiStimNonFaceInd = [ 29:48];

afResFaces = mean(a2fSubset(aiFaceInd,:),1);
afResNonFaces = mean(a2fSubset(aiNonFaceInd,:),1);
aiResStimFace = mean(a2fSubset(aiStimFaceInd,:),1);
aiResStimNonFace = mean(a2fSubset(aiStimNonFaceInd,:),1);
fMaxRes = max([afResFaces,afResNonFaces,aiResStimFace,aiResStimNonFace])*1.1;
subplot(1,4,iSelectedUnit);
hold on;
plot(strctUnit.m_aiPeriStimulusRangeMS,afResFaces,'b');
plot(strctUnit.m_aiPeriStimulusRangeMS,afResNonFaces,'color',[0.5 0.5 0.5]);
plot(strctUnit.m_aiPeriStimulusRangeMS,aiResStimFace,'r');
plot(strctUnit.m_aiPeriStimulusRangeMS,aiResStimNonFace,'k');
set(gca,'xlim',[-100 400]);
set(gca,'ylim',[-2 fMaxRes]);
rectangle('Position',[100,-2,100,2],'facecolor','g');

end% legend('Faces','Non Faces','Faces + Stimulation','Non Faces + Stimulation','Location','NorthEastOutside');

figure(11);
clf;
imagesc(strctUnit.m_aiPeriStimulusRangeMS,1:size(a2fSubset,1),a2fSubset)
set(gca,'ytick',1:48)


%%
acUnits = {'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_018_Unit_019_Passive_Fixation_New_FOB_Microstim.mat',...
            'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_018_Unit_021_Passive_Fixation_New_FOB_Microstim.mat',...
            'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_017_Unit_023_Passive_Fixation_New_FOB_Microstim.mat',...
            'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_017_Unit_032_Passive_Fixation_New_FOB_Microstim.mat'};

figure(11);
clf;
    set(gcf,'color',[1 1 1])    
for iSelectedUnit = 1:4
strctTmp = load(acUnits{iSelectedUnit});        
strctUnit = strctTmp.strctUnit;
a2fSubset = strctUnit.m_a2fAvgFirintRate_Stimulus([1:4,17:end-1],:);
aiFaceInd = [1:4];
aiNonFaceInd = [5:24];
aiStimFaceInd = [ 25:28];
aiStimNonFaceInd = [ 29:48];
subplot(1,4,iSelectedUnit);
imagesc(strctUnit.m_aiPeriStimulusRangeMS,1:size(a2fSubset,1),a2fSubset([aiFaceInd,aiStimFaceInd,aiNonFaceInd,aiStimNonFaceInd],:))
set(gca,'xlim',[-100,500])
set(gca,'yticklabel',[])
hold on;
plot([-100 500],[5 5]-0.5,'w');
plot([-100 500],[9 9]-0.5,'w');
plot([-100 500],[29 29]-0.5,'w');
colorbar('location','NorthOutside');
end

figure(12);
clf;
set(gcf,'color',[1 1 1])    
for iSelectedUnit = 1:4
strctTmp = load(acUnits{iSelectedUnit});        
strctUnit = strctTmp.strctUnit;
subplot(1,4,iSelectedUnit);
plot(1000*strctUnit.m_afAvgWaveForm,'k','LineWidth',3);
set(gca,'xticklabel',[]);
set(gca,'ylim',[-60 40],'yticklabel',[]);
end


aiFaceStimuliInd = 1:4;
aiNonFaceStimuliInd = 17:36;
aiStimFaceStimuliInd = 37:40;
aiStimNonFaceStimuliInd = 41:60;


figure(13);
clf;
set(gcf,'color',[1 1 1])    
Cnt=1;
for iSelectedUnit = [1,3]
strctTmp = load(acUnits{iSelectedUnit});        
strctUnit = strctTmp.strctUnit;

afFaceLFP = mean(strctUnit.m_a2fLFP(strctUnit.m_strctValidTrials.m_abValidTrials & ismember(strctUnit.m_aiStimulusIndex,aiFaceStimuliInd),:),1);
afNonFaceLFP = mean(strctUnit.m_a2fLFP(strctUnit.m_strctValidTrials.m_abValidTrials & ismember(strctUnit.m_aiStimulusIndex,aiNonFaceStimuliInd),:),1);
afStimFaceLFP = mean(strctUnit.m_a2fLFP(strctUnit.m_strctValidTrials.m_abValidTrials & ismember(strctUnit.m_aiStimulusIndex,aiStimFaceStimuliInd),:),1);
afStimNonFaceLFP = mean(strctUnit.m_a2fLFP(strctUnit.m_strctValidTrials.m_abValidTrials & ismember(strctUnit.m_aiStimulusIndex,aiStimNonFaceStimuliInd),:),1);

subplot(1,2,Cnt);hold on;
Cnt=Cnt+1;
plot(strctUnit.m_aiPeriStimulusRangeMS,1e3*afFaceLFP,'b');
plot(strctUnit.m_aiPeriStimulusRangeMS,1e3*afNonFaceLFP,'color',[0.5 0.5 0.5]);
plot(strctUnit.m_aiPeriStimulusRangeMS,1e3*afStimFaceLFP,'color','r');
plot(strctUnit.m_aiPeriStimulusRangeMS,1e3*afStimNonFaceLFP,'color','k');
set(gca,'xlim',[-100,500])
end


%%
acFiles = {'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_018_Unit_019_Passive_Fixation_New_Occlusions.mat',...
            'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_018_Unit_021_Passive_Fixation_New_Occlusions.mat',...
            'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_017_Unit_023_Passive_Fixation_New_Occlusions.mat',...
            'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_017_Unit_032_Passive_Fixation_New_Occlusions.mat'};

acLegend = {'Face-Face Side-by-side','Face-Object Side-by-side','Face-Object Center Foreground','Face-Object Center Background','Face-Face Center Foreground','Face-Face Center Background'};
acColors = {'r-','r--','b--','g--','b-','g-'};
aiCategories = [1,2,5,7,9,11];
figure(15);
clf;
set(gcf,'color',[1 1 1]);

for iSelectedUnit = 1:4
strctTmp = load(acFiles{iSelectedUnit});        
strctUnit = strctTmp.strctUnit;
subplot(1,4,iSelectedUnit);
hold on;

for k=1:length(aiCategories)
    plot(strctUnit.m_aiPeriStimulusRangeMS,strctUnit.m_a2fAvgFirintRate_Category(aiCategories(k),:), acColors{k});
end
    set(gca,'xlim',[-100,500])
     plot(strctUnit.m_aiPeriStimulusRangeMS,mean(strctUnit.m_a2fAvgFirintRate_Stimulus(301:305,:),1),'k','LineWidth',2);

end

figure(16);
clf;
set(gcf,'color',[1 1 1]);
iCnt=1;
for iSelectedUnit = [1,3]
strctTmp = load(acFiles{iSelectedUnit});        
strctUnit = strctTmp.strctUnit;
subplot(1,2,iCnt);
iCnt=iCnt+1;
hold on;

for k=1:length(aiCategories)
    plot(strctUnit.m_aiPeriStimulusRangeMS,1000*strctUnit.m_a2fAvgLFPCategory(aiCategories(k),:), acColors{k});
end
    set(gca,'xlim',[-100,500])
   plot(strctUnit.m_aiPeriStimulusRangeMS,mean(strctUnit.m_a2fAvgFirintRate_Stimulus(301:305,:),1),'k');

end


%%
acFiles = {'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_018_Unit_019_Passive_Fixation_New_TransformationsWithMicroStim.mat',...
'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_018_Unit_021_Passive_Fixation_New_TransformationsWithMicroStim.mat',...
'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_017_Unit_023_Passive_Fixation_New_TransformationsWithMicroStim.mat',...
'E:\Data\Doris\Electrophys\Benjamin\Optogenetics\140225\RAW\..\Processed\SingleUnitDataEntries\Benjamin_2014-02-25_16-36-22_Exp_NaN_Ch_017_Unit_032_Passive_Fixation_New_TransformationsWithMicroStim.mat'};
for k=1:size(strctUnit.m_a2fAvgFirintRate_Stimulus,2)
    [a(k),b(k)]=ttest2(strctUnit.m_a2fAvgFirintRate_Stimulus(1:32,k),    strctUnit.m_a2fAvgFirintRate_Stimulus(33:64,k));
end
strctUnit.m_aiPeriStimulusRangeMS(b<0.01)
(find(strctUnit.m_aiPeriStimulusRangeMS >= 100 & strctUnit.m_aiPeriStimulusRangeMS < 140))

figure(11);
clf;
for j=1:32
    subplot(6,6,j);
    plot(conv2(mean(strctUnit.m_a2bRaster_Valid(strctUnit.m_aiStimulusIndexValid == j,:),1),fspecial('gaussian',[1 50],4),'same'),'b');
    hold on;
    plot(conv2(mean(strctUnit.m_a2bRaster_Valid(strctUnit.m_aiStimulusIndexValid == 32+j,:),1),fspecial('gaussian',[1 50],4),'same'),'r');
end

set(gca,'xlim',[100 140])

figure(16);
clf;
for iSelectedUnit = 1:4
    strctTmp = load(acFiles{iSelectedUnit});        
    strctUnit = strctTmp.strctUnit;
    subplot(1,4,iSelectedUnit);
    imagesc(strctUnit.m_aiPeriStimulusRangeMS,1:size(strctUnit.m_a2fAvgFirintRate_Stimulus,1)-1,strctUnit.m_a2fAvgFirintRate_Stimulus(1:end-1,:))
    set(gca,'xlim',[-100 1000]);
    hold on;
    set(gca,'ytick',0.25+[1:64],'fontSize',5);
    acTickLabel = cell(1,64);
    for j=1:32
        acTickLabel{j}=num2str(j);
        acTickLabel{32+j}=num2str(j);
    end
    set(gca,'yticklabel',acTickLabel);
    plot([-100 1000],[32.5 32.5],'w');
end


figure(17);
clf;
for iSelectedUnit = 1:4
    strctTmp = load(acFiles{iSelectedUnit});        
    strctUnit = strctTmp.strctUnit;
    subplot(1,4,iSelectedUnit);
    hold on;
    plot(strctUnit.m_aiPeriStimulusRangeMS,strctUnit.m_a2fAvgFirintRate_Category(1,:),'k');
    plot(strctUnit.m_aiPeriStimulusRangeMS,strctUnit.m_a2fAvgFirintRate_Category(2,:),'r');
    set(gca,'xlim',[-100 1000]);
end
