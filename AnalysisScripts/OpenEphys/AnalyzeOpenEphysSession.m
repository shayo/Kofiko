%clear all
% Kofiko-Open Ephys analysis script
% strRoot = 'C:\Users\shayo\Documents\GitHub\GUI\Builds\VisualStudio2012\Release64\bin\';
% strSession = 'filter_test3_2014-03-20_15-20-18';


strRoot = 'E:\Data\Doris\Electrophys\Houdini\ML_AL_Project\140404';
%strSession = '140404_154834_Houdini';
%strSession = '140404_160752_Houdini';
strSession = '140404_155441_Houdini';

%strRoot = 'E:\Data\Doris\Electrophys\Houdini\ML_AL_Project\140314\';
%strSession = '140314_150722_Houdini';
%% Additional parameters
%strOpenEphysScriptsFolder = 'C:\Users\shayo\Documents\GitHub\GUI\AnalysisScriptsAndTools';
%photodiodeTTLchannel = 


%% Open-ephys related definitions.
forceAnalysis = false;
verbose = true;

%addpath(strOpenEphysScriptsFolder);
strOutputFolder = 'processed';
strEventFile = 'all_channels.events';
strSettingsFile = 'settings.xml';
TTLchannelsPrefix = 'SETTINGS=>SIGNALCHAIN=>PROCESSOR=>Utilities/Record Control=>EDITOR=>EVENT_CHANNEL_NAME=>Name = ';
strPhotodiodeTTLchannelName = 'PHOTODIODE';
strKofikoSyncTTLchannelName = 'KOFIKO_SYNC';
strTrigger1TTLchannelName = 'STIM_TRIG1';
strTrigger2TTLchannelName = 'STIM_TRIG2';

strTrain1channelName = '100_ADC3';
strTrain2channelName = '100_ADC4';

strFastSettleChannelName = 'FAST_SETTLE';
discardIntervalsDuringFastSettle = true;
lowPassRange = [0.1 300];
highPassRange = [300 6000];
FilterType = 'Butterworth'; %'elliptical','Butterworth','bessel'
notchFilter = []; %60; 
distanceToOnlineSpikeInSamples = 3;
phaseOffsetSamples = 1; % online filters introduce this amount of phase shift...
% NEO = Nonlinear Enetry Operator
% SNEO = Nonlinear Enetry Operator + Barlett window smoothing
spikeThresholdMechanism = 'FixedLow'; % "Automatic","FixedLow", "FixedHigh","FixedBoth" "NEO", "GUI"
spikeThreshold = -25; % when using "Fixed", valuesa are in uV. When using "NEO", probably best to pick > 2000
spikeAlignment = 'Minimum'; %'Maximum','Minimum'
spikePreSamples = 8;
spikePostSamples = 32;

strEyeXPositionChannel = [strRoot,filesep,strSession,filesep,'100_ADC4.continuous'];
strEyeYPositionChannel = [strRoot,filesep,strSession,filesep,'100_ADC5.continuous'];
strStimulationTrainChannel = [strRoot,filesep,strSession,filesep,'100_ADC6.continuous'];

astrctFiles = dir([strRoot,filesep,strSession,filesep,'100_CH*']);
iNumChannels = length(astrctFiles);
acChannelFiles = cell(1,iNumChannels);
aiChannelNumber = zeros(1,iNumChannels);
for k=1:iNumChannels
    aiChannelNumber(k) = sscanf(astrctFiles(k).name,'100_CH%d.continuous');
    acChannelFiles{k} = [strRoot,filesep,strSession,filesep,astrctFiles(k).name];
end

%%
strKofikoFile = [strRoot,filesep,strSession,filesep,strSession,'.mat'];
strSyncFile = [strRoot,filesep,strSession,filesep,strSession,'_Sync.mat'];
strTriggerFile = [strRoot,filesep,strSession,filesep,strSession,'_Triggers.mat'];
strEventFileFullPath = [strRoot,filesep,strSession,filesep,strEventFile];
strEventMatFileFullPath = [strRoot,filesep,strSession,filesep,strEventFile,'.mat'];
strSettingsMatFileFullPath = [strRoot,filesep,strSession,filesep,strSettingsFile,'.mat'];

