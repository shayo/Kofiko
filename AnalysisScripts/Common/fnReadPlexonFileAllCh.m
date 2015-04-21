function strctPlexon = fnReadPlexonFileAllCh(strInputFile, strctNameConversion)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_bVERBOSE
[strctPlexon.m_strctInfo.m_strOpenedFileName, ...
 strctPlexon.m_strctInfo.m_fVersion, ...
 strctPlexon.m_strctInfo.m_fFreq, ...
 strctPlexon.m_strctInfo.m_strComment, ...
 strctPlexon.m_strctInfo.m_fTrodalness, ...
 strctPlexon.m_strctInfo.m_fNPW, ...
 strctPlexon.m_strctInfo.m_fPreThresh, ...
 strctPlexon.m_strctInfo.m_fSpikePeakV, ...
 strctPlexon.m_strctInfo.m_fSpikeADResBits,... 
 strctPlexon.m_strctInfo.m_SlowPeakV, ...
 strctPlexon.m_strctInfo.m_fSlowADResBits, ...
 strctPlexon.m_strctInfo.m_fDuration, ...
 strctPlexon.m_strctInfo.m_strDateTime] = plx_information(strInputFile);
plx_close(strInputFile);

strctPlexon.m_strReadOutVersion = 'S1007';

if g_bVERBOSE
    fnWorkerLog('Information for %s:\nRecorded on %s for %d minutes. ',...
        strctPlexon.m_strctInfo.m_strOpenedFileName,strctPlexon.m_strctInfo.m_strDateTime, ...
        round(strctPlexon.m_strctInfo.m_fDuration/60))
    fnWorkerLog('Using version %d at Freq %d ',strctPlexon.m_strctInfo.m_fVersion, strctPlexon.m_strctInfo.m_fFreq);
end;

[iNumDigitalEventFields,a2cDigitalEventFieldNames] = plx_event_names(strInputFile);
plx_close(strInputFile);

[iNumAnalogFields,a2cAnalogFieldNames] = plx_adchan_names(strInputFile);
plx_close(strInputFile);

strctPlexon.m_acDigitalLineNames = fnCharToCell(a2cDigitalEventFieldNames);
strctPlexon.m_acAnalogLineNames = fnCharToCell(a2cAnalogFieldNames);


[iNumStrobeEvents, afStrobeTimeStamps, Tmp] = plx_event_ts(strInputFile, 257);
strctPlexon.m_strctStrobeWord.m_aiWords = Tmp+32768;
strctPlexon.m_strctStrobeWord.m_afTimestamp = afStrobeTimeStamps;

plx_close(strInputFile);


[iNumChannels, aiNumSamples] = plx_adchan_samplecounts(strInputFile);
aiActiveAnalogChannels = find(aiNumSamples> 0);
acActiveChannelNames = strctPlexon.m_acAnalogLineNames(aiActiveAnalogChannels);
plx_close(strInputFile);



if g_bVERBOSE
    fnWorkerLog('Reading analog signals...');
end;
[iNumCh,afGains] = plx_adchan_gains(strInputFile);
plx_close(strInputFile);

for iAnalogChIter=1:length(aiActiveAnalogChannels)
    iChannel = aiActiveAnalogChannels(iAnalogChIter);
    strChannelNameFromPlexon = acActiveChannelNames{iAnalogChIter};
    fGain = afGains(iChannel);
    bLFP_Channel = strncmpi(strChannelNameFromPlexon, strctNameConversion.m_strLFP_Prefix, length(strctNameConversion.m_strLFP_Prefix));
    if bLFP_Channel
        iLFPChannelIndex = str2num(strChannelNameFromPlexon(length(strctNameConversion.m_strLFP_Prefix)+1:end));
        strctPlexon.m_astrctLFP(iLFPChannelIndex) = fnReadAnalog(strInputFile, iChannel-1,fGain);
        
    else
        strVarName = ['m_strct',strChannelNameFromPlexon];
        strVarName(strVarName == ' ') = '_';

        % Find the new name according to the XML file...
        acFieldNames = fieldnames(strctNameConversion);
        for j=1:length(acFieldNames)
            strFieldName = acFieldNames{j};
            strAnalogName = strFieldName(6:end);
            strPlexonName = getfield(strctNameConversion,acFieldNames{j});

            if strcmpi(strPlexonName, strChannelNameFromPlexon)
                strVarName = ['m_strct',strAnalogName];
                strVarName(strVarName == ' ') = '_';
                break;
            end
        end
        strctPlexon = setfield(strctPlexon, strVarName, fnReadAnalog(strInputFile, iChannel-1,fGain));
    end
    
