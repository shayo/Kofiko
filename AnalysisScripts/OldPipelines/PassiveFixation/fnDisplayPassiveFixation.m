function ahSubPlots = fnDisplayPassiveFixation(ahPanels,strctUnit)
hParent = ahPanels(1);
if ~isfield(strctUnit,'m_afAvgFiringSamplesCategory')
    strctUnit.m_afAvgFiringSamplesCategory = 1e3*strctUnit.m_afAvgFiringRateCategory;
end

if isfield(strctUnit,'m_afRecordingRange') && ~isempty(strctUnit.m_afRecordingRange)
    set(hParent,'Title', sprintf( 'Recording Depth: %.2f - %.2f',strctUnit.m_afRecordingRange(1),strctUnit.m_afRecordingRange(2)));
else
    set(hParent,'Title', 'Recording Depth: Unknown');
end
h1 = tightsubplot(3,3,1,'Spacing',0.1,'Parent',hParent);
imagesc(strctUnit.m_aiPeriStimulusRangeMS,1:size(strctUnit.m_a2fAvgFirintRate_Stimulus,1),...
    strctUnit.m_a2fAvgFirintRate_Stimulus);
xlabel('Time (ms)');
ylabel('Stimulus Index');
colorbar
%title(sprintf('Firing rate (running avg, 30 ms)'));
axis xy
colormap jet


h2 = tightsubplot(3,3,2,'Spacing',0.1,'Parent',hParent);
imagesc(strctUnit.m_aiPeriStimulusRangeMS,1:size(strctUnit.m_a2fAvgFirintRate_Category,1),...
    strctUnit.m_a2fAvgFirintRate_Category);
hold on;


fON = median(strctUnit.m_strctStimulusParams.m_afStimulusON_MS);
fOFF = fON + median(strctUnit.m_strctStimulusParams.m_afStimulusOFF_MS);
plot([0 0],[0.5 0.5+size(strctUnit.m_a2fAvgFirintRate_Category,1)],'w')
plot([fON fON],[0.5 0.5+size(strctUnit.m_a2fAvgFirintRate_Category,1)],'w')
plot([fOFF fOFF],[0.5 0.5+size(strctUnit.m_a2fAvgFirintRate_Category,1)],'w')

if ~isfield(strctUnit.m_strctStatParams,'m_iStartAvgMS')
plot([strctUnit.m_strctStatParams.m_fStartAvgMS strctUnit.m_strctStatParams.m_fStartAvgMS],[0.5 0.5+size(strctUnit.m_a2fAvgFirintRate_Category,1)],'r')
plot([strctUnit.m_strctStatParams.m_fEndAvgMS strctUnit.m_strctStatParams.m_fEndAvgMS],[0.5 0.5+size(strctUnit.m_a2fAvgFirintRate_Category,1)],'r')

else
plot([strctUnit.m_strctStatParams.m_iStartAvgMS strctUnit.m_strctStatParams.m_iStartAvgMS],[0.5 0.5+size(strctUnit.m_a2fAvgFirintRate_Category,1)],'r')
plot([strctUnit.m_strctStatParams.m_iEndAvgMS strctUnit.m_strctStatParams.m_iEndAvgMS],[0.5 0.5+size(strctUnit.m_a2fAvgFirintRate_Category,1)],'r')
end

xlabel('Time (ms)');
ylabel('Category');
colorbar
%title(sprintf('Firing rate (running avg, 30 ms)'));
axis xy
colormap jet

h3=tightsubplot(1,3,3,'Spacing',0.13,'Parent',hParent);
hold off;

hold on;
%plot(h3,[strctUnit.m_fAvgBaseline strctUnit.m_fAvgBaseline],[0, strctUnit.m_iNumCategories+0.5],'c','Linewidth',2);
% axis([floor(min(strctUnit.m_afAvgFiringSamplesCategory)) eps+ceil(max(strctUnit.m_fAvgBaseline,max(strctUnit.m_afAvgFiringSamplesCategory))) 0 strctUnit.m_iNumCategories+0.5])
barh(1:strctUnit.m_iNumCategories, strctUnit.m_afAvgFiringSamplesCategory,0.7);