%% Step one - parse event file into a matlab file.

if ~exist(strEventMatFileFullPath,'file') || forceAnalysis
    fprintf('Parsing events file.\n');
    strctDataFromEvents = load_events_version_0_31(strEventFileFullPath,verbose);
    fprintf('Saving parsed events to disk.\n');
    save(strEventMatFileFullPath,'strctDataFromEvents');
else
    fprintf('Loading cached matlab events file.\n');
    strctTmp = load(strEventMatFileFullPath);
    strctDataFromEvents = strctTmp.strctDataFromEvents;
end



%% Extract information from the settings.xml file
if ~exist(strSettingsMatFileFullPath,'file') || forceAnalysis
    fprintf('Parsing XML settings file.\n');
    strSettingsFileFullPath = [strRoot,filesep,strSession,filesep,strSettingsFile];
    theStruct = parseXML(strSettingsFileFullPath);
    allXMLfields = parseXMLstructure(theStruct);
    save(strSettingsMatFileFullPath,'theStruct','allXMLfields');
else
    fprintf('Loading parsed XML settings file from cache.\n');
    strctTmp = load(strSettingsMatFileFullPath);
    allXMLfields = strctTmp.allXMLfields;
end
%% Sync
if exist(strSyncFile,'file') && ~forceAnalysis
    Tmp = load(strSyncFile);
    strctSync = Tmp.strctSync;
   strctKofiko = load(strKofikoFile);
else
    
%% Verify files exist.
if ~exist(strKofikoFile,'file')
    fprintf('***********Kofiko file is missing. Sync file will not be generated!\n');
    
