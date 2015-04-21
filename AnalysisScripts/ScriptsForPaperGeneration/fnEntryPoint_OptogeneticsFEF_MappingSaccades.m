function fnEntryPoint_OptogeneticsFEF_MappingSaccades

fPIX_TO_VISUAL_ANGLE_OldRig = 28.8/800;
fPIX_TO_VISUAL_ANGLE_NewRig = 28.8 / 1920;

strctRawBertChR2 = load('D:\Data\Doris\Electrophys\Bert\Optogenetics\120514\RAW\..\Processed\ElectricalMicrostim\Bert-14-May-2012_14-51-29_ElectricalMicrostim_Channel1.mat');
strctRawBertArchT = load('D:\Data\Doris\Electrophys\Bert\Optogenetics\120514\RAW\..\Processed\ElectricalMicrostim\Bert-14-May-2012_15-50-35_ElectricalMicrostim_Channel1.mat');

strctRawJulienChR2= load('D:\Data\Doris\Electrophys\Julien\Optogenetics\120124\RAW\..\Processed\ElectricalMicrostim\Julien-24-Jan-2012_13-29-58_ElectricalMicrostim_Channel1.mat');

strctRawJulienArchT = load('D:\Data\Doris\Electrophys\Julien\Optogenetics\120127\RAW\..\Processed\ElectricalMicrostim\Julien-27-Jan-2012_11-26-56_ElectricalMicrostim_Channel1.mat');
strctRawJulienHalo =  load('D:\Data\Doris\Electrophys\Julien\Optogenetics\120125\RAW\..\Processed\ElectricalMicrostim\Julien-25-Jan-2012_18-23-35_ElectricalMicrostim_Channel1.mat');

strctRawAnakinChR2hSyn=  load('D:\Data\Doris\Electrophys\Anakin\Optogenetics\130214\RAW\..\Processed\ElectricalMicrostim\Anakin-14-Feb-2013_14-01-34_ElectricalMicrostim_Channel1.mat');
strctRawAnakinChR2CamK=  load('D:\Data\Doris\Electrophys\Anakin\Optogenetics\130214\RAW\..\Processed\ElectricalMicrostim\Anakin-14-Feb-2013_13-29-43_ElectricalMicrostim_Channel1.mat');

[strctAnakinChR2_CamkII.m_afDepths,strctAnakinChR2_CamkII.m_afMean, strctAnakinChR2_CamkII.m_afStd, ~,afSaccadeLatenciesAnakinChR2_CamKII]=fnAnaylzeSaccadeBeforeInjection(strctRawAnakinChR2CamK,fPIX_TO_VISUAL_ANGLE_NewRig);
[strctAnakinChR2_hSyn.m_afDepths,strctAnakinChR2_hSyn.m_afMean, strctAnakinChR2_hSyn.m_afStd, acSaccadesAnakin,afSaccadeLatenciesAnakinChR2_hSyn, afMeanDirJulienChR2, afStdDirJulienChR2]=fnAnaylzeSaccadeBeforeInjection(strctRawAnakinChR2hSyn,fPIX_TO_VISUAL_ANGLE_NewRig);

[strctBertChR2.m_afDepths,strctBertChR2.m_afMean, strctBertChR2.m_afStd,acSaccadesBert, afSaccadeLatenciesBertChR2]=fnAnaylzeSaccadeBeforeInjection(strctRawBertChR2,fPIX_TO_VISUAL_ANGLE_OldRig);
[strctBertArchT.m_afDepths,strctBertArchT.m_afMean, strctBertArchT.m_afStd,~, afSaccadeLatenciesBertArchT]=fnAnaylzeSaccadeBeforeInjection(strctRawBertArchT,fPIX_TO_VISUAL_ANGLE_OldRig);
[strctJulienChR2.m_afDepths,strctJulienChR2.m_afMean, strctJulienChR2.m_afStd,acSaccadesJulien,afSaccadeLatenciesJulienChR2]=fnAnaylzeSaccadeBeforeInjection(strctRawJulienChR2,fPIX_TO_VISUAL_ANGLE_OldRig);
[strctJulienArchT.m_afDepths,strctJulienArchT.m_afMean, strctJulienArchT.m_afStd,~,afSaccadeLatenciesJulienArchT]=fnAnaylzeSaccadeBeforeInjection(strctRawJulienArchT,fPIX_TO_VISUAL_ANGLE_OldRig);
[strctJulienHalo.m_afDepths,strctJulienHalo.m_afMean, strctJulienHalo.m_afStd,~,afSaccadeLatenciesJulienHalo]=fnAnaylzeSaccadeBeforeInjection(strctRawJulienHalo,fPIX_TO_VISUAL_ANGLE_OldRig);