acCatNamesAug = cell(1,length(strctUnit.m_acCatNames));
acCatNamesAug = cell(1,length(strctUnit.m_acCatNames));
for k=1:length(acCatNamesAug)
    acCatNamesAug{k} = sprintf('%s [%d]',strctUnit.m_acCatNames{k},k);
end

set(h3,'ytick',1:length(strctUnit.m_acCatNames), 'YtickLabel',acCatNamesAug)
fSignificanceLevel = 0.01;
if isfield(strctUnit,'m_a2fPValueCat')
    abHypothesisRejected = strctUnit.m_a2fPValueCat(1:end-1,end) < fSignificanceLevel;
    plot(h3,1+strctUnit.m_afAvgFiringSamplesCategory(abHypothesisRejected),find(abHypothesisRejected), 'r*');
end
if ~isfield(strctUnit.m_strctStatParams,'m_iStartAvgMS')
    xlabel( sprintf('Avg firing [%d, %d] ms',strctUnit.m_strctStatParams.m_fStartAvgMS,strctUnit.m_strctStatParams.m_fEndAvgMS))
else
    xlabel( sprintf('Avg firing [%d, %d] ms',strctUnit.m_strctStatParams.m_iStartAvgMS,strctUnit.m_strctStatParams.m_iEndAvgMS))
end
title('Avg Firing and significance');

h4=tightsubplot(3,6,7,'Spacing',0.05,'Parent',hParent);
if isfield(strctUnit,'m_a2fAvgWaveFormCat')
    plot(strctUnit.m_a2fAvgWaveFormCat');
else
    afX = 1:length(strctUnit.m_afAvgWaveForm);
    afY = strctUnit.m_afAvgWaveForm;
    afS = strctUnit.m_afStdWaveForm;
    
    fill([afX, afX(end:-1:1)],[afY+afS, afY(end:-1:1)-afS(end:-1:1)], [0 1 1]);hold on;
    plot(afX,afY, 'color', 'm','LineWidth',2);
end

grid on;
xlabel('Avg Spike wave form');
h5=tightsubplot(3,6,8,'Spacing',0.05,'Parent',hParent);
hBar = bar(strctUnit.m_afISICenter(1:end-1), strctUnit.m_afISIDistribution(1:end-1));
set(hBar,'EdgeColor','none');
hold on;

fFractionISIinvalid = sum(diff(strctUnit.m_afSpikeTimes) < 1*1e-3) / length(strctUnit.m_afSpikeTimes) * 1e2;
aiIndices = find(strctUnit.m_afISICenter<1);
hBar2 = bar(strctUnit.m_afISICenter(aiIndices), strctUnit.m_afISIDistribution(aiIndices));
set(hBar2,'FaceColor','r','Edgecolor','none');
axis([0 strctUnit.m_afISICenter(end) 0 eps+1.1*max(strctUnit.m_afISIDistribution(1:end-1))])
xlabel('Time (ms)');
ylabel('ISI');
title(sprintf('ISI < 1ms = %.2f %%', fFractionISIinvalid));
%sum(diff(strctUnit.m_afSpikeTimes) * 1e3 < 2) / length(afSpikeTimes) * 100))