else
    
    strctKofiko = load(strKofikoFile);
    
    % Kofiko - Stimulus Server
    strctSync = strctDataFromEvents.strctSync;
    afKofikoTS = strctKofiko.g_strctDAQParams.StimulusServerSync.Buffer(:,1);
    afStimulusServerTime = strctKofiko.g_strctDAQParams.StimulusServerSync.Buffer(:,2);
    
    [strctStimulusServerKofikoSync,JitterStd,Jitter] = fnTimeZoneFit(afStimulusServerTime, afKofikoTS);
    strctSync.strctStimulusServerKofikoSync = strctStimulusServerKofikoSync;
    fprintf('Stimulus Server to Kofiko Synchronization: mean: %.4f +- %.4f ms\n', nanmean(Jitter*1e3), JitterStd*1e3);
    
    if (verbose)
        figure(13);clf;
        plot(Jitter*1e3);
        xlabel('Timestamp index');
        ylabel('Jitter (ms)');
        title(sprintf('Stimulus Server to Kofiko Synchronization: mean: %.4f +- %.4f ms\n', nanmean(Jitter*1e3), JitterStd*1e3));
    end
    
    sampleRate = strctDataFromEvents.headerInfo.sampleRate;
    
    % High precision kofiko to hardware synchronization using TTLs
    % extract TTL hardware TS
    [astrctDetectedKofikoSyncIntervalsOnOpenEphys]= fnGetTTLdataAux(allXMLfields, strctDataFromEvents, TTLchannelsPrefix,  strKofikoSyncTTLchannelName);
    
    % kofiko sends these ttls with randomized inter-sync timing (between 100
    % and 1100 ms). This will help us to match them using string matching
    % algorithms :)
    afRoundedSyncDiffOpenEphys = round(diff(cat(1,astrctDetectedKofikoSyncIntervalsOnOpenEphys.m_iStart))/sampleRate * 10)/10;
    
    aiInd = find(strctKofiko.g_strctDAQParams.TTLlog.Buffer == strctKofiko.g_strctDAQParams.m_fSyncPort);
    afTriggersSentFromKofikoTS = strctKofiko.g_strctDAQParams.TTLlog.TimeStamp(aiInd)';
    afRoundedSyncDiffKofiko = round(diff(afTriggersSentFromKofikoTS)*10)/10;
    
    %figure;plot(afRoundedSyncDiffKofiko,'b');hold on;plot(afRoundedSyncDiffOpenEphys,'r.');
    
    if length(afRoundedSyncDiffKofiko) == length(afRoundedSyncDiffOpenEphys) && ...
            all(afRoundedSyncDiffOpenEphys == afRoundedSyncDiffOpenEphys)
        % Easy! they match perfectly!. no need for heavy compuations...
        
        % compute sync parameters
        afSyncEventsOpenEphysHardwareTS = cat(1,astrctDetectedKofikoSyncIntervalsOnOpenEphys.m_iStart);
        [strctKofikoSoftwareToEphysHardwareSync, JitterStd, Jitter] = fnTimeZoneFit(afTriggersSentFromKofikoTS,afSyncEventsOpenEphysHardwareTS);
        fprintf('Kofiko To Open Ephys Hardware Synchronization standard deviation: %.4f ms\n', JitterStd/sampleRate*1e3);
        if verbose
            figure(14);clf;
            plot(Jitter/sampleRate*1e3);
            xlabel('Timestamp index');
            ylabel('jitter (ms)');
            title(sprintf('Kofiko To Open Ephys Hardware Synchronization:  %.4f +- %.4f ms\n', mean(Jitter)/sampleRate*1e3, JitterStd/sampleRate*1e3));
        end
        strctSync.strctKofikoSoftwareToEphysHardwareSync = strctKofikoSoftwareToEphysHardwareSync;
    else
        fprintf('Mismatch in sync events between Kofiko and Open Ephys:\n');
        fprintf('Kofiko sent %d events and open ephys recorded %d\n',length(afRoundedSyncDiffKofiko),length(afRoundedSyncDiffOpenEphys));
        fMatchWeight = 2;
        fDeleteWeight = -1;
        fMismatchWeight = -3;
        Jitter = 0.01;
        
        [AtoB, BtoA, Alignment] = fnNeedlemanWunschAlignment(afRoundedSyncDiffKofiko,afRoundedSyncDiffOpenEphys,fMatchWeight,fDeleteWeight,fMismatchWeight,Jitter ) ;
     
        afSyncEventsOpenEphysHardwareTS = cat(1,astrctDetectedKofikoSyncIntervalsOnOpenEphys.m_iStart);
        
           [strctKofikoSoftwareToEphysHardwareSync, JitterStd, Jitter] = fnTimeZoneFit(afTriggersSentFromKofikoTS(~isnan(AtoB)),afSyncEventsOpenEphysHardwareTS(AtoB(~isnan(AtoB))));
 
        fprintf('Kofiko To Open Ephys Hardware Synchronization standard deviation: %.4f ms\n', JitterStd/sampleRate*1e3);
        if verbose
            figure(11);
            clf;
            subplot(3,1,1);
            plot(afRoundedSyncDiffKofiko,'b.');
            hold on;
            plot(BtoA(~isnan(BtoA)),afRoundedSyncDiffOpenEphys( ~isnan(BtoA)),'ro');
            plot(find(isnan(BtoA)),afRoundedSyncDiffOpenEphys( isnan(BtoA)),'g*');
            set(gca,'ylim',[0 1.5]);
            fprintf('%.2f%% kofiko sync events were matched to open ephys recorded events\n', sum(~isnan(AtoB))/length(AtoB)*100);
            subplot(3,1,2);
            plot(        afTriggersSentFromKofikoTS(~isnan(AtoB)),         afSyncEventsOpenEphysHardwareTS(AtoB(~isnan(AtoB))))
            subplot(3,1,3);
            plot(Jitter/sampleRate*1e3);
            xlabel('Timestamp index');
            ylabel('jitter (ms)');
            title(sprintf('Kofiko To Open Ephys Hardware Synchronization:  %.4f +- %.4f ms\n', median(Jitter)/sampleRate*1e3, mad(Jitter)/sampleRate*1e3));
            set(gca,'ylim',[-2 2])
        end
        strctSync.strctKofikoSoftwareToEphysHardwareSync = strctKofikoSoftwareToEphysHardwareSync;
        
    end
    
    save(strSyncFile, 'strctSync');
    