end;
clear mex

%% Read Spike Channels
[a2iSpikeCount, wfcounts, evcounts] = plx_info(strInputFile, 1); % Replace this with the mex file once plexon fix their bug....
aiActiveSpikeChannels = find(sum(a2iSpikeCount(2:end,:),1) > 0)-1;
iUnitCounter = 1;
plx_close(strInputFile);

[iNumCh,afSpikeGains] = plx_chan_gains(strInputFile);
plx_close(strInputFile);

for iChannelIter=1:length(aiActiveSpikeChannels)
    iChannel = aiActiveSpikeChannels(iChannelIter);
    aiActiveUnits = find(a2iSpikeCount(2:end,1+iChannel));
    
    for iUnitIter=1:length(aiActiveUnits)
        iUnit = aiActiveUnits(iUnitIter);
        
        strctPlexon.m_astrctUnits(iUnitCounter) = fnReadSpikes(strInputFile, iChannel,iUnit,afSpikeGains(iChannel));    
        
        iUnitCounter = iUnitCounter + 1;
    end
    
end
%    fprintf('Timestamps for channel 1, unit %d was found\n',iUnitIter);

if ~isempty(aiActiveSpikeChannels)
    plx_close(strInputFile);
else
    strctPlexon.m_astrctUnits = [];
end
return;


function strctSpikes = fnReadSpikes(strInputFile, iChannel, iUnit,fGain)
strctSpikes.m_iChannel = iChannel;
strctSpikes.m_iUnit = iUnit;
[nts, strctSpikes.m_afTimestamps] = plx_ts(strInputFile, iChannel, iUnit);
[nwf, npw, tswf, strctSpikes.m_a2fWaveforms] = plx_waves(strInputFile,iChannel, iUnit);
strctSpikes.m_fGain = fGain;
return;

function strctAnalog=fnReadAnalog(strInputFile, iIndex,fGain)
[strctAnalog.m_fFreq, ...
    strctAnalog.m_iNumSamples, ...
    strctAnalog.m_afTimeStamp0, ...
    strctAnalog.m_aiNumSamplesInFragment, ...
    strctAnalog.m_afData] = ...
    plx_ad(strInputFile, iIndex	); %Plexon counts from zero
% This is a shitty way to compute start and end indices without loops...
plx_close(strInputFile);
Tmp = cumsum([1;strctAnalog.m_aiNumSamplesInFragment]);
strctAnalog.m_aiStart = Tmp(1:end-1);
strctAnalog.m_aiEnd = Tmp(2:end)-1;
strctAnalog.m_iChannel = iIndex+1;
strctAnalog.m_fGain = fGain;
return;