h6 = tightsubplot(3,3,5,'Spacing',0.1,'Parent',hParent);
if isfield(strctUnit,'m_a2fAvgLFPCategory') && ~isempty(strctUnit.m_a2fAvgLFPCategory)
plot(strctUnit.m_aiPeriStimulusRangeMS,strctUnit.m_a2fAvgLFPCategory');
grid on;
hold on;
plot([0 0],[ min(strctUnit.m_a2fAvgLFPCategory(:)) max(strctUnit.m_a2fAvgLFPCategory(:))],'k')
title('Local Field Potentials');
xlabel('Time (ms)');
set(gca,'xlim',[strctUnit.m_aiPeriStimulusRangeMS([1,end])]);
end

h7 = tightsubplot(3,3,7,'Spacing',0.13,'Parent',hParent);
iNumStimuli = size(strctUnit.m_a2bStimulusCategory,1);
[aiCount, aiCent] = hist(strctUnit.m_aiStimulusIndexValid,1:iNumStimuli);
hBar = plot(aiCent,aiCount);
%set(hBar,'EdgeColor','none')
xlabel('Stimulus ID');
ylabel('# of presentations');
axis([1 iNumStimuli, 0 eps+1.1*max(aiCount)])

h8 = tightsubplot(3,3,8,'Spacing',0.13,'Parent',hParent);
iNumCategories = size(strctUnit.m_a2bStimulusCategory,2);
plot(strctUnit.m_aiPeriStimulusRangeMS, strctUnit.m_a2fAvgFirintRate_Category')
xlabel('Time (ms)');
ylabel('Avg Res.');

%delete(get(ahPanels(2),'children'))
%h9 = subplot(2,2,1,'parent',ahPanels(2));
% A = log10(strctUnit.m_a2fPValueCat_BCorr);
% A(eye(size(A))>0) = 0;
% imagesc(A,'parent',h9)
% colormap jet
% colorbar
% set(h9,'ytick',1:(length(strctUnit.m_acCatNames)+1), 'YtickLabel',[strctUnit.m_acCatNames,'Baseline'])
% set(h9,'xtick',1:length(strctUnit.m_acCatNames)+1);%, 'XtickLabel',[strctUnit.m_acCatNames,'Baseline'])
% title('Log10 p-value');


%h10 = subplot(2,2,2,'parent',ahPanels(2));
% imagesc(strctUnit.m_a2bSignificantCat_BCorr,'parent',h10)
% colormap jet
% set(h10,'ytick',1:(length(strctUnit.m_acCatNames)+1), 'YtickLabel',[strctUnit.m_acCatNames,'Baseline'])
% set(h10,'xtick',1:length(strctUnit.m_acCatNames)+1);%, 'XtickLabel',[strctUnit.m_acCatNames,'Baseline'])
% title('U-test Significance Result');


ahSubPlots = [h1,h2,h3,h4,h5,h6,h7,h8];


%
% acUnits = {strctUnit};
%
% pThreshold = 1e-8;
%
% iNumExperiments = length(acUnits);
% abFOBExperiments = zeros(1,iNumExperiments) > 0;
% for k=1:iNumExperiments
%     abFOBExperiments(k) =  strcmp(acUnits{k}.m_strImageListDescrip,'SinhaFOB');
% end
%
% % Compute Face Selectivity index
% aiFOB = find(abFOBExperiments);
% iNumFOBExperiments = length(aiFOB);
% aiFaceSelectivityIndex = zeros(1,iNumFOBExperiments);
%
%
% a2fAvgFiringCat = zeros(9, 701);%size(acUnits{aiFOB(1)}.m_a2fAvgFirintRate_Category));
%
% for iExpIter=1:iNumFOBExperiments
%     iFaceGroup = find(ismember(acUnits{aiFOB(iExpIter)}.m_acCatNames,'Faces'));
%     aiNonFaceGroups = find(ismember(acUnits{aiFOB(iExpIter)}.m_acCatNames,    {'Bodies',    'Fruits',    'Gadgets',    'Hands',    'Scrambles'}));
%     fFaceRes = acUnits{aiFOB(iExpIter)}.m_afAvgFiringSamplesCategory(iFaceGroup);
%     fNonFaceRes = mean(acUnits{aiFOB(iExpIter)}.m_afAvgFiringSamplesCategory(aiNonFaceGroups));
%     aiFaceSelectivityIndex(iExpIter) =  (fFaceRes - fNonFaceRes) / (fFaceRes + fNonFaceRes);
%     a2fAvgFiringCat(1:6,:) = ( (iExpIter-1) * a2fAvgFiringCat(1:6,:) + acUnits{aiFOB(iExpIter)}.m_a2fAvgFirintRate_Category(1:6,:)) / iExpIter;
%
%     aiPeriStimulusRangeMS = acUnits{aiFOB(iExpIter)}.m_strctStatParams.m_iBeforeMS:acUnits{aiFOB(iExpIter)}.m_strctStatParams.m_iAfterMS;
%     iStartAvg = find(aiPeriStimulusRangeMS>=acUnits{aiFOB(iExpIter)}.m_strctStatParams.m_fStartAvgMS,1,'first');
%     iEndAvg = find(aiPeriStimulusRangeMS>=acUnits{aiFOB(iExpIter)}.m_strctStatParams.m_fEndAvgMS,1,'first');
%
%
%     a2fAvgFiringCat(7,:) = ( (iExpIter-1) * a2fAvgFiringCat(7,:) + mean(acUnits{aiFOB(iExpIter)}.m_a2fAvgFirintRate_Stimulus(97:338,:),1)) / iExpIter;
%     a2fAvgFiringCat(8,:) = ( (iExpIter-1) * a2fAvgFiringCat(8,:) + mean(acUnits{aiFOB(iExpIter)}.m_a2fAvgFirintRate_Stimulus(96+243:96+25,:),1)) / iExpIter;
%     a2fAvgFiringCat(9,:) = ( (iExpIter-1) * a2fAvgFiringCat(9,:) + mean(acUnits{aiFOB(iExpIter)}.m_a2fAvgFirintRate_Stimulus(96+253:96+255,:),1)) / iExpIter;
% end