afLatencies = [afSaccadeLatenciesAnakinChR2_CamKII,afSaccadeLatenciesAnakinChR2_hSyn,afSaccadeLatenciesBertChR2,afSaccadeLatenciesBertArchT,afSaccadeLatenciesJulienChR2,afSaccadeLatenciesJulienArchT,afSaccadeLatenciesJulienHalo];




figure(13);clf; hold on;
a2fColors = jet(length(strctBertChR2.m_afDepths));
for j=1:length(acSaccadesBert)
    if ~isempty(acSaccadesBert{j})
        plot(acSaccadesBert{j}{2}(:,200:450)',-acSaccadesBert{j}{3}(:,200:450)','color',a2fColors(j,:))
    end
 
end
rectangle('position',[-25 -25 10 2],'facecolor','k');
set(gca,'xlim',[-30 30],'ylim',[-30 30]);
set(gca,'xtick',[]);
set(gca,'ytick',[]);
box on
colormap(a2fColors);
colorbar('ylim',[1 15],'location','eastoutside')

 figure(10);clf;hold on;
     set(gcf,'position',[ 1020        1032         120          66])
     plot([0 0],[0 30],'--','color',[0.5 0.5 0.5])
     plot(-200:500,acSaccadesBert{8}{1}','k')
     set(gca,'xlim',[-100 500])
     set(gca,'ylim',[0 30])
     set(gca,'ytick',[0 15,30])
     set(gca,'fontSize',7)
     box off
figure(12);clf;hold on;
     plot(acSaccadesBert{8}{2}(:,200:450)',-acSaccadesBert{8}{3}(:,200:450)','k')
    rectangle('position',[-25 -25 10 2],'facecolor','k');
plot(0,0,'r+');
set(gca,'xlim',[-30 30],'ylim',[-30 30]);
set(gca,'xtick',[]);
set(gca,'ytick',[]);
box on
 


afColorChR2 = [0,176,240]/255;
afColorArchT = [0,176,80]/255;
afColorCheta1 = [140,25,255]/255;
afColorCheta2 = [64,255,191]/255;
afColorHalo = [255,192,0]/255;
figure(12);clf;
subplot(3,1,1);
hold on;
fnAuxPlot(strctBertChR2,afColorChR2,28.5);
fnAuxPlot(strctBertArchT,afColorArchT,27.5);

% set(gcf,'position',[ 1178         967         211          82]);
set(gca,'xlim',[-1 6])
set(gca,'xtickLabel',[]);

%set(gca,'xtick',-1:6);
set(gca,'ylim',[0 35])

box off
subplot(3,1,2);hold on;
fnAuxPlot(strctJulienHalo,afColorHalo,29);
fnAuxPlot(strctBertArchT,afColorArchT,29);

fnAuxPlot(strctJulienChR2,afColorChR2,29);

set(gca,'xlim',[-1 6])
set(gca,'xtickLabel',[]);
set(gca,'ylim',[0 30])

box off
subplot(3,1,3);hold on;
fnAuxPlot(strctAnakinChR2_CamkII,afColorCheta1,24.2);
fnAuxPlot(strctAnakinChR2_hSyn,afColorCheta2,24.2);

set(gca,'xlim',[-1 6])
set(gca,'ylim',[0 30])
set(gca,'xtick',-1:6);
 set(gcf,'position',[ 1086         772         154         326]);
 
return

function fnAuxPlot(strctData,afColor, fZeroDepth)
plot(strctData.m_afDepths-fZeroDepth, strctData.m_afMean, 'color',afColor,'linewidth',2);
fWidth = 0.05;
for k=1:length(strctData.m_afDepths)
    plot([strctData.m_afDepths(k)-fZeroDepth-fWidth strctData.m_afDepths(k)-fZeroDepth+fWidth],...
            ones(1,2)*( strctData.m_afMean(k)+strctData.m_afStd(k)), 'color',afColor*0.8,'linewidth',1);
    plot([strctData.m_afDepths(k)-fZeroDepth-fWidth strctData.m_afDepths(k)-fZeroDepth+fWidth],...
        ones(1,2)*( strctData.m_afMean(k)-strctData.m_afStd(k)), 'color',afColor*0.8,'linewidth',1);
    plot((strctData.m_afDepths(k)-fZeroDepth)*ones(1,2),...
        [strctData.m_afMean(k)+strctData.m_afStd(k) strctData.m_afMean(k)-strctData.m_afStd(k)], 'color',afColor*0.8,'linewidth',1);
end
set(gca,'fontSize',7);

