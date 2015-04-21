function fnConvertPLXtoFastDataAccess(strInputFile, strctOptions, hProgress)
% Convert PLX file to fast data access files (like DDT, but with more
% information....
%strSessionName = '110506_152934_Houdini';
%strInputFolder = 'D:\Dropbox\My Dropbox\RAW\';
if ~exist('hProgress','var')
    hProgress = [];
end;

fprintf('Converting %s...',strInputFile);
[strInputFolder, strSessionName,strExp] = fileparts(strInputFile);

if strctOptions.m_bAnalog
    if ~isempty(hProgress)
        fnResetWaitbar(hProgress);
    end
    %% Determine Channels names
    [iNumChannels, aiNumSamples] = plx_adchan_samplecounts(strInputFile);
    plx_close(strInputFile);
    aiActiveAnalogChannels = find(aiNumSamples> 0);
    iNumActiveChannels = length(aiActiveAnalogChannels);
    
    [iNumAnalogFields,a2cAnalogFieldNames] = plx_adchan_names(strInputFile);
    plx_close(strInputFile);
    
    %% Dump Analog Channels
    acAnalogChannelNames = fnCharToCell(a2cAnalogFieldNames);
    fprintf('Analog channels...');
    
    for iActiveChannelIter=1:iNumActiveChannels
        if ~isempty(hProgress)
            fnSetWaitbar(hProgress, iActiveChannelIter/iNumActiveChannels);
        end
        
        clear strctAnalog
        strctAnalog.m_iChannel = aiActiveAnalogChannels(iActiveChannelIter);
        strctAnalog.m_strChannelName = acAnalogChannelNames{strctAnalog.m_iChannel};
        
        if strncmpi(strctAnalog.m_strChannelName,'LFP',3) || strncmpi(strctAnalog.m_strChannelName,'AD',2) || strncmpi(strctAnalog.m_strChannelName,'RAW',3)
            [strctAnalog.m_fSamplingFreq, ...
                iTotalNumberofSamples, ...
                strctAnalog.m_afStartTS, ...
                strctAnalog.m_aiNumSamplesPerFrame, ...
                strctAnalog.m_afData] = ...
                plx_ad_v(strInputFile, strctAnalog.m_iChannel-1	); %Plexon counts from zero
            
        else
            [strctAnalog.m_fSamplingFreq, ...
                iTotalNumberofSamples, ...
                strctAnalog.m_afStartTS, ...
                strctAnalog.m_aiNumSamplesPerFrame, ...
                strctAnalog.m_afData] = ...
                plx_ad(strInputFile, strctAnalog.m_iChannel-1	); %Plexon counts from zero
        end
        strOutFilename = fullfile(strInputFolder, [strSessionName,'-',strctAnalog.m_strChannelName,'.raw']);
        fnDumpChannel(strctAnalog,strOutFilename);
    end
end
if strctOptions.m_bStrobe
    if ~isempty(hProgress)
        fnResetWaitbar(hProgress);
        fnSetWaitbar(hProgress, 0.5);
    end
      
    fprintf('Strobe words...');
    %% Dump strobe words
    [iNumStrobeEvents, afStrobeTimeStamps, Tmp] = plx_event_ts(strInputFile, 257);
    strctStrobeWord.m_aiWords = Tmp+32768;
    strctStrobeWord.m_afTimestamp = afStrobeTimeStamps;
    strStrobeWordFile =  fullfile(strInputFolder, [strSessionName,'-','strobe.raw']);
    fnDumpStrobeWords(strctStrobeWord, strStrobeWordFile)
    if ~isempty(hProgress)
        fnSetWaitbar(hProgress, 1);
    end
    
end
if strctOptions.m_bSpikes
    if ~isempty(hProgress)
        fnResetWaitbar(hProgress);
    end     
    fprintf('Spikes...');
    %% Dump Spike information
    
    %strInputFile
    if exist([strInputFolder, filesep,strSessionName,'_part_0.plx'],'file')
        fprintf('WARNING!!! Automatic conversion of splitted plexon files to RAW format has not been implemented yet...\n');
    end    
    [n,cChannelNames] = plx_chan_names(strInputFile);
    acChannelNames = fnCharToCell(cChannelNames);
    [n,abFilterActive] = plx_chan_filters(strInputFile);
    [n,afLastThresholdRecorded] = plx_chan_thresholds(strInputFile);
    [n,afLastGainRecorded] = plx_chan_gains(strInputFile);
    
    [a2iSpikeCount, wfcounts, evcounts] = plx_info(strInputFile, 1); % Replace this with the mex file once plexon fix their bug....
    aiActiveSpikeChannels = find(sum(a2iSpikeCount(1:end,:),1) > 0)-1;
    if isempty(aiActiveSpikeChannels) 
        fprintf('No spikes found at all!!??!? Assuming this was a behavioral session ?\n');
    end;
        
    plx_close(strInputFile);
    iNumCh = length(aiActiveSpikeChannels);
    for iChannelIter=1:iNumCh
        if ~isempty(hProgress)
            fnSetWaitbar(hProgress, iChannelIter/iNumCh);
        end
           
           iChannel = aiActiveSpikeChannels(iChannelIter);
           aiActiveUnits = find(a2iSpikeCount(1:end,1+iChannel));
           
           % chop things using plexon frame system....
           if ~exist('strctStrobeWord','var')
            [iNumStrobeEvents, afStrobeTimeStamps, Tmp] = plx_event_ts(strInputFile, 257);
                strctStrobeWord.m_aiWords = Tmp+32768;
           end
    
           afStartRecordingFrames = afStrobeTimeStamps(strctStrobeWord.m_aiWords==32767);
           afEndRecordingFrames = afStrobeTimeStamps(strctStrobeWord.m_aiWords==32766);
           % TODO...
           clear astrctSpikes
%            iUnitCounter = 1;
           for iUnitIter=1:length(aiActiveUnits)
               iUnit = aiActiveUnits(iUnitIter);
%                if iUnit == 1 % Unsorted spikes. Ignore recording frames for those....This is for the spike sorter later on...
                    astrctSpikes(iUnitIter).m_iUnitIndex = iUnit-1;
                    [nwf, npw, astrctSpikes(iUnitIter).m_afTimestamps, astrctSpikes(iUnitIter).m_a2fWaveforms] = plx_waves_v(strInputFile,iChannel, iUnit-1);
                    astrctSpikes(iUnitIter).m_afInterval = [min(astrctSpikes(iUnitIter).m_afTimestamps), max(astrctSpikes(iUnitIter).m_afTimestamps)];

           end
           strSpikeFile = fullfile(strInputFolder, [strSessionName,'-',sprintf('spikes_ch%d.raw', iChannel)]);
           strctChannelInfo.m_strPlxFile = strInputFile;
           strctChannelInfo.m_strChannelName = acChannelNames{aiActiveSpikeChannels(iChannelIter) };
           strctChannelInfo.m_iChannelID = iChannel;
           strctChannelInfo.m_fGain = afLastGainRecorded(iChannel);
           strctChannelInfo.m_fThreshold = afLastThresholdRecorded(iChannel);
           strctChannelInfo.m_bFiltersActive = abFilterActive(iChannel);
           strctChannelInfo.m_bSorted = false;
           fnDumpChannelSpikes(strctChannelInfo,astrctSpikes, strSpikeFile);
    end
end

%% Generate a fake intervals file using plexon's framing method ?

%% Attempt to sync all computers
if strctOptions.m_bSync
        
    if ~isempty(hProgress)
        fnResetWaitbar(hProgress);
        fnSetWaitbar(hProgress, 0.5);
    end
 
        fprintf('Sync...');
        strKofikoFile = fullfile(strInputFolder,filesep,[strSessionName,'.mat']);
        strStatServerFile = fullfile(strInputFolder,filesep,[strSessionName,'-StatServerInfo.mat']);
        strStrobeFile = fullfile(strInputFolder,filesep,[strSessionName,'-strobe.raw']);
        strAnalogFile = fullfile(strInputFolder,filesep,[strSessionName,'-EyeX.raw']);  % any can suffice...
        strSyncFile = fullfile(strInputFolder,filesep,[strSessionName,'-sync.mat']);
        
        if exist(strKofikoFile,'file') && exist(strStatServerFile,'file') && exist(strStrobeFile,'file') &&  exist(strAnalogFile,'file') 
            strctSync = fnAnalysisSyncComputers(strStrobeFile, strAnalogFile,strKofikoFile, strStatServerFile);
            save(strSyncFile,'strctSync');
        else
            fprintf('Stat server file is missing. Assuming this was recorded without statistics server...');
            
            strctSync = fnAnalysisSyncComputers(strStrobeFile, strAnalogFile,strKofikoFile, []);
            save(strSyncFile,'strctSync');
            
        end
        if ~isempty(hProgress)
            fnSetWaitbar(hProgress, 1);
        end
end


fprintf('Done!\n');
%% Test
if 0
    strctStrobe = fnReadDumpStrobeFile(strStrobeWordFile);
    astrctUnits = fnReadDumpSpikeFile(strSpikeFile);
    
    
    fnReadStrobeWords(strStrobeWordFile);
    
    strctReadAnalog = fnReadDumpAnalogFile(strOutFilename,'ReadHeaderOnly');
    fStartTS = strctReadAnalog.m_afStartTS(1) + 1000*1/strctReadAnalog.m_fSamplingFreq;
    fEndTS = strctReadAnalog.m_afStartTS(1) + 4000*1/strctReadAnalog.m_fSamplingFreq;
    strctReadAnalog = fnReadDumpAnalogFile(strOutFilename,'Interval',[fStartTS,fEndTS 3000]);
end
%%