%
% hAxes = axes('parent',ahPanels(4));
% axis(hAxes);
% cla;
% plot(acUnits{aiFOB(1)}.m_aiPeriStimulusRangeMS, a2fAvgFiringCat','LineWidth',2);
% legend([acUnits{aiFOB(1)}.m_acCatNames(1:6),'Sinha','Sinha Scrambled','Pink Noise']);
% xlabel('Time (ms)');
% ylabel('Firing Rate (Hz)');
% title('Average Firing Rate');
% grid on
if ~isempty(strctUnit.m_strctStimulusParams.m_afStimulusON_MS)
hAxes = axes('parent',ahPanels(4));
hAxes = subplot(2,2,1);
[a,b]=unique(strctUnit.m_strctStimulusParams.m_afStimulusON_MS);
bar(a,b)
title('ON Time');

hAxes = subplot(2,2,2);
[a,b]=unique(strctUnit.m_strctStimulusParams.m_afStimulusOFF_MS);
bar(a,b)
title('OFF Time');

hAxes = subplot(2,2,3);
[a,b]=unique(strctUnit.m_strctStimulusParams.m_afStimulusSizePix);
bar(a,b)
title('Size (Half width)');

hAxes = subplot(2,2,4);
[a,b]=unique(strctUnit.m_strctStimulusParams.m_afRotationAngle);
bar(a,b)
title('Rotation Angle');

end

if isfield(strctUnit,'m_strctValidTrials')
    hParent = ahPanels(2);
    h1 = tightsubplot(2,1,1,'Spacing',0.2,'Parent',hParent);
    plot(strctUnit.m_strctValidTrials.m_afEyeDistanceFromFixationSpotMin);
    hold on;
    if sum(strctUnit.m_strctValidTrials.m_abValidTrials) > 0
        plot(strctUnit.m_strctValidTrials.m_afEyeDistanceFromFixationSpotMedian,'g');
        plot(strctUnit.m_strctValidTrials.m_afAvgStimulusSize,'r');
        axis([1 length(strctUnit.m_strctValidTrials.m_afEyeDistanceFromFixationSpotMin) 0 1.5*max(strctUnit.m_strctValidTrials.m_afAvgStimulusSize)]);
        legend('Min','Median','Stimulus Size');
        xlabel('Trial');
        ylabel('Distance From Fixation Spot (pix)');
        title('Monkey Fixation Performance');
        h2 = tightsubplot(2,1,2,'Spacing',0.2,'Parent',hParent);
        
        iCorrect = sum(strctUnit.m_strctValidTrials.m_afFixationPerc >= strctUnit.m_strctValidTrials.m_fFixationPercThreshold);
        iIncorrect = sum(strctUnit.m_strctValidTrials.m_afFixationPerc < strctUnit.m_strctValidTrials.m_fFixationPercThreshold);
        explode = [1 0];
        pie(h2,[iCorrect,iIncorrect] ,explode)
        legend({'Fixation','Non Fixated'},'Location','NorthEastOutside');
        title(sprintf('%d Trials, Critera: %d%% of presentation time',length(strctUnit.m_strctValidTrials.m_afFixationPerc), strctUnit.m_strctValidTrials.m_fFixationPercThreshold));
        
        %    h2 = tightsubplot(2,2,2,'Spacing',0.2,'Parent',hParent);
        
        %    h2 = tightsubplot(2,1,2,'Spacing',0.2,'Parent',hParent);
        
    end
end
return;