end

end



%figure;plot(afRoundedSyncDiffKofiko);hold on;plot(afRoundedSyncDiffKofiko,'r')

%% Extract information about photodiode
% First, find the ttl channel corresponding to photodiode...
[astrctPhotodiodeIntervalsWithJitter,acTTLchannelNames] = fnGetTTLdataAux(allXMLfields, strctDataFromEvents, TTLchannelsPrefix,  strPhotodiodeTTLchannelName);
if isempty(astrctPhotodiodeIntervalsWithJitter)
    fprintf('Cannot compute photodiode crossings, TTL channel name %s does not exist\n',strPhotodiodeTTLchannelName)
else
    sampleRate = strctDataFromEvents.headerInfo.sampleRate;
    iMergeThreshold = 2*strctKofiko.g_strctStimulusServer.m_fRefreshRateMS/1e3 * sampleRate; % two frame.
    astrctIntervalsNoJitter = fnMergeIntervals(astrctPhotodiodeIntervalsWithJitter, iMergeThreshold);
    afPhotodiodeFlipsTShardware = sort([cat(1,astrctIntervalsNoJitter.m_iStart);cat(1,astrctIntervalsNoJitter.m_iEnd)]);
    abPhotodiode = fnIntervalsToBinary(astrctIntervalsNoJitter, astrctIntervalsNoJitter(end).m_iEnd);
end
%% Analyze advancer position
astrctStimulationTrigger1 = fnGetTTLdataAux(allXMLfields, strctDataFromEvents, TTLchannelsPrefix,  strTrigger1TTLchannelName);
astrctStimulationTrigger2 = fnGetTTLdataAux(allXMLfields, strctDataFromEvents, TTLchannelsPrefix,  strTrigger2TTLchannelName);
[astrctFastSettleEvents,acTTLchannelNames] = fnGetTTLdataAux(allXMLfields, strctDataFromEvents, TTLchannelsPrefix,  strFastSettleChannelName);

strctTriggers.m_astrctStimulationTrigger1 = astrctStimulationTrigger1;
strctTriggers.m_astrctStimulationTrigger2 = astrctStimulationTrigger2;
strctTriggers.m_astrctFastSettleEvents= astrctFastSettleEvents;
strctTriggers.m_astrctPhotodiode = astrctIntervalsNoJitter;

save(strTriggerFile, 'strctTriggers');