% % % aiAnalogOffset = [0;aiNumSamplesInFragment];
% % % afTimeStampEnd = afTimeStamp0 + aiNumSamplesInFragment/fFreq;
% % % [iNumStrobeEvents, afStrobeTimeStamps, Tmp] = plx_event_ts(OpenedFileName, 257);
% % % strctPlexon.m_strctStrobe.m_
% % % aiStrobeWords = Tmp+32768;
% % % 
% % % iNumFrames = size(afTimeStamp0,1);
% % % fprintf('%d Frames were identified:\n',iNumFrames)
% % % for k=1:iNumFrames
% % %     fNumMin=floor(aiNumSamplesInFragment(k)/fFreq/60);
% % %     fNumSec=mod(aiNumSamplesInFragment(k)/fFreq,60);
% % %     fprintf('Frame %d, starting from t=%.2f, and lasting %.2f min and %.2f sec \n',k, afTimeStamp0(k),fNumMin,fNumSec );
% % % end;
% % % 
% % % fPhotodiodeThreshold = 500;
% % % 
% % % for iFrame=1:iNumFrames
% % %     afAnalogTimeSec = afTimeStamp0(iFrame):1/fFreq:afTimeStamp0(iFrame)+1/fFreq * (aiNumSamplesInFragment(iFrame)-1);
% % %     aiStrobesInThisFrame = find(afStrobeTimeStamps >= afTimeStamp0(iFrame) & afStrobeTimeStamps <= afTimeStampEnd(iFrame));
% % %     
% % %     afStrobeTS_Frame = afStrobeTimeStamps(aiStrobesInThisFrame);
% % %     aiStrobeWords_Frame = aiStrobeWords(aiStrobesInThisFrame);
% % %     
% % %     aiStimulusInd = find(aiStrobeWords_Frame > 0 & aiStrobeWords_Frame < 1000);
% % %     afStimulusONTimeStamp = afStrobeTS_Frame(aiStimulusInd);
% % %     aiStimulusIndex = aiStrobeWords_Frame(aiStimulusInd);
% % %   
% % %     aiOnTime = zeros(1,length(afStimulusONTimeStamp));
% % % 
% % %     for iStimulusIndex = 1:length(afStimulusONTimeStamp)-1
% % %         
% % %         
% % %         iStart = find(afAnalogTimeSec>= afStimulusONTimeStamp(iStimulusIndex),1,'first');
% % %         aiInterval = aiAnalogOffset(iFrame)+[iStart:iStart + 0.25 * fFreq];
% % %         iStartDraw = find(afPhotoDiodeData(aiInterval)>fPhotodiodeThreshold,1,'first'); % finished drawing for the first time 
% % %         iEndDraw = find(afPhotoDiodeData(aiInterval)>fPhotodiodeThreshold,1,'last');   % finished drawing for the last time 
% % %         if ~isempty(iStartDraw)
% % %             aiOnTime(iStimulusIndex) = (iEndDraw-iStartDraw) / fFreq * 1e3;
% % %         end;
% % %     end;
% % %     
% % %     figure(10);
% % %     clf;
% % %     plot(aiOnTime)
% % %     hold on;
% % %     plot(aiStimulusIndex,'r');
% % % 
% % % end;
% % % 
% % % %%
% % % % get some counts
% % % [tscounts, wfcounts, evcounts] = plx_info(OpenedFileName,1);
% % % 
% % % % tscounts, wfcounts are indexed by (channel+1,unit+1)
% % % % tscounts(:,ch+1) is the per-unit counts for channel ch
% % % % sum( tscounts(:,ch+1) ) is the total wfs for channel ch (all units)
% % % % [nunits, nchannels+1] = size( tscounts )
% % % % To get number of nonzero units/channels, use nnz() function
% % % %%
% % % % get some timestamps for channel 1 unit a
% % % [nts1, ts1] = plx_ts(OpenedFileName, 1, 1);
% % % [nts2, ts2] = plx_ts(OpenedFileName, 1, 2);
% % % [nts3, ts3] = plx_ts(OpenedFileName, 1, 3);
% % % [nts4, ts4] = plx_ts(OpenedFileName, 1, 4);
% % % 
% % % [nwf, npw, tswf, waves] = plx_waves(OpenedFileName, 1, 1);
% % % figure;
% % % plot( waves(1,1:npw));
% % % 
% % % % get some other info about the spike channels
% % % [nspkfilters,spk_filters] = plx_chan_filters(OpenedFileName);
% % % [nspkgains,spk_gains] = plx_chan_gains(OpenedFileName);
% % % [nspkthresh,spk_threshs] = plx_chan_thresholds(OpenedFileName);
% % % 
% % % % get just a span of a/d data
% % % [adfreq, nadspan, adspan] = plx_ad_span(OpenedFileName,49, 10,100);
% % % 
% % % [nadfreqs,adfreqs] = plx_adchan_freqs(OpenedFileName);
% % % [nadgains,adgains] = plx_adchan_gains(OpenedFileName);
% % % 

