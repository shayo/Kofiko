strFolder = 'E:\Data\Doris\Electrophys\Houdini\ML_AL_Project\140404\';
%strSession = '140404_160752_Houdini';
strSession = '140404_155441_Houdini';
strTriggerFile = [strFolder,filesep,strSession,filesep,strSession,'_Triggers.mat'];
figure(11);
clf;

%
if ~isempty(strctTriggers.m_astrctStimulationTrigger1)
    trigger1TS = cat(1,strctTriggers.m_astrctStimulationTrigger1.m_iStart);
else
    trigger1TS = [];
end

if ~isempty(strctTriggers.m_astrctStimulationTrigger2)
    trigger2TS = cat(1,strctTriggers.m_astrctStimulationTrigger2.m_iStart);
else
    trigger2TS = [];
end

if ~isempty(strctTriggers.m_astrctFastSettleEvents)
    fastSettle_StartTS = cat(1,strctTriggers.m_astrctFastSettleEvents.m_iStart);
    fastSettle_EndTS = cat(1,strctTriggers.m_astrctFastSettleEvents.m_iEnd);
else
    fastSettle_StartTS = [];
    fastSettle_EndTS = [];
end

%
%for k=5:length(strctTriggers.m_astrctStimulationTrigger1)
selectedTriggers = 1:length(trigger2TS);

aiPlotRange = -3000:3000;


numCh = 32;
numTriggers=length(selectedTriggers);
DataSet = zeros(numCh, numTriggers, length(aiPlotRange));
DataSetFiltered = zeros(numCh, numTriggers, length(aiPlotRange));
for ch=1:numCh
    strChannelFile = [strFolder,filesep,strSession,filesep,'100_CH',num2str(ch),'.continuous'];
    
    tmp=load(strTriggerFile);
    strctTriggers = tmp.strctTriggers;
    [data, timestamps, info] = load_continuous_data(strChannelFile);
    subdata_uV_raw = data*info.header.bitVolts;
    subdata_timestamps = timestamps;
    highPassRange = [600 6000];
    [b,a]=butter(2,highPassRange*2/info.header.sampleRate,'bandpass');
    filteredData=filtfilt(b,a,subdata_uV_raw);
    
    
    for triggerIter=1:numTriggers
        t0 = strctTriggers.m_astrctStimulationTrigger2(selectedTriggers(triggerIter)).m_iStart;
        DataIndexOfTriggerStart = t0-subdata_timestamps(1)+1;
        DataSetFiltered(ch,triggerIter,:) = filteredData(aiPlotRange+DataIndexOfTriggerStart);
        DataSet(ch,triggerIter,:) = subdata_uV_raw(aiPlotRange+DataIndexOfTriggerStart);
    end
    
end


selectedTrigger = 1;
t0 = strctTriggers.m_astrctStimulationTrigger2(selectedTriggers(selectedTrigger)).m_iStart;

% Find near by triggers/fast settle/trains/data and plot them.
trigger1IndToPlot = find(trigger1TS >= t0+aiPlotRange(1) & trigger1TS <=t0+aiPlotRange(end));
trigger2IndToPlot = find(trigger2TS >= t0+aiPlotRange(1) & trigger2TS <=t0+aiPlotRange(end));
fastSettleIntervalsToPlot = find(fastSettle_EndTS >= t0+aiPlotRange(1) & fastSettle_StartTS <=t0+aiPlotRange(end));
figure(11);
clf;
% train1ToPlot = train1(aiPlotRange+DataIndexOfTriggerStart);
% train2ToPlot = train2(aiPlotRange+DataIndexOfTriggerStart);
fMinData = min(dataToPlot);
fMaxData = max(dataToPlot);
for ch=1:32
subplot(4,8,ch);
hold on;
% Plot other triggers near by
for k=1:length(trigger1IndToPlot)
  plot(ones(1,2)*(trigger1TS(trigger1IndToPlot(k))-t0),[fMinData fMaxData],'g--');  
end
plot(ones(1,2)*0,[fMinData fMaxData],'g');  
for k=1:length(trigger2IndToPlot)
  plot(ones(1,2)*(trigger2TS(trigger1IndToPlot(k))-t0),[fMinData fMaxData],'c--');  
end
% plot fast settle
for k=1:length(fastSettleIntervalsToPlot)
  plot(ones(1,2)*(fastSettle_StartTS(fastSettleIntervalsToPlot(k))-t0),[fMinData fMaxData],'r');  
  plot(ones(1,2)*(fastSettle_EndTS(fastSettleIntervalsToPlot(k))-t0),[fMinData fMaxData],'r');  
  
  plot([(fastSettle_StartTS(fastSettleIntervalsToPlot(k))-t0) (fastSettle_EndTS(fastSettleIntervalsToPlot(k))-t0)],[fMinData fMinData],'r');  
  plot([(fastSettle_StartTS(fastSettleIntervalsToPlot(k))-t0) (fastSettle_EndTS(fastSettleIntervalsToPlot(k))-t0)],[fMaxData fMaxData],'r');  
end
% Finally, plot data
%whatToPlot = squeeze(DataSet(ch,selectedTrigger,:));
whatToPlot = squeeze(mean(DataSetFiltered(ch,1:10,:),2));
plot(aiPlotRange,whatToPlot,'b');

%title(sprintf('t0 = %d',t0));
title(sprintf('CH%d',ch));
set(gca,'ylim',[-50 50]);
set(gca,'xlim',[-0 350]);
drawnow
end


figure(13);
clf;

for ch=1:32
    subplot(4,8,ch);
    plot(aiPlotRange,squeeze(mean(DataSetFiltered(ch,16,:),2)));
     %set(gca,'ylim',[-50 50]);
     set(gca,'xlim',[-3000 3000]);
    xlabel('');
    ylabel('');
end

clear Table
figure(14);
for ch=1:32
    A = squeeze(sum(DataSetFiltered(ch,:,1:3000) < -15,3));
    B = squeeze(sum(DataSetFiltered(ch,:,3001:6000) < -15,3));
    [h,p]=ttest(A,B);
    Table(ch,1,:)=A;
    Table(ch,2,:)=B;
    subplot(4,8,ch);
    bar(mean(Table(ch,:,:),3))
    if p < 0.01
        title(sprintf('***CH%d',ch));
    else
        title(sprintf('CH%d',ch));
    end
end


% pause;
% end