%% apply low&high pass filters to raw channeld ata
% and save in "kofiko" raw format.
for ch=1:iNumChannels
    [~,chNameShort]=fileparts(acChannelFiles{ch});
    strOutputLFPfilename = [strRoot,filesep,strSession,filesep,strOutputFolder,filesep,chNameShort,'_LFP.raw'];
    strOutputSpikesFilename = [strRoot,filesep,strSession,filesep,strOutputFolder,filesep,chNameShort,'_Spikes.raw'];
    [data, timestamps, info] = load_continuous_data(acChannelFiles{ch});
    % we can't apply the filter on all samples because multiple recording
    % intervals may be present. Split it first, then filter each one
    % independently.
    if max(info.recNum) == 0
        aiStartNewSessionIndex = 1;
        aiEndSessionIndex = length(info.recNum);
    else
        % find out how many recording sessions were there...
        aiStartNewSessionIndex = [1,1+find(diff(info.recNum)>0)];
        aiEndSessionIndex = [aiStartNewSessionIndex(2:end)-1,length(info.recNum)];
    end
    numFrames = length(aiStartNewSessionIndex);
    nsamples = length(data);
    [~,tmp]=fileparts(acChannelFiles{ch});
    fprintf('Channel %s: %d recorded session found\n',tmp,numFrames);
    
    aiStartSampleInd=cumsum([info.nsamples]);
    aiStartSampleInd(1)=1;
    
    clear strctAnalog
    strctAnalog.m_iChannel = aiChannelNumber(ch);
    strctAnalog.m_fSamplingFreq = info.header.sampleRate;
    strctAnalog.m_strChannelName = info.header.channel;
    strctAnalog.m_aiNumSamplesPerFrame = zeros(1, numFrames);
    strctAnalog.m_afStartTS = zeros(1, numFrames);
    strctAnalog.m_afData  = zeros(1, nsamples);
        
    unitCounter = 1;
    clear astrctSpikes
    for session=1:numFrames
        fprintf('analyzing channel %d (%s), session %d/%d\n',strctAnalog.m_iChannel,strctAnalog.m_strChannelName,session,numFrames);
        aiInd = aiStartNewSessionIndex(session):aiEndSessionIndex(session);
        ndatapoints = sum(info.nsamples(aiInd));
        strctAnalog.m_aiNumSamplesPerFrame(session) = ndatapoints;
        aiSubInd = aiStartSampleInd(aiStartNewSessionIndex(session)):aiStartSampleInd(aiEndSessionIndex(session));
        strctAnalog.m_afStartTS(session) = timestamps(aiSubInd(1));
        subdata_uV_raw = data(aiSubInd)*info.header.bitVolts;
        subdata_uV = data(aiSubInd)*info.header.bitVolts;
        subdata_timestamps = timestamps(aiSubInd);
        
        
        
%         figure(11);clf;hold on;
%         plot(afAfterTimestamps,afFilteredAfter)
%         plot(afBeforeTimestamps,afFilteredBefore)
%          k=1;
%             plot(astrctFastSettleEvents(k).m_iStart*ones(1,2),[-200 200],'g');
%             plot(astrctFastSettleEvents(k).m_iEnd*ones(1,2),[-200 200],'g');
%       
%         % look for fast settle events.
%         filteredData=filtfilt(b,a,subdata_uV_raw);
%         nSamplesDiscardBefore = 1;
%         nSamplesDiscardAfter = 1;
%         if ~isempty(notchFilter)
% %             [b,a] = fnNotch(info.header.sampleRate,notchFilter);
% %             subdata_uV = fnFilterAndDiscard(subdata_timestamps,subdata_uV_raw, b,a, astrctFastSettleEvents,nSamplesDiscardBefore,nSamplesDiscardAfter);
%         end
        
