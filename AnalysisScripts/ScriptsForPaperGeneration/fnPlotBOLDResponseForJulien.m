strctData = load('D:\Data\Doris\Data For Publications\FEF Opto\Snapshots from free surfer\Julien\JulienROI.mat');
a2fBOLD = -strctData.a2fBOLD_Perc;
a2fBOLD = conv2(a2fBOLD, fspecial('gaussian',[1 20],1),'same');
N=size(a2fBOLD,1);
figure(11);
clf; hold on;
axis([0 519/60 -9 9])
afBlue = [0,176,240]/255;
afGray = [200,200,200]/255;
afBothColor = (afBlue+afGray)/4;

afGrayOnset = 2*[0,32,64,96,128,160,192]/60;
afOpticalOnset = 2*[16,80,144,176]/60;
afElectricalOnset = 2*[48,80,112,176]/60;
afBoth = intersect(afElectricalOnset,afOpticalOnset);
afOnlyOptical = setdiff(afOpticalOnset,afBoth);
afOnlyElectrical = setdiff(afElectricalOnset,afBoth);
for k=1:length(afOnlyOptical)
   rectangle('position',[afOnlyOptical(k),-14,40/60,28],'facecolor',afBlue,'edgecolor','none');
end

for k=1:length(afBoth)
   rectangle('position',[afBoth(k),-14,40/60,28],'facecolor',afBothColor,'edgecolor','none');
end

for k=1:length(afOnlyElectrical)
     rectangle('position',[afOnlyElectrical(k),-14,40/60,28],'facecolor',afGray,'edgecolor','none');
 
end
% plot(([1:260]*2 -1)/60,mean(a2fBOLD,1)-std(a2fBOLD,1)/sqrt(N),'--','color',[0.5 0.5 0.5],'LineWidth',1);
% plot(([1:260]*2 -1)/60,mean(a2fBOLD,1)+std(a2fBOLD,1)/sqrt(N),'--','color',[0.5 0.5 0.5],'LineWidth',1);
plot(([1:208]*2 -1)/60,mean(a2fBOLD,1),'k','LineWidth',2);


set(gca,'xtick',(0:32:2*208)/60);
set(gca,'xticklabel',[])
set(gca,'ylim',[-14 14]);
set(gca,'xlim',[0 2*208/60])
set(gcf,'position',[ 956   755   522    99]);
set(gca,'fontsize',7);

%% Plot as if 40 sec to make visualization easier....
for k=1:size(a2fBOLD,1)
    aiX = 1:208;
    aiY = a2fBOLD(k,:);
    aiXs = linspace(1,208, 260);
    a2fBOLD_Interpolated(k,:) = interp1(aiX,aiY,aiXs);  
end
figure(13);clf; hold on;

afGrayOnset = 2*[0,40,80,120,160,200,240]/60;
afOpticalOnset = 2*[20,100,180,220]/60;
afElectricalOnset = 2*[60,100,140,220]/60;
afBoth = intersect(afElectricalOnset,afOpticalOnset);
afOnlyOptical = setdiff(afOpticalOnset,afBoth);
afOnlyElectrical = setdiff(afElectricalOnset,afBoth);
for k=1:length(afOnlyOptical)
   rectangle('position',[afOnlyOptical(k),-14,40/60,28],'facecolor',afBlue,'edgecolor','none');
end

for k=1:length(afBoth)
   rectangle('position',[afBoth(k),-14,40/60,28],'facecolor',afBothColor,'edgecolor','none');
end

for k=1:length(afOnlyElectrical)
     rectangle('position',[afOnlyElectrical(k),-14,40/60,28],'facecolor',afGray,'edgecolor','none');
 
end
% plot(([1:260]*2 -1)/60,mean(a2fBOLD,1)-std(a2fBOLD,1)/sqrt(N),'--','color',[0.5 0.5 0.5],'LineWidth',1);
% plot(([1:260]*2 -1)/60,mean(a2fBOLD,1)+std(a2fBOLD,1)/sqrt(N),'--','color',[0.5 0.5 0.5],'LineWidth',1);
plot(([1:260]*2 -1)/60,mean(a2fBOLD_Interpolated,1),'k','LineWidth',2);


set(gca,'xtick',(0:40:2*260)/60);
set(gca,'xticklabel',[])
set(gca,'ylim',[-14 14]);
set(gcf,'position',[ 956   755   522    99]);
set(gca,'fontsize',7);
set(gca,'xlim',[0 2*260/60]);
%%

afGrayOnset = [32,64,96,128,160];
afOpticalOnset = [16,80,144,176];
afElectricalOnset = [48,80,112,176];
afBoth = intersect(afElectricalOnset,afOpticalOnset);
afOnlyOptical = setdiff(afOpticalOnset,afBoth);
afOnlyElectrical = setdiff(afElectricalOnset,afBoth);


acConditions = {afGrayOnset,afOnlyOptical,afBoth,afOnlyElectrical};
iNumCond = length(acConditions);

aiTime = -3:30;
iNumPts = length(aiTime);
a2fMeanResponse = zeros(iNumCond,iNumPts);
a2fSEMResponse = zeros(iNumCond,iNumPts);
for iCondIter=1:iNumCond
    aiOnset = acConditions{iCondIter};
    a2fResponse = zeros(0, length(aiTime));
    for iRepIter=1:length(aiOnset)
        T0=1+aiOnset(iRepIter);
        aiRange = T0+aiTime;
        a2fResponse = [a2fResponse; a2fBOLD(:,aiRange)];
    end
    N = size(a2fResponse,1);
    M = size(a2fResponse,2);
    a2fConf = zeros(2,M);
    for k=1:M
        [~,~,a2fConf(:,k)]=ttest(a2fResponse(:,k));
    end
    afConfidenceLow(iCondIter,:) = a2fConf(1,:);
    afConfidenceHigh(iCondIter,:) = a2fConf(2,:);
    a2fMeanResponse(iCondIter,:) = mean(a2fResponse,1);
    a2fSEMResponse(iCondIter,:) = std(a2fResponse,1)/N;
end

figure(100);
clf;
hold on;
%plot([aiTime(1),aiTime(end)],ones(1,2) * mean(a2fMeanResponse(1,:)),'color',[0.5 0.5 0.5],'LineWidth',2);
plot(aiTime*2,a2fMeanResponse(1,:),'color',[0.5 0.5 0.5],'LineWidth',2);
plot(aiTime*2,a2fMeanResponse(2,:),'color', 'r','LineWidth',2);
plot(aiTime*2,a2fMeanResponse(3,:),'color', afBlue,'LineWidth',2);
plot(aiTime*2,a2fMeanResponse(4,:),'color', 'k','LineWidth',2);

% plot(aiTime*2,afConfidenceLow(1,:),'--','color',[0.5 0.5 0.5]);
% plot(aiTime*2,afConfidenceHigh(1,:),'--','color',[0.5 0.5 0.5]);
% plot(aiTime*2,afConfidenceHigh(2,:),'r--');
% plot(aiTime*2,afConfidenceLow(2,:),'r--');
set(gca,'xlim',[aiTime(1),aiTime(end)]*2);
set(gca,'ylim',[-7 10]);
set(gca,'fontsize',7);

%%

global g_strctModule
g_strctModule.m_strctOverlay.m_pt2fLeft = [-7 1];
g_strctModule.m_strctOverlay.m_pt2fRight = [-4 0];
g_strctModule.m_strctOverlay.m_pt2fLeftPos = [4 0];
g_strctModule.m_strctOverlay.m_pt2fRightPos = [7 1];