%         
%         figure(11);
%         clf;
%         hold on;
% %         plot(subdata_timestamps,subdata_uV_raw,'b');
%         for k=1:length(astrctFastSettleEvents)
%             plot(astrctFastSettleEvents(k).m_iStart*ones(1,2),[-200 200],'g');
%             plot(astrctFastSettleEvents(k).m_iEnd*ones(1,2),[-200 200],'g');
%             plot([astrctFastSettleEvents(k).m_iStart,astrctFastSettleEvents(k).m_iEnd],[-200 -200],'g');
%             plot([astrctFastSettleEvents(k).m_iStart,astrctFastSettleEvents(k).m_iEnd],[200 200],'g');
%         end
%           strctAnalog.m_afData(aiSubInd) = fnFilterAndDiscard(subdata_timestamps,subdata_uV_raw, b,a, astrctFastSettleEvents,nSamplesDiscardBefore,nSamplesDiscardAfter);
%      
%           Y=filtfilt(b,a,subdata_uV_raw);
%         plot(subdata_timestamps,strctAnalog.m_afData,'r');
%         plot(subdata_timestamps,Y,'c');
%         
        % lfp
        if strcmpi(FilterType,'Elliptical')
            [b,a]=ellip(2,0.1,40,lowPassRange*2/info.header.sampleRate);
        elseif strcmpi(FilterType,'Butterworth')             
            [b,a]=butter(2,lowPassRange*2/info.header.sampleRate);
        end
        strctAnalog.m_afData(aiSubInd) = filtfilt(b,a,subdata_uV_raw);
        %fnFilterAndDiscard(subdata_timestamps,subdata_uV_raw, b,a, astrctFastSettleEvents,nSamplesDiscardBefore,nSamplesDiscardAfter);
        
        % spikes
        if strcmpi(FilterType,'Elliptical')
            [b,a]=ellip(2,0.1,40,highPassRange*2/info.header.sampleRate);
        elseif strcmpi(FilterType,'Butterworth')             
            [b,a]=butter(2,highPassRange*2/info.header.sampleRate,'bandpass');
        end
        
        filteredData=filtfilt(b,a,subdata_uV_raw);
        
        
        % ignore data at the start and end. we don't be able to extract
        % wave forms there anyway...
        waveformLength = spikePreSamples + spikePostSamples ;
        halfLength = waveformLength/2;
        
        filteredData(1:waveformLength) = NaN;
        filteredData(end-waveformLength:end) = NaN;
        
        thres=spikeThreshold;
        if strcmpi(spikeThresholdMechanism,'automatic')
            thres = 5*nanmedian(abs(filteredData)/0.6745);
            aiVoltageCrossing = find(abs(filteredData) > thres);
        elseif strcmpi(spikeThresholdMechanism,'FixedHigh')
            aiVoltageCrossing = find(filteredData > spikeThreshold);
        elseif strcmpi(spikeThresholdMechanism,'FixedLow')
            aiVoltageCrossing = find(filteredData < spikeThreshold);            
        elseif strcmpi(spikeThresholdMechanism,'FixedBoth')
            aiVoltageCrossing = find(abs(filteredData) > spikeThreshold);            
        elseif strcmpi(spikeThresholdMechanism,'NEO')
            neo = filteredData(2:end-1).^2 - filteredData(3:end).*filteredData(1:end-2);
            aiVoltageCrossing = neo > spikeThreshold;
        elseif strcmpi(spikeThresholdMechanism,'GUI')
            [thres,direction] = SpikeDetectThresholdSelectGUI(filteredData);
            if strcmpi(direction,'lower')
                aiVoltageCrossing = find(filteredData < thres);
            elseif strcmpi(direction,'higher')
                aiVoltageCrossing = find(filteredData > thres);
            elseif strcmpi(direction,'both')
                aiVoltageCrossing = find(abs(filteredData) > thres);
            else
                error('unknown spike detection threshold');    
            end
        else
            error('unknown spike detection mechanism');
        end
        % online detected spikes
        aiRelevantSortedSpikesInd = find(strctDataFromEvents.Spikes(:,3) == strctAnalog.m_iChannel & ...
            strctDataFromEvents.Spikes(:,2) > subdata_timestamps(1) &  strctDataFromEvents.Spikes(:,2) < subdata_timestamps(end));
        
        RelevantSpikes = strctDataFromEvents.Spikes(aiRelevantSortedSpikesInd,:);
        
        onlines_spikes_waveforms =strctDataFromEvents.AllWaveforms( aiRelevantSortedSpikesInd,:);
        onlineThreshold = mean(onlines_spikes_waveforms(:,1+spikePreSamples));
        online_spike_timestamps = strctDataFromEvents.Spikes(aiRelevantSortedSpikesInd,2) -phaseOffsetSamples;
        online_spike_unitID = strctDataFromEvents.Spikes(aiRelevantSortedSpikesInd,4);
        
        nSpikesOnline=length(online_spike_timestamps);
         
        % Align spike times to local minimum
        if strcmpi(spikeAlignment,'minimum')
            % Throw away spikes in the begining and end of the interval,
            % since we won't be able to extract their wave forms.
         
            aiRange = -spikePreSamples:spikePreSamples-1; % minimum search interval
            k = 1;
            cnt = 1;
            lastDetectedSpikeInd = 0;
            max_spikes = length(aiVoltageCrossing);
            offlineSpikeInd = zeros(1,max_spikes);
            offline_spike_timestamps = zeros(1,max_spikes);
            offlineWaveforms = zeros(max_spikes,waveformLength);
            for k=1:length(aiVoltageCrossing)
                [~,index]=min(filteredData(aiVoltageCrossing(k)+aiRange));
                newSpikeInd=aiVoltageCrossing(k)+index+aiRange(1);
                if (newSpikeInd > lastDetectedSpikeInd + spikePostSamples/2)
                    offlineSpikeInd(cnt) = newSpikeInd;
                    offline_spike_timestamps(cnt) = timestamps(newSpikeInd);
                    offlineWaveforms(cnt,:)=filteredData(newSpikeInd-spikePreSamples-1:newSpikeInd+spikePostSamples-2);
                    cnt = cnt+1;
                    lastDetectedSpikeInd = newSpikeInd;
                end
            end
            nSpikesOffline = cnt-1;
            offlineSpikeInd = offlineSpikeInd(1:nSpikesOffline);
            offline_spike_timestamps = offline_spike_timestamps(1:nSpikesOffline);
            offlineWaveforms = offlineWaveforms(1:nSpikesOffline,:);
            offlineSpikeID = zeros(1,nSpikesOffline);
            
            
            % Match offline spikes to on-line
            distSamples = zeros(1,nSpikesOffline);
            matchInd = zeros(1,nSpikesOffline);
            for k=1:nSpikesOffline
                [distSamples(k), matchInd(k)] = min( abs(online_spike_timestamps-offline_spike_timestamps(k)));
            end
            % Define a match if it is smaller than 3 samples?
            aiMatchedOfflineSpikesToOnlineSpikes = find(distSamples < 3);
            offlineSpikeID(aiMatchedOfflineSpikesToOnlineSpikes) = online_spike_unitID(matchInd(aiMatchedOfflineSpikesToOnlineSpikes));

            [uniqueOfflineSpikeIDs, ~, aiMapSpikeToUniqueUnitInd]=unique(offlineSpikeID);
            
            if 0
            figure(12);
            clf;hold on;
            selSpikeInd = 40;
            plot(offlineWaveforms(aiMatchedOfflineSpikesToOnlineSpikes(selSpikeInd),:));
            plot(onlines_spikes_waveforms( matchInd(aiMatchedOfflineSpikesToOnlineSpikes(selSpikeInd)),:),'r');
            end
            
            if 0
            figure(11);
            clf;
            hold on;
            plot(timestamps,filteredData); %plot continuous data;
            % plot online spikes
            spike_time = [-9:30];
            
            for k=1:nSpikesOffline
                plot(spike_time + offline_spike_timestamps(k), offlineWaveforms(k,:),'k');
            end
            
            
            for k=1:length(aiMatchedOfflineSpikesToOnlineSpikes)
                plot(spike_time + online_spike_timestamps(matchInd(aiMatchedOfflineSpikesToOnlineSpikes(k))), onlines_spikes_waveforms(matchInd(aiMatchedOfflineSpikesToOnlineSpikes(k)),:),'g');
            end
%             
%             for k=1:length(mismatchedOnlineSpikeInd)
%                 plot(spike_time + online_spike_timestamps(mismatchedOnlineSpikeInd(k)), onlines_spikes(mismatchedOnlineSpikeInd(k),:),'r');
%             end
%             
            set(gca,'ylim',[-50 50])
            end
            
            
            
            fprintf('%d spikes were detected OFFLINE for channel %s, session %d with threshold %.2f, of which, %d were matched to online spikes (%.2f%%)\n',...
            length(offlineSpikeInd),strctAnalog.m_strChannelName,session,thres,length(aiMatchedOfflineSpikesToOnlineSpikes),length(aiMatchedOfflineSpikesToOnlineSpikes)/length(offlineSpikeInd)*1e2);
            fprintf('%d spikes were detected ONLINE for channel %s, session %d with threshold %.2f\n',nSpikesOnline,strctAnalog.m_strChannelName,session,onlineThreshold);
           
             for k=1:length(uniqueOfflineSpikeIDs)
            
                % First, put all non-sorted spikes here.
                abRelevInd = aiMapSpikeToUniqueUnitInd == k;
                astrctSpikes(unitCounter).m_iUnitIndex = uniqueOfflineSpikeIDs(k);
                astrctSpikes(unitCounter).m_afTimestamps = offline_spike_timestamps(abRelevInd);
                astrctSpikes(unitCounter).m_iChannel = aiChannelNumber(ch);
                astrctSpikes(unitCounter).m_afInterval = [min(astrctSpikes(unitCounter).m_afTimestamps), max(astrctSpikes(unitCounter).m_afTimestamps)];
                astrctSpikes(unitCounter).m_a2fWaveforms = offlineWaveforms(abRelevInd,:);
                unitCounter=unitCounter+1;
            end
    
    
            
    
            
              if 0
                  aiNonMatchedSpikes = find(~abMatchOnline);
                  aiNonMatchedSpikesTimes = aiSpikeTimesDetectedOnline(aiNonMatchedSpikes);
                  
            figure(14);
            clf;
            plot(subdata_timestamps, filteredData,'b');
            sel=1;
            set(gca,'xlim',[aiNonMatchedSpikesTimes(sel)-350 aiNonMatchedSpikesTimes(sel)+350]);
            hold on;
            plot(ones(1,2)*aiNonMatchedSpikesTimes(sel),[-250 250],'g');
            
            plot( aiSpikeTimesDetectedOnline(aiNonMatchedSpikes(sel)) +[-8:31] ,        strctDataFromEvents.AllWaveforms(aiNonMatchedSpikes(sel),:),'r');
            end
            
            if (0)
                % Visually debug
                figure(14);
                clf;
                plot(subdata_timestamps, filteredData,'b');
                hold on;
                % plot offline-spikes
                for k=1:length(aiHardwareTimeStampDetectedSpikesOffline)
                    plot(aiHardwareTimeStampDetectedSpikesOffline(k)+[-spikePreSamples:spikePostSamples-1] ,a2fWaveFormsAlignedOffline(k,:),'r');
                end
                % plot online-spikes
                for k=1:length(aiSpikeTimesDetectedOnline)
                        plot(aiSpikeTimesDetectedOnline(k)+[-spikePreSamples:spikePostSamples-1]-phaseOffsetSamples ,strctDataFromEvents.AllWaveforms(aiRelevantSortedSpikesInd(k),:),'c');
                end
               
            end
                
            
        else
            error('unknown spike alignment method');
        end
        
      
        
    end
    % Merge entries with same unit ID
    astrctSpikes=fnMergeUnitsWithSameID(astrctSpikes);
    % Save LFP
    fnDumpChannel(strctAnalog,strOutputLFPfilename);
    % Dump Spikes
    
    strctChannelInfo.m_strPlxFile = acChannelFiles{ch};
    strctChannelInfo.m_strChannelName = info.header.channel;
    strctChannelInfo.m_iChannelID = aiChannelNumber(ch);
    strctChannelInfo.m_fGain = info.header.bitVolts;
    strctChannelInfo.m_fThreshold = thres;
    strctChannelInfo.m_bFiltersActive = false;
    strctChannelInfo.m_bSorted = false;
    
  
    fnDumpChannelSpikes(strctChannelInfo, astrctSpikes, strOutputSpikesFilename);
 
    
end

